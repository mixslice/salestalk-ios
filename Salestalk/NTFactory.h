//
// Created by Zhang Zeqing on 4/17/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, NTOnlineStatus) {
    NTOnlineStatusOffline = 0,
    NTOnlineStatusOnline,
    NTOnlineStatusAway
};

@interface NTFactory : NSObject

+ (CGFloat)viewPadding;
+ (CGFloat)buttonHeight;

+ (void)customizeAppearace;

+ (NSDictionary *)placeholderAttributes;

+ (CGFloat)tableViewRowHeight;

+ (UIView *)titleLogoView;

+ (NSAttributedString *)emptySetTitle:(NSString *)text;

+ (UIImage *)defaultBrandImage;
+ (UIImage *)defaultUserImage;
+ (UIImage *)defaultBrandCover;

+ (NSDateFormatter *)dateFormatter;

+ (NSString *)currentUserID;
@end