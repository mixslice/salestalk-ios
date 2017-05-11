//
//  LoginViewController.m
//  Salestalk
//
//  Created by Zhang Zeqing on 3/28/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <UIImage_ImageWithColor/UIImage+ImageWithColor.h>
#import <RMPhoneFormat/RMPhoneFormat.h>
#import "LoginViewController.h"
#import "NTFactory.h"
#import "NTTextField.h"
#import "CodeVerifyViewController.h"
#import "UIView+NTHelper.h"
#import "UIColor+NTFactory.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *countryCodePrefix;
@property(strong, nonatomic) NSRegularExpression *phoneNumberExpression;

@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UIButton *registerButton;
@property(nonatomic, weak) UILabel *invalidErrorLabel;
@end

@implementation LoginViewController

#pragma mark - view cycle

- (void)loadView {
    [super loadView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:NSLocalizedString(@"NEXT_TITLE", @"Next")
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(nextPressed:)];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:NSLocalizedString(@"BACK_TITLE", @"BACK_TITLE")
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:nil];

    _textField = ({
        NTTextField *textField = [[NTTextField alloc] initWithType:NTTextFieldTypeNumber];
        textField.delegate = self;
        [self.view addSubview:textField];
        textField;
    });

    [[_textField rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(UITextField *textField) {
        RMPhoneFormat *formatter = [[RMPhoneFormat alloc] init];
        NSString *formattedOutput = [formatter format:self.phoneNumber];
        textField.text=formattedOutput;
    }];

    _registerButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [[button titleLabel] setNumberOfLines:0];
        [[button titleLabel] setLineBreakMode:NSLineBreakByWordWrapping];
        [button setBackgroundImage:[UIImage imageWithColor:[[UIColor nt_primaryReverseColor] colorWithAlphaComponent:0.25]]
                          forState:UIControlStateNormal];

        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentCenter];

        NSMutableAttributedString *attrString = [[[NSAttributedString alloc]
                initWithString:NSLocalizedString(@"REGISTER_HELPER_TEXT", nil)
                    attributes:@{
                            NSFontAttributeName : [UIFont systemFontOfSize:13],
                            NSForegroundColorAttributeName : [[UIColor nt_primaryForegroundColor] colorWithAlphaComponent:0.75],
                            NSParagraphStyleAttributeName : style

                    }] mutableCopy];
        [attrString appendAttributedString:[[NSAttributedString alloc]
                initWithString:NSLocalizedString(@"REGISTER_TITLE", @"REGISTER_TITLE")
                    attributes:@{
                            NSFontAttributeName : [UIFont boldSystemFontOfSize:17],
                            NSForegroundColorAttributeName : [UIColor nt_primaryForegroundColor],
                            NSParagraphStyleAttributeName : style
                    }]];

        [button setAttributedTitle:[attrString copy] forState:UIControlStateNormal];
        [self.view addSubview:button];
        button;
    });

    _invalidErrorLabel = ({
        UILabel *invalidErrorLabel = [[UILabel alloc] init];
        invalidErrorLabel.textColor = [UIColor whiteColor];
        invalidErrorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        [self.view addSubview:invalidErrorLabel];
        invalidErrorLabel;
    });


    UIView *bottomLine = ({
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor nt_keyboardSeparatorColor];
        [_registerButton addSubview:line];
        line;
    });

    // constraints
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(66);
        make.left.equalTo(self.view).with.offset([NTFactory viewPadding]);
        make.right.equalTo(self.view).with.offset(-[NTFactory viewPadding]);
        make.height.equalTo(@([NTFactory buttonHeight]));
    }];

    [_registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@60);
        make.bottom.equalTo(@0);
    }];

    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0.5);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@0);
    }];

    [_invalidErrorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(_textField.mas_bottom).with.offset(10);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"LOGIN_TITLE", @"LOGIN_TITLE");

    [self clearPhoneNumber];

    NSString *placeholder = NSLocalizedString(@"NAME_FIELD_PLACEHOLDER", @"NAME_FIELD_PLACEHOLDER");
    _textField.attributedPlaceholder = [[NSAttributedString alloc]
            initWithString:placeholder attributes:[NTFactory placeholderAttributes]];

    _invalidErrorLabel.text = NSLocalizedString(@"PHONE_NUMBER_INVALID_INFO_EMPTY", @"PHONE_NUMBER_INVALID_INFO_EMPTY");

    [self addKeyboardSignal];
    [self addNextButtonEvent];
    [self addRegisterButtonEvent];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];

    // call super
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.textField becomeFirstResponder];

    // call super
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter && setter

