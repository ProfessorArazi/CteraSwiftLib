//
//  FetchRequest.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import BasicExtensions
import StorageExtensions

public struct FetchRequest {
	static var includeDeleted = Prefs.standard.bool(key: .SHOW_DELETED)
	static var sortAscending = Prefs.standard.bool(key: .SORT_ASCENDING, fallback: true)
	
	var path: String
	var cachePath: String? = nil
	var folderType = "Personal"
	var passPhrase: String? = nil
	var depth: String = "1"
	var userPassword: String? = nil
	var query: String? = nil
	var withCache = true
	var includeShared = false
	var navigationPane = false
	var startIndex = 0
	
	init(path: String) {
		self.path = path
	}
	
	func toJson() -> JsonObject {
		var param = JsonObject().put(key: "$class", "FetchResourcesParam")
			.put(key: "root", path)
			.put(key: "depth", depth)
			.put(key: "includeDeleted", Self.includeDeleted)
			.put(key: "sharedItems", includeShared)
			.put(key: "quickNavigationPane", navigationPane)
			.put(key: "cloudFolderType", [folderType])
			.put(key: "start", startIndex)
			.put(key: "limit", 200)
			.put(key: "sort", [JsonObject().put(key: "$class", "Sort")
								.put(key: "field", SortMethod.stored.rawValue)
								.put(key: "ascending", Self.sortAscending)])
		
		if includeShared { param["ownedBy"] = -1 }
		if let pass = userPassword { param["userPassword"] = pass }
		if let query = query { param["searchCriteria"] = query }
		if let passPhrase = passPhrase { param["passphrase"] = passPhrase }
		
		return JsonObject().put(key: "type", "user-defined").put(key: "name", "fetchResources").put(key: "param", param);
	}
	
	func with(cachePath: String) -> FetchRequest {
		var copy = self
		copy.cachePath = cachePath
		return copy
	}
	
	func with(folderType: String) -> FetchRequest {
		var copy = self
		copy.folderType = folderType
		return copy
	}
	
	func with(passPhrase: String) -> FetchRequest {
		var copy = self
		copy.passPhrase = passPhrase
		return copy
	}
	
	func with(depth: String) -> FetchRequest {
		var copy = self
		copy.depth = depth
		return copy
	}
	
	func with(userPassword: String) -> FetchRequest {
		var copy = self
		copy.userPassword = userPassword
		return copy
	}
	
	func with(query: String) -> FetchRequest {
		var copy = self
		copy.query = query
		return copy
	}
	
	func with(withCache: Bool) -> FetchRequest {
		var copy = self
		copy.withCache = withCache
		return copy
	}
	
	func with(includeShared: Bool) -> FetchRequest {
		var copy = self
		copy.includeShared = includeShared
		return copy
	}
	
	func with(startIndex: Int) -> FetchRequest {
		var copy = self
		copy.startIndex = startIndex
		return self
	}
	
	func with(navigationPane: Bool) -> FetchRequest {
		var copy = self
		copy.navigationPane = navigationPane
		return self
	}
}

public enum SortMethod: String, CaseIterable {
	case Name = "name", Size = "size", Modified = "lastmodified"
	
	///Gets and sets the current SortMethod stored in Prefs.standard
	/// - Returns: Current SortMethod in Preferences or `Name` as default
	static var stored: SortMethod {
		set {
			Prefs.standard.edit().put(key: .SORT_METHOD, newValue.rawValue).commit()
		}
		get {
			guard let methodStr = Prefs.standard.string(key: .SORT_METHOD) else { return .Name }
			return SortMethod(rawValue: methodStr) ?? .Name
		}
	}
}
