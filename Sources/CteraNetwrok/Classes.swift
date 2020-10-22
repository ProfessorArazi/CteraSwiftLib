//
//  File.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import BasicExtensions
import StorageExtensions
import CteraModels

public class ProgressTask {
	let progress: Progress
	private(set) var cancelled = false
	var onCancel: ()->() = { }
	let msg: String
	let task: URLSessionTask?
	
	init() {
		progress = Progress()
		msg = ".opening"
		task = nil
	}
	
	init(from task: URLSessionTask) {
		progress = task.progress
		onCancel = task.cancel
		msg = ".downloading"
		self.task = task
	}
	
	func cancel() {
		cancelled = true
		onCancel()
	}
}

public struct SrcDestData {
	let action: String
	let pairs: [(src: String, dest: String)]
	let passphrase: String?
	var taskJson: JsonObject! = nil
}

public enum Response<T> {
	case success(T)
	case error(Error)
}

public protocol BackgroundTaskHandler {
	func onTaskStart()
	
	func onTaskConflict(json: JsonObject)
	
	func onTaskError()
	
	func onTaskProgress(_ percentage: Int)
	
	func onTaskDone()
}

public protocol ThumbnailDelegate {
	func thumbnailDelegate(receivedFile url: URL, for item: ItemInfo)
	
	func thumbnailDelegate(removedItem: ItemInfo, from url: URL, completion: @escaping ()->())
}


extension Encryptor {
	static func decrypt(file src: URL, to dest: URL, task: ProgressTask? = nil) {
		FileManager.default.createFile(atPath: dest.path, contents: nil)
		
		let readHandle = try! FileHandle(forReadingFrom: src)
		let writeHandle = try! FileHandle(forWritingTo: dest)
		
		let SIZE = (32 * 1024) + 28
		var offset: UInt64 = 0
		var chunck: Data = readHandle.readData(ofLength: SIZE)
		
		while chunck.count > 0 {
			guard !(task?.cancelled ?? false) else {
				try! FileManager.default.removeItem(at: dest)
				break
			}
			
			autoreleasepool {
				writeHandle.write(try! decrypt(data: chunck))
				offset += UInt64(chunck.count)
				readHandle.seek(toFileOffset: offset)
				chunck = readHandle.readData(ofLength: SIZE)
				task?.progress.completedUnitCount += Int64(chunck.count)
			}
		}
		
		readHandle.closeFile()
		writeHandle.closeFile()
	}
}

class ParserDelegate: NSObject, XMLParserDelegate {
	
	static func parse(data: Data) -> String {
		let parser = XMLParser(data: data)
		let delegate = ParserDelegate()
		parser.delegate = delegate
		return parser.parse() ? delegate.msg : ".error"
	}
	
	private var currentElement = ""
	var rc = "", msg = ""
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		if let id = attributeDict["id"] {
			currentElement = id
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		let str = string.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if !str.isEmpty {
			switch currentElement {
			case "rc":
				rc = str
			case "msg":
				msg = str
			default:
				break
			}
		}
	}
}

enum Errors: LocalizedError {
	case text(String), offline
	
	var errorDescription: String? {
		switch self {
		case .text(let msg): return msg
		case .offline: return ".noConnectionMsg"
		}
	}
}
