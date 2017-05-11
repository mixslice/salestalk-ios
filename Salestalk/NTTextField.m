//
// Created by Zhang Zeqing on 4/18/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import "NTTextField.h"
#import "NTFactory.h"
#import "UIColor+NTFactory.h"


@implementation NTTextField

- (instancetype)initWithType:(NTTextFieldType)fieldType {
    self = [super init];
    if (self) {
        self.fieldType = fieldType;

        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont systemFontOfSize:17];
        self.clearButtonMode = UITextFieldViewModeWhileEditing;

        UIView *bottomLine = [[UIView alloc] init];
        bottomLine.backgroundColor = [UIColor nt_primaryForegroundColor];
        [self addSubview:bottomLine];

        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@1);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
        }];
    }

    return self;
}

- (void)setFieldType:(NTTextFieldType)fieldType {
    switch (fieldType) {
        case NTTextFieldTypeDefault:break;
        case NTTextFieldTypeNumber: {
            self.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.autocorrectionType = UITextAutocorrectionTypeNo;
            self.spellCheckingType = UITextSpellCheckingTypeNo;
            self.keyboardType = UIKeyboardTypeNumberPad;
            break;
        }
        case NTTextFieldTypeEmail: {
            self.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.autocorrectionType = UITextAutocorrectionTypeNo;
            self.spellCheckingType = UITextSpellCheckingTypeNo;
            self.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        }
        case NTTextFieldTypePassword: {
            self.secureTextEntry = YES;
            self.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.autocorrectionType = UITextAutocorrectionTypeNo;
            self.spellCheckingType = UITextSpellCheckingTypeNo;
            self.returnKeyType = UIReturnKeyDone;
            break;
        }
    };

}


@end