//
//  InvitationSettings.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct InvitationSettings: Codable, Equatable {
	public var allowCollaboratorsToReshareContent: Bool = false
	public var invitationMaxValidityDuration: Int?
	public var allowedFrequentContactsTime: Int64 = 0
	public var inviteLifetime: Int64 = 0
	
	public var defaultProtectionLevel: ProtectionLevel?
	public var protectionLevels: [ProtectionLevel]?
	
	public enum CodingKeys: String, CodingKey {
		case allowCollaboratorsToReshareContent
		case invitationMaxValidityDuration
		case allowedFrequentContactsTime
		case inviteLifetime
		case defaultProtectionLevel = "defaultProtectionLevels"
		case protectionLevels
	}
	
	public enum ProtectionLevel: String, Codable { //2 step verification types
		case publicLink, textMessage, email
	}
}
