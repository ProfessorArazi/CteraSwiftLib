//
//  StringFormatter.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
import BasicExtensions
import CteraModels

enum StringFormatter {
	
	static func attachMobileDevice(server: String, password pass: String?, activationCode code: String?, deviceID: String, deviceName: String) -> String {
		JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", "attachMobileDevice")
			.put(key: "param", JsonObject()
					.put(key: "$class", "AttachedMobileDeviceParams")
					.put(key: "hostname", deviceName)
					.put(key: "deviceMac", deviceID)
					.put(key: "deviceType", "Mobile")
					.put(key: "serverName", server)
					.put(key: "password", pass?.escaped ?? "")
					.put(key: "ssoActivationCode", code?.escaped ?? "")
			)
			.xmlString
	}
	
	static func login(with credentials: CredentialsDto) -> String {
		"j_username=device%5c\(credentials.deviceUID)&j_password=\(credentials.sharedSecret)"
	}
	
	static func updateMobileInfo(deviceID: String, deviceName: String) -> String {
		JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", "updateMobileInfo")
			.put(key: "param", JsonObject()
					.put(key: "$class", "UpdateMobileInfoParams")
					.put(key: "cteraMobileVersion", Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
					.put(key: "hostname", deviceName)
					.put(key: "platform", "iOS") //TODO: Check with PM (Ron)
					.put(key: "osName", ProcessInfo.processInfo.operatingSystemVersionString)
					.put(key: "uniqueId", deviceID)
			)
			.xmlString
	}
	
	static func getMulticommand() -> String {
		JsonObject()
			.put(key: "type", "db")
			.put(key: "name", "get-multi")
			.put(key: "param", ["/currentSession", "/currentTime", "/general"])
			.xmlString
	}
	
	static func createNewFolder(folderPath: String, folderName: String) -> String {
		JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", "makeCollection")
			.put(key: "param", JsonObject()
					.put(key: "$class", "makeCollectionParam")
					.put(key: "name", folderName.escaped)
					.put(key: "parentPath", folderPath.escaped)
			)
			.xmlString
	}
	
	static func multipartData(filePath: String) -> String {
		let line = "\r\n",
			boundary = "------MobileBoundaryRRD29pvBCUWyLIg",
			name = filePath.suffix(from: "/")!
		
		return "\(boundary)\(line)" +
			"Content-Disposition: form-data; name=\"fullpath\"\(line)\(line)" +
			"\(filePath)\(line)\(boundary)\(line)" +
			"Content-Disposition: form-data; name=\"Filename\"\(line)\(line)" +
			"\(name)\(line)\(boundary)\(line)" +
			"Content-Disposition: form-data; name=\"file\";filename=\"\(name)\"\(line)" +
			"Content-Type: application/octet-stream\(line)\(line)"
	}
	
	static func sourceDestCommand(with payload: SrcDestData) -> String {
		let urls = payload.pairs.map { pair in
			JsonObject()
				.put(key: "$class", "SrcDstParam")
				.put(key: "src", pair.src)
				.put(key: "dest", pair.dest)
		}
		var json = JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", payload.action)
			.put(key: "param", JsonObject()
					.put(key: "$class", "ActionResourcesParam")
					.put(key: "urls", urls)
			)
		
		if let taskJson = payload.taskJson {
			var cursor = taskJson.jsonObject(key: "cursor")!
			let handler = cursor.string(key: "handler")!
			
			if cursor.bool(key: "applyAll") ?? false { //add json properties to "apply all" request
				cursor.remove(key: "skipHandler")
					.put(key: "fileMoveConflictResolutaion", [
							JsonObject()
								.put(key: "$class", "FileMoveConflictResolutaion")
								.put(key: "errorType", taskJson.string(key: "errorType")!)
								.put(key: "handler", handler)
					])
			} else {
				cursor = cursor.put(key: "skipHandler", handler)
			}
			
			cursor = cursor.remove(key: "handler").remove(key: "applyAll")
			json = json.put(key: "startFrom", cursor)
		}
		return json.xmlString
	}
	
	static func getStatus(for task: String) -> String {
		JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", "getTaskStatus")
			.put(key: "param", task)
			.xmlString
	}
	
	//MARK: - public links
	static func getPublicLinks(at itemPath: String) -> String {
		JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", "listPublicShares")
			.put(key: "param", itemPath)
			.xmlString
	}
	
	static func createPublicLink(from link: PublicLinkDto) -> String {
		var shareJson: JsonObject = JsonObject()
			.put(key: "$class", "ShareConfig")
			.put(key: "accessMode", link.permission.rawValue)
			.put(key: "protectionLevel", "publicLink")
			.put(key: "invitee", JsonObject()
					.put(key: "$class", "Collaborator")
					.put(key: "type", "external")
			)
		
		if let experation = link.expiration {
			shareJson["expiration"] = experation
		}
		
		return JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", "createShare")
			.put(key: "param", JsonObject()
					.put(key: "$class", "CreateShareParam")
					.put(key: "url", link.href)
					.put(key: "share", shareJson)
			)
			.xmlString
	}
	
	static func modifyPublicLink(from link: PublicLinkDto, remove: Bool) -> String {
		let createDate = ItemInfoDto.standardFormat.string(from: link.creationDate!)
		var shareJson: JsonObject = JsonObject()
			.put(key: "$class", "Share")
			.put(key: "accessMode", link.permission.rawValue)
			.put(key: "canEdit", false)
			.put(key: "createDate", createDate)
			.put(key: "href", link.href.escaped)
			.put(key: "id", link.id!)
			.put(key: "isDirectory", link.isFolder)
			.put(key: "key", link.key!)
			.put(key: "protectionLevel", link.protectionLevel!)
			.put(key: "publicLink", link.link!)
			.put(key: "resourceName", link.resourceName!)
			.put(key: "isRemove", remove)
			.put(key: "invitee", JsonObject()
					.put(key: "$class", "Collaborator")
					.put(key: "type", "external")
			)
			
		if let expiration = link.expiration {
			shareJson["expiration"] = expiration
		}
		
		return JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", remove ? "deleteShare" : "updateShare")
			.put(key: "param", shareJson)
			.xmlString
	}
	
	//MARK: - Collaboration
	static func listShares(for path: String) -> String {
		JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", "listShares")
			.put(key: "param", path)
			.xmlString
	}
	
	static func saveCollaboration(at path: String, _ collaboration: CollaborationDto) -> String {
		var collJson = try! JsonObject(encodable: collaboration)

		if var shares = collJson.jsonArray(key: "shares") {
			for i in 0..<shares.count {
				let share = shares.jsonObject(at: i)!
					.put(key: "$class", "ShareConfig")

				shares[i] = share
			}
			
			collJson["shares"] = shares
		}
		
		return JsonObject()
			.put(key: "name", "shareResource")
			.put(key: "type", "user-defined")
			.put(key: "param", collJson
					.put(key: "$class", "ShareResourceParam")
					.put(key: "url", path)
			)
			.xmlString
	}
	
	static func verifyCollaborator(for item: ItemInfoDto, _ invitee: InviteeDto) -> String {
		JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", "preVerifySingleShare")
			.put(key: "param", JsonObject()
					.put(key: "$class", "PreVerifyShareParam")
					.put(key: "url", item.path)
					.put(key: "invitee", invitee)
			)
			.xmlString
	}
	
	static func searchCollaborators(_ query: String, _ type: String, _ uid: Int, _ count: Int) -> String {
		JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", "searchCollaborationMembers")
			.put(key: "param", JsonObject()
					.put(key: "searchType", type)
					.put(key: "searchTerm", query)
					.put(key: "resourceUid", uid)
					.put(key: "countLimit", count)
			)
			.xmlString
	}
	
	static func leaveShared(items: [ItemInfoDto]) -> String {
		JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", "leaveShare")
			.put(key: "param", items.map(\.path))
			.xmlString
	}
	
	static func fileVersions(for item: ItemInfoDto) -> String {
		JsonObject()
			.put(key: "name", "listVersions")
			.put(key: "param", item.path)
			.xmlString
	}
	
	static func lastModified(items: [ItemInfoDto]) -> String {
		JsonObject()
			.put(key: "type", "user-defined")
			.put(key: "name", "getLastModifiedOfFiles")
			.put(key: "param", items.map({ item in
				JsonObject()
					.put(key: "$class", "getLastModifiedOfFilesParam")
					.put(key: "folderUID", item.cloudFolderInfo!.uid)
					.put(key: "path", item.path)
			}))
			.xmlString
	}
}

fileprivate extension String {
	var escaped: String {
		self.replacingOccurrences(of: "&", with: "&amp;")
			.replacingOccurrences(of: "/\"", with: "&quot;")
			.replacingOccurrences(of: "'", with: "&apos;")
			.replacingOccurrences(of: "<", with: "&lt;")
			.replacingOccurrences(of: ">", with: "&gt;")
	}
}

internal extension JsonObject {
	
