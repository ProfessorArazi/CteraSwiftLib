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
	private static let TAG = String(describing: Console.self)
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
			if !fm.fileExists(atPath: FileSystem.url(of: .logs).path) {
				do {
					try FileSystem.create(folder: .logs)
				} catch {
					return
				}
			}
			
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
	
	/// create a populate a clear text file with all the current logs.
	/// - Parameters:
	///   - name: the name of the log file, defaults to "logs.txt"
	///   - completion: a completion handler, passes the result log url or an error
	public static func exportLogs(name: String = "logs.txt", completion: @escaping (Result<URL, Error>)->()) {
		Console.log(tag: Self.TAG, msg: #function)
		queue.async {
			do {
				try FileSystem.create(folder: .logs)
				let clearLogURL = FileSystem.url(of: .logs).appendingPathComponent(name)
				if fm.fileExists(atPath: clearLogURL.path) {
					try fm.removeItem(at: clearLogURL)
				}
				
				let logs = logFiles() //get log files before creating the "clear text" file
				try Data().write(to: clearLogURL, options: .completeFileProtection)
				let handle = try FileHandle(forWritingTo: clearLogURL)
				defer {
					handle.closeFile()
				}
				
				for log in logs {
					autoreleasepool {
						do {
							let encryptedData = try Data(contentsOf: log)
							let clearLogsData = try FileSystem.encryptor.decrypt(data: encryptedData)
							
							handle.write(clearLogsData)
						} catch {
							handle.write(Data("Could not read log file: \(log.pathComponents.last!)".utf8))
						}
						handle.write(Data("\n\n".utf8))
					}
				}
				
				post { completion(.success(clearLogURL)) }
			} catch {
				post { completion(.failure(error)) }
			}
		}
	}
	
	/// synchronize logging queue, to make sure there are not pending writes before continuing
	public static func sync() {
		log(tag: String(describing: Console.self), msg: "Syncing with console")
		queue.sync {
			logs = ""
			currentLog = newLogUrl()
		}
	}
	
	private static func getLogFile() -> URL {
		try! FileSystem.create(folder: .logs)
		
		if let lastLog = logFiles().last,
		   let lastLogSize = lastLog.fileSize, lastLogSize < MAX_LOG_SIZE, //use old log file
		   let data = try? FileSystem.encryptor.decrypt(data: Data(contentsOf: lastLog)) {
			logs = String(decoding: data, as: UTF8.self)
			return lastLog
		} else { //new log file
			return newLogUrl()
		}
	}
	
	private static func newLogUrl() -> URL {
		FileSystem.url(of: .logs).appendingPathComponent("\(Date().timeIntervalSince1970)")
	}
	
	private static func logFiles() -> [URL] {
		guard let urls = try? fm.contentsOfDirectory(at: FileSystem.url(of: .logs), includingPropertiesForKeys: nil) else { return [] }
		
		return urls.sorted(by: { $0.path < $1.path })
	}
}
