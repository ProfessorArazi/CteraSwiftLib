//
//  HttpClient.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import BasicExtensions
import StorageExtensions
import CteraModels
import CteraUtil
import CteraCache

public enum HttpClient {
	//MARK: Private Fields
	private static let SERVICES_PORTAL_API = "ServicesPortal/api?format=jsonext"
	private static let TAG = String(describing: HttpClient.self)
	
	private static var auth = Auth()
	
	private static let session = URLSession(configuration: URLSessionConfiguration.default, delegate: Session(), delegateQueue: nil)
	private static let backgroundSession: URLSession = {
		let bundleID = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
		
		let config = URLSessionConfiguration.background(withIdentifier: "BackgroundSession-" + bundleID)
		config.networkServiceType = .default
		config.sharedContainerIdentifier = Bundle.appGroup
		#if os(iOS)
		config.sessionSendsLaunchEvents = true
		#endif
		
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 5
		return URLSession(configuration: config, delegate: backgroundSessionDelegate, delegateQueue: queue)
	}()
	
	static let backgroundSessionDelegate = BackgroundSession()
	
	public static var downloadDelegate: DownloadDelegate { backgroundSessionDelegate.downloadDelegate }
	public static var uploadDelegate: UploadDelegate { backgroundSessionDelegate.uploadDelegate }
	
	//MARK: Public API
	public private(set) static var hasConnection = true
	
	public static var credentials: CredentialsDto!
	public static var serverAddress: String!
//	public static var isPortalReadOnly = false
	public static var onConnectionChanged: [(Bool)->()] = []
	public static var thumbnailDelegate: ThumbnailDelegate?
	public static var fileCache: FileCache?
	
	public static let SERVICE_WEBDAV = "/ServicesPortal/webdav"
	
	public static func set(hasConnection connection: Bool) {
		guard hasConnection != connection else { return } //prevent multiple events for same status
		
		hasConnection = connection
		Console.log(tag: TAG, msg: "connection changed, hasConnection: \(connection)")
		for observer in onConnectionChanged { observer(connection) }
	}
	
	public static func requestPublicInfo(address: String, handler: @escaping Handler<PublicInfoDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		serverAddress = address
		let req = URLRequest(url: URL(string: "https://\(address)/ServicesPortal/public/publicInfo?format=jsonext")!)
		handle(request: req, PublicInfoDto.fromFormatted(json:), handler: handler)
	}
	
