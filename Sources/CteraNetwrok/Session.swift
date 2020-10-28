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

class Session: NSObject, URLSessionTaskDelegate {
	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		guard let serverTrust = challenge.protectionSpace.serverTrust,
			  let publicKey = SecTrustCopyPublicKey(serverTrust) else {
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
	
	func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
		completionHandler(nil)
	}
}

class BackgroundSession: Session, URLSessionDownloadDelegate, URLSessionDataDelegate {
	/**
	completion handler for finishing background work.
	when a background task is completed the session awakes the app and we get a "done" completion handler to tell the system when we are done.
	
	we call this handler when all the current donwloads are done, to close the app.
	*/
	static var backgroundCompletionHandler: (()->())?
	
	var downloadHandlers: [URLSessionDownloadTask: (URL?, URLResponse?, Error?) -> ()] = [:]
	var uploadHandlers: [URLSessionTask: (Data?, URLResponse?, Error?) -> ()] = [:]
	private var uploadResponseData: [URLSessionTask: Data] = [:]
	
	//finished download
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		if let handler = downloadHandlers.removeValue(forKey: downloadTask) {
			handler(location, downloadTask.response, downloadTask.error)
		}
	}
	
	//receive upload response data
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		uploadResponseData[dataTask] = data
	}
	
	//upload did complete
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let handler = uploadHandlers[task] {
			let data = uploadResponseData.removeValue(forKey: task)
			handler(data, task.response, error)
		}
	}
	
	func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
		post {
			Self.backgroundCompletionHandler?()
		}
	}
}
