//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Realm/RLMRealm.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <NSDate_Extensions/NSDate-Utilities.h>
#import "MessageStore.h"
#import "NTAppDispatcher.h"
#import "Constants.h"
#import "NTMessage.h"
#import "RLMObject+JSON.h"
#import "RoomStore.h"
#import "NTRoom.h"


@interface MessageStore ()
@property (nonatomic) NSInteger unreadCount;
@property (nonatomic, strong) RACSubject *messageCountSubject;
@end

@implementation MessageStore

static NSInteger const kCreateBatchSize = 100;

+ (instancetype)store {
    static MessageStore *store = nil;
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

        _messageCountSubject = [RACSubject subject];

        [[[NSNotificationCenter defaultCenter]
                rac_addObserverForName:kNTDidLoginNotification object:nil] subscribeNext:^(id x) {
            _unreadCount = 0;
            [self emitMessageCount];
        }];

        NTAppDispatcher *dispatcher = [NTAppDispatcher sharedDispatcher];

        @weakify(self);
        self.dispatchToken = [dispatcher registerCallback:^(NSDictionary *payload) {
            @strongify(self);
            NSString *actionType = payload[kActionTypeKey];

            if (actionType == kActionTypeClickRoom) {
                // todo
                [self emit:CHANGE_EVENT];
            }
            else if (actionType == kActionTypeCreateMessage) {
                // create message
                id message = payload[@"message"];
                [self createMessage:message];
                [self emit:CHANGE_EVENT];
            }
            else if (actionType == kActionTypeReceiveRawMessages) {
                [dispatcher waitFor:@[ [RoomStore store].dispatchToken ]];
                // receive message
                id data = payload[@"rawMessages"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    [self addMessage:data];
                } else if ([data isKindOfClass:[NSArray class]]) {
                    [self addMessages:data];
                }
//                [dispatcher waitFor:@[[RoomStore store].dispatchToken]];
                [self emit:CHANGE_EVENT];
            }
            else if (actionType == kActionTypeMarkAsRead) {
                id message = payload[@"message"];
                [self markAsRead:message];
            }
        }];
    }

    return self;
}

- (void)markAsRead:(NTMessage *)message {
    DDLogVerbose(@"read: %@", message.id);
    [self.realm beginWriteTransaction];
    message.isRead = YES;
    [self.realm commitWriteTransaction];

    _unreadCount -= 1;
    [self emitMessageCount];
}

#pragma mark - Helper

- (void)createMessage:(id)rawMessage {
    [self.realm beginWriteTransaction];
    NTMessage *newMessage = [NTMessage createOrUpdateInRealm:self.realm
                                                   withValue:rawMessage];
    DDLogVerbose(@"did save msg: %@", newMessage);
    [self.realm commitWriteTransaction];
}

- (BOOL)isValidMessage:(id)message {
    id from = [message valueForKey:@"from"];
    return nil != from || [from isKindOfClass:[NSDictionary class]] || [from isKindOfClass:[NSString class]];
}

- (void)addMessage:(id)rawMessage {
    if (![self isValidMessage:rawMessage]) {
        return;
    }

    id uuid = [rawMessage valueForKey:@"timeid"];
    id remoteID = [rawMessage valueForKey:@"msgid"];

    NTMessage *msg;
    if (uuid && [uuid isKindOfClass:[NSString class]]) {
        msg = [NTMessage objectInRealm:self.realm forPrimaryKey:uuid];
    }

    if (!msg && remoteID && [remoteID isKindOfClass:[NSString class]]) {
        msg = [NTMessage objectsInRealm:self.realm where:@"remoteID = %@", remoteID].lastObject;
    }

    NSMutableDictionary *mutableMessage = [rawMessage mutableCopy];

    // get msg from realm
    if (msg) {
        [mutableMessage setValue:msg.id forKey:@"id"];
    }

    // parse from
    id from = [rawMessage valueForKey:@"from"];
    if ([from isKindOfClass:[NSString class]]) {
        [mutableMessage setValue:@{@"id" : from} forKey:@"from"];
    } else {
        return;
    }

    // save to realm
    [self.realm beginWriteTransaction];

    NTMessage *newMessage = [NTMessage createOrUpdateInRealm:self.realm
                                          withJSONDictionary:[mutableMessage copy]];
    NTRoom *room = [NTRoom objectInRealm:self.realm forPrimaryKey:newMessage.roomID];
    if (!room.latestMessage || [room.latestMessage.createdAt isEarlierThanDate:newMessage.createdAt]) {
        room.latestMessage = newMessage;
    }
    [self.realm commitWriteTransaction];

    DDLogVerbose(@"did save msg: %@", newMessage);

    // message count increase
    if (!msg) {
        _unreadCount += 1;
        [self emitMessageCount];
    }
}

- (void)addMessages:(NSArray *)array {
    NSInteger count = array.count;

    for (NSInteger index=0; index*kCreateBatchSize<count; index++) {
        NSInteger size = MIN(kCreateBatchSize, count-index*kCreateBatchSize);
        @autoreleasepool {
            for (NSInteger subIndex=0; subIndex<size; subIndex++) {
                NSDictionary *dictionary = array[index*kCreateBatchSize+subIndex];
                [self addMessage:dictionary];
            }
        }
    }
}

#pragma mark - public

- (RLMResults *)getAllWithRoomID:(NSString *)roomID {
    return [NTMessage objectsInRealm:self.realm where:@"roomID = %@", roomID];
}

- (NSInteger)countOfUnreadMessagesInRoom:(NSString *)roomID {
    return [NTMessage objectsInRealm:self.realm where:@"roomID = %@ AND isRead = NO", roomID].count;
}

#pragma mark - Signal

- (void)emitMessageCount {
    [self.messageCountSubject sendNext:[NSString stringWithFormat:@"%d", self.unreadCount]];
}

- (NSInteger)unreadCount {
    if (!_unreadCount) {
        _unreadCount = [NTMessage objectsInRealm:self.realm where:@"isRead = NO"].count;
    }
    return _unreadCount;
}


- (RACSignal *)messageCountSignal {
    return [self.messageCountSubject startWith:[NSString stringWithFormat:@"%d", self.unreadCount]];
}


- (NSDate *)getLatestMessageCreatedAt {
    NTMessage *message = [[NTMessage allObjectsInRealm:self.realm]
            sortedResultsUsingProperty:@"createdAt" ascending:YES].lastObject;
    return message.createdAt;
}
@end