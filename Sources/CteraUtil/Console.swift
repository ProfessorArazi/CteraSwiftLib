//
//  Console.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import BasicExtensions
import StorageExtensions

public enum Console {
	private static let queue = DispatchQueue(label: "Console Queue", qos: .background)
	private static let fm = FileManager.default
	private static let MAX_LOG_SIZE = 5 * 1024
	private static let ROLLING_COUNT = 10
	
	private static var logs: String = ""
	private static var currentLog = getLogFile() //lazy
	
	public static func log(tag: String, msg: String) {
		#if DEBUG
		print("\(tag) - \(msg)")
		#endif
		
		let queueLabel = String(validatingUTF8: __dispatch_queue_get_label(nil))
		queue.async {
			let timestamp = DateFormatter(format: "yyyy MMM dd HH:mm:ss.SSS").string(from: Date())
			logs += "\(timestamp): "
			if let queueLabel = queueLabel { logs += "\(queueLabel) - " }
			logs += "\(tag) - \(msg)\n"
			
			let logData = Data(logs.utf8)
			try? FileSystem.write(data: logData, to: currentLog)
			
			if logData.count > MAX_LOG_SIZE { //switch logs file
				logs = ""
				currentLog = newLogUrl()
				
				let oldLogs = logFiles()
				if oldLogs.count >= ROLLING_COUNT {
					for i in 0...oldLogs.count - ROLLING_COUNT {
						try! fm.removeItem(at: oldLogs[i])
					}
				}
			}
		}
	}
	
	private static func getLogFile() -> URL {
		try! fm.createDirectory(at: FileSystem.url(of: .logs), withIntermediateDirectories: true, attributes: nil)
		
		if let lastLog = logFiles().last,
		   let lastLogSize = lastLog.fileSize, lastLogSize < MAX_LOG_SIZE, //use old log file
		   let data = try? Encryptor.decrypt(data: Data(contentsOf: lastLog)) {
			logs = String(decoding: data, as: UTF8.self)
			return lastLog
		} else { //new log file
			return newLogUrl()
		}
	}
	
	private static func newLogUrl() -> URL {
		FileSystem.url(of: .logs).appendingPathComponent("\(Int(Date().timeIntervalSince1970))")
	}
	
	private static func logFiles() -> [URL] {
		try! fm.contentsOfDirectory(at: FileSystem.url(of: .logs), includingPropertiesForKeys: nil)
			.sorted(by: { $0.path < $1.path })
	}
	
	static func sync() {
		log(tag: String(describing: Console.self), msg: "Syncing with console")
		queue.sync {
			logs = ""
			currentLog = newLogUrl()
		}
	}
}
