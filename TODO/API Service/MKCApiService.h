#import <Foundation/Foundation.h>

typedef void (^APISuccessHandler)(NSURLResponse *response, id responseObject);
typedef void (^APIFailureHandler)(NSError *error);

@interface MKCAPIService : NSObject

+ (instancetype)sharedAPI;

- (NSURLSessionDataTask *)fetchTodoListWithSuccessHandler:(APISuccessHandler)successHandler failureHandler:(APIFailureHandler)failureHandler;

@end
