//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "NTMessage.h"
#import "NTFactory.h"


@implementation NTMessage

+ (NSString *)primaryKey {
    return @"id";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{
            @"id" : [[NSUUID UUID] UUIDString],
            @"remoteID" : @"",
            @"isRead" : @NO,
            @"roomID" : @"NO_ROOM",
            @"text" : @"",
            @"format" : @(NTMessageFormatText),
            @"createdAt" : [NSDate date]
    };
}

+ (NSDictionary *)JSONInboundMappingDictionary {
    return @{
            @"id" : @"id",
            @"msgid" : @"remoteID",
            @"msg" : @"text",
            @"format" : @"format",
            @"roomid" : @"roomID",
            @"createdat" : @"createdAt",
            @"from" : @"from"
    };
}

#pragma mark - transformer

+ (NSValueTransformer *)createdAtJSONTransformer {
    NSDateFormatter *dateFormatter = [NTFactory dateFormatter];

    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
        if ([value isKindOfClass:[NSString class]]) {
            return [dateFormatter dateFromString:value];
        }
        return nil;
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError **error) {
        return [dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)formatJSONTransformer {
    return [MTLValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            @"TEXT" : @(NTMessageFormatText),
            @"IMAGE" : @(NTMessageFormatImage),
            @"VIDEO" : @(NTMessageFormatVideo),
            @"VOICE" : @(NTMessageFormatVoice),
            @"LINK" : @(NTMessageFormatLink),
            @"GPS" : @(NTMessageFormatGPS),
            @"VCARD" : @(NTMessageFormatVCard),
            @"SYSCODE" : @(NTMessageFormatSysCode),
    } defaultValue:@(NTMessageFormatUnknown) reverseDefaultValue:@"UNKNOWN"];
}

@end