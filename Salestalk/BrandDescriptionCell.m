//
// Created by Zhang Zeqing on 5/4/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import "BrandDescriptionCell.h"
#import "NTFactory.h"
#import "UIColor+NTFactory.h"


@implementation BrandDescriptionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textLabel = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            label.textColor = [UIColor nt_descColor];
            label.numberOfLines = 0;
            [self addSubview:label];
            label;
        });

        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(
                    0, [NTFactory viewPadding], 20, [NTFactory viewPadding]));
        }];
    }

    return self;
}


+ (CGFloat)heightWithString:(NSString *)desc {
    CGFloat width = [UIScreen mainScreen].bounds.size.width - [NTFactory viewPadding] * 2;
    CGRect rect = [desc boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:@{
                                          NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                  }
                                     context:nil];
    return rect.size.height + 21;
}
@end