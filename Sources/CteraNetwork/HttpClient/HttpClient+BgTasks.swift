//
//  HttpClient+BgTasks.swift
//  
//
//  Created by Gal Yedidovich on 31/01/2021.
//

import Foundation
import BasicExtensions
import CteraUtil
import CteraModels

extension HttpClient {
	public static func rename(item: ItemInfoDto, to newName: String, handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: Self.TAG, msg: #function)
		let newPath = item.parentPath + "/" + newName
		let data = SrcDestData(action: "moveResources", pairs: [(src: item.path, dest: newPath)])
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func delete(items: [ItemInfoDto], handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: TAG, msg: #function)
		let paths = items.map { item in (src: item.path, dest: "") }
		let data = SrcDestData(action: "deleteResources", pairs: paths)
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func restore(items: [ItemInfoDto], handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: TAG, msg: #function)
		let paths = items.map { item in (src: item.path, dest: item.parentPath) }
		let data = SrcDestData(action: "restoreResources", pairs: paths)
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func restoreVersionedItem(item: ItemInfoDto, handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: TAG, msg: #function)
		let data = SrcDestData(action: "restoreResources", pairs: [(src: item.path, dest: "")])
		srcDestRequest(data: data, handler: handler)
	}
	
	public static func copyMove(isCopy: Bool, items: [ItemInfoDto], folderPath: String, handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: TAG, msg: #function)
		let paths = items.map { item in (src: item.path, dest: folderPath + "/" + item.name) }
		let data = SrcDestData(action: (isCopy ? "copyResources" : "moveResources"), pairs: paths)
		srcDestRequest(data: data, handler: handler)
	}
	
	/// follows the status of a background task on the portal, until an error, conflict or success achived.
	/// - Parameters:
	///   - taskUrl: unique ID of the task to check
	///   - handler: request completion handler
	public static func followServerTask(at taskUrl: String, handler: BackgroundTaskHandler) {
		Console.log(tag: TAG, msg: "\(#function), request status on \(taskUrl)")
		post { handler.onTaskStart() }
		
		func checkStatus() {
			checkTaskStatus(at: taskUrl) { result in
				switch result {
				case .success(let task):
					if let errorType = task.string(key: "errorType"), !errorType.isEmpty {
						Console.log(tag: TAG, msg: "followServerTask, error in action: \(errorType)")
						post {
							if errorType.lowercased() == "conflict" {
								handler.onTaskConflict(task: task)
							} else {
								handler.onTaskError(error: Errors.text(errorType))
							}
						}
					} else {
						if task.int(key: "percentage")! < 100 {
							post { handler.onTaskProgress(task: task) }
							//wait 1 second than try again
							post(delay: 1) { checkStatus() }
						} else {
							post { handler.onTaskDone() }
						}
					}
				case .failure(let error):
					Console.log(tag: Self.TAG, msg: "\(#function) error, \(error)")
					post { handler.onTaskError(error: error) }
				}
			}
		}
		
		checkStatus() //start checking task status
	}
	
	/// checks status of a background task on the portal once.
	/// - Parameters:
	///   - taskUrl: unique ID of the task to check
	///   - handler: request completion handler
	public static func checkTaskStatus(at taskUrl: String, handler: @escaping Handler<JsonObject>) {
		Console.log(tag: TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.getStatus(for: taskUrl))
		
		handle(request: req, JsonObject.init(data:), handler: handler)
	}
	
	public static func resolveConflict(_ srcDestData: SrcDestData, handler: BackgroundTaskHandler) {
		Console.log(tag: Self.TAG, msg: #function)
		srcDestRequest(data: srcDestData) { result in
			switch result {
			case .success(let (taskUrl, _)):
				followServerTask(at: taskUrl, handler: handler)
			case .failure(let error):
				Console.log(tag: Self.TAG, msg: "\(#function) error, \(error)")
				handler.onTaskError(error: error)
			}
		}
	}
	
	private static func srcDestRequest(data payload: SrcDestData, handler: @escaping Handler<(String, SrcDestData)>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.sourceDestCommand(with: payload))
		
		func middleware(data: Data) -> (String, SrcDestData) {
			let taskUrl = String(decoding: data, as: UTF8.self)
				.replacingOccurrences(of: "\\", with: "")
				.replacingOccurrences(of: "\"", with: "")
			
			return (taskUrl, payload)
		}
		
		handle(request: req, middleware, handler: handler)
	}
}
