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
@testable import CteraNetwrok

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
}
