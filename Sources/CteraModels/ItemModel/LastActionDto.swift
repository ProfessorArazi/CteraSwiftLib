//
//  LastActionDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public struct LastActionDto: Codable, Equatable, Hashable {
	public var user: String = ""
	public var action: String = ""
	
	public init() {}
}
