//
// Created by Zhang Zeqing on 4/26/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;

@class NTEvent;
@class RLMResults;


@interface EventDetailViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, weak) UICollectionView *collectionView;
- (instancetype)initWithEvent:(NTEvent *)event;

+ (instancetype)controllerWithEvent:(NTEvent *)event;

@end