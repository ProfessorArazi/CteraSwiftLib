//
//  PublicLinkDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct PublicLinkDto: Codable {
	public var href: String
	public var isFolder: Bool

	public var id: String!
	public var key: String!
	public var protectionLevel: String!
	public var link: String!
	public var resourceName: String!
	public var permission: ItemPermissionDto!

	public var expiration: Date?
	public var creationDate: Date?
}