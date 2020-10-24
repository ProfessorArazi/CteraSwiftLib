//
//  InvitePermissionDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct InvitePermissionDto: Codable, Equatable {
	public var allowedAccess: String
	public var invitationSettings: InvitationSettingsDto
}
