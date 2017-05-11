//
//  NTContainerView.h
//  Salestalk
//
//  Created by Leo Jiang on 6/30/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;
@import Foundation;
#import "NTEvent.h"

@protocol NTNavigationControllerDelegate;

/*
 * Similar to MTStackViewController (https://github.com/mtrudel/MTStackableNavigationController)
 * Custom NavigationController
 */

@interface NTNavigationController : UIViewController
@property(nonatomic, weak) id <NTNavigationControllerDelegate> delegate;
@property(nonatomic, readonly) NSArray *viewControllers;
@property(nonatomic, readonly) UIViewController *topViewController;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

- (void)pushViewController:(UIViewController *)vc animated:(BOOL)animated;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
@end

@protocol NTNavigationControllerDelegate <NSObject>

@optional

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(NTNavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC;

@end