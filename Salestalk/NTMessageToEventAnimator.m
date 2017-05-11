//
//  NTMessageToEventAnimator.m
//  Salestalk
//
//  Created by Leo Jiang on 6/1/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTMessageToEventAnimator.h"
#import "NTSingleLineMessagesController.h"
#import "EventDetailViewController.h"


static CGFloat ANIMATION_DURATION = 0.5;
static CGFloat USER_MESSAGE_SUBVIEW_SIZE = 100;

@interface NTMessageToEventAnimator ()
@end

@implementation NTMessageToEventAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return ANIMATION_DURATION;
}


/*start from bottom of userMessage subview*/
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    [containerView addSubview:toVC.view];
    [containerView addSubview:fromVC.view];
    if (self.operation == UINavigationControllerOperationPush) {
        toVC.view.alpha = 0;
//        toVC.view.transform = CGAffineTransformMakeTranslation(0, -travelDistance);
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
                            options:7 << 16
                         animations:^{
                             fromVC.view.frame = containerView.bounds;
                             toVC.view.alpha = 1;
                             toVC.view.transform = CGAffineTransformIdentity;
                             
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             fromVC.view.transform = CGAffineTransformIdentity;
                         }];

        [UIView animateWithDuration:[self transitionDuration:transitionContext] * 0.7
                              delay:[self transitionDuration:transitionContext] * 0.3
                            options:7 << 16
                         animations:^{
                             fromVC.view.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             fromVC.view.alpha = 1;
                         }];
    }
    else {
        /*pop - drag up*/
        CGFloat travelDistance = containerView.bounds.size.height;
        toVC.view.frame = containerView.bounds;
//        toVC.view.alpha = 0;
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
                            options:7 << 16
                         animations:^{
                             toVC.view.alpha = 1;
                             toVC.view.frame = CGRectMake(0, 0, containerView.bounds.size.width, USER_MESSAGE_SUBVIEW_SIZE);
                             fromVC.view.transform = CGAffineTransformMakeTranslation(0, -travelDistance);
                             fromVC.view.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             fromVC.view.transform = CGAffineTransformIdentity;
                             fromVC.view.alpha = 1;
                         }];

    }
}

- (void)animationEnded:(BOOL)transitionCompleted {
}
@end
