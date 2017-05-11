//
// Created by Zhang Zeqing on 4/21/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <JSQMessagesViewController/JSQMessagesAvatarImageFactory.h>
#import <RMPhoneFormat/RMPhoneFormat.h>
#import "ProfileViewController.h"
#import "NTUser.h"
#import "NTFactory.h"
#import "UIColor+NTFactory.h"
#import "NTReverseButton.h"
#import "UIImage+NTUtilites.h"
#import "UIImageView+NTAvatarView.h"


@interface ProfileViewController ()
@property(nonatomic, weak) UIImageView *avatarView;
@property(nonatomic, weak) UILabel *nameLabel;
@property(nonatomic, weak) UILabel *detailTextLabel;
@property(nonatomic, weak) UIButton *messageButton;
@property(nonatomic, weak) UIButton *followButton;
@end

@implementation ProfileViewController


- (instancetype)initWithUser:(NTUser *)user {
    self = [super init];
    if (self) {
        self.user = user;
    }

    return self;
}

+ (instancetype)controllerWithUser:(NTUser *)user {
    return [[self alloc] initWithUser:user];
}


- (void)loadView {
    [super loadView];

    self.view.backgroundColor = [UIColor nt_primaryColor];
    self.navigationItem.titleView = [NTFactory titleLogoView];

    [self setupSubviews];
}

- (void)setupSubviews {
    _avatarView = ({
        UIImageView *avatarView = [[UIImageView alloc] init];
        [self.view addSubview:avatarView];
        avatarView;
    });

    _nameLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor nt_primaryForegroundColor];
        [self.view addSubview:label];
        label;
    });

    _detailTextLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [[UIColor nt_primaryForegroundColor] colorWithAlphaComponent:0.66];
        [self.view addSubview:label];
        label;
    });

    _messageButton = ({
        UIButton *button = [NTReverseButton new];
        button.tintColor = [UIColor nt_secondaryColor];
        [button setTitleColor:[UIColor nt_primaryReverseColor] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"SEND_MESSAGE_TITLE", @"SEND_MESSAGE_TITLE") forState:UIControlStateNormal];
        [self.view addSubview:button];
        button;
    });

    _followButton = ({
        UIButton *button = [NTReverseButton new];
        [button setTitle:NSLocalizedString(@"FOLLOW", @"FOLLOW") forState:UIControlStateNormal];
        [self.view addSubview:button];
        button;
    });


    // constraints
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@47);
        make.centerX;
        make.width.equalTo(@75);
        make.height.equalTo(@75);
    }];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX;
        make.top.equalTo(_avatarView.mas_bottom).with.offset(20);
    }];

    [_detailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX;
        make.top.equalTo(_nameLabel.mas_bottom).with.offset(0);
    }];

    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_detailTextLabel.mas_bottom).with.offset(20);
        make.left.equalTo(self.view).with.offset([NTFactory viewPadding]);
        make.right.equalTo(self.view).with.offset(-[NTFactory viewPadding]);
        make.height.equalTo(@([NTFactory buttonHeight]));
    }];

    [_followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_messageButton.mas_bottom).with.offset(10);
        make.left.equalTo(self.view).with.offset([NTFactory viewPadding]);
        make.right.equalTo(self.view).with.offset(-[NTFactory viewPadding]);
        make.height.equalTo(@([NTFactory buttonHeight]));
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.avatarView setLargeAvatarWithUser:self.user];
    self.nameLabel.text = self.user.name;

    RMPhoneFormat *formatter = [[RMPhoneFormat alloc] init];
    NSString *formattedOutput = [formatter format:self.user.mobile];

    self.detailTextLabel.text = self.user.email ?: formattedOutput;
}


@end