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
	public var message: String?
	public var key: String?
	public var publicLink: String?
	
	public var phoneNumber: PhoneNumberDto?
	public var invitee = CollaboratorDto()
	public var createdBy = CollaboratorDto()
	public var accessMode = ItemPermissionDto.None
	public var protectionLevel: ProtectionLevelDto?
	public var collaborationPolicyData = CollaborationPolicyDto(protectionLevels: [], defaultProtectionLevel: .publicLink, maxPermission: .None)
	
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
		case message
		case key
		case publicLink
		
		case phoneNumber
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
	
	public func encode(to encoder: Encoder) throws {
		var values = encoder.container(keyedBy: CodingKeys.self)
		
		try values.encode(className, forKey: .className)
		try values.encode(id, forKey: .id)
		try values.encode(href, forKey: .href)
		try values.encode(resourceName, forKey: .resourceName)
		try values.encodeIfPresent(message, forKey: .message)
		try values.encodeIfPresent(key, forKey: .key)
		try values.encodeIfPresent(publicLink, forKey: .publicLink)
		
		try values.encodeIfPresent(phoneNumber?.phoneNumber, forKey: .phoneNumber) //all for this
		try values.encode(invitee, forKey: .invitee)
		try values.encode(createdBy, forKey: .createdBy)
		try values.encode(accessMode, forKey: .accessMode)
		try values.encodeIfPresent(protectionLevel, forKey: .protectionLevel)
		try values.encode(collaborationPolicyData, forKey: .collaborationPolicyData)
		
		try values.encode(isDirectory, forKey: .isDirectory)
		try values.encode(canEdit, forKey: .canEdit)
		try values.encode(createDate, forKey: .createDate)
		try values.encodeIfPresent(expiration, forKey: .expiration)
	}
}

public enum CollaboratorType: String, Codable {
	case localUser
	case localGroup
	case adUser
	case adGroup
	case external
	case admin
}
