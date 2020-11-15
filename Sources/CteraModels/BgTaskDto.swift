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
	
	public init(id: Int = 0, status: String = "", errorType: String? = nil,
				userUid: Int = 0, name: String = "", progstring: String = "",
				cursor: Cursor = Cursor(), startTime: Date = Date(), endTime: Date? = nil,
				bytesProcessed: Int64 = 0, filesProcessed: Int64 = 0,
				totalBytes: Int64 = 0, totalFiles: Int64 = 0,
				percentage: Int = 0, elapsedTime: Int = 0) {
		self.id = id
		self.status = status
		self.errorType = errorType
		self.userUid = userUid
		self.name = name
		self.progstring = progstring
		self.cursor = cursor
		self.startTime = startTime
		self.endTime = endTime
		self.bytesProcessed = bytesProcessed
		self.filesProcessed = filesProcessed
		self.totalBytes = totalBytes
		self.totalFiles = totalFiles
		self.percentage = percentage
		self.elapsedTime = elapsedTime
	}
	
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
		
		public init(totalBytes: Int64 = 0, totalFiles: Int64 = 0, upperLevelUrl: String = "",
					bytesCount: Int64 = 0, filesCount: Int64 = 0,
					destResource: ItemInfoDto? = nil, srcResource: ItemInfoDto? = nil,
					newSuggestedName: String? = nil, newSuggestedNameDate: String? = nil) {
			self.totalBytes = totalBytes
			self.totalFiles = totalFiles
			self.upperLevelUrl = upperLevelUrl
			self.bytesCount = bytesCount
			self.filesCount = filesCount
			self.destResource = destResource
			self.srcResource = srcResource
			self.newSuggestedName = newSuggestedName
			self.newSuggestedNameDate = newSuggestedNameDate
		}
	}
}
