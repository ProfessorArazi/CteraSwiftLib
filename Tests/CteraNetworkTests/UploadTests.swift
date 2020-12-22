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
	func testUpload() throws {
		let file = FileManager.default.temporaryDirectory.appendingPathComponent("test.txt")
		try Data("Bubu is the king".utf8).write(to: file)
		
		let e = XCTestExpectation(description: "Waiting for request")
		HttpClient.uploadRequest(file, to: HttpClient.SERVICE_WEBDAV + "/A1/test.txt") { response in
			switch response {
			case .success:
				e.fulfill()
			case .error(let error):
				fatalError("error: \(error)") //TODO: remove
			}
		}
		
		wait(for: [e], timeout: 100)
	}
}
