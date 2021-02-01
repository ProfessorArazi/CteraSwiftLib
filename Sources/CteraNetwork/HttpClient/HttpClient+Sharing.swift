//
//  HttpClient+Sharing.swift
//  
//
//  Created by Gal Yedidovich on 31/01/2021.
//

import Foundation
import CteraUtil
import CteraModels

extension HttpClient {
	public static func requestPublicLinks(for item: ItemInfoDto, handler: @escaping Handler<[PublicLinkDto]>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.getPublicLinks(at: item.path))
		
		handle(request: req, { try [PublicLinkDto].fromFormatted(json: $0, dateStrategy: .expirationStrategy) }, handler: handler)
	}
	
	public static func createPublicLink(with link: PublicLinkDto, handler: @escaping Handler<PublicLinkDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.createPublicLink(from: link))
		
		handle(request: req, { try PublicLinkDto.fromFormatted(json: $0, dateStrategy: .expirationStrategy) }, handler: handler)
	}
	
	public static func modifyPublicLink(with link: PublicLinkDto, remove: Bool, handler: @escaping Handler<Data>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.modifyPublicLink(from: link, remove: remove))
		
		handle(request: req, handler: handler)
	}
	
	public static func requestCollaboration(for item: ItemInfoDto, handler: @escaping Handler<CollaborationDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.listShares(for: item.path))
		
		handle(request: req, { try CollaborationDto.fromFormatted(json: $0, dateStrategy: .expirationStrategy) }, handler: handler)
	}
	
	public static func saveCollaboration(at path: String, _ collaboration: CollaborationDto, handler: @escaping Handler<Data>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.saveCollaboration(at: path, collaboration))
		
		handle(request: req, handler: handler)
	}
	
	public static func validateCollaborator(for item: ItemInfoDto, invitee: CollaboratorDto, handler: @escaping Handler<CollaborationPolicyDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.verifyCollaborator(for: item, invitee))
		
		handle(request: req, CollaborationPolicyDto.fromFormatted(json:), handler: handler)
	}
	
	public static func searchCollaborators(query: String, type: String, uid: Int, count: Int = 25, handler: @escaping Handler<CollaborationSearchResultDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.searchCollaborators(query, type, uid, count))
		
		handle(request: req, CollaborationSearchResultDto.fromFormatted(json:), handler: handler)
	}
	
	public static func leaveShared(items: [ItemInfoDto], handler: @escaping Handler<Data>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.leaveShared(items: items))
		
		handle(request: req, handler: handler)
	}
}
