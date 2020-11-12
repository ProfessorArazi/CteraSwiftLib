//
//  BgTaskDto.swift
//  
//
//  Created by Gal Yedidovich on 12/11/2020.
//

import Foundation
public struct BgTaskDto: Codable {
	public let id: Int
	public let status: String
	public let errorType: String?
	public let userUid: Int
	public let name: String
	public let progstring: String
	public let cursor: Cursor
	public let startTime: Date
	public let endTime: Date?
	public let bytesProcessed: Int64
	public let filesProcessed: Int64
	public let totalBytes: Int64
	public let totalFiles: Int64
	public let percentage: Int
	public let elapsedTime: Int
	
	public struct Cursor: Codable {
		public let totalBytes: Int64
		public let totalFiles: Int64
		public let upperLevelUrl: String
		public let bytesCount: Int64
		public let filesCount: Int64
		public let destResource: ItemInfoDto?
		public let srcResource: ItemInfoDto?
		public let newSuggestedName: String?
		public let newSuggestedNameDate: String?
	}
}
