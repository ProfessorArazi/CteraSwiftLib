//
//  PublicLinksTests.swift
//  
//
//  Created by Gal Yedidovich on 24/11/2020.
//

import Foundation
import CteraModels
import CteraNetwork
import XCTest

final class PublicLinksTests: BaseNetworkTest {
	func testFetch() {
		let e = XCTestExpectation(description: "Waiting for requests")
		
		let item = ItemInfoDto(path: HttpClient.SERVICE_WEBDAV + "/a", isFolder: true)
		HttpClient.requestPublicLinks(for: item) { response in
			switch response {
			case .success(let links):
				print(links)
			case .error(let error):
				XCTFail("error: \(error.localizedDescription)")
			}
			e.fulfill()
		}
		
		wait(for: [e], timeout: 10)
	}
}
