//
// Created by Zhang Zeqing on 4/20/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;

@protocol NTTabBarDelegate;

@interface NTTabBar : UIView
@property(nonatomic, weak) id <NTTabBarDelegate> delegate;
@property(nonatomic, strong) NSArray *items; // UITabBarItem
@property(nonatomic) NSUInteger selectedIndex;
@end

@protocol NTTabBarDelegate <NSObject>
@optional
- (void)tabBar:(NTTabBar *)tabBar didSelectItemAtIndex:(NSUInteger)idx;
- (void)tabBar:(NTTabBar *)tabBar didDoubleSelectItemAtIndex:(NSUInteger)idx;
@end