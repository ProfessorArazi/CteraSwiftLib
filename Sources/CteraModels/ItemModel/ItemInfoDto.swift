//
//  ItemInfoDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct ItemInfoDto: Codable, Equatable, Hashable {
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
	public var actions = AllowedActionsDto()
	public var itemPermission: ItemPermissionDto = .None
	public var cloudFolderInfo: CloudFolderInfoDto?
	public var lastActionBy: LastActionDto?
	
	public init() { }
	
	public init(path: String, isFolder: Bool = false) {
		self.path = path
		self.name = path.suffix(from: "/")!.removingPercentEncoding!
		self.ext = path.suffix(from: ".")
		self.isFolder = isFolder
	}
	
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
