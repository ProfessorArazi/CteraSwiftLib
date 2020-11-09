//
//  InviteeDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

import Foundation
public struct InviteeDto: Codable {
	public let uid: Int
	public let type: CollaboratorType
	public let email: String?
	public let firstName: String?
	public let lastName: String?
	public let name: String?
	public let frequentlyUsed: Bool
	public let userAvatarName: String?
	
	public init(uid: Int, type: CollaboratorType = .localUser, email: String? = nil,
				firstName: String? = nil, lastName: String? = nil,
				name: String? = nil, frequentlyUsed: Bool = false, userAvatarName: String? = nil) {
		self.uid = uid
		self.type = type
		self.email = email
		self.firstName = firstName
		self.lastName = lastName
		self.name = name
		self.frequentlyUsed = frequentlyUsed
		self.userAvatarName = userAvatarName
	}
}
