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
	public let currentSession: CurrentSession
	public let currentTime: CurrentTime
	public let general: General
	
	public init(currentSession: CurrentSession, currentTime: CurrentTime, general: General) {
		self.currentSession = currentSession
		self.currentTime = currentTime
		self.general = general
	}
	
	public struct CurrentSession: Codable {
		public let userRef: String
		public let showSharedByMe: Bool
		
		public init(userRef: String, showSharedByMe: Bool) {
			self.userRef = userRef
			self.showSharedByMe = showSharedByMe
		}
	}
	
	public struct CurrentTime: Codable {
		public let LocalTime: String
		public let GMTTime: String
		
		public init(LocalTime: String, GMTTime: String) {
			self.LocalTime = LocalTime
			self.GMTTime = GMTTime
		}
	}
	
	public struct General: Codable {
		public let invitationSettings: InvitationSettingsDto
		
		public init(invitationSettings: InvitationSettingsDto) {
			self.invitationSettings = invitationSettings
		}
	}
}
