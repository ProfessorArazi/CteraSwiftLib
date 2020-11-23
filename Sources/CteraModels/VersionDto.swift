//
//  VersionDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct VersionDto: Codable, Equatable {
	public let timestamp: Date
	public let fullUrl: String
	public let modifier: String
	public let restorable: Bool
	public let deleted: Bool
	public let size: Int64
	public let relativeTime: Int64
	
	public init(timestamp: Date = Date(), fullUrl: String = "", modifier: String = "",
				restorable: Bool = false, deleted: Bool = false,
				size: Int64 = 0, relativeTime: Int64 = 0) {
		self.timestamp = timestamp
		self.fullUrl = fullUrl
		self.modifier = modifier
		self.restorable = restorable
		self.deleted = deleted
		self.size = size
		self.relativeTime = relativeTime
	}
	
	private enum CodingKeys: String, CodingKey {
		case timestamp
		case fullUrl
		case modifier
		case restorable
		case deleted
		case size = "getcontentlength"
		case relativeTime = "fileRelativeTime"
	}
}
