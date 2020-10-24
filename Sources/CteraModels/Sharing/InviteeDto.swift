//
//  InviteeDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

import Foundation
public struct InviteeDto: Codable {
	public let uid: String
	public let type: CollaboratorType
	public let email: String?
	public let firstName: String?
	public let lastName: String?
	public let name: String?
	public let frequentlyUsed: Bool
	public let userAvatarName: String?
}
