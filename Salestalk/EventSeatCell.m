//
// Created by Zhang Zeqing on 4/26/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <Masonry/NSArray+MASAdditions.h>
#import "EventSeatCell.h"
#import "UIColor+NTFactory.h"


@implementation EventSeatCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *topSpace = [UIView new];
        UIView *bottomSpace = [UIView new];
        [self addSubview:topSpace];
        [self addSubview:bottomSpace];

        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = [UIColor nt_primaryColor];
        backgroundView.clipsToBounds = YES;
        backgroundView.layer.cornerRadius = 10.f;
        self.selectedBackgroundView = backgroundView;


        _imageView = ({
            UIImageView *imageView = [UIImageView new];
            [self addSubview:imageView];
            imageView;
        });

        _textLabel = ({
            UILabel *label = [UILabel new];
            label.textColor = [UIColor nt_foregroundColor];
            label.font = [UIFont systemFontOfSize:13];
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
            label;
        });

        [topSpace mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX;
            make.top.equalTo(self);
            make.width.equalTo(self);
        }];

        [bottomSpace mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX;
            make.bottom.equalTo(self);
            make.width.equalTo(topSpace);
            make.height.equalTo(topSpace).with.offset(-4);
        }];


        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topSpace.mas_bottom);
            make.width.and.height.equalTo(@50);
            make.centerX;
        }];

        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imageView.mas_bottom).with.offset(5);
            make.bottom.equalTo(bottomSpace.mas_top);
            make.centerX;
            make.width.lessThanOrEqualTo(self.contentView);
        }];
    }

    return self;
}


@end