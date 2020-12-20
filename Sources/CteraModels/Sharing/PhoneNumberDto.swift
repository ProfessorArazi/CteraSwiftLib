//
//  PhoneNumberDto.swift
//  
//
//  Created by Gal Yedidovich on 20/12/2020.
//

import Foundation
public struct PhoneNumberDto: Codable, Hashable {
	private let className = "CteraPhoneNumber"
	public var phoneNumber: String
	public var nationalFormat: String?
	public var phoneNumberRegion: String?
	
	public init(phoneNumber: String = "") {
		self.phoneNumber = phoneNumber
	}
	
	private enum CodingKeys: String, CodingKey {
		case className = "$class"
		case phoneNumber
		case nationalFormat
		case phoneNumberRegion
	}
}
