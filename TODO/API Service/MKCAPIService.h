#import <Foundation/Foundation.h>

typedef void (^MKCAPISuccessHandler)(NSURLResponse *response, id responseObject);
typedef void (^MKCAPIFailureHandler)(NSError *error);

@interface MKCAPIService : NSObject

+ (instancetype)sharedAPI;

- (NSURLSessionDataTask *)fetchTodoListWithSuccessHandler:(MKCAPISuccessHandler)successHandler failureHandler:(MKCAPIFailureHandler)failureHandler;

@end
