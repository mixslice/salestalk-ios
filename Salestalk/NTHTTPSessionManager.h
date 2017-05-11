//
// Created by zzq889 on 10/1/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <AFNetworking/AFHTTPSessionManager.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


@interface NTHTTPSessionManager : AFHTTPSessionManager

+ (instancetype)sharedManager;

- (RACSignal *)authenticateWithPath:(NSString *)path
                         parameters:(NSDictionary *)parameters;

- (RACSignal *)loginWithPhone:(NSString *)phone verifyCode:(NSString *)code;

- (RACSignal *)registerWithPhone:(NSString *)phone verifyCode:(NSString *)code;

- (RACSignal *)logoutSignal;

#pragma mark - specific request

- (void)sendDeviceToPushServer;

#pragma mark - View specific

- (void)getAllBrands;

- (RACSignal *)getMyBrands;

- (void)getEventsByBrandID:(NSString *)brandID;

- (RACSignal *)getEventByEventID:(NSString *)eventID;

- (RACSignal *)followBrandWithID:(NSString *)brandID follow:(BOOL)follow;
@end