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
	func item(for item: ItemInfoDto) -> CacheItem?
	
	func save(file: URL, with item: ItemInfoDto)
	
	func provide(item: CacheItem, handler: @escaping (Swift.Result<URL, Error>)->()) -> ProgressTask
}

public struct CacheItem: Codable {
	public var item: ItemInfoDto
	public var localUrl: URL
	
	public init(item: ItemInfoDto, localUrl: URL) {
		self.item = item
		self.localUrl = localUrl
	}
	
	public mutating func isUpToDate(comparedTo item: ItemInfoDto) -> Bool {
		guard let compareLastModified = item.lastModified else { return true }
		
		guard let lastModified = self.item.lastModified else { //relevant only to uploaded files
			self.item.lastModified = compareLastModified
			return true
		}
		
		return lastModified == compareLastModified
	}
}
