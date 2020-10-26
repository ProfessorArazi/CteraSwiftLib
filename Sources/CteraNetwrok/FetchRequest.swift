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
	
	public func with(cachePath: String) -> FetchRequest {
		var copy = self
		copy.cachePath = cachePath
		return copy
	}
	
	public func with(folderType: String) -> FetchRequest {
		var copy = self
		copy.folderType = folderType
		return copy
	}
	
	public func with(passPhrase: String) -> FetchRequest {
		var copy = self
		copy.passPhrase = passPhrase
		return copy
	}
	
	public func with(depth: String) -> FetchRequest {
		var copy = self
		copy.depth = depth
		return copy
	}
	
	public func with(userPassword: String) -> FetchRequest {
		var copy = self
		copy.userPassword = userPassword
		return copy
	}
	
	public func with(query: String) -> FetchRequest {
		var copy = self
		copy.query = query
		return copy
	}
	
	public func with(withCache: Bool) -> FetchRequest {
		var copy = self
		copy.withCache = withCache
		return copy
	}
	
	public func with(includeShared: Bool) -> FetchRequest {
		var copy = self
		copy.includeShared = includeShared
		return copy
	}
	
	public func with(startIndex: Int) -> FetchRequest {
		var copy = self
		copy.startIndex = startIndex
		return self
	}
	
	public func with(navigationPane: Bool) -> FetchRequest {
		var copy = self
		copy.navigationPane = navigationPane
		return self
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
