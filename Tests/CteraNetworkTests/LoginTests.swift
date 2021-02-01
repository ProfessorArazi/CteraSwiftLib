//
//  LoginTests.swift
//  
//
//  Created by Gal Yedidovich on 31/10/2020.
//

import XCTest
import Foundation
import BasicExtensions
import CteraModels
import CteraUtil
@testable import CteraNetwork

final class LoginTests: BaseNetworkTest {
	func testRenewSessionConcurrent() throws {
		let e = XCTestExpectation(description: "Waiting for requests")
		e.expectedFulfillmentCount = 40
		
		for i in 1...e.expectedFulfillmentCount {
			post(delay: 0.04 * Double(i)) {
				HttpClient.requestSessionInfo { response in
					switch response {
					case .success:
						print("done \(i)")
					default:
						XCTFail()
					}
					e.fulfill()
				}
			}
		}
		
		
		wait(for: [e], timeout: 60 * 60)
	}
	
	func testSessionInfoAndUserSettings() {
		let e = XCTestExpectation(description: "Waiting for requests")
		
		HttpClient.requestSessionInfo { response in
			switch response {
			case .success(let session):
				let ref = session.currentSession.userRef
				
				HttpClient.requestUserSettings(userRef: ref) { response in
					switch response {
					case .success(let settings):
						print(settings)
					case .failure(let error):
						fatalError("error: \(error)")
					}
				}
			case .failure(let error):
				XCTFail("\(error)")
			}
			
			e.fulfill()
		}
		
		
		wait(for: [e], timeout: 10)
	}
	
	func testGlobalStatus() throws {
		let e = XCTestExpectation(description: "Waiting for requests")
		
		HttpClient.requestGlobalStatus { result in
			switch result {
			case .success(let status):
				XCTAssert(status.status == .ok)
				break
			case .failure(let error):
				XCTFail("error: \(error)")
			}
			e.fulfill()
		}
		
		wait(for: [e], timeout: 10)
	}
}
