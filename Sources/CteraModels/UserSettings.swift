//
//  UserSettings.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct UserSettings: Codable {
	public static var instance: UserSettings!
	
	public var userAvatarName: String?
	public var firstName, lastName, displayName, email: String!
	public var sla: SLA
	public var userStats: UserStats
	
	public struct SLA: Codable {
		var calculatedQuota: Int64?
	}
	
	public struct UserStats: Codable {
		var foldersSize: Int64
	}
	
	public var abbreviation: String {
		"\(firstName.first!)\(lastName.first!)".uppercased()
	}
}
