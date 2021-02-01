//
//  File.swift
//  
//
//  Created by Gal Yedidovich on 01/02/2021.
//

import Foundation

public struct GlobalStatusDto: Codable {
	public let className: String
	public let status: Status
	
	private enum CodingKeys: String, CodingKey {
		case className = "$class"
		case status = "globalSystemStatus"
	}
	
	public enum Status: String, Codable {
		case ok = "OK"
		case readOnly = "ReadOnly"
	}
}

