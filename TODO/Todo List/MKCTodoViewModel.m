#import "MKCTodoViewModel.h"
#import "MKCApiService.h"
#import <UIKit/UIKit.h>

@implementation MKCTodoCellViewModel
@end

@interface MKCTodoViewModel()

@property (copy, nonatomic) NSArray<MKCTodoCellViewModel *> *cellViewModels;

@end

@implementation MKCTodoViewModel : NSObject 

- (NSURLSessionDataTask *)fetchData {
    self.currentUiState = UIStateLoading;
    
    NSURLSessionDataTask *dataTask =
    [[MKCApiService sharedApi] fetchTodoListWithSuccessHandler:^(NSURLResponse *response, id responseObject) {
        [self in_processFetchedTodoWithResponseObject:responseObject];
    } failureHandler:^(NSError *error) {
        [self.delegate showErrorMessageWithError:error];
        self.currentUiState = UIStateError;
    }];
    
    return dataTask;
}

- (NSInteger)numberOfCells {
    return self.cellViewModels.count;
}

- (MKCTodoCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellViewModels[indexPath.row];
}

#pragma mark - private function

- (void)in_processFetchedTodoWithResponseObject:(NSArray *)responseObject {
    __block BOOL isInvalidResponseObject = NO;
    
    if (![responseObject isKindOfClass:[NSArray class]]) {
        // Parse JSON Error
        isInvalidResponseObject = YES;
        self.currentUiState = UIStateError;
        return;
    }
    
    NSMutableArray *viewModels = [[NSMutableArray alloc] init];
    [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MKCTodoCellViewModel *viewModel = [[MKCTodoCellViewModel alloc] init];
        
        if (![obj isKindOfClass:[NSDictionary class]]) {
            // Parse JSON Error
            isInvalidResponseObject = YES;
            self.currentUiState = UIStateError;
            *stop = YES;
            return;
        }
        
        if (obj[@"title"] == nil || obj[@"completed"] == nil) {
            // Parse JSON Error
            isInvalidResponseObject = YES;
            self.currentUiState = UIStateError;
            *stop = YES;
            return;
        }
        
        viewModel.title = obj[@"title"];
        viewModel.completed = [obj[@"completed"] boolValue];

        [viewModels addObject:viewModel];
    }];
    
    if (!isInvalidResponseObject) {
        self.cellViewModels = viewModels;
        self.currentUiState = UIStateFinish;
    }
}

#pragma mark - setter

- (void)setCurrentUiState:(UIState)currentUiState {
    _currentUiState = currentUiState;
    
    [self.delegate updateLoadingState];
}

#pragma mark - lazy instance

- (NSArray<MKCTodoCellViewModel *> *)cellViewModels {
    if (!_cellViewModels) {
        _cellViewModels = [[NSArray alloc] init];
    }
    return _cellViewModels;
}

@end
