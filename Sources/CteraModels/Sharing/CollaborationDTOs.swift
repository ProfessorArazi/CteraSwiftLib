//
//  CollaborationDTOs.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

public struct CollaborationDTO: Codable {
	public var shares: [CollaboratorDto]
	public var owner: InviteeDto

	public var allowReshare: Bool
	public var teamProject: Bool
	public var shouldSync: Bool
	public let enableSyncWinNtExtendedAttributes: Bool
	
	public let canModifyTeamProject: Bool
	public let showAllowReshare: Bool
	public let canModifyShouldSync: Bool
	public let canModifySyncWinNtAcl: Bool
}
