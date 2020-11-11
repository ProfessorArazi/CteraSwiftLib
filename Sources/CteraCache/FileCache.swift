//
//  FileCache.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import StorageExtensions
import CteraModels

public enum FileCache {
	private static var cache: [String: CacheItem] = [:]
	private static let queue = DispatchQueue(label: "FileCache", qos: .background)
	
	public static func initialize() {
		guard let json: [String: CacheItem] = FileSystem.load(json: .fileCache) else { return }
		
		cache = json
		
		let filesDir = FileSystem.url(of: .downloads)
		for (key, value) in cache {
			let path = filesDir.appendingPathComponent(value.localUrl.lastPathComponent).path
			if !FileManager.default.fileExists(atPath: path) {
				cache.removeValue(forKey: key)
			} else {
				cache[key]!.localUrl = URL(fileURLWithPath: path) //Fix URL
			}
		}
	}
	
	public static func remove(at path: String) {
		if let cacheItem = FileCache[path] {
			try? FileManager.default.removeItem(at: cacheItem.localUrl)
			cache.removeValue(forKey: path)
		}
	}
	
	public static func clear() {
		try! FileSystem.delete(folder: .downloads)
		cache = [:]
		
		updateJson()
	}
	
	public static func save(file: URL, with item: ItemInfoDto) {
		let downloads = FileSystem.url(of: .downloads)
		if !FileManager.default.fileExists(atPath: downloads.path) {
			try! FileManager.default.createDirectory(at: downloads, withIntermediateDirectories: true)
		}
		
		let encFileUrl = downloads.appendingPathComponent(UUID().uuidString)
		try! Encryptor.encrypt(file: file, to: encFileUrl)
		
		if let url = cache[item.path]?.localUrl { //delete old cached file
			try? FileManager.default.removeItem(at: url)
		}
		cache[item.path] = CacheItem(item: item, localUrl: encFileUrl)
		updateJson()
	}
	
	public static var cacheSize: Int64 {
		cache.compactMap { $0.value.item.size }
			.reduce(0, +)
	}
	
	public static subscript(key: String) -> CacheItem? { cache[key] }
	
	private static func updateJson() {
		queue.async {
			try! FileSystem.write(data: cache.json(format: .standardFormat), to: .fileCache)
		}
	}
}

public struct CacheItem: Codable {
	public var item: ItemInfoDto
	public var localUrl: URL
	
	public mutating func isUpToDate(comparedTo item: ItemInfoDto) -> Bool {
		guard let compareLastModified = item.lastModified else { return true }
		
		guard let lastModified = self.item.lastModified else { //relevant only to uploaded files
			self.item.lastModified = compareLastModified
			return true
		}
		
		return lastModified == compareLastModified
	}
}
