//
//  CollaborationSearchResultDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

public struct CollaborationSearchResultDto: Codable {
	public let objects: [InviteeDto]
	public let hasMore: Bool
}
