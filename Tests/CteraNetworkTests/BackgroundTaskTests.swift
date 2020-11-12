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
@testable import CteraNetwrok

final class BackgroundTaskTests: BaseNetworkTest {
	
	func testDelete() {
		let e = XCTestExpectation(description: "Waiting for requests")
		HttpClient.createFolder(at: HttpClient.SERVICE_WEBDAV, name: "Bubu") { response in
			switch response {
			case .success:
				var item = ItemInfoDto()
				item.name = "Bubu"
				item.path = HttpClient.SERVICE_WEBDAV + "/Bubu"
				HttpClient.copyMove(isCopy: false, items: [item], folderPath: HttpClient.SERVICE_WEBDAV + "/a") { response in
					switch response {
					case .success((let taskUrl, _)):
						HttpClient.followServerTask(at: taskUrl, handler: TestHandler(e, expectedResult: .conflict))
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
	enum ExpectedResult {
		case conflict
		case error
		case done
	}
	
	let e: XCTestExpectation
	let expected: ExpectedResult
	
	internal init(_ e: XCTestExpectation, expectedResult result: ExpectedResult = .done) {
		self.e = e
		self.expected = result
	}
	
	func onTaskStart() {
		print(#function)
	}
	
	func onTaskConflict(task: BgTaskDto) {
		print(#function)
		check(result: .conflict)
		e.fulfill()
	}
	
	func onTaskError(error: Error) {
		print(#function)
		check(result: .error)
		e.fulfill()
	}
	
	func onTaskProgress(task: BgTaskDto) {
		print(#function)
		print(task)
	}
	
	func onTaskDone() {
		print(#function)
//		if expected != .done { XCTFail("expected Done but got \(expected)")}
		check(result: .done)
		e.fulfill()
	}
	
	private func check(result: ExpectedResult) {
		if self.expected != result { XCTFail("expected '\(self.expected)' but got '\(result)'")}
	}
}
