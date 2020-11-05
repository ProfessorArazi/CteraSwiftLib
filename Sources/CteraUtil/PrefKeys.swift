//
//  PrefKeys.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import StorageExtensions

public extension PrefKey {
	static let serverAddress = 			PrefKey(value: "___________________________")
	static let credentials = 			PrefKey(value: "__________________________-")
	static let showDeleted =  			PrefKey(value: "_________________________--")
	static let sortAscending =  		PrefKey(value: "________________________---")
	static let sortMethod =  			PrefKey(value: "_______________________----")
	static let hasWebSso =				PrefKey(value: "______________________-----")
	static let userSettings =			PrefKey(value: "_____________________------")
	static let navigationItems =		PrefKey(value: "____________________-------")
	static let sessionInfo =			PrefKey(value: "___________________--------")
	static let appVersion =				PrefKey(value: "__________________---------")
	static let trustedCertificate =		PrefKey(value: "_________________----------")
}
