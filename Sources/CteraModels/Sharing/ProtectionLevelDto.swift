//
//  ProtectionLevelDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

import Foundation
public enum ProtectionLevelDto: String, Codable { //2 step verification types
	case publicLink, textMessage, email
	
	public var prettyString: String {
		switch self {
		case .publicLink: 	return .publicLink
		case .textMessage:	return .sms
		case .email:		return .email
		}
	}
}
