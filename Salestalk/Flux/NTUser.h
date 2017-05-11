//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;
#import <Realm/Realm.h>

@class JSQMessagesAvatarImage;

typedef NS_ENUM(NSInteger, NTUserGenderType) {
    NTUserGenderTypeUnknown = 0,
    NTUserGenderTypeMale,
    NTUserGenderTypeFemale
};

@interface NTUser : RLMObject

@property NSString *id;
@property NSString *name;
@property NSString *avatar;
@property NSString *mobile;
@property NSString *email;
@property NTUserGenderType gender;
@property(readonly) JSQMessagesAvatarImage *messageAvatarImage;
@property(readonly) UIImage *avatarImage;
@property(readonly) UIImage *largeAvatarImage;
@property(readonly) NSURL *avatarURL;

@end

RLM_ARRAY_TYPE(NTUser)