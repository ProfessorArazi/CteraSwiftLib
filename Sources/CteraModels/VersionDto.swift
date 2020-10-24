//
//  VersionDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct VersionDto: Codable, Equatable {
	let timestamp: String
	let fullUrl: String
	let modifier: String
	let restorable: Bool
	let deleted: Bool
	let size: Int64
	let relativeTime: String
	
	enum CodingKeys: String, CodingKey {
		case timestamp
		case fullUrl
		case modifier
		case restorable
		case deleted
		case size = "getcontentlength"
		case relativeTime = "fileRelativeTime"
	}
}
