//
// Created by Zhang Zeqing on 4/26/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "BrandDetailFlowLayout.h"
#import "NTFactory.h"
#import "EventSeatsDecorationView.h"
#import "EventSeatsDecorationViewLayoutAttributes.h"

static NSString *kDecorationReuseIdentifier = @"section_background";

@implementation BrandDetailFlowLayout

- (void)prepareLayout {
    [super prepareLayout];

    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.itemSize = CGSizeMake(86, 100);
    self.headerReferenceSize = CGSizeMake(0, 42);
    self.sectionInset = UIEdgeInsetsMake(0, [NTFactory viewPadding], 10, [NTFactory viewPadding]);
    [self registerClass:[EventSeatsDecorationView class] forDecorationViewOfKind:kDecorationReuseIdentifier];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];

    NSMutableArray *allAttributes = [attributes mutableCopy];

    for (UICollectionViewLayoutAttributes *attribute in attributes) {

        // Look for the first item in a row
        if (attribute.representedElementCategory == UICollectionElementCategoryCell
                && attribute.frame.origin.x == self.sectionInset.left) {

            // Create decoration attributes
            EventSeatsDecorationViewLayoutAttributes *decorationAttributes =
                    [EventSeatsDecorationViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kDecorationReuseIdentifier
                                                                                        withIndexPath:attribute.indexPath];

            // Make the decoration view span the entire row (you can do item by item as well. I just
            // chose to do it this way)
            decorationAttributes.frame =
                    CGRectMake(0,
                            attribute.frame.origin.y - (self.sectionInset.top) - self.headerReferenceSize.height,
                            self.collectionViewContentSize.width,
                            self.itemSize.height + (self.sectionInset.top + self.sectionInset.bottom) + self.headerReferenceSize.height);

            // Set the zIndex to be behind the item
            decorationAttributes.zIndex = attribute.zIndex-1;

            // Add the attribute to the list
            [allAttributes addObject:decorationAttributes];

        }

    }

    return allAttributes;
}


@end