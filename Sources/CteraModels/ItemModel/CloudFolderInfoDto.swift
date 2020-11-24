//
//  CloudFolderInfoDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct CloudFolderInfoDto: Codable, Equatable, Hashable {
	public var uid: Int
	public var groupUid: Int
	public var name: String
	public var type: String
	public var ownerFriendlyName: String
	public var ownerUid: Int
	public var isShared: Bool
	public var passphraseProtected: Bool
	
	public init(uid: Int = -1, groupUid: Int = -1, name: String = "", type: String = "", ownerFriendlyName: String = "", ownerUid: Int = -1, isShared: Bool = false, passphraseProtected: Bool = false) {
		self.uid = uid
		self.groupUid = groupUid
		self.name = name
		self.type = type
		self.ownerFriendlyName = ownerFriendlyName
		self.ownerUid = ownerUid
		self.isShared = isShared
		self.passphraseProtected = passphraseProtected
	}
}
