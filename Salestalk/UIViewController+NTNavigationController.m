//
// Created by Zhang Zeqing on 7/7/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "UIViewController+NTNavigationController.h"


@implementation UIViewController (NTNavigationController)

- (NTNavigationController *)nt_navigationController {
    return (NTNavigationController *) self.parentViewController;
}

@end