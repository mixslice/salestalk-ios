//
// Created by Zhang Zeqing on 4/21/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTSectionHeaderView.h"
#import "UIColor+NTFactory.h"


@implementation NTSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = [UIColor nt_sectionHeaderForegroundColor];

        UIView *bgView = [UIView new];
        bgView.backgroundColor = [UIColor nt_sectionHeaderBackgroundColor];
        self.backgroundView = bgView;
    }

    return self;
}


@end