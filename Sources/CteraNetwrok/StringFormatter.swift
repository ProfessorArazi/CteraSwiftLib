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
	
	/// build an XML body for HTTP request to server (until happy time when server accepts JSON).
	///
	/// The XML is built from converting a JSON object, current implementation is recursive.
	///
	/// Iterating the values in the JSON:
	/// in case value is JsonObject, convert it (recursively)
	/// in case value is array, build array
	/// otherwise use value as is String, Bool or Int
	/// - Parameter json: a json object to format as XML
	static func buildXml(from json: JsonObject) -> String{
		var body = "<obj";
		if let cls = json.string(key: "$class") { body.append(" class=\"\(cls)\"") }
		body.append(">")
		
		for (key, value) in json {
			if key == "$class" { continue }
			
			body.append("<att id=\"\(key)\">")
			if let obj = value as? JsonObject { body.append(buildXml(from: obj)) }  //build inner object
			else if let dict = value as? [String: Any] { body.append(buildXml(from: JsonObject(from: dict))) }  //build inner object
			else if let arr = value as? [Any] { body.append(buildXml(from: arr)) }    //build array
			else if let num = value as? NSNumber, CFNumberGetType(num as  CFNumber) == .charType, let test = value as? Bool {
				body.append("<val>\(test)</val>")
			}
			else { body.append("<val>\(value)</val>") }
			body.append("</att>")
		}
		
		body.append("</obj>")
		return body
	}
	
	/// build an XML list from array of objects.
	///
	/// - Parameter array: array of values to convert to JSON string
	private static func buildXml(from array: [Any]) -> String {
		var body = "<list>"
		for value in array {
			if let obj = value as? JsonObject { body.append(buildXml(from: obj)) }  //build inner object
			else if let dict = value as? [String: Any] { body.append(buildXml(from: JsonObject(from: dict))) }  //build inner Json
			else if let arr = value as? [Any] { body.append(buildXml(from: arr)) }  //build array
			else { body.append("<val>\(value)</val>") }
		}
		
		body.append("</list>")
		return body
	}
	
	static func attachMobileDevice(server: String, password pass: String?, activationCode code: String?, deviceID: String, deviceName: String) -> String {
		return "<obj><att id=\"type\"><val>user-defined</val></att>" +
			"<att id=\"name\"><val>attachMobileDevice</val></att>" +
			"<att id=\"param\"><obj class=\"AttachedMobileDeviceParams\">" +
			"<att id=\"deviceMac\"><val>\(deviceID)</val></att>" +
			"<att id=\"deviceType\"><val>Mobile</val></att>" +
			"<att id=\"serverName\"><val>\(server)</val></att>" +
			"<att id=\"password\"><val>\(xmlEscape(pass ?? ""))</val></att>" +
			"<att id=\"ssoActivationCode\"><val>\(xmlEscape(code ?? ""))</val></att>" +
			"<att id=\"hostname\"><val>\(deviceName)</val></att>" +
			"</obj></att></obj>"
	}
	
	static func login(deviceId: String, sharedSecret: String) -> String {
		"j_username=device%5c\(deviceId)&j_password=\(sharedSecret)"
	}
	
	static func updateMobileInfo(deviceID: String, deviceName: String) -> String {
		"<obj>" +
			"<att id = \"type\"><val>user-defined</val></att>" +
			"<att id=\"name\"><val>updateMobileInfo</val></att>" +
			"<att id=\"param\">" +
			"<obj class=\"UpdateMobileInfoParams\">" +
			"<att id=\"cteraMobileVersion\"><val>\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)</val></att>" +
			"<att id=\"hostname\"><val>\(deviceID)</val></att>" +
			"<att id=\"platform\"><val>iOS</val></att>" +
			"<att id=\"osName\"><val>\(ProcessInfo.processInfo.operatingSystemVersionString)</val></att>" +
			"<att id=\"uniqueId\"><val>\(deviceName)</val></att>" +
			"</obj></att></obj>"
	}
	
	static func getMulticommand() -> String {
		"<obj><att id=\"type\"><val>db</val></att>" +
			"<att id=\"name\"><val>get-multi</val></att>" +
			"<att id=\"param\"><list>" +
			"<val>/currentSession</val>" +
			"<val>/currentTime</val>" +
			"<val>/general</val>" +
			"</list></att></obj>"
	}
	
	static func createNewFolder(folderPath: String, folderName: String) -> String {
		"<obj><att id=\"type\"><val>user-defined</val></att>" +
			"<att id=\"name\"><val>makeCollection</val></att>" +
			"<att id=\"param\"><obj class=\"makeCollectionParam\">" +
			"<att id=\"name\"><val>\(xmlEscape(folderName))</val></att>" +
			"<att id=\"parentPath\"><val>\(xmlEscape(folderPath))</val></att>" +
			"</obj></att></obj>"
	}
	
	static func multipartData(filePath: String) -> String{
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
		var body = "<obj><att id=\"type\"><val>user-defined</val></att>" +
			"<att id=\"name\"><val>\(payload.action)</val></att>" +
			"<att id=\"param\"><obj class=\"ActionResourcesParam\"><att id=\"urls\"><list>"
		
		for (src, dest) in payload.pairs {
			body += "<obj class=\"SrcDstParam\">" +
				"<att id=\"src\"><val>\(src)</val></att>" +
				"<att id=\"dest\"><val>\(dest)</val></att></obj>"
		}
		
		body += "</list></att>" +
			"<att id=\"passphrase\">\(payload.passphrase != nil && !payload.passphrase!.isEmpty ? "<val>\(xmlEscape(payload.passphrase!))</val>" : "")</att>" +
			"<att id=\"userPassword\"></att>"
		
		
		if let taskJson = payload.taskJson {
			var cursor = taskJson.jsonObject(key: "cursor")!
			let handler = cursor.string(key: "handler")!
			
			if cursor.bool(key: "applyAll") ?? false { //add json properties to "apply all" request
				cursor.remove(key: "skipHandler")
					.put(key: "fileMoveConflictResolutaion", [
							JsonObject()
								.put(key: "$class", "FileMoveConflictResolutaion")
								.put(key: "errorType", taskJson.string(key: "errorType")!)
								.put(key: "handler", handler)])
			} else {
				cursor = cursor.put(key: "skipHandler", handler)
			}
			
			cursor = cursor.remove(key: "handler").remove(key: "applyAll")
			body += "<att id=\"startFrom\">\(buildXml(from: cursor))</att>"
		} else if "restoreResources" == payload.action {
			body += "<att id=\"startFrom\"></att>"
		}
		
		return body + "</obj></att></obj>"
	}
	
	static func getStatus(for task: String) -> String {
		"<obj><att id=\"type\"><val>user-defined</val></att>" +
			"<att id=\"name\"><val>getTaskStatus</val></att>" +
			"<att id=\"param\"><val>\(task)</val>" +
			"</att></obj>"
	}
	
	//MARK: - public links
	
	static func getPublicLinks(at itemPath: String) -> String {
		"<obj><att id=\"type\"><val>user-defined</val></att>" +
			"<att id=\"name\"><val>listPublicShares</val></att>" +
			"<att id=\"param\">" +
			"<val>\(itemPath)</val></att></obj>"
	}
	
	static func createPublicLink(from link: PublicLink) -> String {
		var body = "<obj>" +
			"<att id=\"type\"><val>user-defined</val></att>" +
			"<att id=\"name\">" +
			"<val>createShare</val>" +
			"</att>" +
			"<att id=\"param\">" +
			"<obj class=\"CreateShareParam\">" +
			"<att id=\"url\">" +
			"<val>\(link.href)!)</val>" +
			"</att>" +
			"<att id=\"share\">" +
			"<obj class=\"ShareConfig\">" +
			"<att id=\"accessMode\">" +
			"<val>\(link.permission.rawValue)!)</val>" +
			"</att>" +
			"<att id=\"protectionLevel\">" +
			"<val>publicLink</val>" +
			"</att>"
		
		if let experation = link.expiration {
			body += "<att id=\"expiration\"><val>\(experation)</val></att>"
		}
		
		return body + "<att id=\"invitee\">" +
			"<obj class=\"Collaborator\">" +
			"<att id=\"type\">" +
			"<val>external</val>" +
			"</att></obj>" +
			"</att></obj></att>" +
			"</obj></att></obj>"
	}
	
	static func modifyPublicLink(from link: PublicLink, remove: Bool) -> String {
		let createDate = DateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss").string(from: link.creationDate!)
		var body = "<obj>" +
			"<att id=\"type\"><val>user-defined</val> </att>" +
			"<att id=\"name\"><val>\(remove ? "deleteShare" : "updateShare")</val></att>" +
			"<att id=\"param\"><obj class=\"Share\">" +
			"<att id=\"accessMode\"><val>\(link.permission.rawValue)</val></att>" +
			"<att id=\"canEdit\"><val>false</val></att>" +
			"<att id=\"createDate\"><val>\(createDate)</val></att>"
		
		if let expiration = link.expiration {
			body += "<att id=\"expiration\"><val>\(expiration)</val></att>"
		}
		else { body += "<att id=\"expiration\"></att>" }
		
		body += "<att id=\"href\"><val>\(xmlEscape(link.href))</val></att>" +
			"<att id=\"id\"><val>\(link.id!)</val></att>" +
			"<att id=\"invitee\"><obj class=\"Collaborator\"><att id=\"type\"><val>external</val></att></obj></att>" +
			"<att id=\"isDirectory\"><val>\(link.isFolder)</val></att>" +
			"<att id=\"key\"><val>\(link.key!)</val></att>" +
			"<att id=\"protectionLevel\"><val>\(link.protectionLevel!)</val></att>" +
			"<att id=\"publicLink\"><val>\(xmlEscape(link.link))</val></att>" +
			"<att id=\"resourceName\"><val>\(link.resourceName!)</val></att>"
		
		if remove { body += "<att id=\"isRemove\"><val>true</val></att>" }
		
		return body + "</obj></att></obj>"
	}
	
	//MARK: - Collaboration
	
	static func listShares(for path: String) -> String {
		"<obj><att id=\"type\"><val>user-defined</val></att>" +
			"<att id=\"name\"><val>listShares</val></att>" +
			"<att id=\"param\"><val>\(path)</val></att></obj>"
	}
	
	static func saveCollaboration(at path: String, _ collaboration: JsonObject) -> String {
		if let shares: [JsonObject] = collaboration["shares"] { //configure each share values for request
			for var share in shares {
				share["$class"] = "ShareConfig"
			}
		}
		
		let json = JsonObject()
			.put(key: "name", "shareResource")
			.put(key: "type", "user-defined")
			.put(key: "param", collaboration
					.put(key: "$class", "ShareResourceParam")
					.put(key: "url", path))
		
		return buildXml(from: json)
	}
	
	static func verifyCollaborator(for item: ItemInfo, _ invitee: JsonObject) -> String {
		"<obj><att id=\"type\"><val>user-defined</val></att>" +
			"<att id=\"name\"><val>preVerifySingleShare</val></att>" +
			"<att id=\"param\">" +
			"<obj class=\"PreVerifyShareParam\">" +
			"<att id=\"url\"><val>\(item.path)</val></att>" +
			"<att id=\"invitee\">\(buildXml(from: invitee))</att>" +
			"</obj></att></obj>"
	}
	
	static func searchCollaborators(_ query: String, _ type: String, _ uid: Int) -> String {
		"<obj><att id=\"type\"><val>user-defined</val></att>" +
			"<att id=\"name\"><val>searchCollaborationMembers</val></att>" +
			"<att id=\"param\"><obj>" +
			"<att id=\"searchType\"><val>\(type)</val></att>" +
			"<att id=\"searchTerm\"><val>\(query)</val></att>" +
			"<att id=\"resourceUid\"><val>\(uid)</val></att>" +
			"<att id=\"countLimit\"><val>25</val></att>" +
			"</obj></att></obj>"
	}
	
	static func leaveShared(items: [ItemInfo]) -> String{
		var body = "<obj>" +
			"<att id=\"type\"><val>user-defined</val></att>" +
			"<att id=\"name\">" +
			"<val>leaveShare</val></att>" +
			"<att id=\"param\"><list>"
		
		for item in items { body += "<val>\(item.path)</val>" }
		
		return body + "</list></att></obj>"
	}
	
	static func fileVersions(for item: ItemInfo) -> String {
		"<obj><att id=\"name\"><val>listVersions</val></att>" +
			"<att id=\"param\"><val>\(item.path)</val></att></obj>"
	}
	
	static func lastModified(items: [ItemInfo]) -> String{
		"<obj>" +
			"<att id = \"type\"><val>user-defined</val></att>" +
			"<att id=\"name\"><val>getLastModifiedOfFiles</val></att>" +
			"<att id=\"param\"><list>" +
			items.reduce("") { result, item -> String in
				result +
					"<obj class=\"getLastModifiedOfFilesParam\">" +
					"<att id=\"folderUID\"><val>\(item.cloudFolderInfo!.uid)</val></att>" +
					"<att id=\"path\"><val>\(item.path)</val></att></obj>"
			} +
			"</list></att></obj>"
	}
	
	private static func xmlEscape(_ str: String) -> String {
		str.replacingOccurrences(of: "&", with: "&amp;")
			.replacingOccurrences(of: "/\"", with: "&quot;")
			.replacingOccurrences(of: "'", with: "&apos;")
			.replacingOccurrences(of: "<", with: "&lt;")
			.replacingOccurrences(of: ">", with: "&gt;")
	}
}
