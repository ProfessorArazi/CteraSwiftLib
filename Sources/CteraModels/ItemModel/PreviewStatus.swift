//
//  PreviewStatus.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct PreviewStatus: Codable, Equatable {
	public var preview: Bool
	public var failure: String
}
