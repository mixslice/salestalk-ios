//
//  AppDelegate.m
//  Salestalk
//
//  Created by Zhang Zeqing on 3/28/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "AppDelegate.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "NTSocket.h"
#import "StartViewController.h"
#import "NTFactory.h"
#import "NTTabBarController.h"
#import "BrandsViewController.h"
#import "RoomsViewController.h"
#import "ScannerViewController.h"
#import "FollowingViewController.h"
#import "SettingsViewController.h"
#import "Constants.h"
#import "NTAccountManager.h"
#import "AFNetworkLumberjackLogger.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[AFNetworkLumberjackLogger sharedLogger] startLogging];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [[center rac_addObserverForName:kNTDidLoginNotification object:nil] subscribeNext:^(id x) {
        [NTSocket sharedSocket];
    }];


    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self customizeAppearance];

    // rootViewController
    [self _configuredRootViewController];

    [self.window makeKeyAndVisible];
    [[NTAccountManager sharedManager] startManage];

    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    return YES;
}

- (void)customizeAppearance {
    [NTFactory customizeAppearace];
}

- (void)_configuredRootViewController {
    NSArray *childViewControllers = [self _configuredChildViewControllers];
    NTTabBarController *tabBarController = [[NTTabBarController alloc] initWithViewControllers:childViewControllers];
    self.window.rootViewController = tabBarController;

    @weakify(self);
    [[NSNotificationCenter.defaultCenter rac_addObserverForName:kNTShowLoginNotification object:nil]
            subscribeNext:^(NSNotification *notification) {
        @strongify(self);
        StartViewController *startViewController = [StartViewController new];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:startViewController];
        [self.window.rootViewController presentViewController:nc animated:[notification.object boolValue] completion:NULL];
    }];
}

- (NSArray *)_configuredChildViewControllers {

    // Set colors, titles and tab bar button icons which are used by the ContainerViewController class for display in its button pane.

    NSMutableArray *childViewControllers = [[NSMutableArray alloc] initWithCapacity:5];
    NSArray *configurations = @[
            @{@"icon": @"tabicon-event", @"viewClass": [BrandsViewController class]},
            @{@"icon": @"tabicon-message", @"viewClass": [RoomsViewController class]},
            @{@"icon": @"tabicon-scan", @"viewClass": [ScannerViewController class]},
            @{@"icon": @"tabicon-contact", @"viewClass": [FollowingViewController class]},
            @{@"icon": @"tabicon-profile", @"viewClass": [SettingsViewController class]}
    ];

    for (NSDictionary *configuration in configurations) {
        UIViewController *childViewController = [[configuration[@"viewClass"] alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:childViewController];

        childViewController.tabBarItem.image = [UIImage imageNamed:configuration[@"icon"]];
        childViewController.tabBarItem.selectedImage = [UIImage imageNamed:configuration[@"icon"]];

        [childViewControllers addObject:nc];
    }

    return childViewControllers;
}

@end
