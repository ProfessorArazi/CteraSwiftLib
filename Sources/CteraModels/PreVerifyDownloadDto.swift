//
//  PreVerifyDownloadDto.swift
//  
//
//  Created by Loren Raz on 16/03/2021.
//

import Foundation

public struct PreVerifyDownloadDto: Codable, Hashable, Equatable {
	private let className = "PreVerifyDownloadFileResponse"
	public var status: PreVerifyDownloadFileRcDto
	public var message: String?

	
	private enum CodingKeys: String, CodingKey {
		case className = "$class"
		case status = "rc"
		case message = "msg"
	}
	
	public enum PreVerifyDownloadFileRcDto: String, Codable {
		case ok = "OK"
		case generalError = "GeneralError"
		case fileInfected = "FileIsInfected"
		case fileSensitive = "FileIsSensitive"
	}
}
