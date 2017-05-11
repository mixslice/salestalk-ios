//
// Created by Zhang Zeqing on 7/7/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "EventContainerViewController.h"
#import "EventDetailViewController.h"
#import "NTMessageToEventAnimator.h"
#import "NTMessagesViewController.h"
#import "UserToEventAnimator.h"
#import "NTSingleLineMessagesController.h"


@implementation EventContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;
}

#pragma mark - animation

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(NTNavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    id <UIViewControllerAnimatedTransitioning> animator;

    if (([fromVC isKindOfClass:[NTMessagesViewController class]] && operation == UINavigationControllerOperationPop)
            || ([toVC isKindOfClass:[NTMessagesViewController class]] && operation == UINavigationControllerOperationPush)) {
        animator = [NTMessageToEventAnimator new];
        [(NTMessageToEventAnimator *)animator setOperation:operation];
    } else if (([fromVC isKindOfClass:[EventDetailViewController class]] && operation == UINavigationControllerOperationPush)
               || ([toVC isKindOfClass:[EventDetailViewController class]] && operation == UINavigationControllerOperationPop)) {
        animator = [UserToEventAnimator new];
        [(UserToEventAnimator *)animator setOperation:operation];
    }

    return animator;
}


@end