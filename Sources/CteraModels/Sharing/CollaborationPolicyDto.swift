//
//  CollaborationPolicyDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

public struct CollaborationPolicyDto: Codable, Hashable, Equatable {
	private let className = "PreVerifySingleShareResult"
	public var protectionLevels: [ProtectionLevelDto]?
	public var defaultProtectionLevel: ProtectionLevelDto?
	public var maxPermission: ItemPermissionDto?
	public var error: String?
	
	public init(protectionLevels: [ProtectionLevelDto]? = nil,
				defaultProtectionLevel: ProtectionLevelDto? = nil,
				maxPermission: ItemPermissionDto? = nil,
				error: String? = nil) {
		self.protectionLevels = protectionLevels
		self.maxPermission = maxPermission
		self.defaultProtectionLevel = defaultProtectionLevel
		self.error = error
	}
	
	enum CodingKeys: String, CodingKey {
		case className = "$class"
		case protectionLevels
		case maxPermission
		case defaultProtectionLevel = "deafaultProtectionLevel"
		case error
	}
}
