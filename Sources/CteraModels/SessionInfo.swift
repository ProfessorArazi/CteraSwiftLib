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
	
	public struct CurrentSession: Codable {
		public let userRef: String
		public let showSharedByMe: Bool
	}
	
	public struct CurrentTime: Codable {
		public let LocalTime: String
		public let GMTTime: String
	}
	
	public struct General: Codable {
		public let invitationSettings: InvitationSettingsDto
	}
}
