//
//  InvitePermissionDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct InvitePermissionDto: Codable, Equatable, Hashable {
	public var allowedAccess = ItemPermissionDto.None
	public var invitationSettings = InvitationSettingsDto()
	
	public init() {}
}
