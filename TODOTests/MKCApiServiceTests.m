#import <XCTest/XCTest.h>
#import "MKCApiService.h"

@interface MKCApiServiceTests : XCTestCase

@end

@implementation MKCApiServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFetchTodoListApi {
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    
    [[MKCApiService sharedApi] fetchTodoListWithSuccessHandler:^(NSURLResponse *response, id responseObject) {
        
        [expectation fulfill];
        
        XCTAssertGreaterThan([responseObject count], 0);
        XCTAssertNotNil(responseObject[0][@"userId"]);
        XCTAssertNotNil(responseObject[0][@"id"]);
        XCTAssertNotNil(responseObject[0][@"title"]);
        XCTAssertNotNil(responseObject[0][@"completed"]);
        
    } failureHandler:^(NSError *error) {
        XCTFail(@"error %@", error);
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

@end
