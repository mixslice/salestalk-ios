//
// Created by Zhang Zeqing on 5/4/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;


@interface BrandDescriptionCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *textLabel;

+ (CGFloat)heightWithString:(NSString *)desc;
@end