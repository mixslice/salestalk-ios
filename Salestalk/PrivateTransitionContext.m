//
//  PrivateTransitionContext.m
//  Salestalk
//
//  Created by Leo Jiang on 6/30/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrivateTransitionContext.h"

@interface PrivateTransitionContext ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) CGRect privateDisappearingFromRect; //fromVC init
@property (nonatomic, assign) CGRect privateAppearingFromRect;    //toVC init
@property (nonatomic, assign) CGRect privateDisappearingToRect; //fromVC final
@property (nonatomic, assign) CGRect privateAppearingToRect;    //toVC final
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@end

@implementation PrivateTransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if ((self = [super init])) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromVC.view.superview;
        self.privateViewControllers = @{
                UITransitionContextFromViewControllerKey : fromVC,
                UITransitionContextToViewControllerKey : toVC,
        };

        // Set the view frame properties which make sense in our specialized ContainerViewController context. Views appear from and disappear to the sides, corresponding to where the icon buttons are positioned. So tapping a button to the right of the currently selected, makes the view disappear to the left and the new view appear from the right. The animator object can choose to use this to determine whether the transition should be going left to right, or right to left, for example.
        CGFloat travelDistance = -self.containerView.bounds.size.width;

        self.privateDisappearingFromRect = fromVC.view.frame;
        self.privateAppearingFromRect = toVC.view.frame;

        self.privateDisappearingToRect = fromVC.view.frame;//self.privateDisappearingFromRect;
        self.privateAppearingToRect = toVC.view.frame; //self.privateAppearingFromRect;
    }
    return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)vc{
    if (vc == [self viewControllerForKey:UITransitionContextFromViewControllerKey]){
        NSLog(@"inital fromVC size =  %f",self.privateDisappearingFromRect.size.height);
        return self.privateDisappearingFromRect;
    }
    else{
        NSLog(@"initial toVC size =  %f",self.privateAppearingToRect.size.height);
        return self.privateAppearingFromRect;
    }
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc{
    if (vc == [self viewControllerForKey:UITransitionContextFromViewControllerKey]){
        NSLog(@"final fromVC size =  %f",self.privateDisappearingFromRect.size.height);
        return self.privateDisappearingToRect;
    }
    else{
        NSLog(@"final toVC size =  %f",self.privateAppearingToRect.size.height);
        return self.privateAppearingToRect;
    }
}

-(UIViewController *)viewControllerForKey:(NSString *)key{
    return self.privateViewControllers[key];
}


-(void)completeTransition:(BOOL)didComplete{
    if (self.completionBlock){
        self.completionBlock (didComplete);
    }
}


-(BOOL)transitionWasCancelled{
    return NO;
}
-(void)updateInteractiveTransition:(CGFloat)percentComplete {}
-(void)finishInteractiveTransition {}
-(void)cancelInteractiveTransition {}
@end