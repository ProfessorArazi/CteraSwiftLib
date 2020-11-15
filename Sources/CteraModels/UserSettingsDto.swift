//
//  UserSettingsDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct UserSettingsDto: Codable {
	public var userAvatarName: String?
	public var firstName, lastName, displayName, email: String!
	public var sla: SLA
	public var userStats: UserStats
	
	public init(userAvatarName: String? = nil, firstName: String? = nil,
				lastName: String? = nil, displayName: String? = nil,
				email: String? = nil, sla: SLA, userStats: UserStats) {
		self.userAvatarName = userAvatarName
		self.firstName = firstName
		self.lastName = lastName
		self.displayName = displayName
		self.email = email
		self.sla = sla
		self.userStats = userStats
	}
	
	public struct SLA: Codable {
		public var calculatedQuota: Int64?
		
		public init(calculatedQuota: Int64? = nil) {
			self.calculatedQuota = calculatedQuota
		}
	}
	
	public struct UserStats: Codable {
		public var foldersSize: Int64
		
		public init(foldersSize: Int64) {
			self.foldersSize = foldersSize
		}
	}
	
	public var abbreviation: String {
		"\(firstName.first!)\(lastName.first!)".uppercased()
	}
}
