//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import "BrandCell.h"
#import "UIColor+NTFactory.h"
#import "NTFactory.h"


@implementation BrandCell {
@private
    UILabel *_textLabel;
    UIImageView *_imageView;
}

@synthesize textLabel = _textLabel;
@synthesize imageView = _imageView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self addSubview:imageView];
            imageView;
        });

        _textLabel = ({
            UILabel *textLabel = [UILabel new];
            textLabel.font = [UIFont systemFontOfSize:17];
            textLabel.textColor = [UIColor nt_foregroundColor];
            [self addSubview:textLabel];
            textLabel;
        });

        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY;
            make.width.and.height.equalTo(@50);
            make.left.equalTo(@(self.separatorInset.left));
        }];

        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY;
            make.left.equalTo(_imageView.mas_right).equalTo(@15);
        }];

        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
        self.imageView.image = [NTFactory defaultBrandImage];
    }

    return self;
}


@end