//
// Created by Zhang Zeqing on 4/21/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <UIImage_ImageWithColor/UIImage+ImageWithColor.h>
#import "NTGroupedTableViewCell.h"
#import "UIColor+NTFactory.h"


@implementation NTGroupedTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor nt_groupedTableViewCellBackground];
        self.textLabel.textColor = [UIColor nt_foregroundColor];

        UIView *bgView = [UIView new];
        bgView.backgroundColor = [UIColor nt_groupedTableViewCellSelectedBackground];
        self.selectedBackgroundView = bgView;
    }

    return self;
}


@end