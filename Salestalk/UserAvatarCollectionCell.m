//
// Created by Zhang Zeqing on 5/8/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import "UserAvatarCollectionCell.h"
#import "NTCircleView.h"
#import "UIColor+NTFactory.h"

@interface UserAvatarCollectionCell ()
@property(nonatomic, weak) NTCircleView *statusDot;
@end

@implementation UserAvatarCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            [self addSubview:imageView];
            imageView;
        });

        _textLabel = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont systemFontOfSize:13];
            label.textColor = [UIColor nt_primaryForegroundColor];
            [self addSubview:label];
            label;
        });

        _statusDot = ({
            NTCircleView *dotView = [NTCircleView new];
            [self.imageView addSubview:dotView];
            dotView;
        });

        // constraints
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@20);
            make.centerX;
            make.width.and.height.equalTo(@50);
        }];

        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX;
            make.top.equalTo(_imageView.mas_bottom);
        }];

        [_statusDot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.imageView).with.offset(0);
            make.left.equalTo(self.imageView).with.offset(0);
            make.width.equalTo(@15);
            make.height.equalTo(@15);
        }];

        self.onlineStatus = NTOnlineStatusOffline;
    }

    return self;
}

- (void)setOnlineStatus:(NTOnlineStatus)onlineStatus {
    _onlineStatus = onlineStatus;

    switch (onlineStatus) {
        case NTOnlineStatusOffline:{
            _statusDot.tintColor = [UIColor nt_grayColor];
            break;
        }
        case NTOnlineStatusOnline:{
            _statusDot.tintColor = [UIColor nt_greenColor];
            break;
        }
        case NTOnlineStatusAway:{
            _statusDot.tintColor = [UIColor nt_redColor];
            break;
        }
    };
}


@end