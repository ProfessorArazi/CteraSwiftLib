//
//  FetchRequest.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import BasicExtensions
import StorageExtensions

class FetchRequest {
	static var includeDeleted = Prefs.standard.bool(key: .SHOW_DELETED)
	static var sortAscending = Prefs.standard.bool(key: .SORT_ASCENDING, fallback: true)
	
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
	
	func set(cachePath: String) -> FetchRequest {
		self.cachePath = cachePath
		return self
	}
	
	func set(folderType: String) -> FetchRequest {
		self.folderType = folderType
		return self
	}
	
	func set(passPhrase: String) -> FetchRequest {
		self.passPhrase = passPhrase
		return self
	}
	
	func set(depth: String) -> FetchRequest {
		self.depth = depth
		return self
	}
	
	func set(userPassword: String) -> FetchRequest {
		self.userPassword = userPassword
		return self
	}
	
	func set(query: String) -> FetchRequest {
		self.query = query
		return self
	}
	
	func set(withCache: Bool) -> FetchRequest {
		self.withCache = withCache
		return self
	}
	
	func set(includeShared: Bool) -> FetchRequest {
		self.includeShared = includeShared
		return self
	}
	
	func set(startIndex: Int) -> FetchRequest {
		self.startIndex = startIndex
		return self
	}
	
	func set(navigationPane: Bool) -> FetchRequest {
		self.navigationPane = navigationPane
		return self
	}
}

enum SortMethod: String, CaseIterable {
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
