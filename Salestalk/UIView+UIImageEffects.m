//
// Created by Zhang Zeqing on 5/5/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <UIImageEffects/UIImage+ImageEffects.h>
#import "UIView+UIImageEffects.h"


@implementation UIView (UIImageEffects)

- (UIImage *)nt_imageSnapshot:(BOOL)afterScreenUpdates {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterScreenUpdates];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (UIImage *)blurredImageWithTintColor:(UIColor *)tintColor {
    UIImage *image = [self nt_imageSnapshot:NO];
    return [image applyBlurWithRadius:30
                            tintColor:[tintColor colorWithAlphaComponent:0.66]
                saturationDeltaFactor:1.8
                            maskImage:nil];
}

- (UIImageView *)blurredViewWithTintColor:(UIColor *)tintColor {
    return [[UIImageView alloc] initWithImage:[self blurredImageWithTintColor:tintColor]];
}

+ (UIVisualEffectView *)blurViewWithStyle:(UIBlurEffectStyle)style {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:style];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    return blurView;
}

@end