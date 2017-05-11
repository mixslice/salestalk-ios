//
//  Animator.h
//  Salestalk
//
//  Created by Leo Jiang on 5/28/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface UserToEventAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property(nonatomic) UINavigationControllerOperation operation;
@property(nonatomic) CGRect pushViewSize;
@end
