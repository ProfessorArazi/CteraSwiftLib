//
//  FetchRequestDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import BasicExtensions
import StorageExtensions

public struct FetchRequestDto {
	public static var includeDeleted = Prefs.standard.bool(key: .showDeleted)
	public static var sortAscending = Prefs.standard.bool(key: .sortAscending, fallback: true)
	
	private(set) var path: String
	private(set) var cachePath: String? = nil
	private(set) var folderType = "Personal"
	private(set) var passPhrase: String? = nil
	private(set) var depth: String = "1"
	private(set) var userPassword: String? = nil
	private(set) var query: String? = nil
	private(set) var withCache = true
	private(set) var includeShared = false
	private(set) var navigationPane = false
	private(set) var startIndex = 0
	
	public init(path: String) {
		self.path = path
	}
	
	public func toJson() -> JsonObject {
		var param = JsonObject().with(key: "$class", "FetchResourcesParam")
			.with(key: "root", path)
			.with(key: "depth", depth)
			.with(key: "includeDeleted", Self.includeDeleted)
			.with(key: "sharedItems", includeShared)
			.with(key: "quickNavigationPane", navigationPane)
			.with(key: "cloudFolderType", [folderType])
			.with(key: "start", startIndex)
			.with(key: "limit", 200)
			.with(key: "sort", [JsonObject().with(key: "$class", "Sort")
								.with(key: "field", SortMethod.stored.rawValue)
								.with(key: "ascending", Self.sortAscending)])
		
		if includeShared { param["ownedBy"] = -1 }
		if let pass = userPassword { param["userPassword"] = pass }
		if let query = query { param["searchCriteria"] = query }
		if let passPhrase = passPhrase { param["passphrase"] = passPhrase }
		
		return JsonObject().with(key: "type", "user-defined").with(key: "name", "fetchResources").with(key: "param", param);
	}
	
	public func with(cachePath: String) -> FetchRequestDto {
		var copy = self
		copy.cachePath = cachePath
		return copy
	}
	
	public func with(folderType: String) -> FetchRequestDto {
		var copy = self
		copy.folderType = folderType
		return copy
	}
	
	public func with(passPhrase: String) -> FetchRequestDto {
		var copy = self
		copy.passPhrase = passPhrase
		return copy
	}
	
	public func with(depth: String) -> FetchRequestDto {
		var copy = self
		copy.depth = depth
		return copy
	}
	
	public func with(userPassword: String) -> FetchRequestDto {
		var copy = self
		copy.userPassword = userPassword
		return copy
	}
	
	public func with(query: String) -> FetchRequestDto {
		var copy = self
		copy.query = query
		return copy
	}
	
	public func with(withCache: Bool) -> FetchRequestDto {
		var copy = self
		copy.withCache = withCache
		return copy
	}
	
	public func with(includeShared: Bool) -> FetchRequestDto {
		var copy = self
		copy.includeShared = includeShared
		return copy
	}
	
	public func with(startIndex: Int) -> FetchRequestDto {
		var copy = self
		copy.startIndex = startIndex
		return copy
	}
	
	public func with(navigationPane: Bool) -> FetchRequestDto {
		var copy = self
		copy.navigationPane = navigationPane
		return copy
	}
}

public enum SortMethod: String, CaseIterable {
	case Name = "name", Size = "size", Modified = "lastmodified"
	
	///Gets and sets the current SortMethod stored in Prefs.standard
	/// - Returns: Current SortMethod in Preferences or `Name` as default
	public static var stored: SortMethod {
		set {
			Prefs.standard.edit().put(key: .sortMethod, newValue.rawValue).commit()
		}
		get {
			guard let methodStr = Prefs.standard.string(key: .sortMethod) else { return .Name }
			return SortMethod(rawValue: methodStr) ?? .Name
		}
	}
}
