//
//  InvitationSettingsDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct InvitationSettingsDto: Codable, Equatable, Hashable {
	public var allowCollaboratorsToReshareContent: Bool = false
	public var invitationMaxValidityDuration: Int?
	public var allowedFrequentContactsTime: Int64 = 0
	public var inviteLifetime: Int64 = 0
	
	public var defaultProtectionLevel: ProtectionLevelDto?
	public var protectionLevels: [ProtectionLevelDto]?
	
	public init() {}
	
	public enum CodingKeys: String, CodingKey {
		case allowCollaboratorsToReshareContent
		case invitationMaxValidityDuration
		case allowedFrequentContactsTime
		case inviteLifetime
		case defaultProtectionLevel = "defaultProtectionLevels"
		case protectionLevels
	}
}
