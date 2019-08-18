#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MKCAPIService.h"
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
    // Arrange - Stub API 回傳異常資料
    id invalidResponseObject = @[@"a", @"b", @"c"];
    id mockApiService = OCMPartialMock([MKCAPIService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, invalidResponseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    // Act - 呼叫 API
    MKCTodoViewModel *todoViewModel = [[MKCTodoViewModel alloc] init];
    [todoViewModel fetchData];
    
    // Assert - 驗證 UI State 為 Error
    XCTAssertEqual(todoViewModel.currentUiState, UIStateError);
}

- (void)testApiResponseInvalidDataType {
    // Arrange - Stub API 回傳異常資料
    id invalidResponseObject = @{@"a": @"b", @"c": @"d"};
    id mockApiService = OCMPartialMock([MKCAPIService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, invalidResponseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    // Act - 呼叫 API
    MKCTodoViewModel *todoViewModel = [[MKCTodoViewModel alloc] init];
    [todoViewModel fetchData];
    
    // Assert - 驗證 UI State 為 Error
    XCTAssertEqual(todoViewModel.currentUiState, UIStateError);
}

- (void)testApiResponseInvalidEmptyKeyData {
    // Arrange - Stub API 回傳異常資料
    id invalidResponseObject = @[@{@"title": @"test"}];
    id mockApiService = OCMPartialMock([MKCAPIService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, invalidResponseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    // Act - 呼叫 API
    MKCTodoViewModel *todoViewModel = [[MKCTodoViewModel alloc] init];
    [todoViewModel fetchData];
    
    // Assert - 驗證 UI State 為 Error
    XCTAssertEqual(todoViewModel.currentUiState, UIStateError);
}

#pragma mark - 狀態值切換

- (void)testFetchDataSuccessful {
    // Arrange - 讀取本機 JSON file，模擬 API 回傳資料
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"todos" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    id mockApiService = OCMPartialMock([MKCAPIService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, responseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    id mockTodoViewModel = OCMPartialMock([[MKCTodoViewModel alloc] init]);
    [mockTodoViewModel setExpectationOrderMatters:YES];
    
    // Assert - 以下狀態不會被執行
    OCMReject([mockTodoViewModel setCurrentUiState:UIStateError]);
    // Assert - 以下狀態會依序被執行
    OCMExpect([mockTodoViewModel setCurrentUiState:UIStateLoading]);
    OCMExpect([mockTodoViewModel setCurrentUiState:UIStateFinish]);
    
    // Act - 呼叫 API
    [mockTodoViewModel fetchData];
    
    // Assert - 驗證 UI State 切換順序
    OCMVerifyAll(mockTodoViewModel);
    
    // Assert - 驗證 UI 顯示資料
    XCTAssertEqual([mockTodoViewModel numberOfCells], 5);
    
    MKCTodoCellViewModel *firstTodoCellViewModel = [mockTodoViewModel cellViewModelAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    XCTAssertEqualObjects(firstTodoCellViewModel.title, @"mock test 1");
    XCTAssertFalse(firstTodoCellViewModel.completed);
}

- (void)testFetchingDataOccursError {
    // Arrange - 模擬呼叫 API 錯誤
    id mockApiService = OCMPartialMock([MKCAPIService sharedApi]);
    NSError *error = [NSError errorWithDomain:@"test.error" code:123 userInfo:@{}];
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:OCMOCK_ANY failureHandler:([OCMArg invokeBlockWithArgs:error, nil])]);

    id mockTodoViewModel = OCMPartialMock([[MKCTodoViewModel alloc] init]);
    [mockTodoViewModel setExpectationOrderMatters:YES];

    // Assert - 以下狀態不會被執行
    OCMReject([mockTodoViewModel setCurrentUiState:UIStateFinish]);
    // Assert - 以下狀態會依序被執行
    OCMExpect([mockTodoViewModel setCurrentUiState:UIStateLoading]);
    OCMExpect([mockTodoViewModel setCurrentUiState:UIStateError]);

    // Act - 呼叫 API
    [mockTodoViewModel fetchData];
    
    // Assert - 驗證 UI State 切換順序
    OCMVerifyAll(mockTodoViewModel);
}

#pragma mark - 切換不同 UI 狀態，確認 ViewModel 的 delegate function 是否有正確執行

- (void)testSwitchToFinishUiState {
    // Arrange - 讀取本機 JSON file，模擬 API 回傳資料
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"todos" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    id mockApiService = OCMPartialMock([MKCAPIService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, responseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    // Arrange - Mock ViewModelDelegate，來驗證 delegate function 是否有正確執行
    id mockTodoViewModelDelegate = OCMProtocolMock(@protocol(MKCTodoViewModelDelegate));
    MKCTodoViewModel *mockTodoViewModel = OCMPartialMock([[MKCTodoViewModel alloc] init]);
    mockTodoViewModel.delegate = mockTodoViewModelDelegate;
    
    // Assert - 以下 delegate function 不會被執行
    OCMReject([mockTodoViewModelDelegate showErrorMessageWithError:OCMOCK_ANY]);
    // Assert - 以下 delegate function 會被執行
    OCMExpect([mockTodoViewModelDelegate updateLoadingState]);
    
    // Act - 載入畫面
    MKCTodoViewController *todoViewController = [[MKCTodoViewController alloc] init];
    todoViewController.todoViewModel = mockTodoViewModel;
    [todoViewController view];
    
    // Assert - delegate function 是否有正確執行及 UI State
    OCMVerifyAll(mockTodoViewModelDelegate);
    XCTAssertEqual(todoViewController.todoViewModel.currentUiState, UIStateFinish);
}

- (void)testSwitchToErrorUiState {
    // Arrange - 模擬呼叫 API 錯誤
    id mockApiService = OCMPartialMock([MKCAPIService sharedApi]);
    NSError *error = [NSError errorWithDomain:@"test.error" code:123 userInfo:@{}];
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:OCMOCK_ANY failureHandler:([OCMArg invokeBlockWithArgs:error, nil])]);
    
    // Arrange - Mock ViewModelDelegate，來驗證 delegate function 是否有正確執行
    id mockTodoViewModelDelegate = OCMProtocolMock(@protocol(MKCTodoViewModelDelegate));
    MKCTodoViewModel *mockTodoViewModel = OCMPartialMock([[MKCTodoViewModel alloc] init]);
    mockTodoViewModel.delegate = mockTodoViewModelDelegate;
    
    // Assert - 以下 delegate function 會被執行
    OCMExpect([mockTodoViewModelDelegate updateLoadingState]);
    OCMExpect([mockTodoViewModelDelegate showErrorMessageWithError:OCMOCK_ANY]);
    
    // Act - 載入畫面
    MKCTodoViewController *todoViewController = [[MKCTodoViewController alloc] init];
    todoViewController.todoViewModel = mockTodoViewModel;
    [todoViewController view];
    
    // Assert - delegate function 是否有正確執行及 UI State
    OCMVerifyAll(mockTodoViewModelDelegate);
    XCTAssertEqual(todoViewController.todoViewModel.currentUiState, UIStateError);
}

@end
