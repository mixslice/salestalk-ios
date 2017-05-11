//
// Created by Zhang Zeqing on 4/17/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "StartViewController.h"
#import "NTFactory.h"
#import "LoginViewController.h"
#import "UIColor+NTFactory.h"
#import "NTReverseButton.h"


@interface StartViewController ()
@property (nonatomic, strong) UIButton *startButton;
@end

@implementation StartViewController

#pragma mark - view cycle

- (void)loadView {
    [super loadView];

    UIImageView *textLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-text-large"]];
    [self.view addSubview:textLogo];

    UIImageView *imgLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-img-large"]];
    [self.view addSubview:imgLogo];

    UILabel *sloganLabel = [[UILabel alloc] init];
    sloganLabel.textColor = [UIColor nt_primaryForegroundColor];
    sloganLabel.text = NSLocalizedString(@"SLOGAN_TEXT", @"slogan");
    [self.view addSubview:sloganLabel];

    _startButton = ({
        UIButton *startButton = [NTReverseButton systemButton];
        [startButton setTitle:NSLocalizedString(@"START_TITLE", @"start") forState:UIControlStateNormal];
        [self.view addSubview:startButton];
        startButton;
    });

    // constraints
    [imgLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];

    [sloganLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(imgLogo.mas_top).with.offset(-25);
    }];

    [textLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(sloganLabel.mas_top).with.offset(-10);
    }];

    [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgLogo.mas_bottom).with.offset(1);
        make.left.equalTo(self.view).with.offset([NTFactory viewPadding]);
        make.right.equalTo(self.view).with.offset(-[NTFactory viewPadding]);
        make.height.equalTo(@([NTFactory buttonHeight]));
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;

    [[self.startButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.navigationController pushViewController:[LoginViewController new] animated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    [super viewWillAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end