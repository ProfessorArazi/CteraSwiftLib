//
//  CollaboratorDto.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

import Foundation
public struct CollaboratorDto: Codable, Hashable, Equatable {
	private let className = "Collaborator"
	public var type: CollaboratorType = .localUser
	public var uid: Int?
	public var email: String?
	public var firstName: String?
	public var lastName: String?
	public var name: String?
	public var frequentlyUsed: Bool = false
	public var userAvatarName: String?
	public var domain: String?
	public var dn: String?
	
	public init() {}
	
	private enum CodingKeys: String, CodingKey {
		case className = "$class"
		case type
		case uid
		case email
		case firstName
		case lastName
		case name
		case frequentlyUsed
		case userAvatarName
		case domain
		case dn
	}
}
