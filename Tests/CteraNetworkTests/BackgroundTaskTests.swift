//
//  File.swift
//  
//
//  Created by Gal Yedidovich on 12/11/2020.
//

import XCTest
import Foundation
import BasicExtensions
import StorageExtensions
import CteraModels
import CteraUtil
@testable import CteraNetwork

final class BackgroundTaskTests: BaseNetworkTest {
	
	func testMove() {
		let e = XCTestExpectation(description: "Waiting for requests")
		HttpClient.createFolder(at: HttpClient.SERVICE_WEBDAV, name: "Bubu") { response in
			switch response {
			case .success:
				var item = ItemInfoDto()
				item.name = "Bubu"
				item.path = HttpClient.SERVICE_WEBDAV + "/Bubu"
				HttpClient.copyMove(isCopy: false, items: [item], folderPath: HttpClient.SERVICE_WEBDAV + "/a") { response in
					switch response {
					case .success((let taskUrl, let payload)):
						HttpClient.followServerTask(at: taskUrl, handler: TestHandler(e, expectedResult: .conflict(.Override), payload))
					case .error(let error):
						fatalError("error: \(error)")
					}
				}
				
			case .error(let error):
				fatalError("error: \(error)")
			}
		}
		wait(for: [e], timeout: 60 * 60)
	}
}


class TestHandler: BackgroundTaskHandler {
	enum ConflictHandler: String {
		case Override
		case Skip
		case Rename
	}
	
	enum ExpectedResult: Equatable {
		case conflict(ConflictHandler?)
		case error
		case done
	}
	
	private var resolved = false
	
	let e: XCTestExpectation
	let expected: ExpectedResult
	let payload: SrcDestData
	
	internal init(_ e: XCTestExpectation, expectedResult result: ExpectedResult = .done, _ payload: SrcDestData) {
		self.e = e
		self.expected = result
		self.payload = payload
	}
	
	func onTaskStart() {
		print(#function)
	}
	
	func onTaskConflict(task: JsonObject) {
		print(#function)
		guard case .conflict(.some(let handler)) = expected else {
			check(result: .conflict(nil))
			e.fulfill()
			return
		}
		
		var sd = payload
		sd.taskJson = task
		sd.taskJson.put(key: "cursor", task.jsonObject(key: "cursor")!.with(key: "handler", handler.rawValue))
		
		resolved = true
		
		HttpClient.resolveConflict(sd, handler: self)
	}
	
	func onTaskError(error: Error) {
		print(#function)
		check(result: .error)
		e.fulfill()
	}
	
	func onTaskProgress(task: JsonObject) {
		print(#function)
		print(task)
	}
	
	func onTaskDone() {
		print(#function)
		
		if !resolved { check(result: .done) }
		e.fulfill()
	}
	
	private func check(result: ExpectedResult) {
		if self.expected != result { XCTFail("expected '\(self.expected)' but got '\(result)'") }
	}
}
