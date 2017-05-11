//
//  NTSingleLineMessagesController.m
//  Salestalk
//
//  Created by Leo Jiang on 5/25/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Masonry/View+MASAdditions.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NTSingleLineMessagesController.h"
#import "NTNavigationController.h"
#import "MessageStore.h"
#import "NTMessage.h"
#import "UIColor+NTFactory.h"
#import "NTUser.h"
#import "NTMessagesViewController.h"
#import "Constants.h"

static NSString *TEXT_FONT = @"Helvetica";
static CGFloat ANIMATION_DURATION = 0.250;

@interface NTSingleLineMessagesController ()
@property(nonatomic, strong) NTUser *user;
@property(nonatomic, copy) NSString *roomID;
@property(nonatomic, strong) NTMessage *message;

@property(nonatomic, strong) MessageStore *mStore;

@property(nonatomic, strong) UIImageView *avatarView;
@property(nonatomic, strong) UIView *userMessageSubview;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) NSString *prevMessageText;
@property(nonatomic) CGRect eventCollectionViewFrame;
@end


@implementation NTSingleLineMessagesController

- (instancetype)initUser:(NTUser *)user withFrame:(CGRect)frame withRoomID:(NSString *)roomID {
    self = [super init];
    /*Set up variables*/
    self.user = user;
    self.eventCollectionViewFrame = frame;
    self.roomID = roomID;
    return self;
}

+ (instancetype)initWithUser:(NTUser *)user withFrame:(CGRect)frame withRoomID:(NSString *)roomID {
    return [[self alloc] initUser:user withFrame:frame withRoomID:roomID];
}

#pragma mark - view cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSubviews];

    self.title = self.roomID;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:NSLocalizedString(@"Back", @"Back")
                    style:UIBarButtonItemStylePlain
                   target:nil
                   action:nil];

    self.mStore = [MessageStore store];

    //add observer React cocoa (key value observing)
    @weakify(self);
    [[self.mStore changeSignal] subscribeNext:^(id x) {
        @strongify(self);
        RLMResults *allMessages = [self.mStore getAllWithRoomID:self.roomID];
        self.message = [allMessages lastObject];
        /*This code executes before allMessages gets updated...it's one message behind */
        self.prevMessageText = allMessages.count > 1 ? ((NTMessage *) [allMessages objectAtIndex:(allMessages.count - 1)]).text : @"";
//        [self newMessageAnimation];
    }];
    [self.mStore emit:CHANGE_EVENT];


    /*Button -> full screen */
    [self setFullScreenButton];
    /*Swipe gesture -> full screen */
    UISwipeGestureRecognizer *swipeGesture;
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeGesture];

}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeFullScreenButton];
}

- (void)dealloc {
//    [self removeObserver:self forKeyPath:@"message"];

}

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor nt_primaryColor];

    _userMessageSubview = [[UIView alloc] initWithFrame:_eventCollectionViewFrame];
    _userMessageSubview.translatesAutoresizingMaskIntoConstraints = YES;
    _userMessageSubview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    _userMessageSubview.backgroundColor = [UIColor nt_primaryColor];
    [self.view addSubview:_userMessageSubview];

    _avatarView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        [_userMessageSubview addSubview:imageView];
        [imageView setImageWithURL:self.user.avatarURL];
        imageView;
    });

    _nameLabel = ({
        UILabel *label = [UILabel new];
        label.numberOfLines = 1;
        label.textColor = [UIColor whiteColor];
        label.text = self.user.name;
        label.font = [UIFont fontWithName:TEXT_FONT size:16.0];
        [_userMessageSubview addSubview:label];
        label;
    });

    _messageLabel = ({
        UILabel *label = [UILabel new];
        label.numberOfLines = 2;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:TEXT_FONT size:14.0];
        label.text = @"- No Recorded Messages -";
        [_userMessageSubview addSubview:label];
        label.alpha = 0;
        label;
    });

    // auto layout
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@25);
        make.top.equalTo(@20);
//        make.centerY;
        make.width.and.height.equalTo(@50);
        _avatarView.layer.cornerRadius = 50 / 2;
        _avatarView.clipsToBounds = YES;
    }];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatarView.mas_right).with.offset(self.view.frame.size.width / 16);
        make.top.equalTo(_avatarView.mas_top);
    }];


    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel.mas_bottom).with.offset(1);
        make.left.equalTo(_nameLabel.mas_left);
        make.right.equalTo(@0).with.offset(10);
    }];
}

#pragma mark - FullScreen Button lifecycle

- (void)setFullScreenButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"FullScreen"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(transitionToNTMessenger)];
    [self parentViewController].navigationItem.rightBarButtonItem = button;
};

- (void)removeFullScreenButton {
    [self parentViewController].navigationItem.rightBarButtonItem = nil;
}


#pragma mark - animations

- (void)newMessageAnimation {
    /*old message label moves down - out of screen(container) */
    /*new message label drops from outscreen into screen */
    UILabel *oldMessageLabel = [[UILabel alloc] initWithFrame:_messageLabel.frame];
    oldMessageLabel.font = _messageLabel.font;
    oldMessageLabel.textColor = _messageLabel.textColor;
    oldMessageLabel.text = _prevMessageText;
    [_userMessageSubview addSubview:oldMessageLabel];
    [_userMessageSubview bringSubviewToFront:oldMessageLabel];
    CGFloat travelDistance = _messageLabel.frame.size.height;
    _messageLabel.transform = CGAffineTransformMakeTranslation(0, -travelDistance);
    _messageLabel.alpha = 0;
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         oldMessageLabel.transform = CGAffineTransformMakeTranslation(0, travelDistance);
                         oldMessageLabel.alpha = 0;
                         _messageLabel.transform = CGAffineTransformIdentity;
                         _messageLabel.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [oldMessageLabel removeFromSuperview];
                     }];
    oldMessageLabel = nil;

}


- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)gesture {
    [self transitionToNTMessenger];
}

- (void)transitionToNTMessenger {
    if (![self NTMessageExists]) {
        NTMessagesViewController *messagesViewController = [NTMessagesViewController controllerWithRoomID:self.roomID];
        [(NTNavigationController *) self.parentViewController pushViewController:messagesViewController animated:YES];
    }
}

- (BOOL)NTMessageExists {
    return [self.parentViewController.childViewControllers.lastObject isKindOfClass:[NTMessagesViewController class]];
}

#pragma mark - getter & setter

- (void)setMessage:(NTMessage *)message {
    /* set subviews to correspond to latest message */
    if (message != nil) {
        _message = message;
        _messageLabel.text = self.message.text;
        [_nameLabel setText:message.from.name];
        [_avatarView setImageWithURL:self.message.from.avatarURL];
    }
    /* no message history - default values */
}


@end
