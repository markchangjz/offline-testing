#import <Foundation/Foundation.h>

@interface MKCTodoCellViewModel : NSObject

@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL completed;

@end

typedef NS_ENUM(NSUInteger, UIState) {
    UIStateLoading = 0,
    UIStateFinish,
    UIStateError
};

@protocol MKCTodoViewModelDelegate

- (void)updateLoadingState;
- (void)showErrorMessageWithError:(NSError *)error;

@end

@interface MKCTodoViewModel : NSObject

- (NSURLSessionDataTask *)fetchData;
- (MKCTodoCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

@property (weak, nonatomic) id <MKCTodoViewModelDelegate> delegate;
@property (assign, nonatomic) UIState currentUiState;
@property (readonly, nonatomic) NSInteger numberOfCells;

@end
