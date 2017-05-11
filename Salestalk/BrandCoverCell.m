//
// Created by Zhang Zeqing on 5/6/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "BrandCoverCell.h"
#import "UIColor+NTFactory.h"


@implementation BrandCoverCell {
@private
    UIImageView *_imageView;
}

@synthesize imageView = _imageView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.backgroundColor = [UIColor clearColor];

        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont systemFontOfSize:24];

        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        self.backgroundView = _imageView;

        UIView *bgView = [UIView new];
        bgView.backgroundColor = [UIColor nt_selectedBackgroundColor];
        self.selectedBackgroundView = bgView;
    }

    return self;
}


@end