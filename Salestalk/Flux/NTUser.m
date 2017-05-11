//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <JSQMessagesViewController/JSQMessagesAvatarImage.h>
#import <JSQMessagesViewController/JSQMessagesCollectionViewFlowLayout.h>
#import <JSQMessagesViewController/JSQMessagesAvatarImageFactory.h>
#import "NTUser.h"


@implementation NTUser

+ (NSString *)primaryKey {
    return @"id";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{
            @"id" : [[NSUUID UUID] UUIDString],
            @"name": @"Unknown",
            @"avatar": @"",
            @"mobile": @"",
            @"email": @"",
            @"gender": @(NTUserGenderTypeUnknown)
    };
}

+ (NSArray *)ignoredProperties {
    return @[@"avatarImage"];
}

+ (NSDictionary *)JSONInboundMappingDictionary {
    return @{
            @"id": @"id",
            @"userName": @"name",
            @"avatar": @"avatar",
            @"mobile": @"mobile",
            @"email": @"email",
            @"gender": @"gender"
    };
}

#pragma mark - transformer

+ (NSValueTransformer *)genderJSONTransformer {
    return [MTLValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            @"MALE": @(NTUserGenderTypeMale),
            @"FEMALE": @(NTUserGenderTypeFemale)
    } defaultValue:@(NTUserGenderTypeUnknown) reverseDefaultValue:@"UNKNOWN"];
}

#pragma mark - Avatar Image

- (JSQMessagesAvatarImage *)messageAvatarImage {
    JSQMessagesAvatarImage *avatarImage = [self avatarImageWithDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    return [JSQMessagesAvatarImageFactory
            avatarImageWithPlaceholder:avatarImage.avatarImage diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

- (UIImage *)avatarImage {
    return [self avatarImageWithDiameter:50].avatarImage;
}

- (UIImage *)largeAvatarImage {
    return [self avatarImageWithDiameter:75].avatarImage;
}


- (JSQMessagesAvatarImage *)avatarImageWithDiameter:(NSUInteger)diameter {
    NSString *userInitials = self.name.length > 0 ? [self.name substringWithRange:NSMakeRange(0, 1)] : self.name;
    userInitials = [userInitials uppercaseString];

    return [JSQMessagesAvatarImageFactory
            avatarImageWithUserInitials:userInitials
                        backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                              textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                   font:[UIFont systemFontOfSize:0.47 * diameter]
                               diameter:diameter];
}

- (NSURL *)avatarURL {
    return [NSURL URLWithString:self.avatar];
}


@end