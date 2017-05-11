//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTEvent.h"
#import "NTBrand.h"


@implementation NTEvent

+ (NSString *)primaryKey {
    return @"id";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{
            @"id" : [[NSUUID UUID] UUIDString],
            @"title": @"",
            @"logo": @"",
            @"contentURL": @"",
            @"summary": @""
    };
}

+ (NSDictionary *)JSONInboundMappingDictionary {
    return @{
            @"id": @"id",
            @"title": @"title",
            @"eventLogo": @"logo",
            @"contentRef": @"contentURL",
            @"summary": @"summary",
            @"brand": @"brand"
    };
}

@end