//
// Created by Zhang Zeqing on 5/5/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <UIImage_ImageWithColor/UIImage+ImageWithColor.h>
#import "NTSearchController.h"
#import "UIColor+NTFactory.h"


@interface NTSearchController ()
@end

@implementation NTSearchController

- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController {
    self = [super initWithSearchResultsController:searchResultsController];
    if (self) {
        [self initialize];
    }

    return self;
}


- (void)initialize {
    [self.searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor nt_primaryColor]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor nt_primaryColor]];

//    [self.searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(44, 44)] forState:UIControlStateNormal];
//    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(8.0, 0.0)];
//
//    UIImage *searchIcon = [[UIImage imageNamed:@"icon-search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
////    [self.searchBar setImage:searchIcon forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
//    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setLeftView:[[UIImageView alloc] initWithImage:searchIcon]];
//
//    [self.searchBar setImage:[UIImage imageNamed:@"icon-clear"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
//    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
//    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont systemFontOfSize:17]];
//    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setPlaceholder:nil];

//    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setAttributedPlaceholder:
//            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Search", @"Search") attributes:@{
//                    NSForegroundColorAttributeName : [[UIColor nt_foregroundColor] colorWithAlphaComponent:0.66]
//            }]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end