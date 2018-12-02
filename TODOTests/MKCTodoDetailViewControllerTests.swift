import XCTest
@testable import TODO

class MKCTodoDetailViewControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetTodoTitle() {
        let todoDetailViewController = TodoDetailViewController()
        todoDetailViewController.todoTitle = "test title"
        _ = todoDetailViewController.view
        
        XCTAssertEqual(todoDetailViewController.todoLabel.text, "test title")
    }
    
}
