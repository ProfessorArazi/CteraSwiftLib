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
	internal static let SERVICES_PORTAL_API = "ServicesPortal/api?format=jsonext"
	internal static let TAG = String(describing: HttpClient.self)
		
	internal static var auth = Auth()
	internal static let session = URLSession(configuration: URLSessionConfiguration.default, delegate: Session(), delegateQueue: nil)
	internal static let backgroundSession: URLSession = {
		let bundleID = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
		
		let config = URLSessionConfiguration.background(withIdentifier: "BackgroundSession-" + bundleID)
		config.networkServiceType = .default
		config.sharedContainerIdentifier = getAppGroup()
		#if os(iOS)
		config.sessionSendsLaunchEvents = true
		#endif
		
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 5
		return URLSession(configuration: config, delegate: backgroundSessionDelegate, delegateQueue: queue)
	}()
	
	internal static let backgroundSessionDelegate = BackgroundSession()
	
	//MARK: Public Properties
	public static let SERVICE_WEBDAV = "/ServicesPortal/webdav"
	public private(set) static var hasConnection = true
	
	public static var credentials: CredentialsDto!
	public static var serverAddress: String!
	public static var onConnectionChanged: [(Bool)->()] = []
	public static var thumbnailDelegate: ThumbnailDelegate?
	public static var fileCache: FileCache?
	
	public static var downloadDelegate: DownloadDelegate { backgroundSessionDelegate.downloadDelegate }
	public static var uploadDelegate: UploadDelegate { backgroundSessionDelegate.uploadDelegate }
	
	public static func set(hasConnection connection: Bool) {
		guard hasConnection != connection else { return } //prevent multiple events for same status
		
		hasConnection = connection

		if !hasConnection {
			let url = URL(string: "https://www.google.com")!
			let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
				return
			}
			task.resume()
		}

		Console.log(tag: TAG, msg: "connection changed, hasConnection: \(connection)")
		for observer in onConnectionChanged { observer(connection) }
	}
	
	/// get the appGroup from info.plist or use hard coded value for testing
	/// - Returns: the appGroup string
	private static func getAppGroup() -> String {
		#if DEBUG
		if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
			return "group.com.ctera"
		}
		#endif
		return Bundle.appGroup
	}
}

extension HttpClient {
	// MARK: - handling requests
	internal static func handle<T>(request: URLRequest,
								  _ middleware: @escaping (Data) throws -> T,
								  errorParser: @escaping (Data) throws -> Error = parseXml(error:),
								  handler: Handler<T>?) {
		func onError(_ error: Error) { post { handler?(.failure(error)) } }
		
		if !hasConnection {
			onError(Errors.offline)
			return
		}
		
		send(request: request) { response in
			guard let handler = handler else { return }
			
			switch response {
			case .success(let (response, data)):
				guard response.statusCode / 100 == 2 else {
					Console.log(tag: TAG, msg: "Failure - status: \(response.statusCode), msg:" + String(decoding: data, as: UTF8.self))
					do {
						onError(try errorParser(data))
					} catch {
						onError(error)
					}
					return
				}
				
				do {
					let result = try middleware(data)
					post { handler(.success(result)) }
				} catch {
					onError(error)
				}
			case .failure(let error): onError(error)
			}
		}
	}
	
	internal static func handle(request: URLRequest, handler: Handler<Data>?) {
		handle(request: request, { $0 }, handler: handler)
	}
	
	///Reads XML for error message
	/// - Parameter data: Response data from portal, should contain the error message
	/// - Returns: the error from the portal on a generic "error" as fallback
	internal static func parseXml(error data: Data) -> Errors {
		let msg = ParserDelegate.parse(data: data)?.msg ?? .error
		
		return .text(msg)
	}
	
	private static func send(request: URLRequest,  handler: @escaping (Result<(HTTPURLResponse, Data), Error>)->()) {
		let requestTime = Date()
		session.dataTask(with: request) { d, r, e in
			if let error = e {
				handler(.failure(error))
				return
			}
			
			guard let response = r as? HTTPURLResponse, let data = d else {
				handler(.failure(URLError(.badServerResponse)))
				return
			}
			
			if response.statusCode == 302 && credentials != nil {
				Console.log(tag: Self.TAG, msg: "received 302, sent at: \(requestTime.timeIntervalSince1970)")
				handle302(at: requestTime, with: request, and: handler)
			} else {
				handler(.success((response, data)))
			}
		}.resume()
	}
	
	private static func handle302(at time: Date, with request: URLRequest, and handler: @escaping (Result<(HTTPURLResponse, Data), Error>)->()) {
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
				if case .failure(let error) = response {
					Console.log(tag: Self.TAG, msg: "\(#function), Could not renew session - user should fully relogin")
					handler(.failure(error))
				} else {
					send(request: request, handler: handler)
				}
				auth.semaphore.signal()
			}
		}
	}
}
