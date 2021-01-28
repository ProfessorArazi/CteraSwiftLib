//
//  File.swift
//  
//
//  Created by Gal Yedidovich on 28/01/2021.
//

import XCTest
import CteraModels
import CteraNetwork

final class PreviewTests: BaseNetworkTest {
	func testPreviewSession() {
		let e = XCTestExpectation(description: "Waiting for requests")
		
		let item = ItemInfoDto(path: HttpClient.SERVICE_WEBDAV + "/a/weekly.txt")
		HttpClient.requestPreviewSession(for: item) { response in
			switch response {
			case .success: break
			case .error(let error) where error is PreviewError: break
			case .error(let error):
				XCTFail(error.localizedDescription)
			}
			
			e.fulfill()
		}
		
		wait(for: [e], timeout: 10)
	}
}
