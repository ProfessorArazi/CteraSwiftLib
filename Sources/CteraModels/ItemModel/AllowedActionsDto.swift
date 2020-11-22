//
//  AllowedActionsDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct AllowedActionsDto: Codable, Equatable, Hashable {
	public var delete: Bool = false
	public var copy: Bool = false
	public var move: Bool = false
	public var createFile: Bool = false
	public var createFolder: Bool = false
	public var createPublicLink: Bool = false
	public var manageSharing: Bool = false
	public var leaveShare: Bool = false
	public var download: Bool = false
	public var allowShowDeleted: Bool = false
	public var versioning: Bool = false
	public var undelete: Bool = false
	
	public var invitePermissions: InvitePermissionDto?
	public var previewStatus: PreviewStatusDto?
	
	public init() {}
	
	private enum CodingKeys: String, CodingKey {
		case delete = "_delete"
		case copy
		case move
		case createFile
		case createFolder
		case createPublicLink
		case manageSharing
		case leaveShare
		case download
		case allowShowDeleted
		case versioning
		case undelete
		
		case invitePermissions
		case previewStatus
	}
}
