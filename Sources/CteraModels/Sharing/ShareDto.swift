//
//  ShareDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

import Foundation
public struct ShareDto: Codable, Hashable, Equatable {
	public var id: Int
	public var href: String
	public var phoneNumber: String
	public var invitee: CollaboratorDto
	public var createdBy: CollaboratorDto
	public var accessMode: ItemPermissionDto
	public var protectionLevel: ProtectionLevelDto
	public var collaborationPolicyData: CollaborationPolicyDto
	public var isDirectory: Bool
	public var canEdit: Bool
	public var createDate: Date
	public var expiration: Date?
	
	public init(id: Int = 0, href: String = "", phoneNumber: String = "", invitee: CollaboratorDto, createdBy: CollaboratorDto, accessMode: ItemPermissionDto = .None, protectionLevel: ProtectionLevelDto = .publicLink, collaborationPolicyData: CollaborationPolicyDto, isDirectory: Bool = false, canEdit: Bool = false, createDate: Date = Date(), expiration: Date? = nil) {
		self.id = id
		self.href = href
		self.phoneNumber = phoneNumber
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
		case phoneNumber
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
}

public enum CollaboratorType: String, Codable {
	case external
	case group
	case localUser
}
