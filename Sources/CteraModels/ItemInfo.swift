//
//  ItemInfo.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct ItemInfo: Codable, Equatable {
	public var path: String = ""
	public var name: String = ""
	public var ext: String?
	public var lastModified: Date!
	public var size: Int64?
	public var isFolder: Bool = false
	public var cloudFolderInfo: CloudFolderInfo?
	
	public var parentPath: String {
		String(path.prefix(upTo: path.lastIndex(of: "/")!))
	}
	
	public mutating func set(lastModified: Date) {
		self.lastModified = lastModified
	}
	
	public func updatedPrettyTime() -> ItemInfo{
		//TODO: implement
		return self
	}
}

public struct CloudFolderInfo: Codable, Equatable {
	public var uid: String
}
