//
// Created by Zhang Zeqing on 6/8/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;@class NTUser;

@interface UIImageView (NTAvatarView)


- (void)setAvatarWithUser:(NTUser *)user;

- (void)setLargeAvatarWithUser:(NTUser *)user;
@end