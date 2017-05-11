//
// Created by Zhang Zeqing on 4/18/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;

@interface UIView (NTHelper)
- (void)shake;
- (void)shake:(void (^)())completion;
@end