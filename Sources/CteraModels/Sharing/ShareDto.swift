//
//  ShareDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

import Foundation
public struct ShareDto: Codable {
	public var id: Int
	public var href: String
	public var invitee: CollaboratorDto
	public var createdBy: CollaboratorDto
	public var accessMode: ItemPermissionDto
	public var protectionLevel: ProtectionLevelDto
	public var collaborationPolicyData: CollaborationPolicyDto
	public var isDirectory: Bool
	public var canEdit: Bool
	public var createDate: Date
	public var expiration: Date?
	
	public init(id: Int = 0, href: String = "", invitee: CollaboratorDto, createdBy: CollaboratorDto, accessMode: ItemPermissionDto = .None, protectionLevel: ProtectionLevelDto = .publicLink, collaborationPolicyData: CollaborationPolicyDto, isDirectory: Bool = false, canEdit: Bool = false, createDate: Date = Date(), expiration: Date? = nil) {
		self.id = id
		self.href = href
		self.invitee = invitee
		self.createdBy = createdBy
		self.accessMode = accessMode
		self.protectionLevel = protectionLevel
		self.collaborationPolicyData = collaborationPolicyData
		self.isDirectory = isDirectory
		self.canEdit = canEdit
		self.createDate = createDate
		self.expiration = expiration
	}
	
	private enum CodingKeys : CodingKey {
		case id
		case href
		case invitee
		case createdBy
		case accessMode
		case protectionLevel
		case collaborationPolicyData
		case isDirectory
		case canEdit
		case createDate
		case expiration
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		id = try container.decode(Int.self, forKey: .id)
		href = try container.decode(String.self, forKey: .href)
		invitee = try container.decode(CollaboratorDto.self, forKey: .invitee)
		createdBy = try container.decode(CollaboratorDto.self, forKey: .createdBy)
		accessMode = try container.decode(ItemPermissionDto.self, forKey: .accessMode)
		protectionLevel = try container.decode(ProtectionLevelDto.self, forKey: .protectionLevel)
		collaborationPolicyData = try container.decode(CollaborationPolicyDto.self, forKey: .collaborationPolicyData)
		isDirectory = try container.decode(Bool.self, forKey: .isDirectory)
		canEdit = try container.decode(Bool.self, forKey: .canEdit)
		
		//all for these
		let createDateStr = try container.decode(String.self, forKey: .createDate)
		createDate = DateFormatter.standardFormat.date(from: createDateStr)!
		
		if let expirationStr = try container.decodeIfPresent(String.self, forKey: .createDate) {
			expiration = DateFormatter.standardFormat.date(from: expirationStr)!
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(id, forKey: .id)
		try container.encode(href, forKey: .href)
		try container.encode(invitee, forKey: .invitee)
		try container.encode(createdBy, forKey: .createdBy)
		try container.encode(accessMode, forKey: .accessMode)
		try container.encode(protectionLevel, forKey: .protectionLevel)
		try container.encode(collaborationPolicyData, forKey: .collaborationPolicyData)
		try container.encode(isDirectory, forKey: .isDirectory)
		try container.encode(canEdit, forKey: .canEdit)
		
		let createDateStr = DateFormatter.standardFormat.string(from: createDate)
		try container.encode(createDateStr, forKey: .createDate)
		
		//all for these
		if let expiration = expiration {
			let expirationStr = DateFormatter.standardFormat.string(from: expiration)
			try container.encode(expirationStr, forKey: .expiration)
		}
	}
}

public enum CollaboratorType: String, Codable {
	case external
	case group
	case localUser
}
