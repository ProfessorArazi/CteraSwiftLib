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
			.with(key: "type", "user-defined")
			.with(key: "name", "attachMobileDevice")
			.with(key: "param", JsonObject()
					.with(key: "$class", "AttachedMobileDeviceParams")
					.with(key: "hostname", deviceName)
					.with(key: "deviceMac", deviceID)
					.with(key: "deviceType", "Mobile")
					.with(key: "serverName", server)
					.with(key: "password", pass?.escaped ?? "")
					.with(key: "ssoActivationCode", code?.escaped ?? "")
			)
			.xmlString
	}
	
	static func login(with credentials: CredentialsDto) -> String {
		"j_username=device%5c\(credentials.deviceUID)&j_password=\(credentials.sharedSecret)"
	}
	
	static func updateMobileInfo(deviceID: String, deviceName: String) -> String {
		JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", "updateMobileInfo")
			.with(key: "param", JsonObject()
					.with(key: "$class", "UpdateMobileInfoParams")
					.with(key: "cteraMobileVersion", Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
					.with(key: "hostname", deviceName)
					.with(key: "platform", "iOS") //TODO: Check with PM (Ron)
					.with(key: "osName", ProcessInfo.processInfo.operatingSystemVersionString)
					.with(key: "uniqueId", deviceID)
			)
			.xmlString
	}
	
	static func getMulticommand() -> String {
		JsonObject()
			.with(key: "type", "db")
			.with(key: "name", "get-multi")
			.with(key: "param", ["/currentSession", "/currentTime", "/general"])
			.xmlString
	}
	
	static func createNewFolder(folderPath: String, folderName: String) -> String {
		JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", "makeCollection")
			.with(key: "param", JsonObject()
					.with(key: "$class", "makeCollectionParam")
					.with(key: "name", folderName.escaped)
					.with(key: "parentPath", folderPath.escaped)
			)
			.xmlString
	}
	
	static func multipartData(filePath: String) -> String {
		let line = "\r\n",
			boundary = "------MobileBoundaryRRD29pvBCUWyLIg",
			name = filePath.suffix(from: "/")!.removingPercentEncoding!
		
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
				.with(key: "$class", "SrcDstParam")
				.with(key: "src", pair.src)
				.with(key: "dest", pair.dest)
		}
		var param = JsonObject()
			.with(key: "$class", "ActionResourcesParam")
			.with(key: "urls", urls)
		
		if let taskJson = payload.taskJson {
			var cursor = taskJson.jsonObject(key: "cursor")!
			let handler = cursor.string(key: "handler")!
			
			if cursor.bool(key: "applyAll") ?? false { //add json properties to "apply all" request
				cursor.remove(key: "skipHandler")
				cursor.put(key: "fileMoveConflictResolutaion", [
					JsonObject()
						.with(key: "$class", "FileMoveConflictResolutaion")
						.with(key: "errorType", taskJson.string(key: "errorType")!)
						.with(key: "handler", handler)
				])
			} else {
				cursor["skipHandler"] = handler
			}
			
			cursor.remove(key: "handler")
			cursor.remove(key: "applyAll")
			param["startFrom"] = cursor
		}
		
		return JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", payload.action)
			.with(key: "param", param)
			.xmlString
	}
	
	static func getStatus(for task: String) -> String {
		JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", "getTaskStatus")
			.with(key: "param", task)
			.xmlString
	}
	
	//MARK: - public links
	static func getPublicLinks(at itemPath: String) -> String {
		JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", "listPublicShares")
			.with(key: "param", itemPath)
			.xmlString
	}
	
	static func createPublicLink(from link: PublicLinkDto) -> String {
		var shareJson: JsonObject = JsonObject()
			.with(key: "$class", "ShareConfig")
			.with(key: "accessMode", link.permission.rawValue)
			.with(key: "protectionLevel", "publicLink")
			.with(key: "invitee", JsonObject()
					.with(key: "$class", "Collaborator")
					.with(key: "type", "external")
			)
		
		if let expiration = link.expiration {
			let str = DateFormatter.dateOnlyFormat.string(from: expiration)
			shareJson["expiration"] = str
		}
		
		return JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", "createShare")
			.with(key: "param", JsonObject()
					.with(key: "$class", "CreateShareParam")
					.with(key: "url", link.href)
					.with(key: "share", shareJson)
			)
			.xmlString
	}
	
	static func modifyPublicLink(from link: PublicLinkDto, remove: Bool) -> String {
		let createDate = DateFormatter.standardFormat.string(from: link.creationDate)
		var shareJson: JsonObject = JsonObject()
			.with(key: "$class", "Share")
			.with(key: "accessMode", link.permission.rawValue)
			.with(key: "canEdit", false)
			.with(key: "createDate", createDate)
			.with(key: "href", link.href.escaped)
			.with(key: "id", link.id)
			.with(key: "isDirectory", link.isFolder)
			.with(key: "key", link.key)
			.with(key: "protectionLevel", link.protectionLevel)
			.with(key: "publicLink", link.link.escaped)
			.with(key: "resourceName", link.resourceName)
			.with(key: "isRemove", remove)
			.with(key: "invitee", JsonObject()
					.with(key: "$class", "Collaborator")
					.with(key: "type", "external")
			)
			
		if let expiration = link.expiration {
			let str = DateFormatter.dateOnlyFormat.string(from: expiration)
			shareJson["expiration"] = str
		}
		
		return JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", remove ? "deleteShare" : "updateShare")
			.with(key: "param", shareJson)
			.xmlString
	}
	
	//MARK: - Collaboration
	static func listShares(for path: String) -> String {
		JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", "listShares")
			.with(key: "param", path)
			.xmlString
	}
	
	static func saveCollaboration(at path: String, _ collaboration: CollaborationDto) -> String {
		let collJson = try! JsonObject(data: collaboration.json(format: .standardFormat))
		
		return JsonObject()
			.with(key: "name", "shareResource")
			.with(key: "type", "user-defined")
			.with(key: "param", collJson.with(key: "url", path))
			.xmlString
	}
	
	static func verifyCollaborator(for item: ItemInfoDto, _ invitee: CollaboratorDto) -> String {
		JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", "preVerifySingleShare")
			.with(key: "param", JsonObject()
					.with(key: "$class", "PreVerifyShareParam")
					.with(key: "url", item.path)
					.with(key: "invitee", try! JsonObject(encodable: invitee))
			)
			.xmlString
	}
	
	static func searchCollaborators(_ query: String, _ type: String, _ uid: Int, _ count: Int) -> String {
		JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", "searchCollaborationMembers")
			.with(key: "param", JsonObject()
					.with(key: "searchType", type)
					.with(key: "searchTerm", query)
					.with(key: "resourceUid", uid)
					.with(key: "countLimit", count)
			)
			.xmlString
	}
	
	static func leaveShared(items: [ItemInfoDto]) -> String {
		JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", "leaveShare")
			.with(key: "param", items.map(\.path))
			.xmlString
	}
	
	static func fileVersions(for item: ItemInfoDto) -> String {
		JsonObject()
			.with(key: "name", "listVersions")
			.with(key: "param", item.path)
			.xmlString
	}
	
	static func lastModified(items: [ItemInfoDto]) -> String {
		JsonObject()
			.with(key: "type", "user-defined")
			.with(key: "name", "getLastModifiedOfFiles")
			.with(key: "param", items.map({ item in
				JsonObject()
					.with(key: "$class", "getLastModifiedOfFilesParam")
					.with(key: "folderUID", item.cloudFolderInfo!.uid)
					.with(key: "path", item.path)
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
			
			if value as? String == "" {
				body.append("<att id=\"\(key)\" />")
				continue
			}
			
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
