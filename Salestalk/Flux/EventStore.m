//
// Created by Zhang Zeqing on 5/8/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "EventStore.h"
#import "NTAppDispatcher.h"
#import "Constants.h"
#import "NTEvent.h"
#import "RLMObject+JSON.h"


@implementation EventStore

+ (instancetype)store {
    static EventStore *store = nil;
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

            if (actionType == kActionTypeReceiveRawEvents) {
                NSArray *rawEvents = payload[@"rawEvents"];
                [self initEvents:rawEvents];
                [self emit:CHANGE_EVENT];
            }
        }];
    }

    return self;
}

- (void)initEvents:(NSArray *)rawEvents {
    [self.realm beginWriteTransaction];
    [NTEvent createOrUpdateInRealm:self.realm withJSONArray:rawEvents];
    [self.realm commitWriteTransaction];
}

- (RLMResults *)getAllWithBrandID:(NSString *)brandID {
    return [NTEvent objectsInRealm:self.realm
                             where:@"brand.id = %@", brandID];
}
@end