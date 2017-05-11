//
// Created by Zhang Zeqing on 5/26/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTThemeBasedViewController.h"
#import "UIColor+NTFactory.h"


@implementation NTThemeBasedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.tintColor = [UIColor nt_primaryForegroundColor];
    self.view.backgroundColor = [UIColor nt_primaryColor];
}


@end