//
// Created by Zhang Zeqing on 4/21/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTCircleView.h"


@implementation NTCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.borderWidth = 1;
        self.borderColor = [UIColor whiteColor];
    }

    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextAddEllipseInRect(ctx, CGRectInset(rect, self.borderWidth, self.borderWidth));
    [self.tintColor setFill];
    [self.borderColor setStroke];
    CGContextDrawPath(ctx, kCGPathFillStroke);

}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];

    [self setNeedsDisplay];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;

    [self setNeedsDisplay];
}


@end