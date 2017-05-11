//
// Created by Zhang Zeqing on 4/21/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;

@class NTUser;


@interface ProfileViewController : UIViewController
@property(nonatomic, strong) NTUser *user;

- (instancetype)initWithUser:(NTUser *)user;

+ (instancetype)controllerWithUser:(NTUser *)user;

@end