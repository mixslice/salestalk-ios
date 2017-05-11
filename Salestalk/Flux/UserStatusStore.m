//
// Created by Zhang Zeqing on 5/25/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "UserStatusStore.h"
#import "NTAppDispatcher.h"
#import "Constants.h"
#import "NTUserStatus.h"
#import "RLMObject+JSON.h"


@implementation UserStatusStore

+ (instancetype)store {
    static UserStatusStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [self new];
    });

    return store;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.realm = [RLMRealm inMemoryRealmWithIdentifier:kInMemoryRealmIdentifier];

        NTAppDispatcher *dispatcher = [NTAppDispatcher sharedDispatcher];

        @weakify(self);
        self.dispatchToken = [dispatcher registerCallback:^(NSDictionary *payload) {
            @strongify(self);
            NSString *actionType = payload[kActionTypeKey];

            if (actionType == kActionTypeUpdateUserStatus) {
                id message = payload[@"message"];
                [self updateStatusForUser:message];
                [self emit:CHANGE_EVENT];
            }
        }];
    }

    return self;
}

- (void)updateStatusForUser:(id)message {
    [self.realm beginWriteTransaction];
    [NTUserStatus createOrUpdateInRealm:self.realm
                     withJSONDictionary:message];
    [self.realm commitWriteTransaction];
}

@end