//
// Created by Zhang Zeqing on 4/26/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "EventSeatsDecorationView.h"
#import "EventSeatsDecorationViewLayoutAttributes.h"


@implementation EventSeatsDecorationView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];

    self.backgroundColor = ((EventSeatsDecorationViewLayoutAttributes *)layoutAttributes).color;
}

@end