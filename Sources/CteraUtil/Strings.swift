//
//  File.swift
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
	
	//MARK: - Permissions
	static let permissionPreviewOnly = "permissionPreviewOnly".localizedModule
	static let permissionReadOnly = "permissionReadOnly".localizedModule
	static let permissionReadWrite = "permissionReadWrite".localizedModule
	static let permissionDenied = "permissionDenied".localizedModule
	
	internal var localizedModule: String {
		NSLocalizedString(self, bundle: Bundle.module, comment: self)
	}
}
