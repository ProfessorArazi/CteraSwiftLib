//
//  CloudFolderInfoDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct CloudFolderInfoDto: Codable, Equatable, Hashable {
	public var uid: Int = 0
	public var groupUid: Int = 0
	public var ownerUid: Int?
	public var name: String = ""
	public var type: String = ""
	public var ownerFriendlyName: String?
	public var isShared: Bool = false
	public var passphraseProtected: Bool = false
	
	public init() {}
}
