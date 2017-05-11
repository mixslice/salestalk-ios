//
// Created by Zhang Zeqing on 5/28/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <M13BadgeView/M13BadgeView.h>
#import <UIImage_ImageWithColor/UIImage+ImageWithColor.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NTTabBarItem.h"
#import "UIColor+NTFactory.h"
#import "UIImage+NTUtilites.h"


@interface NTTabBarItem ()
@property(nonatomic, strong) M13BadgeView *badgeView;
@end

@implementation NTTabBarItem

- (instancetype)initWithItem:(UITabBarItem *)item {
    self = [super init];
    if (self) {
        [self setup];

        // imageView
        [self setImage:[item.image imageWithTintColor:self.foregroundColor] forState:UIControlStateNormal];
        [self setImage:[item.image imageWithTintColor:self.foregroundColor] forState:UIControlStateHighlighted];
        [self setImage:[item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
              forState:UIControlStateSelected];
        [self setImage:[item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
              forState:UIControlStateHighlighted | UIControlStateSelected];

        // background
        [self setBackgroundImage:[UIImage imageWithColor:self.selectedBackgroundColor]
                        forState:UIControlStateSelected];
        [self setBackgroundImage:[UIImage imageWithColor:self.selectedBackgroundColor]
                        forState:UIControlStateHighlighted | UIControlStateSelected];
        [self setBackgroundImage:[UIImage imageWithColor:self.highlightedBackgroundColor]
                        forState:UIControlStateHighlighted];

        _badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _badgeView.font = [UIFont systemFontOfSize:12];
        _badgeView.alignmentShift = CGSizeMake(-15, 4);
        _badgeView.animateChanges = NO;
        _badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
        [self addSubview:_badgeView];

        [RACObserve(item, badgeValue) subscribeNext:^(NSString *badgeValue) {
            self.badgeValue = badgeValue;
        }];
    }

    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor nt_tabBarBackgroundColor];
    self.foregroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    self.selectedForegroundColor = [UIColor nt_primaryForegroundColor];
    self.highlightedBackgroundColor = [UIColor nt_backgroundColor];
    self.selectedBackgroundColor = [UIColor nt_primaryColor];
    self.tintColor = self.selectedForegroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _badgeView.maximumWidth = self.bounds.size.width;
}

- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = [badgeValue mutableCopy];
    self.badgeView.text = badgeValue;
    self.badgeView.hidden = (nil == badgeValue) || [badgeValue isEqualToString:@"0"];
}


@end