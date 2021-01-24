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
		let item = ItemInfoDto(path: HttpClient.SERVICE_WEBDAV + "/a")
		HttpClient.requestCollaboration(for: item) { fetchRes in
			switch fetchRes {
			case .success(var coll):
				coll.shares[0].accessMode = .PreviewOnly
//				coll.shares[0].phoneNumber = PhoneNumberDto(phoneNumber: "+972123456789")
				
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
	
	func testValidation() {
		let e = XCTestExpectation(description: "Waiting for requests")
		let item = ItemInfoDto(path: HttpClient.SERVICE_WEBDAV + "/a")
		
		var collaborator = CollaboratorDto()
		collaborator.type = .external
		collaborator.email = "Bubu@bubu.com"
		HttpClient.validateCollaborator(for: item, invitee: collaborator) { response in
			switch response {
			case .success:
				break
			case .error(let error):
				XCTFail(error.localizedDescription)
			}
			e.fulfill()
		}
		
		wait(for: [e], timeout: 60)
	}
}
