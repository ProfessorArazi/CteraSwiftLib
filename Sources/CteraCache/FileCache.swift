//
//  FileCache.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import StorageExtensions
import CteraUtil
import CteraModels

public protocol FileCache {
	init()
	
	var cache: [String: CacheItem] { get }
	
	var cacheSize: Int64 { get }
	
	func item(for item: ItemInfoDto) -> CacheItem?
	
	func save(file: URL, with item: ItemInfoDto)
	
	func provide(item: CacheItem, handler: @escaping (Swift.Result<URL, Error>)->()) -> ProgressTask
}

public extension FileCache {
	var cacheSize: Int64 {
		cache.compactMap { $0.value.item.size }
			.reduce(0, +)
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
