//
// Created by Zhang Zeqing on 4/20/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "UIImage+NTUtilites.h"


@implementation UIImage (NTUtilites)

- (UIImage *)imageWithTintColor:(UIColor *)color {
    // begin a new image context, to draw our colored image onto
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(self.size, NO, scale);

    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();

    // set the fill color
    [color setFill];

    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.f);

    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);

//    // set the blend mode to color burn, and the original image
//    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
//    CGContextDrawImage(context, rect, self.CGImage);

    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);

    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

//return the color-burned image
    return coloredImg;
}



@end