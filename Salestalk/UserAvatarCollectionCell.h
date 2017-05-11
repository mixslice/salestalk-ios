//
// Created by Zhang Zeqing on 5/8/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;

#import "NTFactory.h"


@interface UserAvatarCollectionCell : UICollectionViewCell
@property(nonatomic, weak) UIImageView *imageView;
@property(nonatomic, weak) UILabel *textLabel;
@property (nonatomic) NTOnlineStatus onlineStatus;
@end