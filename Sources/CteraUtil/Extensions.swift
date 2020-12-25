//
//  Extensions.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import StorageExtensions

public extension URLRequest {
	init(to host: String, _ path: String) {
		let url = URL(string: "https://\(host)/\(path)")!
		self.init(url: url)
		addValue("no-store", forHTTPHeaderField: "Cache-Control")
	}
}

public extension DateFormatter {
	static let standardFormat = DateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss")
	static let hourFormat = DateFormatter(format: "HH:mm")
	static let dayFormat = DateFormatter(format: "d MMM HH:mm")
	static let dateOnlyFormat = DateFormatter(format: "yyyy-MM-dd")
}

public extension JSONDecoder.DateDecodingStrategy {
	/// decoding strategy for multiple date formats where only "expiration" is formatted by date.
	///other date are formatted with the `standardFormat`.
	static var expirationStrategy: JSONDecoder.DateDecodingStrategy {
		return .custom { decoder -> Date in
			let container = try decoder.singleValueContainer()
			let str = try container.decode(String.self)
			let key = decoder.codingPath.last!.stringValue.lowercased()
			
			let format: DateFormatter = key == "expiration" ? .dateOnlyFormat : .standardFormat
			return format.date(from: str)!
		}
	}
}

public extension Int64 {
	/// calculates and returns a string representation of this value in byte units.
	var sizeFormat: String {
		ByteCountFormatter.string(fromByteCount: self, countStyle: .file)
	}
}

public extension SecKey {
	var data: Data? {
		guard let cddata = SecKeyCopyExternalRepresentation(self, nil) else { return nil }
		return cddata as Data
	}
	
	var base64: String? {
		data?.base64EncodedString()
	}
}

public extension Bundle {
	static let CteraResources = Bundle.module
	
	private static var ctera: [String: String] { main.infoDictionary!["CTERA"] as! [String: String] }
	
	static var keyGroup: String { ctera["KeyGroup"]! }
	
	static var appGroup: String { ctera["AppGroup"]! }
}

public extension String {
	/// fetches a suffix sub string from given string, starting after the last index of given character.
	/// - Parameter char: character to start suffix from (exlucive).
	/// - Returns: string representing the suffix.
	func suffix(from char: Character) -> String? {
		guard let index = lastIndex(of: char) else { return nil }
		
		return String(suffix(from: self.index(after: index)))
	}
}

public extension FileSystem {
	static func create(folder: Folder, withIntermediateDirectories: Bool = true) throws {
		try FileManager.default.createDirectory(at: url(of: folder), withIntermediateDirectories: withIntermediateDirectories)
	}
}

public extension Folder {
	static let logs =		Folder(name: "______________--")
	static let downloads =	Folder(name: "_____________---")
	static let uploads =	Folder(name: "____________----")
}

public extension Filename {
	//Prefs.standard filename is "_", defined in SwiftExtensions Package
	static let fileCache = 			Filename(name: "-_______________")
	static let folderCache = 		Filename(name: "--______________")
	static let downloadTasks = 		Filename(name: "___-------------")
	static let uploadTasks = 		Filename(name: "____------------")
}

public extension Encodable {
	func json(format: DateFormatter) -> Data {
		json(dateStrategy: .formatted(format))
	}
	
	func json(dateStrategy: JSONEncoder.DateEncodingStrategy) -> Data {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = dateStrategy
		return try! encoder.encode(self)
	}
}

public extension Decodable {
	static func fromFormatted<T: Decodable>(json: Data, dateStrategy: JSONDecoder.DateDecodingStrategy) throws -> T {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = dateStrategy
		return try decoder.decode(T.self, from: json)
	}
	
	static func fromFormatted<T: Decodable>(json: Data) throws -> T {
		try fromFormatted(json: json, dateStrategy: .formatted(.standardFormat))
	}
}
