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
			Console.log(tag: "Test Tag", msg: "Log \(i)")
		}
		
		let e = XCTestExpectation(description: "Waiting for Console")
		
		Console.exportLogs { result in
			switch result {
			case .success(let logUrl):
				do {
					let str = try String(contentsOf: logUrl)
					for i in range {
						XCTAssert(str.contains("Log \(i)"))
					}
					
				} catch {
					XCTFail(error.localizedDescription)
				}
				break
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			e.fulfill()
		}
		
		wait(for: [e], timeout: 10_000)
	}
}
