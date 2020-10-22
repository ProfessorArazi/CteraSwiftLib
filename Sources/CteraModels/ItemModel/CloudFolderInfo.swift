//
//  CloudFolderInfo.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct CloudFolderInfo: Codable, Equatable {
	public var uid: Int
	public var groupUid: Int
	public var name: String
	public var type: String
	public var ownerFriendlyName: String?
	public var ownerUid: Int?
	public var isShared: Bool = false
	public var passphraseProtected: Bool = false
}
