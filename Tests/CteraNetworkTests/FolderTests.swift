//
//  FolderTests.swift
//  CteraNetworkTests
//
//  Created by Gal Yedidovich on 24/11/2020.
//

import XCTest
import CteraNetwork
import CteraModels

class FolderTests: BaseNetworkTest {
	
	func testFetch2() {
		let e = XCTestExpectation(description: "Waiting for requests")
		HttpClient.fetchFolder(FetchRequestDto(path: HttpClient.SERVICE_WEBDAV + "/Bubu%202")) { response in
			switch response {
			case .success(let folder):
				print(folder)
			case .failure(let error):
				XCTFail("\(error)")
			}
			
			e.fulfill()
		}
		wait(for: [e], timeout: 10)
	}
	
	func testFetchShareByMe() {
		let e = XCTestExpectation(description: "Waiting for requests")
		let req = FetchRequestDto(path: HttpClient.SERVICE_WEBDAV)
			.with(depth: "Infinity")
			.with(cachePath: "SharedByMe")
			.with(includeShared: true)
		
		HttpClient.fetchFolder(req) { response in
			switch response {
			case .success(let folder):
				print(folder)
				break
			case .failure(let error):
				XCTFail("\(error)")
			}
			
			e.fulfill()
		}
		wait(for: [e], timeout: 10)
	}
	
}
