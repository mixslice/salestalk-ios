//
// Created by Zhang Zeqing on 5/28/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;


@interface NTTabBarItem : UIButton
@property (nonatomic, copy) NSString *badgeValue;

@property(nonatomic, strong) UIColor *foregroundColor;
@property(nonatomic, strong) UIColor *selectedForegroundColor;
@property(nonatomic, strong) UIColor *highlightedBackgroundColor;
@property(nonatomic, strong) UIColor *selectedBackgroundColor;

- (instancetype)initWithItem:(UITabBarItem *)item;
@end