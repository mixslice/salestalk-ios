//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTStore.h"
#import "NTFactory.h"


@interface MessageStore : NTStore

+ (instancetype)store;

- (RLMResults *)getAllWithRoomID:(NSString *)roomID;

- (NSInteger)countOfUnreadMessagesInRoom:(NSString *)roomID;

- (void)markAsRead:(id)o;

- (RACSignal *)messageCountSignal;

- (NSDate *)getLatestMessageCreatedAt;
@end