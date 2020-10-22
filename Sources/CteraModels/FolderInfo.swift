//
//  FolderInfo.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct FolderInfo: Equatable, Codable {
	public var items: [ItemInfo]
	public var folderItem: ItemInfo! = ItemInfo()
	public var errorType: String?
	public var hasMore: Bool = false
	
	private enum CodingKeys: String, CodingKey {
		case folderItem = "root"
		case items
		case errorType
		case hasMore
	}
}
