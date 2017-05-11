//
// Created by Zhang Zeqing on 4/19/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "UIColor+NTFactory.h"

static BOOL darkTheme = YES;

@implementation UIColor (NTFactory)

+ (UIColor *)nt_primaryColor {
    return [UIColor colorWithRed:22/255.f green:148/255.f blue:246/255.f alpha:1];
}

+ (UIColor *)nt_primaryForegroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)nt_primaryReverseColor {
    return [UIColor blackColor];
}

+ (UIColor *)nt_foregroundColor {
    if (darkTheme) {
        return [UIColor whiteColor];
    } else {
        return [UIColor blackColor];
    }
}

+ (UIColor *)nt_backgroundColor {
    if (darkTheme) {
        return [UIColor colorWithRed:38/255.f green:41/255.f blue:49/255.f alpha:1];
    } else {
        return [UIColor whiteColor];
    }
}

+ (UIColor *)nt_keyboardSeparatorColor {
    return [UIColor colorWithWhite:0.549 alpha:1];
}

+ (UIColor *)nt_tabBarBackgroundColor {
    if (darkTheme) {
        return [UIColor blackColor];
    } else {
        return [UIColor colorWithRed:38/255.f green:41/255.f blue:49/255.f alpha:1];
    }
}

+ (UIColor *)nt_separatorColor {
    if (darkTheme) {
        return [UIColor colorWithWhite:0.867 alpha:0.16];
    } else {
        return [UIColor colorWithWhite:0 alpha:0.2];
    }
}

+ (UIColor *)nt_greenColor {
    return [UIColor colorWithRed:126/255.f green:211/255.f blue:33/255.f alpha:1];
}

+ (UIColor *)nt_grayColor {
    return [UIColor colorWithWhite:0.5 alpha:1];
}

+ (UIColor *)nt_redColor {
    return [UIColor redColor];
}

+ (UIColor *)nt_sectionHeaderForegroundColor {
    if (darkTheme) {
        return [UIColor whiteColor];
    } else {
        return [UIColor blackColor];
    }
}

+ (UIColor *)nt_sectionHeaderBackgroundColor {
    if (darkTheme) {
        return [UIColor colorWithRed:63/255.f green:66/255.f blue:72/255.f alpha:1];
    } else {
        return [UIColor colorWithWhite:0.9 alpha:1];
    }
}

+ (UIColor *)nt_selectedBackgroundColor {
    if (darkTheme) {
        return [UIColor colorWithWhite:1 alpha:0.2];
    } else {
        return [UIColor colorWithWhite:0 alpha:0.2];
    }
}

+ (UIColor *)nt_groupedTableViewBackground {
    if (darkTheme) {
        return [UIColor nt_backgroundColor];
    } else {
        return [UIColor colorWithWhite:0.95 alpha:1];
    }
}

+ (UIColor *)nt_groupedTableViewCellBackground {
    if (darkTheme) {
        return [UIColor nt_sectionHeaderBackgroundColor];
    } else {
        return [UIColor whiteColor];
    }
}

+ (UIColor *)nt_groupedTableViewCellSelectedBackground {
    if (darkTheme) {
        return [UIColor nt_primaryColor];
    } else {
        return [UIColor nt_selectedBackgroundColor];
    }
}

+ (UIColor *)nt_descColor {
    return [UIColor colorWithWhite:1 alpha:0.5];
}

+ (UIColor *)nt_lighterBackgroundColor {
    if (darkTheme) {
        return [UIColor colorWithRed:60 / 255.f green:62 / 255.f blue:70 / 255.f alpha:1];
    } else {
        return [UIColor colorWithWhite:0.9 alpha:1];
    }
}

+ (UIColor *)nt_secondaryColor {
    return [UIColor colorWithRed:157/255.f green:225/255.f blue:82/255.f alpha:1];
}

+ (UIColor *)nt_yellowColor {
    return [UIColor colorWithRed:253/255.f green:240/255.f blue:195/255.f alpha:1];
}
@end