//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Realm/Realm.h>

@class NTUser;

typedef NS_ENUM(NSInteger, NTMessageType) {
    NTMessageFormatText = 0,
    NTMessageFormatImage,
    NTMessageFormatVideo,
    NTMessageFormatVoice,
    NTMessageFormatLink,
    NTMessageFormatGPS,
    NTMessageFormatVCard,
    NTMessageFormatSysCode,
    NTMessageFormatUnknown
};


@interface NTMessage : RLMObject

@property NSString *id;
@property NSString *remoteID;
@property NSString *roomID;
@property BOOL isRead;
@property NSString *text;
@property NTMessageType format;
@property NSDate *createdAt;
@property NTUser *from;

@end

RLM_ARRAY_TYPE(NTMessage)