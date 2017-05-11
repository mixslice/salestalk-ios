//
// Created by Zhang Zeqing on 4/19/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;

@protocol NTCodeFieldDelegate;

@interface NTTextcodeField : UIControl <UIKeyInput>
@property(nonatomic, weak) id <NTCodeFieldDelegate> delegate;

// code
@property(nonatomic, copy) NSString *textcode;

// configurations
@property(nonatomic) NSUInteger maximumLength;
@property (nonatomic) CGSize dotSize;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic) CGFloat lineHeight;
@property(nonatomic) CGFloat dotSpacing;
@property(nonatomic, strong) UIColor *dotColor;

@property(nonatomic) UIKeyboardType keyboardType;


@end

@protocol NTCodeFieldDelegate <NSObject>
@optional
/**
* Ask the delegate that whether passcode field accepts text.
* If you want to accept entering text, return YES.
*/
- (BOOL)textcodeField:(NTTextcodeField *)aTextcodeField shouldInsertText:(NSString *)aText;

/**
* Ask the delegate that whether passcode can be deleted.
* If you want to accept deleting passcode, return YES.
*/
- (BOOL)textcodeFieldShouldDeleteBackward:(NTTextcodeField *)aTextcodeField;

- (void)textcodeFieldDidFinishInsert:(NTTextcodeField *)aTextcodeField;

@end
