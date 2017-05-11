//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Realm/Realm.h>

@class NTMessage;
@class NTEvent;
@protocol NTUser;


@interface NTRoom : RLMObject

@property NSString *id;
@property NSString *eventID;
@property NTMessage *latestMessage;
@property NTEvent *event;

@end

RLM_ARRAY_TYPE(NTRoom)