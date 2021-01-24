//
//  UploadTests.swift
//  
//
//  Created by Gal Yedidovich on 22/12/2020.
//

import XCTest
import Foundation
import BasicExtensions
import StorageExtensions
import CteraModels
import CteraUtil
@testable import CteraNetwork

//TODO: handle Info.plist: (`CTERA` key) for unit tests

final class UploadTests: BaseNetworkTest {
	let file = FileManager.default.temporaryDirectory.appendingPathComponent("test.txt")
	
	override func tearDownWithError() throws {
		try FileManager.default.removeItem(at: file)
	}
	
	func testUpload() throws {
		try Data("Bubu is the king".utf8).write(to: file)
		
		let e = XCTestExpectation(description: "Waiting for request")
		HttpClient.uploadRequest(self.file, to: HttpClient.SERVICE_WEBDAV + "/myFiles/test.txt") { response in
			switch response {
			case .success:
				break
			case .error(let error):
				XCTFail(error.localizedDescription)
			}
			e.fulfill()
		}
		
		wait(for: [e], timeout: 100)
	}
}
