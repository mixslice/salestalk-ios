//
// Created by Zhang Zeqing on 4/19/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PasswordViewController.h"
#import "UIColor+NTFactory.h"
#import "NTTextField.h"
#import "NTFactory.h"
#import "UIView+NTHelper.h"
#import "Constants.h"


@interface PasswordViewController () <UITextFieldDelegate>
@property (nonatomic, weak) UITextField *textField;
@property(nonatomic, weak) UILabel *invalidErrorLabel;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic) BOOL isSubmitting;
@end

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"PASSWORD_VIEW_TITLE", @"PASSWORD_VIEW_TITLE");

    NSString *placeholder = NSLocalizedString(@"PASSFIELD_PLACEHOLDER", @"PASSFIELD_PLACEHOLDER");
    _textField.attributedPlaceholder = [[NSAttributedString alloc]
            initWithString:placeholder attributes:[NTFactory placeholderAttributes]];

    _invalidErrorLabel.text = NSLocalizedString(@"PASSWORD_INVALID_INFO", @"PASSWORD_INVALID_INFO");
    self.invalidErrorLabel.hidden = YES;

    [RACObserve(self, isSubmitting) subscribeNext:^(NSNumber *isSubmitting) {
        if (isSubmitting.boolValue) {
            [self.activityIndicatorView startAnimating];
        } else {
            [self.activityIndicatorView stopAnimating];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.textField becomeFirstResponder];

    [super viewDidAppear:animated];
}

- (void)loadView {
    [super loadView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:NSLocalizedString(@"NEXT_TITLE", @"Next")
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(nextPressed)];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:NSLocalizedString(@"BACK_TITLE", @"BACK_TITLE")
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:nil];

    _textField = ({
        NTTextField *textField = [[NTTextField alloc] initWithType:NTTextFieldTypePassword];
        textField.delegate = self;
        [self.view addSubview:textField];
        textField;
    });

    _invalidErrorLabel = ({
        UILabel *invalidErrorLabel = [[UILabel alloc] init];
        invalidErrorLabel.textColor = [UIColor nt_primaryForegroundColor];
        invalidErrorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        [self.view addSubview:invalidErrorLabel];
        invalidErrorLabel;
    });

    _activityIndicatorView = ({
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.hidesWhenStopped = YES;
        [self.view addSubview:indicatorView];
        indicatorView;
    });


    // constraints
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(66);
        make.left.equalTo(self.view).with.offset([NTFactory viewPadding]);
        make.right.equalTo(self.view).with.offset(-[NTFactory viewPadding]);
        make.height.equalTo(@([NTFactory buttonHeight]));
    }];

    [_invalidErrorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(_textField.mas_bottom).with.offset(10);
    }];

    [_activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX;
        make.top.equalTo(_invalidErrorLabel.mas_bottom).with.offset(10);
    }];
}

#pragma mark - Helper

- (void)nextPressed {
    // todo: login
    self.isSubmitting = YES;
    [[[RACSignal empty] delay:0.5] subscribeCompleted:^{
        if ([self.textField.text isEqualToString:@"8888"]) {
            [self didFinishLogin];
        } else {
            self.invalidErrorLabel.hidden = NO;
            [self.invalidErrorLabel shake:^{
                self.textField.text = nil;
            }];
        }
        self.isSubmitting = NO;
    }];

}

- (void)didFinishLogin {
    // did finish login
    [self.textField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNTDidLoginNotification object:nil];
}

#pragma mark - textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self nextPressed];
    return YES;
}


@end