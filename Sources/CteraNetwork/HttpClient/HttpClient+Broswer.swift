//
//  HttpClient+Broswer.swift
//  
//
//  Created by Gal Yedidovich on 31/01/2021.
//

import Foundation
import BasicExtensions
import StorageExtensions
import CteraUtil
import CteraModels
import CteraCache

//MARK: - Fetch Folders
extension HttpClient {
	public static func fetchFolder(_ request: FetchRequestDto, handler: @escaping Handler<FolderDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let cachePath = request.cachePath ?? request.path
		
		if request.withCache, let cache = FolderCache[cachePath] {
			Console.log(tag: TAG, msg: "loading from cache")
			handler(.success(cache))
		}
		
		requestFolder(request, handler: { result in
			async {
				if case let .success(folder) = result {
					if request.withCache, folder == FolderCache[cachePath] {
						Console.log(tag: TAG, msg: "same list, not refreshing list")
						return
					}
					
					if request.startIndex == 0 {
						FolderCache[cachePath] = folder
					}
				}
				
				post { handler(result) }
			}
		})
	}
	
	public static func searchFolder(_ request: FetchRequestDto, handler: @escaping Handler<FolderDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		requestFolder(request, handler: handler)
	}
	
	public static func requestNavigationItems(handler: @escaping Handler<FolderDto>) {
		Console.log(tag: Self.TAG, msg: #function)
		let fetchReq = FetchRequestDto(path: "/ServicesPortal/webdav").with(navigationPane: true)
		requestFolder(fetchReq, handler: handler)
	}
	
	private static func requestFolder(_ request: FetchRequestDto, handler: @escaping Handler<FolderDto>) {
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: request.toJson().xmlString)
		
		handle(request: req, FolderDto.fromFormatted(json:), handler: handler)
	}
}

//MARK: - Preview
extension HttpClient {
	public static func requestPreviewSession(for item: ItemInfoDto, handler: @escaping Handler<String>) {
		Console.log(tag: TAG, msg: "\(#function), \(item.name)")
		
		let path = item.path.dropFirst()
		let req = URLRequest(to: serverAddress, path + "?preview=true&showDeleted=true")
		
		func middleware(data: Data) throws -> String {
			let json: [String: String] = try .from(json: data)
			return json["viewingSessionId"]!
		}
		
		func errorParser(data: Data) throws -> PreviewError {
			let json: [String: String] = try .from(json: data)
			guard let str = json["previewFailure"] else { return .unknown }
			return PreviewError(rawValue: str) ?? .unknown
		}
		
		handle(request: req, middleware, errorParser: errorParser, handler: handler)
	}
	
	public static func requestPreview(page: Int, viewingSession: String, handler: @escaping Handler<Data>) {
		let req = URLRequest(to: serverAddress, "ServicesPortal/pcc/Page/q/\(page)?DocumentID=u\(viewingSession)&Scale=1&ContentType=png")
		
		handle(request: req, handler: handler)
	}
	
	public static func requestPreviewPageCount(viewingSession: String, handler: @escaping Handler<Int>) {
		let req = URLRequest(to: serverAddress, "ServicesPortal/pcc/Document/q/Attributes?DocumentID=u\(viewingSession)&DesiredPageCountConfidence=50")
		
		func middleware(data: Data) throws -> Int {
			let json: [String: Int] = try .fromFormatted(json: data)
			return json["pageCount"]!
		}
		
		handle(request: req, middleware, handler: handler)
	}
}

//MARK: - Download & Upload
extension HttpClient {
	public static func requestFile(for item: ItemInfoDto, config: @escaping (ProgressTask)->(), handler: @escaping Handler<URL>) {
		Console.log(tag: TAG, msg: "\(#function), \(item.name)")
		
		if let fileCache = fileCache, let cacheItem = fileCache.item(for: item) {
			let task = fileCache.provide(item: cacheItem) { result in
				switch result {
				case .success(let url):
					thumbnailDelegate?.thumbnail(receivedFile: url, for: item)
					post { handler(.success(url)) }
				case .failure(let error):
					post { handler(.failure(error)) }
				}
			}
			
			config(task)
			return
		}
		
		guard hasConnection else {
			handler(.failure(Errors.offline))
			return
		}
		
		verifySession { //must verify session before creating download task.
			let path = String(item.path.dropFirst())
			let req = URLRequest(to: serverAddress, path)
			
			let task = backgroundSession.downloadTask(with: req)
			task.resume()
			config(ProgressTask(from: task))
			if let size = item.size { task.countOfBytesClientExpectsToReceive = size }
			
			downloadDelegate.onStart(task, item, handler)
		}
	}
	
	public static func uploadRequest(_ fileUrl: URL, to itemPath: String,
									 onStart: @escaping (URLSessionUploadTask)->() = { $0.resume() },
									 handler: @escaping Handler<Void>) {
		Console.log(tag: Self.TAG, msg: #function)
		async {
			let boundary = "----MobileBoundaryRRD29pvBCUWyLIg"
			let req = URLRequest(to: serverAddress, "ServicesPortal/upload?")
				.set(method: .POST)
				.set(contentType: ContentType(stringLiteral: "multipart/form-data; boundary=\(boundary)"))
			
			let uploadFileUrl = uploadDelegate.multipartDataFile(fileUrl, boundary: boundary, for: itemPath)
			
			//upload
			let task = backgroundSession.uploadTask(with: req, fromFile: uploadFileUrl)
			uploadDelegate.onStart(task, path: itemPath, filename: uploadFileUrl.lastPathComponent, handler)
			onStart(task)
		}
	}
}

//MARK: - Other
extension HttpClient {
	public static func createFolder(at path: String, name: String, handler: @escaping Handler<Data>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.createNewFolder(folderPath: path, folderName: name))
		
		handle(request: req, handler: handler)
	}
	
	public static func requestLastModified(for items: [ItemInfoDto], userRef: String, handler: @escaping Handler<[LastModifiedDto]>) {
		Console.log(tag: TAG, msg: "\(#function), items: \(items.map(\.name))")
		let req = URLRequest(to: serverAddress, "ServicesPortal/api/\(userRef)?format=jsonext")
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.lastModified(items: items))
		
		handle(request: req, [LastModifiedDto].fromFormatted(json:), handler: handler)
	}
	
	public static func requestVersions(of item: ItemInfoDto, handler: @escaping Handler<[VersionDto]>) {
		Console.log(tag: Self.TAG, msg: #function)
		let req = URLRequest(to: serverAddress, SERVICES_PORTAL_API)
			.set(method: .POST)
			.set(contentType: .xml)
			.set(body: StringFormatter.fileVersions(for: item))
		
		handle(request: req, [VersionDto].fromFormatted(json:), handler: handler)
	}
}
