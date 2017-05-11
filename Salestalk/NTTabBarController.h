//
// Created by Zhang Zeqing on 4/19/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;
@import Foundation;

@interface NTTabBarController : UIViewController

/// The view controllers currently managed by the container view controller.
@property (nonatomic, copy, readonly) NSArray *viewControllers;

/// The currently selected and visible child view controller.
@property (nonatomic, assign) UIViewController *selectedViewController;

/** Designated initializer.
@note The view controllers array cannot be changed after initialization.
*/
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

- (void)hideBottomBar:(BOOL)hidesBottomBarWhenPushed;
@end