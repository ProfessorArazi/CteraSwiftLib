//
//  ProtectionLevelDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

import Foundation
public enum ProtectionLevelDto: String, Codable { //2 step verification types
	case publicLink, textMessage, email
}
