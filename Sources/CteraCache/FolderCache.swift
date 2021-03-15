//
//  FolderCache.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import StorageExtensions
import CteraModels

public enum FolderCache {
	private static let queue = DispatchQueue(label: "Folder Cache", qos: .background)
	private static var cache: [String: FolderDto] = [:]
	
	public static func initialize() {
		if let cache: [String: FolderDto] = try? FileSystem.load(json: .folderCache) {
			Self.cache = cache
		}
	}
	
	public static func clearCache() { cache = [:] }
	
	public static subscript(key: String) -> FolderDto? {
		get { cache[key] }
		set {
			if let folder = newValue {
				cache[key] = folder
			} else {
				cache.removeValue(forKey: key)
			}
			update()
		}
	}
	
	private static func update() {
		let copy = cache //using copy to avoid manipulation while queue is busy
		queue.async {
			try! FileSystem.write(data: copy.json(), to: .folderCache)
		}
	}
}
