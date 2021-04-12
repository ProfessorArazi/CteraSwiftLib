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
		let targetFolder = "moveTestTarget"
		let destFolder = "moveTestDest"
		
		createFolder(name: targetFolder)
		createFolder(name: destFolder)

		let e = XCTestExpectation(description: "Waiting for requests")
		let item = ItemInfoDto(path: HttpClient.SERVICE_WEBDAV + "/" + destFolder)
		let payload: BgTaskPayload = .move(items: [item], to: HttpClient.SERVICE_WEBDAV + "/" + targetFolder)
		let handler = TestHandler(e, expectedResult: .done, payload)
		
		HttpClient.requestBgTask(handler: handler)
		wait(for: [e], timeout: 60)
		
		let targetItem = ItemInfoDto(path: HttpClient.SERVICE_WEBDAV + "/" + targetFolder, isFolder: true)
		delete(items: [targetItem])
	}
	
	func testDeleteRestore() {
		let target = "testRestoreFolder"
		let item = ItemInfoDto(path: HttpClient.SERVICE_WEBDAV + "/" + target, isFolder: true)
		
		createFolder(name: target)
		
		let deletePayload: BgTaskPayload = .delete(items: [item])
		let e1 = XCTestExpectation(description: "Waiting for delete")
		HttpClient.requestBgTask(handler: TestHandler(e1, deletePayload))
		wait(for: [e1], timeout: 60)
		
		let restorePayload: BgTaskPayload = .undelete(items: [item])
		let e2 = XCTestExpectation(description: "Waiting for undelete")
		HttpClient.requestBgTask(handler: TestHandler(e2, restorePayload))
		wait(for: [e2], timeout: 60)
		
		delete(items: [item])
	}
	
	private func delete(items: [ItemInfoDto]) {
		print("Clean ups test items")
		let payload: BgTaskPayload = .delete(items: items)
		HttpClient.requestBgTask(handler: IgnoringHandler(payload: payload))
	}
	
	private func createFolder(at parent: String = HttpClient.SERVICE_WEBDAV, name: String) {
		let e = XCTestExpectation(description: "Waiting for requests")
		HttpClient.createFolder(at: parent, name: name) { response in
			if case .failure(let error) = response {
				XCTFail(error.localizedDescription)
			}
			
			e.fulfill()
		}
		wait(for: [e], timeout: 10)
	}
}

struct IgnoringHandler: BackgroundTaskHandler {
	var payload: BgTaskPayload
	
	func onTaskStart() { }
	func onTaskConflict(task: JsonObject) { }
	func onTaskError(error: Error) { }
	func onTaskProgress(task: JsonObject) { }
	func onTaskDone() { }
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
	var payload: BgTaskPayload
	
	internal init(_ e: XCTestExpectation, expectedResult result: ExpectedResult = .done, _ payload: BgTaskPayload) {
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
			check(result: .conflict(.none))
			e.fulfill()
			return
		}
		
		let taskJson = task.with(key: "cursor", task.jsonObject(key: "cursor")!.with(key: "handler", handler.rawValue))
		
		resolved = true
		
		HttpClient.resolveConflict(taskJson: taskJson, handler: self)
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
