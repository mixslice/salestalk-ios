//
//  Animator.m
//  Salestalk
//
//  Created by Leo Jiang on 5/28/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserToEventAnimator.h"
#import "EventDetailViewController.h"
#import "NTSingleLineMessagesController.h"

static CGFloat ANIMATION_DURATION = .5;
static CGFloat const MESSAGE_BOX_SIZE = 100;

@interface UserToEventAnimator ()
@end


@implementation UserToEventAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return ANIMATION_DURATION;
}


/* make tableCells Disappear */
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];

    if (self.operation == UINavigationControllerOperationPush) {
        NTSingleLineMessagesController *toVC = (NTSingleLineMessagesController *) toViewController;
        EventDetailViewController *fromVC = (EventDetailViewController *) fromViewController;
        NSArray *visibleCells = [fromVC.collectionView visibleCells];
        NSIndexPath *selectedIndex = [fromVC.collectionView indexPathsForSelectedItems].firstObject;
        UICollectionViewCell *selectedCell = [fromVC.collectionView cellForItemAtIndexPath:selectedIndex];

        /* shrink size of userMessageSubview's view*/
        CGRect toViewFrame = toVC.view.frame;
        toViewFrame.size.height = MESSAGE_BOX_SIZE;
        toVC.view.frame = toViewFrame;

        [containerView addSubview:fromVC.view];
        [containerView addSubview:toVC.view];

        toVC.view.transform = CGAffineTransformMakeTranslation(selectedCell.frame.origin.x,
                selectedCell.frame.origin.y);
        toVC.view.alpha = 0;
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
                            options:7 << 16
                         animations:^{
                             /*collectionView cells fade */
                             for (NSUInteger i = 0; i < visibleCells.count; i++) {
                                 UICollectionViewCell *curCell = visibleCells[i];
                                 curCell.alpha = 0;
                             }
                             toVC.view.transform = CGAffineTransformIdentity;
                             toVC.view.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             for (NSUInteger i = 0; i < visibleCells.count; i++) {
                                 UICollectionViewCell *curCell = visibleCells[i];
                                 curCell.alpha = 1;
                             }
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             [containerView addSubview:fromVC.view];
                             [containerView bringSubviewToFront:toVC.view];
                         }];

        toVC.messageLabel.transform = CGAffineTransformMakeTranslation(0, -10);
        [UIView animateWithDuration:0.1
                              delay:ANIMATION_DURATION * 0.5
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             toVC.messageLabel.transform = CGAffineTransformIdentity;
                             toVC.messageLabel.alpha = 1;
                         }
                         completion:nil];

    }
    else {
        EventDetailViewController *toVC = (EventDetailViewController *) toViewController;
        NTSingleLineMessagesController *fromVC = (NTSingleLineMessagesController *) fromViewController;
        [containerView addSubview:toVC.view];
        [containerView addSubview:fromVC.view];
        fromVC.view.alpha = 0;
        NSArray *visibleCells = [toVC.collectionView visibleCells];
        NSIndexPath *selectedIndex = [toVC.collectionView indexPathsForSelectedItems].firstObject;
        UICollectionViewCell *selectedCell = [toVC.collectionView cellForItemAtIndexPath:selectedIndex];

        CGFloat travelDistance = fabsf(selectedCell.frame.origin.x - fromVC.view.frame.origin.x);
        selectedCell.transform = CGAffineTransformMakeTranslation(-travelDistance, 0);
        /*Set collection Cell invisible */
        for (NSUInteger i = 0; i < visibleCells.count; i++) {
            if (visibleCells[i] != selectedCell) {
                UICollectionViewCell *curCell = visibleCells[i];
                curCell.alpha = 0;
            }
        }
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
                            options:7 << 16
                         animations:^{
                             /* move selected cell back into place */
                             selectedCell.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             fromVC.view.alpha = 1;
                             selectedCell.alpha = 1;
                         }];

        [UIView animateWithDuration:[self transitionDuration:transitionContext] * 0.5
                              delay:[self transitionDuration:transitionContext] * 0.5
                            options:7 << 16
                         animations:^{
                             /* set collection cell visible */
                             for (NSUInteger i = 0; i < visibleCells.count; i++) {
                                 if (visibleCells[i] != selectedCell) {
                                     UICollectionViewCell *curCell = visibleCells[i];
                                     curCell.alpha = 1;
                                 }
                             }
                         }
                         completion:nil];
    }
}

- (void)animationEnded:(BOOL)transitionCompleted {

}
@end

