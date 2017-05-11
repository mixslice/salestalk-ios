//
// Created by Zhang Zeqing on 4/18/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <CocoaLumberjack/DDLogMacros.h>
#import <RMPhoneFormat/RMPhoneFormat.h>
#import "CodeVerifyViewController.h"
#import "NTFactory.h"
#import "UIColor+NTFactory.h"
#import "NTReverseButton.h"
#import "NTTextcodeField.h"
#import "UIView+NTHelper.h"
#import "Constants.h"
#import "PasswordViewController.h"
#import "NTHTTPSessionManager.h"


@interface CodeVerifyViewController () <NTCodeFieldDelegate>
@property (nonatomic, weak) UILabel *textLabel;
@property (nonatomic, weak) UILabel *detailLabel;
@property (nonatomic, weak) UIButton *verifyButton;
@property (nonatomic, weak) UIButton *loginWithPassButton;
@property (nonatomic, weak) NTTextcodeField *textcodeField;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic) BOOL isCounting;
@property (nonatomic) BOOL isSubmitting;
@property (nonatomic) BOOL showTextcodeViewOnce;
@property (nonatomic) NSUInteger countdownIntervals;
@property(nonatomic, strong) RACSubject *cancelTimer;
@end

@implementation CodeVerifyViewController

#pragma mark - init

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber {
    self = [super init];
    if (self) {
        self.phoneNumber = phoneNumber;
        self.countdownIntervals = 60;
    }

    return self;
}

#pragma mark - view cycle

- (void)loadView {
    [super loadView];

    [self setupSubviews];

    self.textcodeField.delegate = self;
    self.textcodeField.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"VERIFY_PAGE_TITLE", @"Verify");

    RMPhoneFormat *formatter = [[RMPhoneFormat alloc] init];
    NSString *formattedOutput = [formatter format:self.phoneNumber];
    self.textLabel.text = formattedOutput;

    self.detailLabel.text = NSLocalizedString(@"YOUR_PHONE_NUMBER_IS", nil);
    [self.verifyButton setTitle:NSLocalizedString(@"SEND_VERIFY_CODE_TITLE", @"Send Verify Code") forState:UIControlStateNormal];

    RAC(self.textcodeField, enabled) = [RACObserve(self, isSubmitting) map:^id(NSNumber *value) {
        return @(!value.boolValue);
    }];

    [RACObserve(self, isSubmitting) subscribeNext:^(NSNumber *isSubmitting) {
        if (isSubmitting.boolValue) {
            [self.activityIndicatorView startAnimating];
        } else {
            [self.activityIndicatorView stopAnimating];
        }
    }];

    [[self.loginWithPassButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        PasswordViewController *passwordViewController = [PasswordViewController new];
        [self.navigationController pushViewController:passwordViewController animated:YES];
    }];

    [self addVerifyButtonEvents];
}

#pragma mark - Helper

- (void)setShowTextcodeViewOnce:(BOOL)showTextcodeViewOnce {
    if (_showTextcodeViewOnce != showTextcodeViewOnce) {
        _showTextcodeViewOnce = showTextcodeViewOnce;
        [self showTextcodeView];
    }
}

- (void)showTextcodeView {
    self.textLabel.hidden = YES;
    self.textcodeField.hidden = NO;
    self.detailLabel.text = NSLocalizedString(@"PLEASE_ENTER_VERIFY_CODE", nil);

    [self.verifyButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(_textcodeField.mas_bottom).with.offset(18);
    }];

    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];

}

- (void)addVerifyButtonEvents {
    @weakify(self);
    [[self.verifyButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        @strongify(self);
        self.isCounting = YES;
        self.showTextcodeViewOnce = YES;
        [self.textcodeField becomeFirstResponder];


        // countdown
        [sender setTitle:[NSString stringWithFormat:NSLocalizedString(@"RESEND_VERIFY_CODE_WITH_%@", nil), @(self.countdownIntervals)]
                forState:UIControlStateNormal];

        __block NSDate *startDate = [NSDate date];

        _cancelTimer = [RACSubject subject];
        RACSignal *tickWithCancel = [[RACSignal
                interval:1 onScheduler:[RACScheduler mainThreadScheduler]]
                merge:self.cancelTimer];

        @weakify(self);
        [[[tickWithCancel take:self.countdownIntervals] map:^id(NSDate *date) {
            @strongify(self);
            return @(self.countdownIntervals - round([date timeIntervalSinceDate:startDate]));
        }] subscribeNext:^(NSNumber *countdown) {
            @strongify(self);
            [sender setTitle:[NSString stringWithFormat:NSLocalizedString(@"RESEND_VERIFY_CODE_WITH_%@", nil), countdown]
                    forState:UIControlStateNormal];
        }          error:^(NSError *error) {
            @strongify(self);
            self.isCounting = NO;
            [sender setTitle:NSLocalizedString(@"RESEND_VERIFY_CODE_TITLE", nil) forState:UIControlStateNormal];
        }      completed:^{
            @strongify(self);
            self.isCounting = NO;
            [sender setTitle:NSLocalizedString(@"RESEND_VERIFY_CODE_TITLE", nil) forState:UIControlStateNormal];
        }];
    }];

    RAC(self.verifyButton, enabled) = [RACObserve(self, isCounting) map:^id(NSNumber *value) {
        @strongify(self);
        return @(!value.boolValue);
    }];
}

