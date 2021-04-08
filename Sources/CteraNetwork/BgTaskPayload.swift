//
//  BgTaskPayload.swift
//  
//
//  Created by Gal Yedidovich on 08/04/2021.
//

import CteraModels
public struct BgTaskPayload {
	public var action: Action
	public var paths: [SrcDest]
	
	public init(action: Action, paths: [SrcDest]) {
		self.action = action
		self.paths = paths
	}
}

public extension BgTaskPayload {
	enum Action: String {
		case delete = "deleteResources"
		case copy = "copyResources"
		case move = "moveResources"
		case restore = "restoreResources"
	}
	
	struct SrcDest {
		public init(source: String, destination: String = "") {
			self.source = source
			self.destination = destination
		}
		
		public var source: String
		public var destination: String
	}
}

public extension BgTaskPayload {
	static func rename(item: ItemInfoDto, to newName: String) -> BgTaskPayload {
		let newPath = item.parentPath + "/" + newName
		return BgTaskPayload(action: .move, paths: [.init(source: item.path, destination: newPath)])
	}
	
	static func move(items: [ItemInfoDto], to folderPath: String) -> BgTaskPayload {
		let paths = items.map { item in BgTaskPayload.SrcDest(source: item.path, destination: folderPath + "/" + item.name) }
		return BgTaskPayload(action: .move, paths: paths)
	}
	
	static func copy(items: [ItemInfoDto], to folderPath: String) -> BgTaskPayload {
		let paths = items.map { item in BgTaskPayload.SrcDest(source: item.path, destination: folderPath + "/" + item.name) }
		return BgTaskPayload(action: .copy, paths: paths)
	}
	
	static func delete(items: [ItemInfoDto]) -> BgTaskPayload {
		let paths = items.map { item in BgTaskPayload.SrcDest(source: item.path) }
		return BgTaskPayload(action: .delete, paths: paths)
	}
	
	static func undelete(items: [ItemInfoDto]) -> BgTaskPayload {
		let paths = items.map { item in BgTaskPayload.SrcDest(source: item.path, destination: item.parentPath) }
		return BgTaskPayload(action: .restore, paths: paths)
	}
	
	static func restoreVersion(item: ItemInfoDto) -> BgTaskPayload {
		BgTaskPayload(action: .restore, paths: [.init(source: item.path)])
	}
}
