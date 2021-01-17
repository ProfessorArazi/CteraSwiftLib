//
//  Session.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import BasicExtensions
import StorageExtensions

public enum TrustManager {
	private static var trustedKeyBase64: String? = Prefs.standard.string(key: .trustedCertificate)
	fileprivate static var lastCheckedKey: SecKey?
	
	public static func trustLastCheck() {
		guard let b64Key = lastCheckedKey?.base64 else { fatalError("missing key") }
		
		trustedKeyBase64 = b64Key
		Prefs.standard.edit()
			.put(key: .trustedCertificate, b64Key)
			.commit()
	}
	
	static func check(_ key: SecKey) -> Bool {
		trustedKeyBase64 != nil && trustedKeyBase64 == key.base64
	}
}

public class Session: NSObject, URLSessionTaskDelegate {
	public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		guard let serverTrust = challenge.protectionSpace.serverTrust,
			  let publicKey = publicKey(from: serverTrust) else {
			completionHandler(.performDefaultHandling, nil)
			return
		}
		
		if TrustManager.check(publicKey) { //if trusted
			completionHandler(.useCredential, URLCredential(trust: serverTrust))
		} else {
			TrustManager.lastCheckedKey = publicKey //remember, for later trusting
			completionHandler(.performDefaultHandling, nil)
		}
	}
	
	private func publicKey(from serverTrust: SecTrust) -> SecKey? {
		if #available(iOS 14.0, macOS 11.0, *) {
			return SecTrustCopyKey(serverTrust)	
		} else {
			return SecTrustCopyPublicKey(serverTrust)
		}
	}
	
	public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
		completionHandler(nil)
	}
}

public class BackgroundSession: Session, URLSessionDownloadDelegate, URLSessionDataDelegate {
	/**
	completion handler for finishing background work.
	when a background task is completed the session awakes the app and we get a "done" completion handler to tell the system when we are done.
	
	we call this handler when all the current downloads are done, to close the app.
	*/
	public static var backgroundCompletionHandler: (()->())?
	
	private var uploadResponseData: [URLSessionTask: Data] = [:]
	
	let downloadDelegate = DownloadDelegate()
	let uploadDelegate = UploadDelegate()
	
	//finished download
	public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		downloadDelegate.onComplete(location, task: downloadTask)
	}
	
	//receive upload response data
	public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		uploadResponseData[dataTask] = data
	}
	
	//upload did complete
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		guard let task = task as? URLSessionUploadTask else { return }
		let data = uploadResponseData.removeValue(forKey: task)
		uploadDelegate.onComplete(task, with: data)
	}
	
	func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
		post {
			Self.backgroundCompletionHandler?()
		}
	}
}