- (void)setupSubviews {

    _textcodeField = ({
        NTTextcodeField *codeField = [NTTextcodeField new];
        [self.view addSubview:codeField];
        codeField;
    });

    _textLabel = ({
        UILabel *textLabel = [UILabel new];
        textLabel.font = [UIFont systemFontOfSize:17];
        textLabel.textColor = [UIColor nt_primaryForegroundColor];
        [self.view addSubview:textLabel];
        textLabel;
    });

    _detailLabel = ({
        UILabel *label = [UILabel new];
        label.textColor = [UIColor nt_primaryForegroundColor];
        label.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:label];
        label;
    });

    _verifyButton = ({
        UIButton *button = [NTReverseButton new];
        [self.view addSubview:button];
        button;
    });

    _loginWithPassButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tintColor = [UIColor nt_primaryForegroundColor];
        UIImage *image = [[UIImage imageNamed:@"right-arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:image forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"LOGIN_WITH_PASSWORD", @"Login with password") forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 200 - (image.size.width + 5.f), 0, 0);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, image.size.width);
//        [self.view addSubview:button];
        button;
    });

    _activityIndicatorView = ({
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.hidesWhenStopped = YES;
        [self.view addSubview:indicatorView];
        indicatorView;
    });

    // constraints
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX;
        make.top.equalTo(self.view).with.offset(66);
        make.height.equalTo(@([NTFactory buttonHeight]));
    }];

    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX;
        make.bottom.equalTo(_textLabel.mas_top);
    }];

    [_textcodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@50);
        make.top.equalTo(self.view).with.offset(76);
    }];

    [_verifyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(_textLabel.mas_bottom).with.offset(18);
        make.left.equalTo(self.view).with.offset([NTFactory viewPadding]);
        make.right.equalTo(self.view).with.offset(-[NTFactory viewPadding]);
        make.height.equalTo(@([NTFactory buttonHeight]));
    }];

//    [_loginWithPassButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX;
//        make.width.greaterThanOrEqualTo(@200);
//        make.top.greaterThanOrEqualTo(_verifyButton.mas_bottom).with.offset(18);
//        make.height.equalTo(@([NTFactory buttonHeight]));
//    }];

    [_activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX;
//        make.top.equalTo(_loginWithPassButton.mas_bottom).equalTo(@20);
        make.top.equalTo(_verifyButton.mas_bottom).equalTo(@20);
    }];
}

#pragma mark - textcodeField delegate

- (void)textcodeFieldDidFinishInsert:(NTTextcodeField *)aTextcodeField {
    [self submitVerifyCode:aTextcodeField.textcode];
}

#pragma mark - submit

- (void)submitVerifyCode:(NSString *)textcode {
    DDLogVerbose(@"verify code: %@", textcode);

    self.isSubmitting = YES;
    // send request
    @weakify(self);
    [[[NTHTTPSessionManager sharedManager]
            loginWithPhone:self.phoneNumber verifyCode:textcode]
            subscribeNext:^(id x) {
                @strongify(self);
                [self didFinishLogin];
                [self.cancelTimer sendError:nil];
                self.isSubmitting = NO;
            }
            error:^(NSError *error) {
                @strongify(self);
                [self.textcodeField shake:^{
                    self.textcodeField.textcode = nil;
                }];
                self.isSubmitting = NO;
                [self.textcodeField becomeFirstResponder];
            }];
}

- (void)didFinishLogin {
    // did finish login
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - setter && getter

- (void)setIsSubmitting:(BOOL)isSubmitting {
    _isSubmitting = isSubmitting;
    if (_isSubmitting) {
        [self.textcodeField resignFirstResponder];
    }
}


@end