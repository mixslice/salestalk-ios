//
// Created by Zhang Zeqing on 5/5/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;

@interface UIView (UIImageEffects)

- (UIImage *)nt_imageSnapshot:(BOOL)afterScreenUpdates;

- (UIImage *)blurredImageWithTintColor:(UIColor *)tintColor;

- (UIImageView *)blurredViewWithTintColor:(UIColor *)tintColor;

+ (UIVisualEffectView *)blurViewWithStyle:(UIBlurEffectStyle)style;

@end