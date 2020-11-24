//
//  PreviewStatusDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct PreviewStatusDto: Codable, Equatable, Hashable {
	public var preview: Bool = false
	public var failure: String = ""
	
	public init() {}
}
