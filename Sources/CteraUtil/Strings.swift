//
//  Strings.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public extension String {
	//MARK: - General
	static let on = "on".localizedModule
	static let yes = "yes".localizedModule
	static let off = "off".localizedModule
	static let error = "error".localizedModule
	static let ok = "ok".localizedModule
	static let trust = "trust".localizedModule

	//MARK: - Sizes
	static let zeroBytes = "zeroBytes".localizedModule
	static let oneByte = "oneByte".localizedModule
	static let bytes = "bytes".localizedModule
	static let kb = "kb".localizedModule
	static let mb = "mb".localizedModule
	static let gb = "gb".localizedModule
	static let tb = "tb".localizedModule
	static let pb = "pb".localizedModule

	//MARK: - Pretty Time
	static let lessThanMinuteAgo = "lessThanMinuteAgo".localizedModule
	static let oneMinuteAgo = "oneMinuteAgo".localizedModule
	static let minutesAgo = "minutesAgo".localizedModule
	static let todayAt = "todayAt".localizedModule
	static let yesterdayAt = "yesterdayAt".localizedModule

	//MARK: - Permissions
	static let permissionPreviewOnly = "permissionPreviewOnly".localizedModule
	static let permissionReadOnly = "permissionReadOnly".localizedModule
	static let permissionReadWrite = "permissionReadWrite".localizedModule
	static let permissionDenied = "permissionDenied".localizedModule

	//MARK: - Error Messages
	static let noConnectionMsg = "noConnectionMsg".localizedModule
	static let fileNotFoundErrorMsg = "fileNotFoundErrorMsg".localizedModule
	
//	static let  = "".localizedModule

	internal var localizedModule: String {
		NSLocalizedString(self, bundle: .module, comment: self)
	}
}