	/// build an XML body for HTTP request to server (until happy time when server accepts JSON).
	///
	/// The XML is built from converting this JSON object, current implementation is recursive.
	///
	/// Iterating the values in the JSON:
	/// in case value is JsonObject, convert it (recursively)
	/// in case value is array, build array
	/// otherwise use value as is String, Bool or Int
	var xmlString: String {
		var body = "<obj";
		if let cls = string(key: "$class") { body.append(" class=\"\(cls)\"") }
		body.append(">")
		
		for (key, value) in self {
			if key == "$class" { continue }
			
			body.append("<att id=\"\(key)\">")
			if let dict = value as? [String: Any] { body.append(JsonObject(from: dict).xmlString) }  //build inner object
			else if let arr = value as? [Any] { body.append(buildXml(from: arr)) } //build array
			else if let num = value as? NSNumber,
					CFNumberGetType(num as CFNumber) == .charType,
					let bool = value as? Bool {
				body.append("<val>\(bool)</val>")
			}
			else { body.append("<val>\(value)</val>") }
			body.append("</att>")
		}
		
		body.append("</obj>")
		return body
	}
}

/// build an XML list from array of objects.
///
/// - Parameter array: array of values to convert to JSON string
fileprivate func buildXml(from array: [Any]) -> String {
	var body = "<list>"
	for value in array {
		if let obj = value as? JsonObject { body.append(obj.xmlString) }  //build inner object
		else if let dict = value as? [String: Any] { body.append(JsonObject(from: dict).xmlString) }  //build inner Json
		else if let arr = value as? [Any] { body.append(buildXml(from: arr)) }  //build array
		else { body.append("<val>\(value)</val>") }
	}
	
	body.append("</list>")
	return body
}
