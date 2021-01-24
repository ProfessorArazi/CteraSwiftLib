//
//  Classes.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import BasicExtensions
import StorageExtensions
import CteraModels

public typealias Handler<T> = (Response<T>) -> ()

public struct SrcDestData {
	public var action: String
	public var pairs: [(src: String, dest: String)]
	public var taskJson: JsonObject?
	
	public init(action: String, pairs: [(src: String, dest: String)], taskJson: JsonObject? = nil) {
		self.action = action
		self.pairs = pairs
		self.taskJson = taskJson
	}
}

public enum Response<T> {
	case success(T)
	case error(Error)
}

public protocol BackgroundTaskHandler {
	func onTaskStart()
	
	func onTaskConflict(task: JsonObject)
	
	func onTaskError(error: Error)
	
	func onTaskProgress(task: JsonObject)
	
	func onTaskDone()
}

public protocol ThumbnailDelegate {
	func thumbnail(receivedFile url: URL, for item: ItemInfoDto)
}

public enum Errors: LocalizedError {
	case text(String), offline
	
	public var errorDescription: String? {
		switch self {
		case .text(let msg): return msg
		case .offline: return .noConnectionMsg
		}
	}
}

class ParserDelegate: NSObject, XMLParserDelegate {
	
	static func parse(data: Data) -> (rc: Int, msg: String)? {
		let parser = XMLParser(data: data)
		let delegate = ParserDelegate()
		parser.delegate = delegate
		return parser.parse() ? (delegate.rc, delegate.msg) : nil
	}
	
	private var currentElement = ""
	var rc = -1
	var  msg = ""
	
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
				rc = Int(str) ?? -1
			case "msg":
				msg = str
			default:
				break
			}
		}
	}
}

struct Auth {
	let semaphore = DispatchSemaphore(value: 1)
	private(set) var cookie: HTTPCookie?
	private(set) var timestamp: Date = Date(timeIntervalSince1970: 0)
	
	///invalidate the authentication status to 'Not Authenticated' and authentication time to minimum
	mutating func invalidate() {
		cookie = nil
		timestamp = Date(timeIntervalSince1970: 0)
	}
	
	///set authentication status to 'Success' and authentication time to now
	mutating func renew(with newCookie: HTTPCookie) {
		cookie = newCookie
		timestamp = Date()
	}
}
