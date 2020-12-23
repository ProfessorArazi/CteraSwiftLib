//
//  DownloadDelegate.swift
//  
//
//  Created by Gal Yedidovich on 21/12/2020.
//

import Foundation
import BasicExtensions
import StorageExtensions
import CteraModels
import CteraUtil

public class DownloadDelegate {
	public typealias DownloadTask = URLSessionDownloadTask
	
	private static let TAG = String(describing: DownloadDelegate.self)
	private static let queue = DispatchQueue(label: "DownloadDelegate")
	private let fm = FileManager.default

	public private(set) var tasks: [String: DownloadTask] = [:]
	private var items: [Int: ItemInfoDto] = [:]
	private var handlers: [Int: Handler<URL>] = [:]
	
	init() {
		items = FileSystem.load(json: .downloadTasks) ?? [:]
	}
	
	public func invalidateTasks(completion: @escaping ([String: DownloadTask])->()) {
		HttpClient.getTasks { _, _, downloadTasks in
			var remaining = Set(self.items.keys)
			for task in downloadTasks {
				guard let item = self.items[task.taskIdentifier] else {
					let downloadPath = task.originalRequest?.url?.path ?? "no path"
					Console.log(tag: Self.TAG, msg: "task with id: \(task.taskIdentifier) is not observed. download path: \"\(downloadPath)\"")
					
					task.cancel()
					if let url = task.response?.url {
						try? FileManager.default.removeItem(at: url)
					}
					continue
				}
				
				self.tasks[item.path] = task
				remaining.remove(task.taskIdentifier)
			}
			
			if !remaining.isEmpty {
				for id in remaining { //removed tracking for missing tasks
					self.items.removeValue(forKey: id)
				}
				
				self.updateJson()
			}
			
			completion(self.tasks)
		}
	}
	
	public func setHandler(taskID: Int, handler: @escaping Handler<URL>) {
		precondition(items[taskID] != nil)
		handlers[taskID] = handler
	}
	
	public func clear() {
		for task in tasks.values {
			task.cancel()
		}
		
		items = [:]
		tasks = [:]
		handlers = [:]
		
		try? FileSystem.delete(file: .downloadTasks)
		try? FileSystem.delete(folder: .downloads)
	}
	
	func onStart(_ task: DownloadTask, _ item: ItemInfoDto, _ handler: @escaping Handler<URL>) {
		tasks[item.path] = task
		items[task.taskIdentifier] = item
		handlers[task.taskIdentifier] = handler
		
		updateJson()
	}
	
	func onComplete(_ url: URL, task: DownloadTask) {
		guard let item = items[task.taskIdentifier] else {
			let path = task.originalRequest?.url?.path ?? "No Path"
			Console.log(tag: Self.TAG, msg: "\(#function), no item found for donwload: \"\(path)\"")
			return
		}
		
		defer {
			items.removeValue(forKey: task.taskIdentifier)
			updateJson()
			
			try? fm.removeItem(at: url) //delete temp file
		}
		
		let handler = handlers.removeValue(forKey: task.taskIdentifier)
		guard let status = (task.response as? HTTPURLResponse)?.statusCode else { return }
		guard status != 404 else {
			post { handler?(.error(Errors.text(.fileNotFoundErrorMsg))) }
			return
		}
		
		Console.log(tag: Self.TAG, msg: "download done, success: " + (task.error == nil && status == 200  ? "Yes" : "No"))
		if let error = task.error {
			post { handler?(.error(error)) }
			return
		}
		
		try! FileSystem.create(folder: .downloads)
		let destUrl = FileSystem.url(of: .downloads).appendingPathComponent(item.name)
		if fm.fileExists(atPath: destUrl.path) {
			try! fm.removeItem(at: destUrl)
		}
		try! fm.moveItem(at: url, to: destUrl)
		
		HttpClient.fileCache?.save(file: destUrl, with: item)
		HttpClient.thumbnailDelegate?.thumbnail(receivedFile: destUrl, for: item)
		
		post { handler?(.success(destUrl)) }
	}
	
	private func updateJson() {
		let copy = items
		Self.queue.async {
			try! FileSystem.write(data: copy.json(), to: .downloadTasks)
		}
	}
}
