//
//  UserSettingsDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct UserSettingsDto: Codable {
	public var userAvatarName: String?
	public var firstName: String = ""
	public var lastName: String = ""
	public var displayName: String = ""
	public var email: String = ""
	public var sla = SLA()
	public var userStats = UserStats()
	
	public init() {}
	
	public struct SLA: Codable {
		public var calculatedQuota: Int64?
		
		public init() {}
	}
	
	public struct UserStats: Codable {
		public var foldersSize: Int64 = 0
		
		public init() {}
	}
	
	public var abbreviation: String {
		"\(firstName.first!)\(lastName.first!)".uppercased()
	}
}
