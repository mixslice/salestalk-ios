//
// Created by Zhang Zeqing on 4/18/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "UIView+NTHelper.h"


@implementation UIView (NTHelper)

-(void)shake {
    [self shake:nil];
}

- (void)shake:(void (^)())completion {
    const int reset = 5;
    const int maxShakes = 6;

    //pass these as variables instead of statics or class variables if shaking two controls simultaneously
    static int shakes = 0;
    static int translate = reset;

    [UIView animateWithDuration:0.09-(shakes*.01) // reduce duration every shake from .09 to .04
                          delay:0.01f//edge wait delay
                        options:(enum UIViewAnimationOptions) UIViewAnimationCurveEaseInOut
                     animations:^{self.transform = CGAffineTransformMakeTranslation(translate, 0);}
                     completion:^(BOOL finished){
                         if(shakes < maxShakes){
                             shakes++;

                             //throttle down movement
                             if (translate>0)
                                 translate--;

                             //change direction
                             translate*=-1;
                             [self shake:completion];
                         } else {
                             self.transform = CGAffineTransformIdentity;
                             shakes = 0;//ready for next time
                             translate = reset;//ready for next time
                             if (completion) {
                                 completion();
                             }
                             return;
                         }
                     }];
}

@end