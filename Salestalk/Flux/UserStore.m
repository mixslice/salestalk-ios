//
// Created by Zhang Zeqing on 5/8/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "UserStore.h"
#import "NTUser.h"
#import "NTAppDispatcher.h"
#import "Constants.h"
#import "RLMObject+JSON.h"


@implementation UserStore

+ (instancetype)store {
    static UserStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [self new];
    });

    return store;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.realm = [RLMRealm defaultRealm];

        NTAppDispatcher *dispatcher = [NTAppDispatcher sharedDispatcher];

        @weakify(self);
        self.dispatchToken = [dispatcher registerCallback:^(NSDictionary *payload) {
            @strongify(self);
            NSString *actionType = payload[kActionTypeKey];

            if (actionType == kActionTypeReceiveRawUsers) {
                NSArray *rawUsers = payload[@"rawUsers"];
                [self initUsers:rawUsers];
                [self emit:CHANGE_EVENT];
            }
            else if (actionType == kActionTypeReceiveRawUser) {
                NSDictionary *rawUser = payload[@"rawUser"];
                [self initUser:rawUser];
                [self emit:CHANGE_EVENT];
            }
        }];
    }

    return self;
}

- (void)initUsers:(NSArray *)rawUsers {
    [self.realm beginWriteTransaction];
    [NTUser createOrUpdateInRealm:self.realm withJSONArray:rawUsers];
    [self.realm commitWriteTransaction];
}

- (void)initUser:(NSDictionary *)rawUser {
    [self.realm beginWriteTransaction];
    [NTUser createOrUpdateInRealm:self.realm withJSONDictionary:rawUser];
    [self.realm commitWriteTransaction];
}

@end