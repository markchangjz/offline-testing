import XCTest

struct Todo: Codable {
    var userId: Int
    var id: Int
    var title: String
    var completed: Bool
}

class MKCApiServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchTodoListApi() {
        let wait = expectation(description: "wait")

        MKCApiService.sharedApi().fetchTodoList(successHandler: { (response, responseObject) in
    
            do {                
                let data = try JSONSerialization.data(withJSONObject: responseObject!, options: .prettyPrinted)
                
                let decoder = JSONDecoder()
                let model = try decoder.decode([Todo].self, from: data)
                
                XCTAssertGreaterThan(model.count, 0);
                XCTAssertNotNil(model[0].userId);
                XCTAssertNotNil(model[0].id);
                XCTAssertNotNil(model[0].title);
                XCTAssertNotNil(model[0].completed);
            } catch {
                XCTFail("error \(String(describing: error))")
            }
            
            wait.fulfill()
        }) { (error) in
            XCTFail("error \(String(describing: error))")
        }

        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
}
