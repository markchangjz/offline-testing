import XCTest

class TODOUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDataIsLoaded() {

        let tableView = XCUIApplication().tables.firstMatch
        waitFor(element: tableView, status: .exist);
        
        XCTAssertTrue(tableView.cells.count > 0)
    }
    
}

extension TODOUITests {
    
    enum UIState: String {
        case exist = "exists == true"
        case notExist = "exists == false"
        case hittable = "isHittable == true"
    }
    
    func waitFor(element: XCUIElement, status: UIState) {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: status.rawValue), object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: 10)
        
        if (result == .timedOut) {
            XCTFail(expectation.description)
        }
    }
}
