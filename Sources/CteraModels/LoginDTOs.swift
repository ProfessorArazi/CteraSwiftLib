//
//  LoginDTOs.swift
//  
//
//  Created by Gal Yedidovich on 24/10/2020.
//

public struct PublicInfoDto: Decodable {
	public let hasWebSSO: Bool
}

public struct CredentialsDto: Decodable {
	public let deviceUID: String
	public let sharedSecret: String
}
