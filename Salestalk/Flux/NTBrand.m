//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTBrand.h"


@implementation NTBrand

+ (NSString *)primaryKey {
    return @"id";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{
            @"id" : [[NSUUID UUID] UUIDString],
            @"logo" : @"",
            @"coverPic" : @"",
            @"name": @"",
            @"desc": @""
    };
}

+ (NSDictionary *)JSONInboundMappingDictionary {
    return @{
            @"id": @"id",
            @"logo": @"logo",
            @"coverPic": @"coverPic",
            @"name": @"name",
            @"desc": @"desc"
    };
}

@end