//
//  FolderDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct FolderDto: Codable, Equatable {
	
	public static var navigationItems: FolderDto?
	
	public var items: [ItemInfoDto] = []
	public var folderItem: ItemInfoDto! = ItemInfoDto()
	public var errorType: String?
	public var hasMore: Bool = false
	
	public init() {}
	
	private enum CodingKeys: String, CodingKey {
		case folderItem = "root"
		case items
		case errorType
		case hasMore
	}
}
