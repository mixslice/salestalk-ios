//
// Created by Zhang Zeqing on 4/19/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTReverseButton.h"
#import "UIColor+NTFactory.h"
#import "UIImage+NTUtilites.h"


@implementation NTReverseButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self setTitleColor:[UIColor nt_primaryReverseColor] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"button-white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"button-white-highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        self.tintColor = [UIColor nt_primaryForegroundColor];
    }

    return self;
}

+ (UIButton *)systemButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setBackgroundImage:[UIImage imageNamed:@"button-white"] forState:UIControlStateNormal];
    return button;
}


@end