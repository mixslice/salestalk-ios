//
// Created by Zhang Zeqing on 4/26/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "EventSeatsDecorationViewLayoutAttributes.h"
#import "UIColor+NTFactory.h"


@implementation EventSeatsDecorationViewLayoutAttributes

+ (instancetype)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind withIndexPath:(NSIndexPath *)indexPath {
    EventSeatsDecorationViewLayoutAttributes *layoutAttributes = (EventSeatsDecorationViewLayoutAttributes *) [super layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    if (indexPath.section == 0) {
        layoutAttributes.color = [UIColor nt_lighterBackgroundColor];
    } else {
        layoutAttributes.color = [UIColor clearColor];
    }
    return layoutAttributes;
}


@end