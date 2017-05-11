//
//  PrivateTransitionContext.h
//  Salestalk
//
//  Created by Leo Jiang on 6/30/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//
@import UIKit;

@interface PrivateTransitionContext : NSObject< UIViewControllerContextTransitioning>
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete); /// A block of code we can set to execute after having received the completeTransition: message.
@property (nonatomic, assign, getter=isAnimated) BOOL animated; /// Private setter for the animated property.
@property (nonatomic, assign, getter=isInteractive) BOOL interactive; /// Private setter for the interactive property.
-(instancetype)initWithFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC;
@end