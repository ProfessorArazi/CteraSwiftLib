//
//  HttpClient+Session.swift
//  
//
//  Created by Gal Yedidovich on 31/01/2021.
//

import Foundation
import BasicExtensions
import StorageExtensions
import CteraUtil
import CteraModels

//MARK: - Login Flow
extension HttpClient {
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
		
		handle(request: req, CredentialsDto.fromFormatted(json:)) { (response: Result<CredentialsDto, Error>) in
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
	
	public static func sendUpdateMobileInfo(deviceID: String, deviceName: String) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/objs/\(credentials.deviceUID)?format=jsonext")
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.updateMobileInfo(deviceID: deviceID, deviceName: deviceName))
		
		handle(request: req, handler: nil)
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
}

extension HttpClient {
	public static func logout() {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/logout").set(method: .POST)
		handle(request: req, handler: nil)
	}
	
	public static func verifySession(completion: @escaping ()->()) {
		Console.log(tag: TAG, msg: "\(#function)")
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/currentTime?format=jsonext")
		
		handle(request: req) { result in
			if case let .failure(error) = result {
				Console.log(tag: TAG, msg: "could not verify session: \n\(error)")
			}
			
			completion()
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
					handler(.failure(parseXml(error: data)))
				case .error(let error):
					handler(.failure(error))
				}
			}
		}.resume()
	}
	
	public static func requestGlobalStatus(handler: @escaping Handler<GlobalStatusDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: JsonObject(from: ["name": "getGlobalSystemStatus"]).xmlString)
		
		handle(request: req, GlobalStatusDto.from(json:), handler: handler)
	}
	
	public static func getTasks(completion: @escaping ([URLSessionDataTask], [URLSessionUploadTask], [URLSessionDownloadTask])->()) {
		backgroundSession.getTasksWithCompletionHandler(completion)
	}
	
	public static func preVerifyDownload(for itemPath: String, handler: @escaping Handler<PreVerifyDownloadDto>) {
		Console.log(tag: TAG, msg: "\(#function)")
		let req = URLRequest(to: serverAddress, "ServicesPortal/api?format=jsonext")
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.preVerifyDownload(at: itemPath))
		
		handle(request: req, PreVerifyDownloadDto.fromFormatted(json:), handler: handler)
	}
}
