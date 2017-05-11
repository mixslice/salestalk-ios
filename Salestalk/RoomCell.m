//
// Created by Zhang Zeqing on 4/21/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <M13BadgeView/M13BadgeView.h>
#import "RoomCell.h"
#import "UIColor+NTFactory.h"
#import "NTCircleView.h"

@interface RoomCell ()
@property(nonatomic, strong) M13BadgeView *badgeView;
@end

@implementation RoomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
        self.detailTextLabel.font = [UIFont systemFontOfSize:15];

        _badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _badgeView.font = [UIFont systemFontOfSize:12];
        _badgeView.animateChanges = NO;
        _badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
        [self.imageView addSubview:_badgeView];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _badgeView.maximumWidth = self.imageView.bounds.size.width;
}

- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = [badgeValue mutableCopy];
    self.badgeView.text = badgeValue;
    self.badgeView.hidden = (nil == badgeValue) || [badgeValue isEqualToString:@"0"];
}


@end