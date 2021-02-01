//
//  File.swift
//  
//
//  Created by Gal Yedidovich on 31/01/2021.
//

import Foundation
public enum Errors: LocalizedError {
	case offline
	case text(String)
	
	public var errorDescription: String? {
		switch self {
		case .offline: return .noConnectionMsg
		case .text(let msg): return msg
		}
	}
}

public enum PreviewError: String, LocalizedError {
	case fileTooBig = "FileTooBig"
	case noPreviewServer = "NoPreviewServer"
	case typeNotSupported = "TypeNotSupported"
	case notAFile = "NotAFile"
	case noPermission = "NoPermission"
	case unknown = "UnknownError"
	case none = "None"
}
