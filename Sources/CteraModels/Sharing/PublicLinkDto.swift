//
//  PublicLinkDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct PublicLinkDto: Codable, Hashable, Equatable {
	public var href: String
	public var isFolder: Bool
	
	public var id: Int
	public var key: String
	public var protectionLevel: ProtectionLevelDto
	public var link: String
	public var resourceName: String
	public var permission: ItemPermissionDto
	
	public var expiration: Date?  //format 'yyyy-dd-MM'
	public var creationDate: Date
	
	public init(href: String = "", isFolder: Bool = false, id: Int = -1, key: String = "",
				  protectionLevel: ProtectionLevelDto = .publicLink, link: String = "",
				  resourceName: String = "", permission: ItemPermissionDto = .None,
				  expiration: Date? = nil, creationDate: Date = Date()) {
		self.href = href
		self.isFolder = isFolder
		self.id = id
		self.key = key
		self.protectionLevel = protectionLevel
		self.link = link
		self.resourceName = resourceName
		self.permission = permission
		self.expiration = expiration
		self.creationDate = creationDate
	}
	
	private enum CodingKeys: String, CodingKey {
		case href
		case id
		
		case key
		case protectionLevel
		case resourceName
		case link = "publicLink"
		case isFolder = "isDirectory"
		
		case permission = "accessMode"
		case expiration
		case creationDate = "createDate"
	}
	
	/// decoding strategy for both date formats (createDate & expiration)
	public static var dateStrategy: JSONDecoder.DateDecodingStrategy = .custom { decoder -> Date in
		let key = decoder.codingPath.last! as! PublicLinkDto.CodingKeys
		let container = try decoder.singleValueContainer()
		let str = try container.decode(String.self)
		
		let format: DateFormatter = key == .expiration ?  .dateOnlyFormat : .standardFormat
		return format.date(from: str)!
	}
}
