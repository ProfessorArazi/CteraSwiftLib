//
//  ShareDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

import Foundation
public struct ShareDto: Codable, Hashable, Equatable {
	private let className = "ShareConfig"
	public var id: Int = 0
	public var href: String = ""
	public var resourceName: String = ""

	public var invitee = CollaboratorDto()
	public var createdBy = CollaboratorDto()
	public var accessMode = ItemPermissionDto.None
	public var protectionLevel: ProtectionLevelDto?
	public var collaborationPolicyData = CollaborationPolicyDto(protectionLevels: [], maxPermission: .None, defaultProtectionLevel: .publicLink)

	public var isDirectory: Bool = false
	public var canEdit: Bool = false
	public var createDate: Date = Date()
	public var expiration: Date?
	
	public init() {}
	
	private enum CodingKeys: String, CodingKey {
		case className = "$class"
		case id
		case href
		case resourceName
		
		case invitee
		case createdBy
		case accessMode
		case protectionLevel
		case collaborationPolicyData
		
		case isDirectory
		case canEdit
		case createDate
		case expiration
	}
}

public enum CollaboratorType: String, Codable {
	case external
	case localGroup
	case localUser
	case adUser
}
