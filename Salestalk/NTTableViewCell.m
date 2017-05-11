//
// Created by Zhang Zeqing on 4/20/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <UIImage_ImageWithColor/UIImage+ImageWithColor.h>
#import "NTTableViewCell.h"
#import "UIColor+NTFactory.h"


@implementation NTTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor nt_foregroundColor];
        self.detailTextLabel.textColor = [[UIColor nt_foregroundColor] colorWithAlphaComponent:0.66];

        UIView *bgView = [UIView new];
        bgView.backgroundColor = [UIColor nt_selectedBackgroundColor];
        self.selectedBackgroundView = bgView;
    }

    return self;
}


@end