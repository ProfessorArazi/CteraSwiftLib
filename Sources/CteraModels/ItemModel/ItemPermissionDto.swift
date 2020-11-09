//
//  ItemPermissionDto.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

public enum ItemPermissionDto: String, Codable {
	case None, ReadWrite, ReadOnly, PreviewOnly
	
	public var prettyString: String {
		switch self {
		case .PreviewOnly:	return .permissionPreviewOnly
		case .ReadOnly:		return .permissionReadOnly
		case .ReadWrite:	return .permissionReadWrite
		default:			return .permissionDenied
		}
	}
	
	static func from(string: String) -> ItemPermissionDto {
		switch string {
		case .permissionReadWrite:		return .ReadWrite
		case .permissionReadOnly:		return .ReadOnly
		case .permissionPreviewOnly:	return .PreviewOnly
		default:						return .None
		}
	}
}
