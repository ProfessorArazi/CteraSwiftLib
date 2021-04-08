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
	public static func requestBgTask(handler: BackgroundTaskHandler) {
		Console.log(tag: Self.TAG, msg: #function)
		startBgTask(payload: handler.payload) { result in
			switch result {
			case .success(let taskUrl):
				followServerTask(at: taskUrl, handler: handler)
			case .failure(let error):
				Console.log(tag: Self.TAG, msg: "\(#function) error, \(error)")
				handler.onTaskError(error: error)
			}
		}
	}
	
	public static func resolveConflict(taskJson: JsonObject, handler: BackgroundTaskHandler) {
		Console.log(tag: Self.TAG, msg: #function)
		startBgTask(payload: handler.payload, taskJson: taskJson) { result in
			switch result {
			case .success(let taskUrl):
				followServerTask(at: taskUrl, handler: handler)
			case .failure(let error):
				Console.log(tag: Self.TAG, msg: "\(#function) error, \(error)")
				handler.onTaskError(error: error)
			}
		}
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
}

fileprivate extension HttpClient {
	static func startBgTask(payload: BgTaskPayload, taskJson: JsonObject? = nil, handler: @escaping Handler<String>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.bgTaskCommand(with: payload, taskJson: taskJson))
		
		func middleware(data: Data) -> String {
			let taskUrl = String(decoding: data, as: UTF8.self)
				.replacingOccurrences(of: "\\", with: "")
				.replacingOccurrences(of: "\"", with: "")
			
			return taskUrl
		}
		
		handle(request: req, middleware, handler: handler)
	}
	
}
