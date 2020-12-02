//
//  CollaborationTests.swift
//  
//
//  Created by Gal Yedidovich on 02/12/2020.
//

import Foundation
import XCTest
import CteraNetwork
import CteraModels

class CollaborationTests: BaseNetworkTest {
	func testSaveCollaboration() {
		let e = XCTestExpectation(description: "Waiting for requests")
		let item = ItemInfoDto(path: HttpClient.SERVICE_WEBDAV + "/big1")
		HttpClient.requestCollaboration(for: item) { fetchRes in
			switch fetchRes {
			case .success(var coll):
				coll.shares[0].accessMode = .PreviewOnly
				
				HttpClient.saveCollaboration(at: item.path, coll) { saveRes in
					switch saveRes {
					case .success:
						print("Success!")
					case .error(let error):
						XCTFail(error.localizedDescription)
					}
					e.fulfill()
				}
				
			case .error(let error):
				XCTFail(error.localizedDescription)
				e.fulfill()
			}
		}
		
		wait(for: [e], timeout: 60)
	}
}
