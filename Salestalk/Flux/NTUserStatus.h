//
// Created by Zhang Zeqing on 5/25/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Realm/Realm.h>
#import "NTFactory.h"


@interface NTUserStatus : RLMObject

@property NSString *userID;
@property NTOnlineStatus onlineStatus;

@end

RLM_ARRAY_TYPE(NTUserStatus)