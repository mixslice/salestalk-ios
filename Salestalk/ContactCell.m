//
// Created by Zhang Zeqing on 4/21/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "ContactCell.h"


@implementation ContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    }

    return self;
}


@end