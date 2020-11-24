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
				break
			case .error(let error):
				fatalError("error: \(error)")
			}
			
			e.fulfill()
		}
		wait(for: [e], timeout: 10)
	}
	
}
