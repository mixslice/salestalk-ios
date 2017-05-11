//
// Created by Zhang Zeqing on 5/4/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import "BrandHeaderView.h"
#import "NTFactory.h"
#import "UIView+UIImageEffects.h"


@interface BrandHeaderView ()
@property(nonatomic, strong) UIView *blurView;
@end

@implementation BrandHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [self addSubview:imageView];
            imageView;
        });

        _blurView = ({
            UIView *blurView = [UIView blurViewWithStyle:UIBlurEffectStyleDark];
            [_backgroundImageView addSubview:blurView];
            blurView;
        });


        _imageView = ({
            UIImageView *imageView = [UIImageView new];
            [self addSubview:imageView];
            imageView;
        });

        _textLabel = ({
            UILabel *label = [UILabel new];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:24];
            [self addSubview:label];
            label;
        });

        // constraints

        [_blurView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_backgroundImageView);
        }];

        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY;
            make.left.equalTo(_imageView.mas_right).with.offset([NTFactory viewPadding]);
        }];

        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.left.equalTo(self).with.offset([NTFactory viewPadding]);
        }];

        [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.and.right.equalTo(self);
            make.bottom.equalTo(self).with.offset(5);
        }];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat percent = MIN(1, MAX(0, (self.frame.size.height - 160) / 100.f));
    self.imageView.alpha = 1 - percent;
    self.blurView.alpha = 1 - percent;
    self.textLabel.alpha = 1 - percent;
}


@end