//
// Created by Zhang Zeqing on 4/21/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;

@class NTBrand;
@class EventStore;

@interface BrandDetailViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate>
@property (nonatomic, strong) NTBrand *brand;

- (instancetype)initWithBrand:(NTBrand *)brand;

+ (instancetype)controllerWithBrand:(NTBrand *)brand;

@end