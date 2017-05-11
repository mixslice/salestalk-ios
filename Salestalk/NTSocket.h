//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "SocketShuttle+RACSignalSupport.h"
#import "NTSocketShuttle.h"


@interface NTSocket : NTSocketShuttle

+ (instancetype)sharedSocket;

- (RACSignal *)getEventUsersSignalWithEventID:(NSString *)eventID;

- (void)subscribeUsers:(NSArray *)userIds;

- (void)unSubscribeUsers:(NSArray *)eventID;

- (RACSignal *)createRoomWithEventID:(NSString *)eventID andUserID:(NSString *)userID;

- (void)sendMessageWithRoomID:(NSString *)roomID
                         text:(NSString *)text
                         uuid:(NSString *)uuid;

- (RACSignal *)logoutSignal;

- (void)sendOfflineMessageRequest;
@end