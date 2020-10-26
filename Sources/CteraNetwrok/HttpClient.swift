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
	private static let SERVICES_PORTAL_API = "ServicesPortal/api?format=jsonext"
	private static let TAG = String(describing: HttpClient.self)
	
	static var hasConnection = true
	static var credentials: CredentialsDto!
	public static var serverAddress: String!
//	public static var isPortalReadOnly = false
	public static var onConnectionChanged: [(Bool)->()] = []
	public static var thumbnailDelegate: ThumbnailDelegate?
	
	private static let session = URLSession(configuration: URLSessionConfiguration.default, delegate: Session(), delegateQueue: nil)
	private static let backgroundSession: URLSession = {
		let bundleID = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
		
		let config = URLSessionConfiguration.background(withIdentifier: "BackgroundSession-" + bundleID)
		config.sharedContainerIdentifier = Bundle.appGroup
		#if os(iOS)
		config.sessionSendsLaunchEvents = true
		#endif
		
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 5
		return URLSession(configuration: config, delegate: BackgroundSession(), delegateQueue: queue)
	}()
	
	//MARK: Public API
	public static let SERVICE_WEBDAV = "/ServicesPortal/webdav"
	
	public static func set(hasConnection connection: Bool) {
		guard hasConnection != connection else { return } //prevent multiple events for same status
		
		hasConnection = connection
		Console.log(tag: TAG, msg: "connection changed, hasConnection: \(connection)")
		for observer in onConnectionChanged { observer(connection) }
	}
	
	public static func requestPublicInfo(address: String, handler: @escaping (Response<PublicInfoDto>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		serverAddress = address
		let req = URLRequest(url: URL(string: "https://\(address)/ServicesPortal/public/publicInfo?format=jsonext")!)
		handle(request: req, PublicInfoDto.from(json:), handler: handler)
	}
	
	public static func login(_ user: String? = nil, _ pass: String? = nil, activationCode code: String? = nil, deviceID: String, deviceName: String, handler: @escaping (Response<CredentialsDto>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "ServicesPortal/public/users\(user != nil ? "/\(user!)" : "")?format=jsonext")
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.attachMobileDevice(server: serverAddress, password: pass, activationCode: code, deviceID: deviceID, deviceName: deviceName))
		
		handle(request: req, CredentialsDto.from(json:)) { (response: Response<CredentialsDto>) in
			if case let .success(credentials) = response {
				Prefs.standard.edit()
					.put(key: .deviceId, credentials.deviceUID)
					.put(key: .sharedSecret, credentials.sharedSecret)
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
	
//	static func fullLogin(handler: @escaping (Response<Data?>) -> ()) {
//		Console.log(tag: Self.TAG, msg: #function)
//		sendCredentials { response in
//			switch response {
//			case .success:
//				updateSession(handler: handler)
//			case .error(let error):
//				handler(.error(error))
//			}
//		}
//	}
	
	public static func sendUpdateMobileInfo(deviceID: String, deviceName: String) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/objs/\(credentials.deviceUID)?format=jsonext")
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.updateMobileInfo(deviceID: deviceID, deviceName: deviceName))
		
		handle(request: req, handler: nil)
	}
	
	public static func fetchFolder(_ request: FetchRequest, handler: @escaping (Response<FolderDto>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let cachePath = request.cachePath ?? request.path
		
		if request.withCache, let cache = FolderCache.load(folder: cachePath) {
			Console.log(tag: TAG, msg: "loading from cache")
			handler(.success(cache))
		}
		
		requestFolder(request, handler: { result in
			async {
				if case let .success(folder) = result {
					if request.withCache && FolderCache.has(cachePath) && folder == FolderCache.load(folder: cachePath) {
						Console.log(tag: TAG, msg: "same list, not refreshing list")
						return
					}
					
					if request.startIndex == 0 {
						FolderCache.save(cachePath, folder)
					}
				}
				
				post { handler(result) }
			}
		})
	}
	
	public static func searchFolder(_ request: FetchRequest, handler: @escaping (Response<FolderDto>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		requestFolder(request, handler: handler)
	}
	
	public static func createFolder(at path: String, name: String, handler: @escaping (Response<Data>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.createNewFolder(folderPath: path, folderName: name))
		
		handle(request: req, handler: handler)
	}
	
	public static func requestFile(for item: ItemInfoDto, autoDeleteTempFile: Bool = false, config: @escaping (ProgressTask)->(), handler: @escaping (Response<URL>) -> ()) {
		Console.log(tag: TAG, msg: "\(#function), \(item.name)")
		let fm = FileManager.default
		
		if var cacheItem = FileCache[item.path],
		   fm.fileExists(atPath: cacheItem.localUrl.path)
			&& cacheItem.isUpToDate(comparedTo: item) {
			let tempFile = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(item.ext ?? "")
			if fm.fileExists(atPath: tempFile.path) {
				try! fm.removeItem(at: tempFile)
			}
			
			let task = ProgressTask()
			if let size = item.size { task.progress.totalUnitCount = size }
			config(task)
			
			async {
				Encryptor.decrypt(file: cacheItem.localUrl, to: tempFile, task: task)
				//TODO: handle thumbnail
				thumbnailDelegate?.thumbnailDelegate(receivedFile: tempFile, for: item)
//				if ThumbnailCache.thumbnail(at: item.path) == nil {
//					ThumbnailCache.saveThumbnail(for: item, from: tempFile)
//				}
				post { handler(.success(tempFile)) }
			}
			
			return
		}
		
		guard hasConnection else {
			handler(.error(Errors.offline))
			return
		}
		
		verifySession { //must verify session before creating download task.
			var path = item.path
			path.remove(at: item.path.startIndex)
			let req = URLRequest(to: serverAddress, path)
			
			let task = backgroundSession.downloadTask(with: req)
			
			if let size = item.size { task.countOfBytesClientExpectsToReceive = size } //for background downloads
			let handler = { (u: URL?, r: URLResponse?, e: Error?) in
				guard let status = (r as? HTTPURLResponse)?.statusCode else { return }
				guard status != 404 else {
					if let tempFile = u { try? fm.removeItem(at: tempFile) }
					post { handler(.error(Errors.text(.fileNotFoundErrorMsg))) }
					return
				}
				
				Console.log(tag: TAG, msg: "download done, success: " + (e == nil && status == 200  ? "Yes" : "No"))
				var tempFile: URL? = nil
				if let url = u {
					tempFile = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(item.ext ?? "")
					if fm.fileExists(atPath: tempFile!.path) {
						try! fm.removeItem(at: tempFile!)
					}
					try! fm.moveItem(at: url, to: tempFile!)
					post { handler(.success(tempFile!)) }
				} else {
					post { handler(.error(e ?? Errors.text(.error))) }
				}
				
				if let clearFileUrl = tempFile {
					FileCache.save(file: clearFileUrl, with: item)
					
					thumbnailDelegate?.thumbnailDelegate(removedItem: item, from: clearFileUrl) {
						if autoDeleteTempFile {
							try? fm.removeItem(at: clearFileUrl)
						}
					}
				}
			}
			
			(backgroundSession.delegate as! BackgroundSession).downloadHandlers[task] = handler
			task.resume()
			
			config(ProgressTask(from: task))
		}
	}
	
	public static func requestPreviewSession(for item: ItemInfoDto, handler: @escaping (Response<String>) -> ()) {
		Console.log(tag: TAG, msg: "\(#function), \(item.name)")
		
		let path = item.path.dropFirst()
		let req = URLRequest(to: serverAddress, path + "?preview=true&showDeleted=true")
		
		let middleware = { (d: Data) -> String in
			let json: [String: String] = try .from(json: d)
			return json["viewingSessionId"]!
		}
		handle(request: req, middleware, handler: handler)
	}
	
	public static func requestPreview(page: Int, viewingSession: String, handler: @escaping (Response<Data>) -> ()) {
		let req = URLRequest(to: serverAddress, "ServicesPortal/pcc/Page/q/\(page)?DocumentID=u\(viewingSession)&Scale=1&ContentType=png")
		
		handle(request: req, handler: handler)
	}
	
	public static func requestPreviewPageCount(viewingSession: String, handler: @escaping (Response<Int>) -> ()) {
		let req = URLRequest(to: serverAddress, "ServicesPortal/pcc/Document/q/Attributes?DocumentID=u\(viewingSession)&DesiredPageCountConfidence=50")
		
		let middleware = { (d: Data) -> Int in
			let json: [String: Int] = try .from(json: d)
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
									 handler: @escaping ()->()) {
		Console.log(tag: Self.TAG, msg: #function)
		async {
			let boundary = "----MobileBoundaryRRD29pvBCUWyLIg"
			let req = URLRequest(to: serverAddress, "ServicesPortal/upload?")
				.set(method: .POST)
				.set(contentType: ContentType(stringLiteral: "multipart/form-data; boundary=\(boundary)"))
			
			let uploadFileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
			
			let bodyStart = Data(StringFormatter.multipartData(filePath: itemPath).utf8)
			let bodyEnd = Data("\r\n--\(boundary)--\r\n".utf8)
			try! bodyStart.write(to: uploadFileUrl)
			
			//Prepare file with boundaries
			let readHandle = try! FileHandle(forReadingFrom: fileUrl)
			let writeHandle = try! FileHandle(forWritingTo: uploadFileUrl)
			writeHandle.seekToEndOfFile() //append to bodyStart
			
			let SIZE = 32 * 1000
			var offset: UInt64 = 0
			var chunck: Data = readHandle.readData(ofLength: SIZE)
			
			while chunck.count > 0 {
				autoreleasepool {
					writeHandle.write(chunck)
					offset += UInt64(chunck.count)
					
					readHandle.seek(toFileOffset: offset)
					chunck = readHandle.readData(ofLength: SIZE)
				}
			}
			writeHandle.write(bodyEnd)
			
			readHandle.closeFile()
			writeHandle.closeFile()
			
			//upload
			let task = backgroundSession.uploadTask(with: req, fromFile: uploadFileUrl)
			let del = (backgroundSession.delegate as! BackgroundSession)
			
			del.uploadHandlers[task] = { (d, r, e) in
				try! FileManager.default.removeItem(at: uploadFileUrl)
				
				if e == nil {
					let str = String(decoding: d!, as: UTF8.self)
					Console.log(tag: TAG, msg: str)
					post { handler() }
				} else {
					Console.log(tag: TAG, msg: "error: \(e!.localizedDescription)")
				}
			}
			
			let _ = task.progress.observe(\.fractionCompleted) { progress, _ in
				Console.log(tag: TAG, msg: "\(round(progress.fractionCompleted * 100))")
			}
			onStart(task)
		}
	}
	
	public static func requestLastModified(for items: [ItemInfoDto], userRef: String,
										   handler: @escaping (Response<[JsonObject]>)->()) {
		Console.log(tag: TAG, msg: "\(#function), items: \(items.map { $0.name })")
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/\(userRef)?format=jsonext")
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.lastModified(items: items))
		
		handle(request: req, { data in
			let arr = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
			return arr.map { dict in JsonObject(from: dict) }
		}, handler: handler)
	}
	
	public static func rename(item: ItemInfoDto, to newName: String, handler: @escaping (Response<(String, SrcDestData)>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let newPath = item.parentPath + "/" + newName
		let data = SrcDestData(action: "moveResources", pairs: [(src: item.path, dest: newPath)])
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func delete(items: [ItemInfoDto], handler: @escaping (Response<(String, SrcDestData)>) -> ()) {
		Console.log(tag: TAG, msg: #function)
		let paths = items.map { item in (src: item.path, dest: "") }
		let data = SrcDestData(action: "deleteResources", pairs: paths)
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func restore(items: [ItemInfoDto], handler: @escaping (Response<(String, SrcDestData)>) -> ()) {
		Console.log(tag: TAG, msg: #function)
		let paths = items.map { item in (src: item.path, dest: item.parentPath) }
		let data = SrcDestData(action: "restoreResources", pairs: paths)
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func restoreVersionedItem(item: ItemInfoDto, handler: @escaping (Response<(String, SrcDestData)>) -> ()) {
		Console.log(tag: TAG, msg: #function)
		let data = SrcDestData(action: "restoreResources", pairs: [(src: item.path, dest: "")])
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func copyMove(isCopy: Bool, items: [ItemInfoDto], folderPath: String, handler: @escaping (Response<(String, SrcDestData)>) -> ()) {
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
			handle(request: req, JsonObject.init(data:)) { result in
				switch result {
				case .success(let json):
					if let errorType = json.string(key: "errorType"), !errorType.isEmpty {
						Console.log(tag: TAG, msg: "followServerTask, error in action: \(errorType)")
						post {
							if errorType.lowercased() == "conflict" {
								handler.onTaskConflict(json: json)
							} else {
								handler.onTaskError()
							}
						}
					} else {
						let percentage = json.int(key: "percentage")!
						if percentage < 100 {
							post { handler.onTaskProgress(percentage) }
							//wait 1 second than try again
							post(delay: 1) { checkStatus() }
						} else {
							post { handler.onTaskDone() }
						}
					}
				case .error(let error):
					Console.log(tag: Self.TAG, msg: "\(#function) error, \(error)")
					post { handler.onTaskError() }
				}
			}
		}
		
		checkStatus() //start checking task status
	}
	
	/// checks status of a background task on the portal once.
	/// - Parameters:
	///   - taskUrl: unique ID of the task to check
	///   - handler: request completion handler
	public static func checkTaskStatus(at taskUrl: String, handler: @escaping (Response<JsonObject>) -> ()) {
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
			case .error(let error): Console.log(tag: Self.TAG, msg: "\(#function) error, \(error)")
			}
		}
	}
	
//	public static func updateSession(handler: @escaping (Response<Data?>) -> ()) {
//		Console.log(tag: TAG, msg: #function)
//
//		sendSessionInfo { sessionInfoRes in //session
//			switch sessionInfoRes {
//			case .success(let sessionInfoDto):
//				Prefs.standard.edit().put(key: .sessionInfo, sessionInfoDto).commit()
//
//				sendUserSettings(userRef: sessionInfoDto.currentSession.userRef) { userSettingsRes in //settings
//					switch userSettingsRes {
//					case .success(let userSettings):
////						UserSettingsDto.instance = userSettings
//						Prefs.standard.edit().put(key: .userSettings, userSettings).commit()
//
//						if let avaterName = userSettings.userAvatarName { //avatar
//							requestAvatar(avatarName: avaterName, handler: handler)
//						} else {
//							handler(.success(nil))
//						}
//
//					case .error(let error): handler(.error(error))
//					}
//				}
//			case .error(let error): handler(.error(error))
//			}
//		}
//	}
	
	public static func sendCredentials(handler: @escaping (Response<Any?>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/login?format=jsonext")
			.set(method: .POST)
			.set(body: StringFormatter.login(with: credentials))
			.set(contentType: .urlEncoded)
		
		session.dataTask(with: req) { (d, r, e) in
			if let error = e { post { handler(.error(error)) } }
			handler(.success(nil))
			
		}.resume()
	}
	
	public static func requestSessionInfo(handler: @escaping (Response<SessionInfoDto>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.getMulticommand())
		
		handle(request: req, SessionInfoDto.from(json:), handler: handler)
	}
	
	public static func requestUserSettings(userRef: String, handler: @escaping (Response<UserSettingsDto>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/\(userRef)?format=jsonext")
		
		handle(request: req, UserSettingsDto.from(json:), handler: handler)
	}
	
	public static func requestAvatar(avatarName: String, handler: @escaping (Response<Data?>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "/ServicesPortal/avatar/getUserAtar/\(avatarName)?format=jsonext")
		
		handle(request: req, { $0 }, handler: handler)
	}
	
	public static func requestGlobalStatus(handler: @escaping (Response<JsonObject>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.buildXml(from: JsonObject(from: ["name": "getGlobalSystemStatus"])))
		
		handle(request: req, JsonObject.init(data:), handler: handler)
	}
	
	public static func requestNavigationItems(completion: @escaping (Response<FolderDto>)->()) {
		Console.log(tag: Self.TAG, msg: #function)
		let fetchReq = FetchRequest(path: "/ServicesPortal/webdav").with(navigationPane: true)
		
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.buildXml(from: fetchReq.toJson()))
		
		handle(request: req, { try FolderDto.from(json: $0) }, handler: completion)
	}
	
	public static func requestPublicLinks(for item: ItemInfoDto, handler: @escaping (Response<[PublicLinkDto]>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.getPublicLinks(at: item.path))
		
		handle(request: req, { try [PublicLinkDto].from(json: $0) }, handler: handler)
	}
	
	public static func createPublicLink(with link: PublicLinkDto, handler: @escaping (Response<PublicLinkDto>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.createPublicLink(from: link))
		
		handle(request: req, { try PublicLinkDto.from(json: $0) }, handler: handler)
	}
	
	public static func modifyPublicLink(with link: PublicLinkDto, remove: Bool, handler: @escaping (Response<Data>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.modifyPublicLink(from: link, remove: remove))
		
		handle(request: req, handler: handler)
	}
	
	public static func requestCollaboration(for item: ItemInfoDto, handler: @escaping (Response<CollaborationDTO>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.listShares(for: item.path))
		
		handle(request: req, CollaborationDTO.from(json:), handler: handler)
	}
	
	public static func saveCollaboration(at path: String, _ collaboration: CollaborationDTO, handler: @escaping (Response<Data>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.saveCollaboration(at: path, collaboration))
		
		handle(request: req, handler: handler)
	}
	
	public static func validateCollaborator(for item: ItemInfoDto, invitee: InviteeDto, handler: @escaping (Response<CollaborationPolicyDto>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.verifyCollaborator(for: item, invitee))
		
		handle(request: req, CollaborationPolicyDto.from(json:), handler: handler)
	}
	
	public static func searchCollaborators(query: String, type: String, uid: Int, count: Int = 25, handler: @escaping (Response<CollaborationSearchResultDto>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.searchCollaborators(query, type, uid, count))
		
		handle(request: req, CollaborationSearchResultDto.from(json:), handler: handler)
	}
	
	public static func leaveShared(items: [ItemInfoDto], handler: @escaping (Response<Data>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.leaveShared(items: items))
		
		handle(request: req, handler: handler)
	}
	
	public static func requestVersions(of item: ItemInfoDto, handler: @escaping (Response<[VersionDto]>) -> ()) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.fileVersions(for: item))
		
		handle(request: req, { try [VersionDto].from(json: $0) }, handler: handler)
	}
	
	// MARK: - Private methods
	private static func requestFolder(_ request: FetchRequest, handler: @escaping (Response<FolderDto>) -> ()) {
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.buildXml(from: request.toJson()))
		
		handle(request: req, FolderDto.from(json:), handler: handler)
	}
	
	private static func srcDestRequest(data payload: SrcDestData, handler: @escaping (Response<(String, SrcDestData)>) ->()) {
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
	private static func handle<T>(request: URLRequest, _ middleware: @escaping (Data) throws -> T, handler: ((Response<T>) -> ())?) {
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
				//read XML for error message and pass it to handler
				Console.log(tag: TAG, msg: "Failure - status: \(status), msg:" + String(decoding: data, as: UTF8.self))
				let errorMsg = ParserDelegate.parse(data: data)
				post { handler(.error(Errors.text(errorMsg))) }
			case .error(let error): post { handler(.error(error)) }
			}
		}
	}
	
	private static func handle(request: URLRequest, handler: ((Response<Data>) -> ())?) {
		handle(request: request, { $0 }, handler: handler)
	}
	
	private static func send(request: URLRequest,  handler: @escaping (Result<Data, Data>) -> ()) {
		session.dataTask(with: request) { result in
			if case let .failure(status, _) = result, status == 302 && credentials != nil {
				sendCredentials { response in
					if case .error(let error) = response {
						handler(.error(error))
					} else {
						send(request: request, handler: handler)
					}
				}
			} else { handler(result) }
		}.resume()
	}
}
