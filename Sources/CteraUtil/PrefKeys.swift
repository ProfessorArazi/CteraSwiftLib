//
//  PrefKeys.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import StorageExtensions

public extension PrefKey {
	static let serverAddress =					PrefKey(value: "-----_")
	static let sharedSecret =					PrefKey(value: "----__")
	static let deviceId =						PrefKey(value: "---___")
	static let userRef =						PrefKey(value: "--____")
//	static let PASSCODE_MODE =					PrefKey(value: "-_____")
//
//	//Offline Access Settings
//	static let USE_CELLULAR =                   PrefKey(value: "______")
//	static let UPDATE_MIN_BATTERY_PERCENTAGE =  PrefKey(value: "_______")
//	static let UPDATE_MIN_BATTERY_ACTIVE =      PrefKey(value: "________")
//	static let UPDATE_INTERVAL =                PrefKey(value: "_________")
//	static let UPDATE_INTERVAL_ACTIVE =         PrefKey(value: "__________")
//
//	//browser settings
	static let showDeleted =                   PrefKey(value: "___________")
	static let sortAscending =                 PrefKey(value: "____________")
	static let sortMethod =                    PrefKey(value: "_____________")
//
//	//passcode
//	static let PASSCODE =                       PrefKey(value: "______________")
//	static let PASSCODE_REMAINING =             PrefKey(value: "_______________")
//	//recent searches
//	//	static let RECENT_SEARCHES =				PrefKey(value: "________________")
//
//	//info
//	//	static let PORTAL_VERSION = 				PrefKey(value: "_________________")
	static let hasWebSso =					PrefKey(value: "__________________")
//	static let ITEM_VIEW_MODE =					PrefKey(value: "___________________")
//	//	static let COMMON_PATH =					PrefKey(value: "____________________")
//
	static let userSettings =					PrefKey(value: "_____________________")
	static let navigationItems =				PrefKey(value: "______________________")
//	static let SHARED_WITH_ME_ITEM =			PrefKey(value: "_______________________")
//	static let HOME_FOLDER_ITEM =				PrefKey(value: "_________________________")
	static let showSharedByMe =				PrefKey(value: "________________________")
//
//	//	static let MIGRATED =						PrefKey(value: "__________________________")
//	static let JAILBREAK_DETECTED =				PrefKey(value: "___________________________")
	static let timeZoneDiff =					PrefKey(value: "____________________________")
//
//	static let PASSCODE_LENGTH = 				PrefKey(value: "___________________________-")
	static let appVersion = 					PrefKey(value: "__________________________--")
	static let trustedCertificate = 			PrefKey(value: "_________________________---")
	static let invitationMaxDuration = 		PrefKey(value: "________________________----")
//	static let BIO_AUTH_ALLOWED = 				PrefKey(value: "_______________________-----")
//	static let BIO_AUTH_FAILED = 				PrefKey(value: "______________________------")
//	static let SHORCUTS = 						PrefKey(value: "_____________________-------")
//	//	static let ACTIVITY = 						PrefKey(value: "____________________--------")
//
//	static let FIRST_LOGIN_DATE =				PrefKey(value: "___________________---------")
//	static let LAST_REVIEW_REQ_DATE =			PrefKey(value: "__________________----------")
//	static let REVIEW_REQ_TIMES =				PrefKey(value: "_________________-----------")
//	static let LAST_REVIEW_REQ_VERSION =		PrefKey(value: "________________------------")
}
