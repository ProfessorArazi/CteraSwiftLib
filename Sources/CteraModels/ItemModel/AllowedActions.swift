//
//  AllowedActions.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct AllowedActions: Codable, Equatable {
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
	
	public var invitePermissions: InvitePermission?
	public var previewStatus: PreviewStatus?
}
