//
// Created by Zhang Zeqing on 5/25/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "NTUserStatus.h"


@implementation NTUserStatus

+ (NSString *)primaryKey {
    return @"userID";
}


+ (NSDictionary *)JSONInboundMappingDictionary {
    return @{
            @"userid": @"userID",
            @"status": @"onlineStatus"
    };
}

#pragma mark - transformer

+ (NSValueTransformer *)onlineStatusJSONTransformer {
    return [MTLValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            @"Online": @(NTOnlineStatusOnline)
    } defaultValue:@(NTOnlineStatusOffline) reverseDefaultValue:@"Offline"];
}

@end