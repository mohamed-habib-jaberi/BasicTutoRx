import XCTest
import Foundation
import ObjectiveC

class TestObserver: NSObject, XCTestObservation {
    func testCase(_ testCase: XCTestCase,
                  didFailWithDescription description: String,
                  inFile filePath: String?,
                  atLine lineNumber: Int) {
        assertionFailure(description, line: UInt(lineNumber))
    }
}

public func runTestObserver() {
    let testObserver = TestObserver()
    XCTestObservationCenter.shared.addTestObserver(testObserver)
}
