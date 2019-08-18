#import <Foundation/Foundation.h>

typedef void (^ApiSuccessHandler)(NSURLResponse *response, id responseObject);
typedef void (^ApiFailureHandler)(NSError *error);

@interface MKCAPIService : NSObject

+ (instancetype)sharedApi;

- (NSURLSessionDataTask *)fetchTodoListWithSuccessHandler:(ApiSuccessHandler)successHandler failureHandler:(ApiFailureHandler)failureHandler;

@end
