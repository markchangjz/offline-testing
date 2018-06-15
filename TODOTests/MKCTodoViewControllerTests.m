#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MKCApiService.h"
#import "MKCTodoViewController.h"
#import "MKCTodoViewModel.h"

@interface MKCTodoViewController (UnitTest)

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIBarButtonItem *refreshBarButtonItem;

@end

@interface MKCTodoViewControllerTests : XCTestCase

@end

@implementation MKCTodoViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - 驗證 UI 顯示

/**
 呼叫 API 完成，完成狀態顯示
 */
- (void)testFinishState {
    // Arrange - 讀取本機 JSON file，模擬 API 回傳資料
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"todos" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, responseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    // Act - 載入畫面
    MKCTodoViewController *todoViewController = [[MKCTodoViewController alloc] init];
    [todoViewController view];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
 
    // Assert - 驗證畫面狀態，及資料數量
    XCTAssertEqual(todoViewController.tableView.alpha, 1.0);
    XCTAssertTrue(todoViewController.activityIndicatorView.isHidden);
    XCTAssertEqual([todoViewController.tableView numberOfRowsInSection:0], 5);
}

/**
 呼叫 API，載入中狀態顯示
 */
- (void)testLoadingState {
    // Arrange - 將狀態固定回傳 Loading
    id mockTodoViewModel = OCMPartialMock([[MKCTodoViewModel alloc] init]);
    [OCMStub([mockTodoViewModel currentUiState]) andReturn:@(UIStateLoading)];
    
    // Act - 載入畫面
    MKCTodoViewController *todoViewController = [[MKCTodoViewController alloc] init];
    [todoViewController view];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
    
    // Assert - 驗證畫面狀態，及資料數量
    XCTAssertEqual(todoViewController.tableView.alpha, 0.0);
    XCTAssertFalse(todoViewController.activityIndicatorView.isHidden);
    XCTAssertEqual([todoViewController.tableView numberOfRowsInSection:0], 0);
}

/**
 呼叫 API 發生錯誤時，錯誤狀態顯示
 */
- (void)testErrorState {
    // Arrange - 模擬呼叫 API 錯誤
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    NSError *error = [NSError errorWithDomain:@"test.error" code:123 userInfo:@{}];
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:OCMOCK_ANY failureHandler:([OCMArg invokeBlockWithArgs:error, nil])]);
    
    // Act - 載入畫面
    MKCTodoViewController *todoViewController = [[MKCTodoViewController alloc] init];
    [todoViewController view];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
    
    // Assert - 驗證畫面狀態，及資料數量
    XCTAssertEqual(todoViewController.tableView.alpha, 0.0);
    XCTAssertTrue(todoViewController.activityIndicatorView.isHidden);
    XCTAssertEqual([todoViewController.tableView numberOfRowsInSection:0], 0);
}

/**
 驗證 Cell 顯示的資料
 */
- (void)testCellData {
    // Arrange - 讀取本機 JSON file，模擬 API 回傳資料
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"todos" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, responseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    // Act - 載入畫面
    MKCTodoViewController *todoViewController = [[MKCTodoViewController alloc] init];
    [todoViewController view];
    
    // Assert - 驗證 Cell 顯示資料
    UITableView *todoTableView = todoViewController.tableView;
    [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UITableViewCell *cell = [todoTableView.dataSource tableView:todoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        
        XCTAssertEqualObjects(cell.textLabel.text, obj[@"title"]);
        
        UITableViewCellAccessoryType accessoryType = [obj[@"completed"] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        XCTAssertEqual(cell.accessoryType, accessoryType);
    }];
}

#pragma mark - 使用者 UI 操作

/**
 點選 Refresh Button 後，可正確載入資料
 */
- (void)testTappedRefreshBarButtonItem {
    // Arrange - 讀取本機 JSON file，模擬 API 回傳資料
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"todos" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:([OCMArg invokeBlockWithArgs:OCMOCK_ANY, responseObject, nil]) failureHandler:OCMOCK_ANY]);
    
    // Act - 載入畫面
    MKCTodoViewController *todoViewController = [[MKCTodoViewController alloc] init];
    [todoViewController view];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
    
    // Assert - 驗證畫面狀態，及資料數量
    XCTAssertEqual(todoViewController.tableView.alpha, 1.0);
    XCTAssertTrue(todoViewController.activityIndicatorView.isHidden);
    XCTAssertEqual([todoViewController.tableView numberOfRowsInSection:0], 5);
    
    // Act - 模擬使用者點選 Refresh Button
    UIBarButtonItem *refreshBarButtonItem = todoViewController.refreshBarButtonItem;
    [[UIApplication sharedApplication] sendAction:refreshBarButtonItem.action
                                               to:refreshBarButtonItem.target
                                             from:nil
                                         forEvent:nil];
    
    // Assert - 驗證畫面狀態，及資料數量
    XCTAssertEqual(todoViewController.tableView.alpha, 1.0);
    XCTAssertTrue(todoViewController.activityIndicatorView.isHidden);
    XCTAssertEqual([todoViewController.tableView numberOfRowsInSection:0], 5);
}

/**
 點選 table view 的 cell 後，cell 會顯示取消選取動畫
 */
- (void)testTapTableViewCell {
    // Arrange - 模擬 table view
    id mockTableView = OCMPartialMock([[MKCTodoViewController alloc] init].tableView);
    
    // Act - 模擬使用者點選 table view 的 cell
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [[mockTableView delegate] tableView:mockTableView didSelectRowAtIndexPath:selectIndexPath];
    
    // Assert - 取消選取有被執行
    OCMVerify([mockTableView deselectRowAtIndexPath:selectIndexPath animated:YES]);
}

/**
 API 回傳錯誤訊息，會顯示 alert
 */
- (void)testShowErrorAlert {
    // Arrange - 模擬呼叫 API 錯誤
    id mockApiService = OCMPartialMock([MKCApiService sharedApi]);
    NSError *error = [NSError errorWithDomain:@"test.error" code:123 userInfo:@{}];
    OCMStub([mockApiService fetchTodoListWithSuccessHandler:OCMOCK_ANY failureHandler:([OCMArg invokeBlockWithArgs:error, nil])]);
    
    id mockAlertController = OCMClassMock([UIAlertController class]);
    
    // Act - 載入畫面
    id mockTodoViewController = OCMPartialMock([[MKCTodoViewController alloc] init]);
    [mockTodoViewController view];
    
    // Assert - 驗證 alert 訊息，及 alert 被顯示
    OCMVerify([mockAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert]);
    OCMVerify([mockTodoViewController presentViewController:OCMOCK_ANY animated:YES completion:nil]);
}

@end
