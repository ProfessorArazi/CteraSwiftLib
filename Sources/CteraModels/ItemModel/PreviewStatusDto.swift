//
//  PreviewStatusDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct PreviewStatusDto: Codable, Equatable {
	public var preview: Bool
	public var failure: String
}
