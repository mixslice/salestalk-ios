//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTRoom.h"
#import "NTMessage.h"
#import "NTEvent.h"
#import "NTUser.h"


@implementation NTRoom

+ (NSString *)primaryKey {
    return @"id";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{
            @"id" : [[NSUUID UUID] UUIDString],
            @"eventID" : @""
    };
}

+ (NSDictionary *)JSONInboundMappingDictionary {
    return @{
            @"roomid" : @"id",
            @"eventid" : @"eventID"
    };
}

@end