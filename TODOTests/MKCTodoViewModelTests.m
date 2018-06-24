#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MKCApiService.h"
#import "MKCTodoViewModel.h"
#import "MKCTodoViewController.h"

@interface MKCTodoViewController (UnitTest)

@property (strong, nonatomic) MKCTodoViewModel *todoViewModel;

@end

@interface MKCTodoViewModelTests : XCTestCase

@end

@implementation MKCTodoViewModelTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - API 回傳異常資料

- (void)testApiResponseInvalidData {
    // Arrange
    id invalidResponseObject = @[@"a", @"b", @"c"];
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, invalidResponseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    // Act
    MKCTodoViewModel *todoViewModel = [[MKCTodoViewModel alloc] init];
    [todoViewModel fetchData];
    
    // Assert
    XCTAssertEqual(todoViewModel.currentUiState, UIStateError);
}

- (void)testApiResponseInvalidDataType {
    // Arrange
    id invalidResponseObject = @{@"a": @"b", @"c": @"d"};
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, invalidResponseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    // Act
    MKCTodoViewModel *todoViewModel = [[MKCTodoViewModel alloc] init];
    [todoViewModel fetchData];
    
    // Assert
    XCTAssertEqual(todoViewModel.currentUiState, UIStateError);
}

- (void)testApiResponseInvalidEmptyKeyData {
    // Arrange
    id invalidResponseObject = @[@{@"title": @"test"}];
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, invalidResponseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    // Act
    MKCTodoViewModel *todoViewModel = [[MKCTodoViewModel alloc] init];
    [todoViewModel fetchData];
    
    // Assert
    XCTAssertEqual(todoViewModel.currentUiState, UIStateError);
}

#pragma mark - 狀態值切換

- (void)testFetchDataSuccessful {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"todos" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, responseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    id mockTodoViewModel = OCMPartialMock([[MKCTodoViewModel alloc] init]);
    [mockTodoViewModel setExpectationOrderMatters:YES];
    
    // 以下狀態不會被執行
    OCMReject([mockTodoViewModel setCurrentUiState:UIStateError]);
    
    // 以下狀態會依序被執行
    OCMExpect([mockTodoViewModel setCurrentUiState:UIStateLoading]);
    OCMExpect([mockTodoViewModel setCurrentUiState:UIStateFinish]);
    
    [mockTodoViewModel fetchData];
    OCMVerifyAll(mockTodoViewModel);
    
    MKCTodoCellViewModel *firstTodoCellViewModel = [mockTodoViewModel cellViewModelAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    XCTAssertEqualObjects(firstTodoCellViewModel.title, @"mock test 1");
    XCTAssertFalse(firstTodoCellViewModel.completed);
}

- (void)testFetchingDataOccursError {
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    NSError *error = [NSError errorWithDomain:@"test.error" code:123 userInfo:@{}];
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:OCMOCK_ANY failureHandler:([OCMArg invokeBlockWithArgs:error, nil])]);

    id mockTodoViewModel = OCMPartialMock([[MKCTodoViewModel alloc] init]);
    [mockTodoViewModel setExpectationOrderMatters:YES];

    // 以下狀態不會被執行
    OCMReject([mockTodoViewModel setCurrentUiState:UIStateFinish]);

    // 以下狀態會依序被執行
    OCMExpect([mockTodoViewModel setCurrentUiState:UIStateLoading]);
    OCMExpect([mockTodoViewModel setCurrentUiState:UIStateError]);

    [mockTodoViewModel fetchData];
    OCMVerifyAll(mockTodoViewModel);
}

#pragma mark - 切換不同 UI 狀態，確認 delegate function 是否有正確執行

- (void)testSwitchToFinishUiState {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"todos" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, responseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    id mockTodoViewModelDelegate = OCMProtocolMock(@protocol(MKCTodoViewModelDelegate));
    MKCTodoViewModel *mockTodoViewModel = OCMPartialMock([[MKCTodoViewModel alloc] init]);
    mockTodoViewModel.delegate = mockTodoViewModelDelegate;
    [mockTodoViewModelDelegate setExpectationOrderMatters:YES];
    
    // 以下 delegate function 不會被執行
    OCMReject([mockTodoViewModelDelegate showErrorMessageWithError:OCMOCK_ANY]);
    
    // 以下 delegate function 會被執行
    OCMExpect([mockTodoViewModelDelegate updateLoadingState]);
    
    MKCTodoViewController *todoViewController = [[MKCTodoViewController alloc] init];
    todoViewController.todoViewModel = mockTodoViewModel;
    [todoViewController view];
    OCMVerifyAll(mockTodoViewModelDelegate);
    
    XCTAssertEqual(todoViewController.todoViewModel.currentUiState, UIStateFinish);
}

- (void)testSwitchToErrorUiState {
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    NSError *error = [NSError errorWithDomain:@"test.error" code:123 userInfo:@{}];
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:OCMOCK_ANY failureHandler:([OCMArg invokeBlockWithArgs:error, nil])]);
    
    id mockTodoViewModelDelegate = OCMProtocolMock(@protocol(MKCTodoViewModelDelegate));
    MKCTodoViewModel *mockTodoViewModel = OCMPartialMock([[MKCTodoViewModel alloc] init]);
    mockTodoViewModel.delegate = mockTodoViewModelDelegate;
    [mockTodoViewModelDelegate setExpectationOrderMatters:YES];
    
    // 以下 delegate function 會被執行
    OCMExpect([mockTodoViewModelDelegate updateLoadingState]);
    OCMExpect([mockTodoViewModelDelegate showErrorMessageWithError:OCMOCK_ANY]);
    
    MKCTodoViewController *todoViewController = [[MKCTodoViewController alloc] init];
    todoViewController.todoViewModel = mockTodoViewModel;
    [todoViewController view];
    OCMVerifyAll(mockTodoViewModelDelegate);
    
    XCTAssertEqual(todoViewController.todoViewModel.currentUiState, UIStateError);
}

@end