	public static func login(_ user: String? = nil, _ pass: String? = nil, activationCode code: String? = nil, deviceID: String, deviceName: String, handler: @escaping Handler<CredentialsDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "ServicesPortal/public/users\(user != nil ? "/\(user!)" : "")?format=jsonext")
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.attachMobileDevice(server: serverAddress, password: pass, activationCode: code, deviceID: deviceID, deviceName: deviceName))
		
		handle(request: req, CredentialsDto.fromFormatted(json:)) { (response: Response<CredentialsDto>) in
			if case let .success(credentials) = response {
				Prefs.standard.edit()
					.put(key: .credentials, credentials)
					.commit()
				
				//save in memory
				Self.credentials = credentials
			}
			
			handler(response)
		}
	}
	
	public static func logout() {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/logout").set(method: .POST)
		handle(request: req, handler: nil)
	}
	
	public static func sendUpdateMobileInfo(deviceID: String, deviceName: String) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/objs/\(credentials.deviceUID)?format=jsonext")
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.updateMobileInfo(deviceID: deviceID, deviceName: deviceName))
		
		handle(request: req, handler: nil)
	}
	
	public static func fetchFolder(_ request: FetchRequestDto, handler: @escaping Handler<FolderDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let cachePath = request.cachePath ?? request.path
		
		if request.withCache, let cache = FolderCache[cachePath] {
			Console.log(tag: TAG, msg: "loading from cache")
			handler(.success(cache))
		}
		
		requestFolder(request, handler: { result in
			async {
				if case let .success(folder) = result {
					if request.withCache, folder == FolderCache[cachePath] {
						Console.log(tag: TAG, msg: "same list, not refreshing list")
						return
					}
					
					if request.startIndex == 0 {
						FolderCache[cachePath] = folder
					}
				}
				
				post { handler(result) }
			}
		})
	}
	
	public static func searchFolder(_ request: FetchRequestDto, handler: @escaping Handler<FolderDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		requestFolder(request, handler: handler)
	}
	
	public static func createFolder(at path: String, name: String, handler: @escaping Handler<Data>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.createNewFolder(folderPath: path, folderName: name))
		
		handle(request: req, handler: handler)
	}
	
	public static func requestFile(for item: ItemInfoDto, config: @escaping (ProgressTask)->(), handler: @escaping Handler<URL>) {
		Console.log(tag: TAG, msg: "\(#function), \(item.name)")
		
		if let fileCache = fileCache, let cacheItem = fileCache.item(for: item) {
			let task = fileCache.provide(item: cacheItem) { result in
				switch result {
				case .success(let url):
					thumbnailDelegate?.thumbnail(receivedFile: url, for: item)
					post { handler(.success(url)) }
				case .failure(let error):
					post { handler(.error(error)) }
				}
			}
			
			config(task)
			return
		}
		
		guard hasConnection else {
			handler(.error(Errors.offline))
			return
		}
		
		verifySession { //must verify session before creating download task.
			let path = String(item.path.dropFirst())
			let req = URLRequest(to: serverAddress, path)
			
			let task = backgroundSession.downloadTask(with: req)
			task.resume()
			config(ProgressTask(from: task))
			if let size = item.size { task.countOfBytesClientExpectsToReceive = size }
			
			downloadDelegate.onStart(task, item, handler)
		}
	}
	
	public static func requestPreviewSession(for item: ItemInfoDto, handler: @escaping Handler<String>) {
		Console.log(tag: TAG, msg: "\(#function), \(item.name)")
		
		let path = item.path.dropFirst()
		let req = URLRequest(to: serverAddress, path + "?preview=true&showDeleted=true")
		
		func middleware(data: Data) throws -> String {
			let json: [String: String] = try .from(json: data)
			return json["viewingSessionId"]!
		}
		
		func errorParser(data: Data) throws -> PreviewError {
			let json: [String: String] = try .from(json: data)
			guard let str = json["previewFailure"] else { return .unknown }
			return PreviewError(rawValue: str) ?? .unknown
		}
		
		handle(request: req, middleware, errorParser: errorParser, handler: handler)
	}
	
	public static func requestPreview(page: Int, viewingSession: String, handler: @escaping Handler<Data>) {
		let req = URLRequest(to: serverAddress, "ServicesPortal/pcc/Page/q/\(page)?DocumentID=u\(viewingSession)&Scale=1&ContentType=png")
		
		handle(request: req, handler: handler)
	}
	
	public static func requestPreviewPageCount(viewingSession: String, handler: @escaping Handler<Int>) {
		let req = URLRequest(to: serverAddress, "ServicesPortal/pcc/Document/q/Attributes?DocumentID=u\(viewingSession)&DesiredPageCountConfidence=50")
		
		func middleware(data: Data) throws -> Int {
			let json: [String: Int] = try .fromFormatted(json: data)
			return json["pageCount"]!
		}
		
		handle(request: req, middleware, handler: handler)
	}
	
	public static func verifySession(completion: @escaping ()->()) {
		Console.log(tag: TAG, msg: "\(#function)")
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/currentTime?format=jsonext")
		
		handle(request: req) { result in
			if case let .error(error) = result {
				Console.log(tag: TAG, msg: "could not verify session: \n\(error)")
			}
			
			completion()
		}
	}
	
	public static func uploadRequest(_ fileUrl: URL, to itemPath: String,
									 onStart: @escaping (URLSessionUploadTask)->() = { $0.resume() },
									 handler: @escaping Handler<Void>) {
		Console.log(tag: Self.TAG, msg: #function)
		async {
			let boundary = "----MobileBoundaryRRD29pvBCUWyLIg"
			let req = URLRequest(to: serverAddress, "ServicesPortal/upload?")
				.set(method: .POST)
				.set(contentType: ContentType(stringLiteral: "multipart/form-data; boundary=\(boundary)"))
			
			let uploadFileUrl = uploadDelegate.multipartDataFile(fileUrl, boundary: boundary, for: itemPath)
			
			//upload
			let task = backgroundSession.uploadTask(with: req, fromFile: uploadFileUrl)
			uploadDelegate.onStart(task, path: itemPath, filename: uploadFileUrl.lastPathComponent, handler)
			onStart(task)
		}
	}
	
	public static func requestLastModified(for items: [ItemInfoDto], userRef: String, handler: @escaping Handler<[LastModifiedDto]>) {
		Console.log(tag: TAG, msg: "\(#function), items: \(items.map(\.name))")
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/\(userRef)?format=jsonext")
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.lastModified(items: items))
		
		handle(request: req, [LastModifiedDto].fromFormatted(json:), handler: handler)
	}
	
	public static func rename(item: ItemInfoDto, to newName: String, handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: Self.TAG, msg: #function)
		let newPath = item.parentPath + "/" + newName
		let data = SrcDestData(action: "moveResources", pairs: [(src: item.path, dest: newPath)])
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func delete(items: [ItemInfoDto], handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: TAG, msg: #function)
		let paths = items.map { item in (src: item.path, dest: "") }
		let data = SrcDestData(action: "deleteResources", pairs: paths)
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func restore(items: [ItemInfoDto], handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: TAG, msg: #function)
		let paths = items.map { item in (src: item.path, dest: item.parentPath) }
		let data = SrcDestData(action: "restoreResources", pairs: paths)
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func restoreVersionedItem(item: ItemInfoDto, handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: TAG, msg: #function)
		let data = SrcDestData(action: "restoreResources", pairs: [(src: item.path, dest: "")])
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func copyMove(isCopy: Bool, items: [ItemInfoDto], folderPath: String, handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: TAG, msg: #function)
		let paths = items.map { item in (src: item.path, dest: folderPath + "/" + item.name) }
		let data = SrcDestData(action: (isCopy ? "copyResources" : "moveResources"), pairs: paths)
		srcDestRequest(data: data, handler: handler)
	}
	
	/// follows the status of a background task on the portal, until an error, conflict or success achived.
	/// - Parameters:
	///   - taskUrl: unique ID of the task to check
	///   - handler: request completion handler
	public static func followServerTask(at taskUrl: String, handler: BackgroundTaskHandler) {
		Console.log(tag: TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.getStatus(for: taskUrl))
		
		Console.log(tag: TAG, msg: "followServerTask, request status on \(taskUrl)")
		post { handler.onTaskStart() }
		
		func checkStatus() {
			handle(request: req, JsonObject.init(data:)) { (result: Response<JsonObject>) in
				switch result {
				case .success(let task):
					if let errorType = task.string(key: "errorType"), !errorType.isEmpty {
						Console.log(tag: TAG, msg: "followServerTask, error in action: \(errorType)")
						post {
							if errorType.lowercased() == "conflict" {
								handler.onTaskConflict(task: task)
							} else {
								handler.onTaskError(error: Errors.text(errorType))
							}
						}
					} else {
						if task.int(key: "percentage")! < 100 {
							post { handler.onTaskProgress(task: task) }
							//wait 1 second than try again
							post(delay: 1) { checkStatus() }
						} else {
							post { handler.onTaskDone() }
						}
					}
				case .error(let error):
					Console.log(tag: Self.TAG, msg: "\(#function) error, \(error)")
					post { handler.onTaskError(error: error) }
				}
			}
		}
		
		checkStatus() //start checking task status
	}
	
	/// checks status of a background task on the portal once.
	/// - Parameters:
	///   - taskUrl: unique ID of the task to check
	///   - handler: request completion handler
	public static func checkTaskStatus(at taskUrl: String, handler: @escaping Handler<JsonObject>) {
		Console.log(tag: TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.getStatus(for: taskUrl))
		
		handle(request: req, JsonObject.init(data:), handler: handler)
	}
	
	public static func resolveConflict(_ srcDestData: SrcDestData, handler: BackgroundTaskHandler) {
		Console.log(tag: Self.TAG, msg: #function)
		srcDestRequest(data: srcDestData) { result in
			switch result {
			case .success(let (taskUrl, _)):
				followServerTask(at: taskUrl, handler: handler)
			case .error(let error):
				Console.log(tag: Self.TAG, msg: "\(#function) error, \(error)")
				handler.onTaskError(error: error)
			}
		}
	}
	
	public static func renewSession(handler: @escaping Handler<Any?>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/login?format=jsonext")
			.set(method: .POST)
			.set(body: StringFormatter.login(with: credentials))
			.set(contentType: .urlEncoded)
		
		session.dataTask(with: req) { result in
			post {
				switch result {
				case .success:
					let newCookie = HTTPCookieStorage.shared.cookies!.first { $0.name == "JSESSIONID" }!
					auth.renew(with: newCookie)
					handler(.success(nil))
				case .failure(let status, let data):
					Console.log(tag: TAG, msg: "Failure - status: \(status), msg:" + String(decoding: data, as: UTF8.self))
					let errorMsg = ParserDelegate.parse(data: data)?.msg ?? .error
					handler(.error(Errors.text(errorMsg)))
				case .error(let error):
					handler(.error(error))
				}
			}
		}.resume()
	}
	
	public static func requestSessionInfo(handler: @escaping Handler<SessionInfoDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.getMulticommand())
		
		handle(request: req, SessionInfoDto.fromFormatted(json:), handler: handler)
	}
	
	public static func requestUserSettings(userRef: String, handler: @escaping Handler<UserSettingsDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/\(userRef)?format=jsonext")
		
		handle(request: req, UserSettingsDto.fromFormatted(json:), handler: handler)
	}
	
	public static func requestAvatar(avatarName: String, handler: @escaping Handler<Data?>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "/ServicesPortal/avatar/getUserAtar/\(avatarName)?format=jsonext")
		
		handle(request: req, { $0 }, handler: handler)
	}
	
	public static func requestGlobalStatus(handler: @escaping Handler<JsonObject>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: JsonObject(from: ["name": "getGlobalSystemStatus"]).xmlString)
		
		handle(request: req, JsonObject.init(data:), handler: handler)
	}
	
	public static func requestNavigationItems(completion: @escaping Handler<FolderDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let fetchReq = FetchRequestDto(path: "/ServicesPortal/webdav").with(navigationPane: true)
		
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: fetchReq.toJson().xmlString)
		
		handle(request: req, FolderDto.fromFormatted(json: ), handler: completion)
	}
	
	public static func requestPublicLinks(for item: ItemInfoDto, handler: @escaping Handler<[PublicLinkDto]>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.getPublicLinks(at: item.path))
		
		handle(request: req, { try [PublicLinkDto].fromFormatted(json: $0, dateStrategy: .expirationStrategy) }, handler: handler)
	}
	
	public static func createPublicLink(with link: PublicLinkDto, handler: @escaping Handler<PublicLinkDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.createPublicLink(from: link))
		
		handle(request: req, { try PublicLinkDto.fromFormatted(json: $0, dateStrategy: .expirationStrategy) }, handler: handler)
	}
	
	public static func modifyPublicLink(with link: PublicLinkDto, remove: Bool, handler: @escaping Handler<Data>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.modifyPublicLink(from: link, remove: remove))
		
		handle(request: req, handler: handler)
	}
	
	public static func requestCollaboration(for item: ItemInfoDto, handler: @escaping Handler<CollaborationDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.listShares(for: item.path))
		
		handle(request: req, { try CollaborationDto.fromFormatted(json: $0, dateStrategy: .expirationStrategy) }, handler: handler)
	}
	
	public static func saveCollaboration(at path: String, _ collaboration: CollaborationDto, handler: @escaping Handler<Data>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.saveCollaboration(at: path, collaboration))
		
		handle(request: req, handler: handler)
	}
	
	public static func validateCollaborator(for item: ItemInfoDto, invitee: CollaboratorDto, handler: @escaping Handler<CollaborationPolicyDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.verifyCollaborator(for: item, invitee))
		
		handle(request: req, CollaborationPolicyDto.fromFormatted(json:), handler: handler)
	}
	
	public static func searchCollaborators(query: String, type: String, uid: Int, count: Int = 25, handler: @escaping Handler<CollaborationSearchResultDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.searchCollaborators(query, type, uid, count))
		
		handle(request: req, CollaborationSearchResultDto.fromFormatted(json:), handler: handler)
	}
	
	public static func leaveShared(items: [ItemInfoDto], handler: @escaping Handler<Data>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.leaveShared(items: items))
		
		handle(request: req, handler: handler)
	}
	
	public static func requestVersions(of item: ItemInfoDto, handler: @escaping Handler<[VersionDto]>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.fileVersions(for: item))
		
		handle(request: req, [VersionDto].fromFormatted(json:), handler: handler)
	}
	
	public static func getTasks(completion: @escaping ([URLSessionDataTask], [URLSessionUploadTask], [URLSessionDownloadTask])->()) {
		backgroundSession.getTasksWithCompletionHandler(completion)
	}
	
	// MARK: - Private methods
	private static func requestFolder(_ request: FetchRequestDto, handler: @escaping Handler<FolderDto>) {
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: request.toJson().xmlString)
		
		handle(request: req, FolderDto.fromFormatted(json:), handler: handler)
	}
	
	private static func srcDestRequest(data payload: SrcDestData, handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.sourceDestCommand(with: payload))
		
		let middleware = { (data: Data) -> (String, SrcDestData) in
			let taskUrl = String(decoding: data, as: UTF8.self)
				.replacingOccurrences(of: "\\", with: "")
				.replacingOccurrences(of: "\"", with: "")
			
			return (taskUrl, payload)
		}
		
		handle(request: req, middleware, handler: handler)
	}
	
	// MARK: handling requests
	private static func handle<T>(request: URLRequest,
								  _ middleware: @escaping (Data) throws -> T,
								  errorParser: @escaping (Data) throws -> Error = parseXml(error:),
								  handler: Handler<T>?) {
		if !hasConnection {
			post { handler?(.error(Errors.offline)) }
			return
		}
		
		send(request: request) { result in
			guard let handler = handler else { return }
			
			switch result {
			case .success(let data):
				do {
					let result2 = try middleware(data)
					post { handler(.success(result2)) }
				} catch {
					post { handler(.error(error)) }
				}
			case .failure(let status, let data):
				Console.log(tag: TAG, msg: "Failure - status: \(status), msg:" + String(decoding: data, as: UTF8.self))
				do {
					let error = try errorParser(data)
					post { handler(.error(error)) }
				} catch {
					post { handler(.error(error)) }
				}
			case .error(let error): post { handler(.error(error)) }
			}
		}
	}
	
	private static func handle(request: URLRequest, handler: Handler<Data>?) {
		handle(request: request, { $0 }, handler: handler)
	}
	
	///Reads XML for error message
	/// - Parameter data: Response data from portal, should contain the error message
	/// - Returns: the error from the portal on a generic "error" as fallback
	private static func parseXml(error data: Data) -> Errors {
		let msg = ParserDelegate.parse(data: data)?.msg ?? .error
		
		return .text(msg)
	}
	
	private static func send(request: URLRequest,  handler: @escaping (Result<Data, Data>) -> ()) {
		let requestTime = Date()
		session.dataTask(with: request) { result in
			if case let .failure(status, _) = result, status == 302 && credentials != nil {
				Console.log(tag: Self.TAG, msg: "received 302, sent at: \(requestTime.timeIntervalSince1970)")
				handle302(at: requestTime, with: request, and: handler)
			} else { handler(result) }
		}.resume()
	}
	
	private static func handle302(at time: Date, with request: URLRequest, and handler: @escaping (Result<Data, Data>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		async {
			auth.semaphore.wait()
			if let cookie = auth.cookie, auth.timestamp > time { //session already renewed. retry original request
				Console.log(tag: Self.TAG, msg: "session already renewed")
				HTTPCookieStorage.shared.setCookie(cookie)  //override response cookie with verified cookie
				
				send(request: request, handler: handler)
				auth.semaphore.signal()
				return
			}
			
			renewSession { response in
				if case .error(let error) = response {
					handler(.error(error))
				} else {
					send(request: request, handler: handler)
				}
				auth.semaphore.signal()
			}
		}
	}
}
