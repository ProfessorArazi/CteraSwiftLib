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
@testable import CteraNetwrok

final class CteraNetworkTests: XCTestCase {
	override class func setUp() {
		let str = """
{
	"deviceUID": 6123,
	"sharedSecret": "1F563C9C7FF36062C7F57C662D6184974D92E390E45DF91CB1C207FBF0BDDD9C"
}
"""
		let data = Data(str.utf8)
		HttpClient.serverAddress = "team65.ctera.me"
		HttpClient.credentials = try! .fromFormatted(json: data)
	}
	
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
