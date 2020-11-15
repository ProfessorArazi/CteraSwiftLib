//
//  PreviewStatusDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public struct PreviewStatusDto: Codable, Equatable, Hashable {
	public var preview: Bool
	public var failure: String
	
	public init(preview: Bool, failure: String) {
		self.preview = preview
		self.failure = failure
	}
}
