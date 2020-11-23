//
//  CollaborationDTOs.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

public struct CollaborationDto: Codable, Equatable {
	public var shares: [ShareDto]
	public var owner: CollaboratorDto

	public var allowReshare: Bool
	public var teamProject: Bool
	public var shouldSync: Bool
	public var enableSyncWinNtExtendedAttributes: Bool
	
	public let canModifyTeamProject: Bool
	public let showAllowReshare: Bool
	public let canModifyShouldSync: Bool
	public let canModifySyncWinNtAcl: Bool
	
	public init(shares: [ShareDto], owner: CollaboratorDto,
				allowReshare: Bool = false, teamProject: Bool = false,
				shouldSync: Bool = false, enableSyncWinNtExtendedAttributes: Bool = false,
				canModifyTeamProject: Bool = false, showAllowReshare: Bool = false,
				canModifyShouldSync: Bool = false, canModifySyncWinNtAcl: Bool = false) {
		self.shares = shares
		self.owner = owner
		self.allowReshare = allowReshare
		self.teamProject = teamProject
		self.shouldSync = shouldSync
		self.enableSyncWinNtExtendedAttributes = enableSyncWinNtExtendedAttributes
		self.canModifyTeamProject = canModifyTeamProject
		self.showAllowReshare = showAllowReshare
		self.canModifyShouldSync = canModifyShouldSync
		self.canModifySyncWinNtAcl = canModifySyncWinNtAcl
	}
}
