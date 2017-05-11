//
// Created by zzq889 on 10/1/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import "NTHTTPSessionManager.h"
#import "JSONResponseSerializerWithData.h"
#import "Constants.h"
#import "BrandActions.h"
#import "NTAPIConstants.h"
#import "AFHTTPSessionManager+RACSupport.h"
#import "EventActions.h"
#import "UserActions.h"
#import "EventStore.h"
#import "NTEvent.h"
#import "RLMObject+JSON.h"
#import <CocoaLumberjack/CocoaLumberjack.h>


@implementation NTHTTPSessionManager

+ (instancetype)sharedManager {
    static NTHTTPSessionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
    });

    return sharedManager;
}

- (id)initWithBaseURL:(NSURL *)url {
    DDLogVerbose(@"URL_ROOT: %@", url);
    self = [super initWithBaseURL:url];
    if (self) {
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [JSONResponseSerializerWithData serializer];

        // for oauth token
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [defaults valueForKey:kAuthTokenKey];

        if (token) {
            DDLogVerbose(@"token: %@", token);
            [self.requestSerializer setValue:[NSString stringWithFormat:@"TOKEN %@", token] forHTTPHeaderField:@"Authorization"];
        }
    }

    return self;
}

#pragma mark - Authenticate

- (RACSignal *)authenticateWithPath:(NSString *)path
                         parameters:(NSDictionary *)parameters {

    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        NSURLSessionDataTask *task =
                [self POST:path
                parameters:parameters
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       // set OAuth Token for client
                       NSDictionary *JSON = responseObject;
                       NSString *token = [JSON valueForKey:@"token"];

                       // get user info
                       NSString *userID = [JSON valueForKey:@"id"];

                       // store auth info
                       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                       [defaults setValue:userID forKey:kAuthUserIDKey];
                       [defaults setValue:token forKey:kAuthTokenKey];
                       [defaults synchronize];

                       // store user
                       [UserActions receiveUser:JSON];

                       [self.requestSerializer setValue:[NSString stringWithFormat:@"TOKEN %@", token]
                                     forHTTPHeaderField:@"Authorization"];

                       // send login notification
                       [[NSNotificationCenter defaultCenter] postNotificationName:kNTDidLoginNotification object:nil];

                       // call success block
                       [subscriber sendNext:responseObject];
                       [subscriber sendCompleted];
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       [subscriber sendError:error];
                   }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];

    }] setNameWithFormat:@"%@ -authenticateWithPath: %@, parameters: %@", self.class, path, parameters];
}

- (RACSignal *)registerWithPhone:(NSString *)phone verifyCode:(NSString *)code {

    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:phone forKey:@"mobile"];
    return [[self authenticateWithPath:[NSString stringWithFormat:@"%@/%@", kRegisterURLString, code]
                            parameters:mutableParameters]
            setNameWithFormat:@"%@ -registerWithUserName: %@ verifyCode: %@", self.class, phone, code];
}


- (RACSignal *)loginWithPhone:(NSString *)phone verifyCode:(NSString *)code {

    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:phone forKey:@"mobile"];
    return [[self authenticateWithPath:[NSString stringWithFormat:@"%@/%@", kLoginURLString, code]
                            parameters:mutableParameters]
            setNameWithFormat:@"%@ -loginWithUserName: %@ verifyCode: %@", self.class, phone, code];
}

- (RACSignal *)logoutSignal {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        // delete persistent data
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [defaults removePersistentDomainForName:appDomain];

        [self.requestSerializer clearAuthorizationHeader];

        [subscriber sendCompleted];
        return nil;
    }];
}


#pragma mark - specific request

- (void)sendDeviceToPushServer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [defaults valueForKey:kDeviceTokenKey];
    NSString *token = [defaults valueForKey:kAuthTokenKey];


    if (deviceToken && token) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"token"] = deviceToken;

        [self POST:kDeviceTokenURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            DDLogVerbose(@"deviceToken uploaded successfully");
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DDLogError(@"deviceToken failed to upload: %@", error);
        }];
    }
}

#pragma mark - View specific

- (void)getAllBrands {
    // get brands from server
    [[self rac_GET:kFeatureBrandsURLString parameters:nil] subscribeNext:^(id x) {
        RACTupleUnpack(id responseObject, NSURLResponse *response) = x;
        [BrandActions receiveAll:responseObject];
    }];
}

- (RACSignal *)getMyBrands {
    return [self rac_GET:kMyBrandsURLString parameters:nil];
}

- (void)getEventsByBrandID:(NSString *)brandID {
    [[self rac_GET:[NSString stringWithFormat:kBrandEventsURLFormatString, brandID] parameters:nil] subscribeNext:^(id x) {
        RACTupleUnpack(id responseObject, NSURLResponse *response) = x;
        [EventActions receiveAll:responseObject];
    }];
}

- (RACSignal *)getEventByEventID:(NSString *)eventID {
    return [[self rac_GET:[NSString stringWithFormat:kEventsURLFormatString, eventID] parameters:nil]
            flattenMap:^RACStream *(id value) {
                RACTupleUnpack(id responseObject, NSURLResponse *response) = value;

                EventStore *store = [EventStore store];
                return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

                    [store.realm beginWriteTransaction];
                    NTEvent *event = [NTEvent createOrUpdateInRealm:store.realm withJSONDictionary:responseObject];
                    [store.realm commitWriteTransaction];

                    [subscriber sendNext:event];
                    [subscriber sendCompleted];
                    return nil;
                }];
            }];
}

#pragma mark - brand follow/unfollow

- (RACSignal *)followBrandWithID:(NSString *)brandID follow:(BOOL)follow {
    NSString *brandFollowURLStringFormat = kBrandUnFollowURLString;
    if (follow) {
        brandFollowURLStringFormat = kBrandFollowURLString;
    }
    return [self rac_POST:[NSString stringWithFormat:brandFollowURLStringFormat, brandID] parameters:nil];
}

@end