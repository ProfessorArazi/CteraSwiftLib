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
	
	public init(protectionLevels: [ProtectionLevelDto], maxPermission: ItemPermissionDto, defaultProtectionLevel: ProtectionLevelDto) {
		self.protectionLevels = protectionLevels
		self.maxPermission = maxPermission
		self.defaultProtectionLevel = defaultProtectionLevel
	}
	
	enum CodingKeys: String, CodingKey {
		case protectionLevels
		case maxPermission
		case defaultProtectionLevel = "deafaultProtectionLevel"
	}
}
