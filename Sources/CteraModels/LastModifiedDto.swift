//
//  LastModifiedDto.swift
//  
//
//  Created by Gal Yedidovich on 23/11/2020.
//

import Foundation

public struct LastModifiedDto: Codable {
	public var status: String = "OK"
	public var lastModified: Date?
	public var folderUID: Int = 0
	public var path: String = ""
	
	public init() {}
}
