//
// Created by Zhang Zeqing on 5/7/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>

@class NTSocket;
@class RLMResults;
@class NTUser;


@interface NTMessagesViewController : JSQMessagesViewController
@property(nonatomic, copy) NSString *roomID;

- (instancetype)initWithRoomID:(NSString *)roomID;

+ (instancetype)controllerWithRoomID:(NSString *)roomID;

@end