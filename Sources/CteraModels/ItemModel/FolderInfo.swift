//
//  FolderInfo.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct FolderInfo: Codable, Equatable {
	
	public static var navigationItems: FolderInfo?
	
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
