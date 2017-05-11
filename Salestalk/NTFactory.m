//
// Created by Zhang Zeqing on 4/17/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <UIImage_ImageWithColor/UIImage+ImageWithColor.h>
#import <JDStatusBarNotification/JDStatusBarNotification.h>
#import "NTFactory.h"
#import "UIColor+NTFactory.h"
#import "Constants.h"


@implementation NTFactory

+ (CGFloat)viewPadding {
    return 20.f;
}

+ (CGFloat)buttonHeight {
    return 44.f;
}

+ (void)customizeAppearace {
    [[UIButton appearance] setTintColor:[UIColor nt_primaryReverseColor]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor nt_primaryColor]]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setTintColor:[UIColor nt_primaryForegroundColor]];
    [[UITableView appearance] setSeparatorColor:[UIColor nt_separatorColor]];


    [JDStatusBarNotification setDefaultStyle:^JDStatusBarStyle *(JDStatusBarStyle *style) {

        // main properties
        style.barColor = [UIColor nt_primaryColor];
        style.textColor = [UIColor nt_primaryForegroundColor];

        return style;
    }];
}

+ (NSDictionary *)placeholderAttributes {
    return @{NSForegroundColorAttributeName : [[UIColor nt_primaryForegroundColor] colorWithAlphaComponent:0.5]};
}

+ (CGFloat)tableViewRowHeight {
    return 80;
}

+ (UIView *)titleLogoView {
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-img-small"]];
    logoView.contentMode = UIViewContentModeBottom;
    CGRect logoViewFrame = logoView.frame;
    logoViewFrame.size.height = 44;
    logoView.frame = logoViewFrame;

    return logoView;
}

+ (NSAttributedString *)emptySetTitle:(NSString *)text {
    NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:18.0],
            NSForegroundColorAttributeName: [UIColor nt_primaryForegroundColor]
    };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

+ (UIImage *)defaultBrandImage {
    return [UIImage imageNamed:@"icon-brand-default"];
}

+ (UIImage *)defaultUserImage {
    return [UIImage imageNamed:@"avatar"];
}

+ (UIImage *)defaultBrandCover {
    return [UIImage imageNamed:@"brand-sample-cover"];
}

+ (NSDateFormatter *)dateFormatter {
    // todo: return date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    return dateFormatter;
}

+ (NSString *)currentUserID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults valueForKey:kAuthUserIDKey];
    return userID;
}
@end