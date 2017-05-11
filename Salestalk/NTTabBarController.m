//
// Created by Zhang Zeqing on 4/19/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <ObjectiveSugar/NSArray+ObjectiveSugar.h>
#import <ReactiveCocoa/RACSignal.h>
#import <ReactiveCocoa/NSNotificationCenter+RACSupport.h>
#import "NTTabBarController.h"
#import "NTTabBar.h"
#import "Constants.h"


@interface NTTabBarController () <NTTabBarDelegate, UINavigationControllerDelegate>
@property(nonatomic, copy, readwrite) NSArray *viewControllers;
@property(nonatomic, strong) NTTabBar *privateTabBar; /// The view hosting the buttons of the child view controllers.
@property(nonatomic, strong) UIView *privateContainerView; /// The view hosting the child view controllers views.
@end

@implementation NTTabBarController

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
    NSParameterAssert ([viewControllers count] > 0);
    if ((self = [super init])) {
        self.viewControllers = [viewControllers copy];
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
            if ([controller isKindOfClass:[UINavigationController class]]) {
                ((UINavigationController *)controller).delegate = self;
            }
        }];
    }
    return self;
}

- (void)loadView {

    // Add  container and buttons views.

    UIView *rootView = [[UIView alloc] init];
    rootView.backgroundColor = [UIColor blackColor];
    rootView.opaque = YES;

    self.privateContainerView = [[UIView alloc] init];
    self.privateContainerView.backgroundColor = [UIColor blackColor];
    self.privateContainerView.opaque = YES;

    self.privateTabBar = [[NTTabBar alloc] init];
    self.privateTabBar.delegate = self;

    [self.privateContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.privateTabBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rootView addSubview:self.privateContainerView];
    [rootView addSubview:self.privateTabBar];

    // Place buttons view in the top half, horizontally centered.
    [self.privateTabBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(@0);
        make.height.equalTo(@49);
    }];

    // Container view fills out entire root view.
    [self.privateContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(@0);
        make.bottom.equalTo(@(-49));
    }];

    [self _addChildViewControllerTabItems];

    self.view = rootView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedViewController = (self.selectedViewController ?: self.viewControllers[0]);

    [[[NSNotificationCenter defaultCenter]
            rac_addObserverForName:kNTDidLoginNotification object:nil] subscribeNext:^(id x) {
        self.selectedViewController = self.viewControllers[0];
    }];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    NSParameterAssert (selectedViewController);
    [self _transitionToChildViewController:selectedViewController];
    _selectedViewController = selectedViewController;
    [self.privateTabBar setSelectedIndex:[self.viewControllers indexOfObject:selectedViewController]];
}

#pragma mark Private Methods

- (void)_addChildViewControllerTabItems {
    NSArray *items = [self.viewControllers map:^id(UIViewController *childViewController) {
        return childViewController.tabBarItem;
    }];

    self.privateTabBar.items = items;
}

- (void)_transitionToChildViewController:(UIViewController *)toViewController {

    UIViewController *fromViewController = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (toViewController == fromViewController || ![self isViewLoaded]) {
        return;
    }

    UIView *toView = toViewController.view;
    [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.privateContainerView.bounds;

    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    [self.privateContainerView addSubview:toView];
    [fromViewController.view removeFromSuperview];
    [fromViewController removeFromParentViewController];
    [toViewController didMoveToParentViewController:self];
}

#pragma mark - NTTabBar Delegate

- (void)tabBar:(NTTabBar *)tabBar didSelectItemAtIndex:(NSUInteger)idx {
    UIViewController *selectedViewController = self.viewControllers[idx];
    self.selectedViewController = selectedViewController;
}

- (void)tabBar:(NTTabBar *)tabBar didDoubleSelectItemAtIndex:(NSUInteger)idx {
    UIViewController *selectedViewController = self.viewControllers[idx];
    if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *) selectedViewController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - UINavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {

    [self hideBottomBar:viewController.hidesBottomBarWhenPushed];
}

- (void)hideBottomBar:(BOOL)hidesBottomBarWhenPushed {
    if (self.privateTabBar.isHidden != hidesBottomBarWhenPushed) {
        self.privateTabBar.hidden = hidesBottomBarWhenPushed;

        [self.privateContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (hidesBottomBarWhenPushed) {
                make.bottom.equalTo(@0);
            } else {
                make.bottom.equalTo(@(-49));
            }
        }];

        [self.view layoutIfNeeded];
    }
}


@end