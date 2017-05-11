//
//  NTMessageToEventAnimator.h
//  Salestalk
//
//  Created by Leo Jiang on 6/1/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface NTMessageToEventAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property(nonatomic) UINavigationControllerOperation operation;
@end