- (NSRegularExpression *)phoneNumberExpression {
    if (nil == _phoneNumberExpression) {
        _phoneNumberExpression = [[NSRegularExpression alloc] initWithPattern:@"^(\\+)?[0-9]+$" options:0 error:nil];
    }
    return _phoneNumberExpression;
}

#pragma mark - selector

- (NSString *)countryCodePrefix {
    if (nil == _countryCodePrefix) {
        RMPhoneFormat *formatter = [[RMPhoneFormat alloc] init];
        NSLocale *loc = [NSLocale currentLocale];
        NSString *defaultCountry = [[loc objectForKey:NSLocaleCountryCode] lowercaseString];
        _countryCodePrefix = [NSString stringWithFormat:@"+%@", [formatter callingCodeForCountryCode:defaultCountry]];
    }
    return _countryCodePrefix;
}


- (void)clearPhoneNumber {
    self.phoneNumber = @"";
    self.textField.text = self.phoneNumber;
}

- (void)nextPressed:(id)sender {
    CodeVerifyViewController *codeVerifyViewController = [[CodeVerifyViewController alloc]
            initWithPhoneNumber:self.phoneNumber];
    [self.navigationController pushViewController:codeVerifyViewController animated:YES];
}

#pragma mark - signal

- (void)addNextButtonEvent {
    // bind signal
    @weakify(self);
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal
            combineLatest:@[
                    [RACSignal merge:@[
                            [self.textField rac_textSignal]
                    ]]
            ]
                   reduce:^(NSString *text) {
                       return @(text.length > 0);
                   }];
}

- (void)addRegisterButtonEvent {
    [[self.registerButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.invalidErrorLabel shake];
    }];
}

- (void)addKeyboardSignal {
    RACSignal *keyboardShowSignal = [
            [NSNotificationCenter.defaultCenter rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
            takeUntil:self.rac_willDeallocSignal];
    RACSignal *keyboardHideSignal = [
            [NSNotificationCenter.defaultCenter rac_addObserverForName:UIKeyboardWillHideNotification object:nil]
            takeUntil:self.rac_willDeallocSignal];
    RACSignal *latestNotification = [RACSignal merge:@[keyboardShowSignal, keyboardHideSignal]];
    [[[latestNotification map:^id(NSNotification *notification) {
        return notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    }] distinctUntilChanged] subscribeNext:^(NSNumber *rectNumber) {
        // Animate things here with [rectNumber CGRectValue]
        CGRect rect = [rectNumber CGRectValue];
        [_registerButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@(rect.origin.y - self.view.bounds.size.height - self.view.frame.origin.y));
        }];

        [self.view layoutIfNeeded];
    }];
}

#pragma mark - TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""] && self.phoneNumber.length > 0) {
        self.phoneNumber = [self.phoneNumber substringWithRange:NSMakeRange(0, self.phoneNumber.length - 1)];
        return YES;
    } else if (self.phoneNumber) {
        NSString *text = [self.phoneNumber stringByAppendingString:string];
        NSTextCheckingResult *match = [self.phoneNumberExpression firstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
        if (match) {
            self.phoneNumber = text;
            return YES;
        }
    }
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self clearPhoneNumber];
    return YES;
}


@end
