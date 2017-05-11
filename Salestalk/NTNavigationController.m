//
//  NTNavigationController.m
//  Salestalk
//
//  Created by Leo Jiang on 6/30/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>
#import "NTNavigationController.h"
#import "PrivateTransitionContext.h"
#import "PrivateAnimatedTransition.h"
#import "UIColor+NTFactory.h"


@interface NTNavigationController () <UINavigationBarDelegate>
@property (nonatomic, readwrite) NSArray *viewControllers;
@property(nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UIView *privateContainerView;

@property(nonatomic, strong) UIViewController *rootViewController;
@end

@implementation NTNavigationController


#pragma mark - status bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - init

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super init];
    if (self) {
        self.rootViewController = rootViewController;
    }

    return self;
}

- (void)loadView {
    // Add  container and navigation bar.

    UIView *rootView = [[UIView alloc] init];
    rootView.backgroundColor = [UIColor blackColor];
    rootView.opaque = YES;

    self.privateContainerView = [[UIView alloc] init];
    self.privateContainerView.backgroundColor = [UIColor yellowColor];
    self.privateContainerView.opaque = YES;

    self.navigationBar = [[UINavigationBar alloc] init];

    [self.privateContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.navigationBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.navigationBar.delegate = self;
    [rootView addSubview:self.privateContainerView];
    [rootView addSubview:self.navigationBar];


    // constraints

    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(rootView);
        make.height.equalTo(@64);
    }];
    [self.privateContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navigationBar.mas_bottom);
        make.bottom.and.left.and.right.equalTo(rootView);
    }];

    self.view = rootView;
}

#pragma mark - view cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self pushViewController:self.rootViewController animated:NO];
}

#pragma mark - Setter & getter

- (NSArray *)viewControllers {
    return [self.childViewControllers copy];
}

- (UIViewController *)topViewController {
    return [self.childViewControllers lastObject];
}

#pragma mark - viewcontroller transition

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self _transitionToChildViewController:viewController forOperation:UINavigationControllerOperationPush animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *toViewController = [self ancestorViewControllerTo:self.topViewController];
    if (toViewController) {
        [self _transitionToChildViewController:toViewController forOperation:UINavigationControllerOperationPop animated:animated];
    }
    return toViewController;
}

#pragma mark - View controller hierarchy methods

- (UINavigationController *)ancestorViewControllerTo:(UIViewController *)viewController {
    NSUInteger index = [self.childViewControllers indexOfObject:viewController];
    return (index > 0)? self.childViewControllers[index - 1] : nil;
}

- (void)_transitionToChildViewController:(UIViewController *)toViewController
                            forOperation:(UINavigationControllerOperation)operation
                                animated:(BOOL)animated {

    UIViewController *fromViewController = self.topViewController;
    if (toViewController == fromViewController) {
        return;
    }

    UIView *toView = toViewController.view;
    [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.privateContainerView.bounds;

    if (operation == UINavigationControllerOperationPop) {
        [fromViewController willMoveToParentViewController:nil];
    } else {
        [self addChildViewController:toViewController];
    }

    // navigation bar item push/pop
    if (operation == UINavigationControllerOperationPush) {
        [_navigationBar pushNavigationItem:toViewController.navigationItem animated:animated];
    }

    // If this is the initial presentation, add the new child with no animation.
    if (!fromViewController) {
        [self.privateContainerView addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        return;
    }

    if (!animated) {
        [fromViewController.view removeFromSuperview];
        [self.privateContainerView addSubview:toViewController.view];

        if (operation == UINavigationControllerOperationPop) {
            [fromViewController removeFromParentViewController];
        } else {
            [toViewController didMoveToParentViewController:self];
        }
    }

    // Animate the transition by calling the animator with our private transition context. If we don't have a delegate, or if it doesn't return an animated transitioning object, we will use our own, private animator.

    id<UIViewControllerAnimatedTransitioning>animator = nil;
    if ([self.delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        animator = [self.delegate navigationController:self
                       animationControllerForOperation:operation
                                    fromViewController:fromViewController
                                      toViewController:toViewController];
    }
    animator = (animator ?: [[PrivateAnimatedTransition alloc] init]);

    PrivateTransitionContext *transitionContext = [[PrivateTransitionContext alloc]
            initWithFromViewController:fromViewController
                      toViewController:toViewController];

    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete) {
        [fromViewController.view removeFromSuperview];
        if (operation == UINavigationControllerOperationPop) {
            [fromViewController removeFromParentViewController];
        } else {
            [toViewController didMoveToParentViewController:self];
        }

        if ([animator respondsToSelector:@selector(animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
        self.navigationBar.userInteractionEnabled = YES;
        self.privateContainerView.userInteractionEnabled = YES;
    };

    self.navigationBar.userInteractionEnabled = NO; // Prevent user tapping buttons mid-transition, messing up state
    self.privateContainerView.userInteractionEnabled = NO;
    [animator animateTransition:transitionContext];
}

#pragma mark - back action

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    [self popViewControllerAnimated:YES];
    return YES;
}

@end

