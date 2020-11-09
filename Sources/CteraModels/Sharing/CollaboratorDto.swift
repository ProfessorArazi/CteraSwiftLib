//
//  CollaboratorDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

import Foundation
public struct CollaboratorDto: Codable {
	public var invitee: InviteeDto
	public var accessMode: ItemPermissionDto
	public var collaborationPolicyData: CollaborationPolicyDto
	public var isDirectory: Bool
	public var protectionLevel: ProtectionLevelDto
	public var expiration: Date?
	
	public init(invitee: InviteeDto, accessMode: ItemPermissionDto = .None,
				collaborationPolicyData: CollaborationPolicyDto, isDirectory: Bool = false,
				protectionLevel: ProtectionLevelDto = .publicLink, expiration: Date? = nil) {
		self.invitee = invitee
		self.accessMode = accessMode
		self.collaborationPolicyData = collaborationPolicyData
		self.isDirectory = isDirectory
		self.protectionLevel = protectionLevel
		self.expiration = expiration
	}
}

public enum CollaboratorType: String, Codable {
	case external
	case group
	case localUser
}
