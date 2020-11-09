//
//  CollaborationSearchResultDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

public struct CollaborationSearchResultDto: Codable {
	public let objects: [CollaboratorDto]
	public let hasMore: Bool
	
	public init(objects: [CollaboratorDto], hasMore: Bool) {
		self.objects = objects
		self.hasMore = hasMore
	}
}
