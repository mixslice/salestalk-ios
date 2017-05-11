//
// Created by Zhang Zeqing on 5/11/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <ReactiveCocoa/NSNotificationCenter+RACSupport.h>
#import <ReactiveCocoa/RACSignal.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <Realm/Realm.h>
#import "NTAccountManager.h"
#import "Constants.h"
#import "NTHTTPSessionManager.h"
#import "NTSocket.h"


@implementation NTAccountManager

+ (instancetype)sharedManager {
    static NTAccountManager *_sharedManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (void)startManage {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    // set current user info
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults valueForKey:kAuthTokenKey];

    // show login
    if (!token) {
        [center postNotificationName:kNTShowLoginNotification object:@NO];
    } else {
        [center postNotificationName:kNTDidLoginNotification object:nil];
    }

    RACSignal *deleteRealmSignal = [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteAllObjects];
        [realm commitWriteTransaction];
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return nil;
    }];

    // logout signal
    [[center
            rac_addObserverForName:kNTDidLogoutNotification object:nil]
            subscribeNext:^(NSNotification *notification) {
                [[RACSignal
                        merge:@[
                                [[NTHTTPSessionManager sharedManager] logoutSignal],
                                [[NTSocket sharedSocket] logoutSignal],
                                deleteRealmSignal
                        ]]
                        subscribeCompleted:^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNTShowLoginNotification object:@YES];
                        }];
            }];
}

@end