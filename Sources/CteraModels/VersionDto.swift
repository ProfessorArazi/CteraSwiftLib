//
//  VersionDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct VersionDto: Codable, Equatable {
	public var timestamp: Date = Date()
	public var fullUrl: String = ""
	public var modifier: String = ""
	public var current: Bool = false
	public var restorable: Bool = false
	public var deleted: Bool = false
	public var size: Int64 = 0
	public var relativeTimeStr: String = ""
	public var snapshotTimeStr: String = ""
	public var lastActionBy = LastActionDto()
	
	public init() {}
	
	private enum CodingKeys: String, CodingKey {
		case timestamp
		case fullUrl
		case modifier
		case current
		case restorable
		case deleted
		case size = "getcontentlength"
		case relativeTimeStr = "fileRelativeTime"
		case snapshotTimeStr = "snapshotTime"
		case lastActionBy
	}
}
