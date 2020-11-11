//
//  PublicLinkDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct PublicLinkDto: Codable {
	public var href: String
	public var isFolder: Bool
	
	public var id: Int!
	public var key: String!
	public var protectionLevel: String!
	public var link: String!
	public var resourceName: String!
	public var permission: ItemPermissionDto!
	
	public var expiration: Date?
	public var creationDate: Date?
	
	init(href: String, isFolder: Bool) {
		self.href = href
		self.isFolder = isFolder
	}
	
//	public init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//
//		href = try container.decode(String.self, forKey: .href)
//		isFolder = try container.decode(Bool.self, forKey: .isFolder)
//
//		id = try container.decodeIfPresent(String.self, forKey: .id)
//		key = try container.decodeIfPresent(String.self, forKey: .key)
//		protectionLevel = try container.decodeIfPresent(String.self, forKey: .protectionLevel)
//		link = try container.decodeIfPresent(String.self, forKey: .link)
//		resourceName = try container.decodeIfPresent(String.self, forKey: .resourceName)
//		permission = try container.decodeIfPresent(ItemPermissionDto.self, forKey: .permission)
//
//		expiration = try container.decodeDateIfPresent(forKey: .expiration)
//		creationDate = try container.decodeDateIfPresent(forKey: .creationDate)
//	}
//
//	public func encode(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//
//		try container.encode(href, forKey: .href)
//		try container.encode(isFolder, forKey: .isFolder)
//
//		try container.encodeIfPresent(id, forKey: .id)
//		try container.encodeIfPresent(key, forKey: .key)
//		try container.encodeIfPresent(protectionLevel, forKey: .protectionLevel)
//		try container.encodeIfPresent(link, forKey: .link)
//		try container.encodeIfPresent(resourceName, forKey: .resourceName)
//		try container.encodeIfPresent(permission, forKey: .permission)
//
//		try container.encodeIfPresent(date: expiration, forKey: .expiration)
//		try container.encodeIfPresent(date: creationDate, forKey: .creationDate)
//	}
	
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
}

//internal extension KeyedDecodingContainer {
//	func decodeDate(forKey key: K, formatter: DateFormatter = .standardFormat) throws -> Date {
//		let str = try decode(String.self, forKey: key)
//		return formatter.date(from: str)!
//	}
//
//	func decodeDateIfPresent(forKey key: K, formatter: DateFormatter = .standardFormat) throws -> Date? {
//		guard let str = try decodeIfPresent(String.self, forKey: key) else { return nil }
//		return formatter.date(from: str)!
//	}
//}
//
//internal extension KeyedEncodingContainer {
//	mutating func encode(date: Date, forKey key: K, formatter: DateFormatter = .standardFormat) throws {
//		try encodeIfPresent(date: date, forKey: key, formatter: formatter)
//	}
//
//	mutating func encodeIfPresent(date: Date?, forKey key: K, formatter: DateFormatter = .standardFormat) throws {
//		guard let date = date else { return }
//
//		let str = formatter.string(from: date)
//		try encode(str, forKey: key)
//	}
//}
