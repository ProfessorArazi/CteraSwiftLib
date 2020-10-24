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
		cache = FileSystem.load(json: .folderCache) ?? [:]
	}
	
	public static func has(_ path: String) -> Bool { cache[path] != nil }
	
	public static func load(folder path: String) -> FolderDto? { cache[path] }
	
	public static func save(_ path: String, _ folder: FolderDto) {
		cache[path] = folder
		update()
	}
	
	public static func clearCache() { cache = [:] }
	
	private static func update() {
		let copy = cache //using copy to avoid manipulation while queue is budy
		queue.async { try! FileSystem.write(data: copy.json(), to: .folderCache) }
	}
}
