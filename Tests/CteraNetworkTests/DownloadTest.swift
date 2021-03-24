//
//  DownloadTest.swift
//  
//
//  Created by Loren Raz on 17/03/2021.
//

import Foundation
import XCTest
import BasicExtensions
import CteraModels
import CteraUtil
@testable import CteraNetwork

final class DownloadTest: BaseNetworkTest {
	private var item = ItemInfoDto(path: HttpClient.SERVICE_WEBDAV + "/Bubu/a.jpg")
	
	func testPreVerifyDownload() {
		let e = XCTestExpectation(description: "Waiting for request")
		
		HttpClient.preVerifyDownload(for: item.path) {result in
			switch result {
			case .success(let preVerifyRes):
				XCTAssertEqual(preVerifyRes.status, .ok)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			e.fulfill()
		}
		
		wait(for: [e], timeout: 60)
	}
	
	func testRequestFile() {
		let e = XCTestExpectation(description: "Waiting for request")
		item.actions.download = true
		
		HttpClient.requestFile(for: item, config: {_ in}) { result in
			switch result {
			case .success(let url):
				try? FileManager.default.removeItem(at: url)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			e.fulfill()
		}
		
		wait(for: [e], timeout: 60)
	}
}
