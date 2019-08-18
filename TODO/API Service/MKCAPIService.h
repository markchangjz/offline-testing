#import <Foundation/Foundation.h>

typedef void (^ApiSuccessHandler)(NSURLResponse *response, id responseObject);
typedef void (^ApiFailureHandler)(NSError *error);

@interface MKCAPIService : NSObject

+ (instancetype)sharedAPI;

- (NSURLSessionDataTask *)fetchTodoListWithSuccessHandler:(ApiSuccessHandler)successHandler failureHandler:(ApiFailureHandler)failureHandler;

@end
