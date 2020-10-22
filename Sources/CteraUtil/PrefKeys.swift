//
//  PrefKeys.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import StorageExtensions

public extension PrefKey {
	static let SERVER_ADDRESS =					PrefKey(value: "-----_")
	static let SHARED_SECRET =					PrefKey(value: "----__")
	static let DEVICE_ID =						PrefKey(value: "---___")
	static let USER_REF =						PrefKey(value: "--____")
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
	static let SHOW_DELETED =                   PrefKey(value: "___________")
	static let SORT_ASCENDING =                 PrefKey(value: "____________")
	static let SORT_METHOD =                    PrefKey(value: "_____________")
//
//	//passcode
//	static let PASSCODE =                       PrefKey(value: "______________")
//	static let PASSCODE_REMAINING =             PrefKey(value: "_______________")
//	//recent searches
//	//	static let RECENT_SEARCHES =				PrefKey(value: "________________")
//
//	//info
//	//	static let PORTAL_VERSION = 				PrefKey(value: "_________________")
//	static let HAS_WEB_SSO =					PrefKey(value: "__________________")
//	static let ITEM_VIEW_MODE =					PrefKey(value: "___________________")
//	//	static let COMMON_PATH =					PrefKey(value: "____________________")
//
	static let USER_SETTINGS =					PrefKey(value: "_____________________")
	static let USERS_FOLDER_ITEM =				PrefKey(value: "______________________")
	static let SHARED_WITH_ME_ITEM =			PrefKey(value: "_______________________")
	static let SHOW_SHARED_BY_ME =				PrefKey(value: "________________________")
	static let HOME_FOLDER_ITEM =				PrefKey(value: "_________________________")
//
//	//	static let MIGRATED =						PrefKey(value: "__________________________")
//	static let JAILBREAK_DETECTED =				PrefKey(value: "___________________________")
	static let TIME_ZONE_DIFF =					PrefKey(value: "____________________________")
//
//	static let PASSCODE_LENGTH = 				PrefKey(value: "___________________________-")
//	static let APP_VERSION = 					PrefKey(value: "__________________________--")
	static let TRUSTED_CERTIFICATE = 			PrefKey(value: "_________________________---")
	static let INVITATION_MAX_DURATION = 		PrefKey(value: "________________________----")
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
