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
	
	//MARK: - Protection Level
	static let publicLink = "publicLink".localizedModule
	static let email = "email".localizedModule
	static let sms = "sms".localizedModule

	//MARK: - Error Messages
	static let noConnectionMsg = "noConnectionMsg".localizedModule
	static let fileNotFoundErrorMsg = "fileNotFoundErrorMsg".localizedModule
	static let previewOnlyError = "previewOnlyError".localizedModule
	static let cannotDownloadFileError = "cannotDownloadFileError".localizedModule
	static let invalidUsernameError = "invalidUsernameError".localized
	
//	static let  = "".localizedModule

	internal var localizedModule: String {
		NSLocalizedString(self, bundle: .module, comment: self)
	}
}
