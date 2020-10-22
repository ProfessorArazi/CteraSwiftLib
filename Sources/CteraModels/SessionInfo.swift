//
//  File.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//
import Foundation
import BasicExtensions
import StorageExtensions
import CteraUtil

public enum SessionInfo {
	private static let TAG = String(describing: SessionInfo.self)
	public static var userRef: String!
	public static var timeZoneDiff: Int!
	public static var showSharedByMe: Bool!
	public static var invitationMaxDuration: Int!
	
	public static func load(json: JsonObject) {
		Console.log(tag: Self.TAG, msg: #function)
		let currentSession = json.jsonObject(key: "currentSession")!
		userRef = currentSession.string(key: "userRef")
		
		showSharedByMe = currentSession.bool(key: "showSharedByMe")
		
		let currentTime = json.jsonObject(key: "currentTime")!
		let format = DateFormatter()
		format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		
		let localTime = format.date(from: currentTime.string(key: "LocalTime")!)!
		let gmtTime = format.date(from: currentTime.string(key: "GMTTime")!)!
		timeZoneDiff = Int(localTime.timeIntervalSince1970 - gmtTime.timeIntervalSince1970)
		
		invitationMaxDuration = json.jsonObject(key: "general")!.jsonObject(key: "invitationSettings")!.int(key: "invitationMaxValidityDuration") ?? -1
	}
	
	public static func save() {
		Console.log(tag: TAG, msg: #function)
		Prefs.standard.edit()
			.put(key: .USER_REF, userRef!)
			.put(key: .SHOW_SHARED_BY_ME, showSharedByMe)
			.put(key: .TIME_ZONE_DIFF, timeZoneDiff)
			.put(key: .INVITATION_MAX_DURATION, invitationMaxDuration)
			.commit()
	}
	
	public static func loadFromPrefs() {
		Console.log(tag: TAG, msg: #function)
		userRef = Prefs.standard.string(key: .USER_REF)
		showSharedByMe = Prefs.standard.bool(key: .SHOW_SHARED_BY_ME)
		timeZoneDiff = Prefs.standard.int(key: .TIME_ZONE_DIFF)
		invitationMaxDuration = Prefs.standard.int(key: .INVITATION_MAX_DURATION)
	}
	
	public static func reset() {
		Console.log(tag: Self.TAG, msg: #function)
		timeZoneDiff = 0
		invitationMaxDuration = 0
		userRef = nil
		showSharedByMe = false
	}
}
