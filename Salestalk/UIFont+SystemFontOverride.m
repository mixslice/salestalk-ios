//
// Created by Zhang Zeqing on 4/18/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "UIFont+SystemFontOverride.h"


@implementation UIFont (SystemFontOverride)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:fontSize];
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:fontSize];
}

+ (UIFont *)preferredFontForTextStyle:(NSString *)style {
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:style];
    float fontSize = [fontDescriptor pointSize];
    return [UIFont systemFontOfSize:fontSize];
}

#pragma clang diagnostic pop

@end