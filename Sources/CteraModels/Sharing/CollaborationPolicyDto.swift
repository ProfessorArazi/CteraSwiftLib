//
//  CollaborationPolicyDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

public struct CollaborationPolicyDto: Codable {
	public let protectionLevels: [ProtectionLevelDto]
	public let maxPermission: ItemPermissionDto
	public let defaultProtectionLevel: ProtectionLevelDto
	
	enum CodingKeys: String, CodingKey {
		case protectionLevels
		case maxPermission
		case defaultProtectionLevel = "deafaultProtectionLevel"
	}
}
