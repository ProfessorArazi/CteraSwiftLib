//
//  SessionInfoDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//
import Foundation
import BasicExtensions
import StorageExtensions
import CteraUtil

public struct SessionInfoDto: Codable {
	public var currentSession = CurrentSession()
	public var currentTime = CurrentTime()
	public var general = General()
	
	public init() {}
	
	public struct CurrentSession: Codable {
		public var userRef: String = ""
		public var showSharedByMe: Bool = false
		
		public init() {}
	}
	
	public struct CurrentTime: Codable {
		public var LocalTime: String = ""
		public var GMTTime: String = ""
		
		public init() {}
	}
	
	public struct General: Codable {
		public var invitationSettings = InvitationSettingsDto()
		
		public init() {}
	}
}
