//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <ObjectiveSugar/NSArray+ObjectiveSugar.h>
#import "RoomStore.h"
#import "NTAppDispatcher.h"
#import "Constants.h"
#import "NTRoom.h"
#import "RLMObject+JSON.h"
#import "NTHTTPSessionManager.h"


@implementation RoomStore

static NSInteger const kCreateBatchSize = 100;

+ (instancetype)store {
    static RoomStore *store = nil;
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
            if (actionType == kActionTypeReceiveRawRooms) {
                id rawRooms = payload[@"rawRooms"];
                [self storeRooms:rawRooms];
                [self emit:CHANGE_EVENT];
            }
            else if (actionType == kActionTypeClickRoom) {
                // todo
                [self emit:CHANGE_EVENT];
            }
            else if (actionType == kActionTypeReceiveRawMessages) {
                id data = payload[@"rawMessages"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    [self recvMessage:data];
                } else if ([data isKindOfClass:[NSArray class]]) {
                    [self recvMessages:data];
                }
                [self emit:CHANGE_EVENT];
            }
        }];
    }

    return self;
}

- (void)recvMessages:(NSArray *)array {
    NSInteger count = array.count;

    for (NSInteger index=0; index*kCreateBatchSize<count; index++) {
        NSInteger size = MIN(kCreateBatchSize, count-index*kCreateBatchSize);
        @autoreleasepool {
            for (NSInteger subIndex=0; subIndex<size; subIndex++) {
                NSDictionary *dictionary = array[index*kCreateBatchSize+subIndex];
                [self recvMessage:dictionary];
            }
        }
    }
}

- (void)recvMessage:(NSDictionary *)data {
    NSString *roomID = data[@"roomid"];
    [self.realm beginWriteTransaction];
    [NTRoom createOrUpdateInRealm:self.realm
               withJSONDictionary:@{@"roomid" : roomID}];

    [self.realm commitWriteTransaction];
}

- (void)storeRooms:(id)rooms {
    [self.realm beginWriteTransaction];
    [NTRoom createOrUpdateInRealm:self.realm
                    withJSONArray:rooms];
    [self.realm commitWriteTransaction];
}

- (RLMResults *)getAll {
    return [NTRoom objectsInRealm:self.realm where:@"NOT latestMessage = nil"];
}

- (RLMResults *)getAllEventRoom {
    return [NTRoom objectsInRealm:self.realm where:@"NOT latestMessage = nil AND NOT eventID = %@", @""];
}

- (RLMResults *)getAllUserRoom {
    return [NTRoom objectsInRealm:self.realm where:@"NOT latestMessage = nil AND eventID = %@", @""];
}

- (RACSignal *)getEventWithRoom:(NTRoom *)room {
    @weakify(self);
    if (room.event) {
        return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
            @strongify(self);
            [subscriber sendNext:room.event];
            [subscriber sendCompleted];
            return nil;
        }];
    } else {
        return [[[NTHTTPSessionManager sharedManager] getEventByEventID:room.eventID] map:^id(NTEvent *event) {
            @strongify(self);
            [self.realm beginWriteTransaction];
            room.event = event;
            [self.realm commitWriteTransaction];
            return event;
        }];
    }
}
@end