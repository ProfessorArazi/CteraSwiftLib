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
	static let dateOnlyFormat = DateFormatter(format: "yyyy-dd-MM")
}

public extension Int64 {
	/// calculates and returns a string representation of this value in byte units.
	var sizeFormat: String {
		if self == 0 { return .zeroBytes }
		if self == 1 { return .oneByte }
		
		let sizes: [String] = [ .bytes, .kb, .mb, .gb, .tb, .pb ]
		var index = 0;
		
		var prettySize: Double = Double(self);
		while (prettySize > 1024 && index < sizes.count) {
			index += 1
			prettySize /= 1024
		}
		
		return String(format: "%.0f %@", prettySize, sizes[index])
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

public extension URL {
	var isDirectory: Bool {
		let values = try? resourceValues(forKeys: [.isDirectoryKey])
		return values?.isDirectory ?? false
	}
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

public extension Folder {
	static let downloads =	Folder(name: "_______________-")
	static let logs =		Folder(name: "______________--")
}

public extension Filename {
	//Prefs.standard filename is "_", defined in SwiftExtensions Package
	static let fileCache = 			Filename(name: "-_______________")
	static let folderCache = 		Filename(name: "--______________")
}

public extension Encodable {
	func json(format: DateFormatter) -> Data {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .formatted(format)
		return try! encoder.encode(self)
	}
}

public extension Decodable {
	static func fromFormatted<T: Decodable>(json: Data, dateStrategy: JSONDecoder.DateDecodingStrategy = .formatted(.standardFormat)) throws -> T {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = dateStrategy
		return try decoder.decode(T.self, from: json)
	}
	
	static func fromFormatted<T: Decodable>(json: Data) throws -> T {
		try fromFormatted(json: json, dateStrategy: .formatted(.standardFormat))
	}
}
