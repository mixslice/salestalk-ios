//
// Created by Zhang Zeqing on 4/18/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, NTTextFieldType) {
    NTTextFieldTypeDefault = 0,
    NTTextFieldTypeNumber,
    NTTextFieldTypeEmail,
    NTTextFieldTypePassword
};

@interface NTTextField : UITextField
@property (nonatomic, assign) NTTextFieldType fieldType;

- (instancetype)initWithType:(NTTextFieldType)fieldType;
@end