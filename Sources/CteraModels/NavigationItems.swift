//
//  NavigationItems.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//
//import CteraUtil
//import StorageExtensions
//
//public enum NavigationItems {
//	private static let TAG = String(describing: NavigationItems.self)
//	public static var sharedWithMe, usersFolder, homeFolder: ItemInfo?
//
//	public static func loadFromPrefs() {
//		Console.log(tag: Self.TAG, msg: #function)
//		sharedWithMe = Prefs.standard.codable(key: .SHARED_WITH_ME_ITEM)
//		usersFolder = Prefs.standard.codable(key: .USERS_FOLDER_ITEM)
//		homeFolder = Prefs.standard.codable(key: .HOME_FOLDER_ITEM)
//	}
//
//	public static func reset() {
//		Console.log(tag: Self.TAG, msg: #function)
//		sharedWithMe = nil
//		usersFolder = nil
//		homeFolder = nil
//	}
//}
