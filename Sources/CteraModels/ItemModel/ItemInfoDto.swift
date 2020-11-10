//
//  ItemInfoDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct ItemInfoDto: Codable, Equatable {
	public var path: String = ""
	public var name: String = ""
	public var ext: String?
	public var scope: String = ""
	
	public var isShared: Bool = false
	public var hasLinks: Bool = false
	public var isFolder: Bool = false
	public var isDeleted: Bool = false
	
	public var lastModified: Date?
	public var size: Int64?
	public var actions: AllowedActionsDto?
	public var itemPermission: ItemPermissionDto?
	public var cloudFolderInfo: CloudFolderInfoDto?
	public var lastActionBy: LastActionDto?
	
	private enum CodingKeys: String, CodingKey {
		case name
		case path = "href"
		case ext = "extension"
		case scope
		case lastModified = "lastmodified"
		case isShared
		case hasLinks
		case isFolder
		case isDeleted
		case size
		case actions = "actionsAllowed"
		case itemPermission = "permission"
		case cloudFolderInfo
		case lastActionBy
	}
	
	public init() { }
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		
		self.name = try values.decode(String.self, forKey: .name)
		self.path = try values.decode(String.self, forKey: .path)
		self.ext = try values.decodeIfPresent(String.self, forKey: .ext)
		self.scope = try values.decode(String.self, forKey: .scope)
		
		self.isShared = try values.decode(Bool.self, forKey: .isShared)
		self.hasLinks = try values.decode(Bool.self, forKey: .hasLinks)
		self.isFolder = try values.decode(Bool.self, forKey: .isFolder)
		self.isDeleted = try values.decode(Bool.self, forKey: .isDeleted)
		
		self.size = try values.decodeIfPresent(Int64.self, forKey: .size)
		self.actions = try values.decodeIfPresent(AllowedActionsDto.self, forKey: .actions)
		self.itemPermission = try values.decodeIfPresent(ItemPermissionDto.self, forKey: .itemPermission)
		self.cloudFolderInfo = try values.decodeIfPresent(CloudFolderInfoDto.self, forKey: .cloudFolderInfo)
		self.lastActionBy = try values.decodeIfPresent(LastActionDto.self, forKey: .lastActionBy)
		
		//all for this
		if let lastModified = try values.decodeIfPresent(String.self, forKey: .lastModified) {
			self.lastModified = DateFormatter.standardFormat.date(from: lastModified)
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(name, forKey: .name)
		try container.encode(path, forKey: .path)
		try container.encode(ext, forKey: .ext)
		try container.encode(scope, forKey: .scope)
		
		try container.encode(isShared, forKey: .isShared)
		try container.encode(hasLinks, forKey: .hasLinks)
		try container.encode(isFolder, forKey: .isFolder)
		try container.encode(isDeleted, forKey: .isDeleted)
		
		try container.encode(size, forKey: .size)
		try container.encode(actions, forKey: .actions)
		try container.encode(itemPermission, forKey: .itemPermission)
		try container.encode(cloudFolderInfo, forKey: .cloudFolderInfo)
		try container.encode(lastActionBy, forKey: .lastActionBy)
		
		if let lastModified = lastModified {
			let str = DateFormatter.standardFormat.string(from: lastModified)
			try container.encode(str, forKey: .lastModified)
		}
	}
	
	public var parentPath: String {
		String(path.prefix(upTo: path.lastIndex(of: "/")!))
	}
}

public extension ItemInfoDto {
	static func format(lastModified: Date, timeDiff diff: Int) -> String {
		var date = lastModified
		let timezone = TimeZone.current.secondsFromGMT()
		
		date.addTimeInterval(TimeInterval(timezone - diff))
		
		if Calendar.current.isDateInToday(date) {
			let seconds = -date.timeIntervalSinceNow
			
			if seconds < 60 * 60 { //if less than hour ago - print in minutes
				if seconds < 60 { return .lessThanMinuteAgo }
				else if seconds < 120 { return .oneMinuteAgo }
				else { return .localizedStringWithFormat(.minutesAgo, Int(seconds / 60)) }
			} else { return .localizedStringWithFormat(.todayAt, DateFormatter.hourFormat.string(from: date)) }
		} else if Calendar.current.isDateInYesterday(date) {
			return .localizedStringWithFormat(.yesterdayAt, DateFormatter.hourFormat.string(from: date))
		} else {
			return DateFormatter.dayFormat.string(from: date)
		}
	}
}
