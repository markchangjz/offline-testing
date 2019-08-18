#import "MKCAPIService.h"

@interface MKCAPIService()

@property (copy, nonatomic) NSString *apiHost;

@end

@implementation MKCAPIService

+ (instancetype)sharedApi {
    static MKCAPIService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MKCAPIService alloc] init];
    });
    return instance;
}

- (NSURLSessionDataTask *)fetchTodoListWithSuccessHandler:(ApiSuccessHandler)successHandler failureHandler:(ApiFailureHandler)failureHandler {
    NSString *urlString = [NSString stringWithFormat:@"%@/todos", self.apiHost];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failureHandler(error);
        } else {
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            successHandler(response, responseObject);
        }
    }];
    [dataTask resume];
    
    return dataTask;
}

#pragma mark - getter

- (NSString *)apiHost {
    return [[NSBundle mainBundle].infoDictionary[@"API HOST"] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
}

@end
