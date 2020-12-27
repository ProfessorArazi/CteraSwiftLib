//
//  File.swift
//  
//
//  Created by Gal Yedidovich on 22/12/2020.
//

import Foundation
import BasicExtensions
import StorageExtensions
import CteraModels
import CteraUtil

fileprivate struct UploadData: Codable {
	let items: [Int: String]
	let ids: [Int: String]
}

public class UploadDelegate {
	public typealias UploadTask = URLSessionUploadTask
	
	private static let TAG = String(describing: UploadDelegate.self)
	private let queue = DispatchQueue(label: "UploadDelegate")
	private let uploadFolder = FileSystem.url(of: .uploads)
	private let fm = FileManager.default
	
	public private(set) var tasks: [String: UploadTask] = [:]
	private var items: [Int: String] = [:]
	private var handlers: [Int: Handler<Void>] = [:]
	private var ids: [Int: String] = [:] //links from task ID to upload file
	
	init() {
		guard let ud: UploadData = FileSystem.load(json: .uploadTasks) else { return }
		
		items = ud.items
		ids = ud.ids
	}
	
	public func invalidateTasks(completion: @escaping ([String: UploadTask])->()) {
		HttpClient.getTasks { _, uploadTasks, _ in
			var remaining = Set(self.items.keys)
			for task in uploadTasks {
				guard let path = self.items[task.taskIdentifier] else {
					Console.log(tag: Self.TAG, msg: "task with id: \(task.taskIdentifier) is not observed.")
					
					task.cancel()
					if let fileID = self.ids[task.taskIdentifier] {
						let url = self.uploadFolder.appendingPathComponent(fileID)
						try? self.fm.removeItem(at: url)
					}
					continue
				}
				
				self.tasks[path] = task
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
	
	public func setHandler(taskID: Int, handler: @escaping Handler<Void>) {
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
		
		try? FileSystem.delete(file: .uploadTasks)
		try? FileSystem.delete(folder: .uploads)
	}
	
	func multipartDataFile(_ contentUrl: URL, boundary: String, for path: String) -> URL {
		let id = UUID().uuidString
		try! fm.createDirectory(at: self.uploadFolder, withIntermediateDirectories: true)
		let uploadFile = self.uploadFolder.appendingPathComponent(id)
		
		let bodyStart = StringFormatter.multipartData(filePath: path)
		let bodyEnd = "\r\n--\(boundary)--\r\n"
		
		//Prepare file with boundaries
		let input = InputStream(url: contentUrl)!
		let output = OutputStream(url: uploadFile, append: false)!

		output.open()
		defer { output.close() }
		
		output.write(data: Data(bodyStart.utf8))
		input.readAll { output.write($0, maxLength: $1) }
		output.write(data: Data(bodyEnd.utf8))
		
		return uploadFile
	}
	
	func onStart(_ task: UploadTask, path: String, filename id: String, _ handler: @escaping Handler<Void>) {
		tasks[path] = task
		items[task.taskIdentifier] = path
		ids[task.taskIdentifier] = id
		handlers[task.taskIdentifier] = handler
		
		updateJson()
	}
	
	func onComplete(_ task: URLSessionUploadTask, with responseData: Data?) {
		let filename = ids.removeValue(forKey: task.taskIdentifier)
		
		defer {
			if let filename = filename {
				try? fm.removeItem(at: uploadFolder.appendingPathComponent(filename))
			}
			items.removeValue(forKey: task.taskIdentifier)
			updateJson()
		}
		
		guard let path = items[task.taskIdentifier] else {
			Console.log(tag: Self.TAG, msg: "\(#function), no item found for upload, task: \(task.taskIdentifier)")
			return
		}
		
		let handler = handlers.removeValue(forKey: task.taskIdentifier)
		//failure
		if let error = task.error {
			Console.log(tag: Self.TAG, msg: "\(#function), error uploading to \"\(path)\". \(error.localizedDescription)")
			post { handler?(.error(error)) }
			return
		}
		
		if let status = (task.response as? HTTPURLResponse)?.statusCode, status != 200 {
			let error = ParserDelegate.parse(data: responseData!)
			post { handler?(.error(Errors.text(error))) }
			return
		}
		
		//success
		if let responseData = responseData {
			let msg = String(decoding: responseData, as: UTF8.self)
			Console.log(tag: Self.TAG, msg: "\(#function), upload completed: \(msg)")
		}
		post { handler?(.success(())) }
	}
	
	private func updateJson() {
		let ud = UploadData(items: items, ids: ids)
		queue.async {
			try! FileSystem.write(data: ud.json(), to: .uploadTasks)
		}
	}
}
