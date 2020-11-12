//
//  BaseNetworkTest.swift
//  
//
//  Created by Gal Yedidovich on 12/11/2020.
//

import XCTest
import StorageExtensions
import CteraUtil
import CteraNetwrok

class BaseNetworkTest: XCTestCase {
	override class func setUp() {
		HttpClient.serverAddress = "team65.ctera.me"
	}
	
	override class func tearDown() {
		try? FileSystem.delete(file: .prefs)
		try? FileSystem.delete(folder: .logs)
	}
	
	private static var loggedIn = false
	
	override func setUp() {
		if Self.loggedIn { return }
		
		let e = XCTestExpectation(description: "Waiting for requests")
		HttpClient.login("galy", "password1!", deviceID: "0", deviceName: "Test device") { response in
			switch response {
			case .success:
				Self.loggedIn = true
			case .error(let error):
				XCTFail("error: \(error)")
			}
			e.fulfill()
		}
		wait(for: [e], timeout: 10)
	}
}
