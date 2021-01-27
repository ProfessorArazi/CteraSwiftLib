import XCTest
import StorageExtensions
import CteraUtil

final class CteraUtilTests: XCTestCase {
	override func setUpWithError() throws {
		try FileSystem.delete(folder: .logs)
	}
	
	override func tearDownWithError() throws {
		try FileSystem.delete(folder: .logs)
	}
	
	func testGetLogs() throws {
		let range = 1...100
		for i in range {
			Console.log(tag: #function, msg: "Log \(i)")
		}
		
		getLogs { (str) in
			for i in range {
				XCTAssert(str.contains("Log \(i)"))
			}
		}
	}
	
	
	func testLogAfterDelete() throws {
		let range = 1...100
		for i in range {
			Console.log(tag: #function, msg: "Log \(i)")
		}
		
		Console.sync()
		try FileSystem.delete(folder: .logs)
		Console.log(tag: #function, msg: "After Delete")
		
		getLogs { (str) in
			XCTAssert(!str.contains("Log 1"))
			XCTAssert(str.contains("After Delete"))
		}
	}
	
	private func getLogs(completion: @escaping (String)->()) {
		let e = XCTestExpectation(description: "Waiting for Console")
		
		Console.exportLogs { result in
			print("done")
			switch result {
			case .success(let logUrl):
				do {
					let str = try String(contentsOf: logUrl)
					completion(str)
				} catch {
					XCTFail(error.localizedDescription)
				}
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			e.fulfill()
		}
		
		wait(for: [e], timeout: 10)
	}
}
