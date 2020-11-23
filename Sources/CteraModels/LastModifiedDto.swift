//
//  LastModifiedDto.swift
//  
//
//  Created by Gal Yedidovich on 23/11/2020.
//

import Foundation

public struct LastModifiedDto: Codable {
	public var status: String
	public var lastModified: Date?
	public var folderUID: Int
	public var path: String
	
	public init(status: String = "OK", lastModified: Date? = nil, folderUID: Int = 0, path: String = "") {
		self.status = status
		self.lastModified = lastModified
		self.folderUID = folderUID
		self.path = path
	}
}
