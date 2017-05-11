//
// Created by Zhang Zeqing on 4/26/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import "NTCollectionSupplementaryView.h"
#import "UIColor+NTFactory.h"
#import "NTFactory.h"


@implementation NTCollectionSupplementaryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textLabel = ({
            UILabel *label = [UILabel new];
            label.textColor = [UIColor nt_foregroundColor];
            [self addSubview:label];
            label;
        });

        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(5, [NTFactory viewPadding], 0, [NTFactory viewPadding]));
        }];
    }

    return self;
}


@end