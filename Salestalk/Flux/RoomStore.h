//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTStore.h"

@class NTRoom;


@interface RoomStore : NTStore

+ (instancetype)store;

- (void)storeRooms:(id)rooms;

- (RLMResults *)getAll;

- (RLMResults *)getAllEventRoom;

- (RLMResults *)getAllUserRoom;

- (void)recvMessage:(id)data;

- (void)recvMessages:(id)data;

- (RACSignal *)getEventWithRoom:(NTRoom *)room;
@end