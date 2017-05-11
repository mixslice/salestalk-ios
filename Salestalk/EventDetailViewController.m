//
// Created by Zhang Zeqing on 4/26/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <Realm/Realm.h>
#import <NJKWebViewProgress/NJKWebViewProgress.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "EventDetailViewController.h"
#import "NTNavigationController.h"
#import "UIColor+NTFactory.h"
#import "UserAvatarCollectionCell.h"
#import "NTSocket.h"
#import "UserStore.h"
#import "NTUser.h"
#import "UserStatusStore.h"
#import "NTUserStatus.h"
#import "UIViewController+NTTabBarController.h"
#import "NTSingleLineMessagesController.h"
#import "UIImageView+NTAvatarView.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

#define MAX_NUM_OF_USERS 3

static NSString *cellIdentifier = @"AvatarCell";

@interface EventDetailViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>
@property(nonatomic, strong) NTEvent *event;
@property(nonatomic, strong) RLMResults *users;
@property(nonatomic, weak) UIActivityIndicatorView *indicatorView;
@property(nonatomic, weak) UIWebView *webView;
@property(nonatomic, strong) NJKWebViewProgress *progressProxy;
@end

@implementation EventDetailViewController

- (instancetype)initWithEvent:(NTEvent *)event {
    self = [super init];
    if (self) {
        self.event = event;
        self.title = self.event.title;
    }

    return self;
}

+ (instancetype)controllerWithEvent:(NTEvent *)event {
    return [[self alloc] initWithEvent:event];
}

#pragma mark - view cycle

- (void)loadView {
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor nt_backgroundColor];
    self.hidesBottomBarWhenPushed = YES;

    _collectionView = ({
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.itemSize = CGSizeMake(100, 100);
        flowLayout.minimumLineSpacing = 0;

        UICollectionView *collectionView = [[UICollectionView alloc]
                initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)
         collectionViewLayout:flowLayout];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        collectionView.backgroundColor = [UIColor nt_primaryColor];
        collectionView.scrollsToTop = NO;
        collectionView.pagingEnabled = YES;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        [self.view addSubview:collectionView];
        collectionView;
    });

    _indicatorView = ({
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.view addSubview:indicatorView];
        indicatorView;
    });

    _webView = ({
        UIWebView *webView = [[UIWebView alloc] init];
        _progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
        webView.delegate = self.progressProxy;
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
        [self.view addSubview:webView];
        webView;
    });

    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_collectionView.mas_bottom);
        make.left.and.right.and.bottom.equalTo(self.view);
    }];

    [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_collectionView);
        make.width.and.height.equalTo(@50);
    }];

    UIBarButtonItem *item = [[UIBarButtonItem alloc]
            initWithTitle:NSLocalizedString(@"Back", @"Back")
                    style:UIBarButtonItemStyleDone
                   target:self
                   action:@selector(dismiss:)];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = item;

}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    DDLogVerbose(@"content URL: %@", self.event.contentURL);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.event.contentURL]]];

    [self.collectionView registerClass:[UserAvatarCollectionCell class] forCellWithReuseIdentifier:cellIdentifier];

    [self.indicatorView startAnimating];

    // start fetch user
    NTSocket *socket = [NTSocket sharedSocket];
    @weakify(self);

    [[socket getEventUsersSignalWithEventID:self.event.id]
            subscribeNext:^(NSArray *rawUsers) {
                @strongify(self);

                NSArray *filteredUsers = [rawUsers filteredArrayUsingPredicate:
                        [NSPredicate predicateWithFormat:@"NOT id = %@", [NTFactory currentUserID]]];
                [[UserStore store] initUsers:filteredUsers];
                self.users = [NTUser objectsInRealm:[UserStore store].realm
                                      withPredicate:[NSPredicate predicateWithFormat:@"id IN %@", [filteredUsers valueForKey:@"id"]]];

                id userIds = [self.users valueForKey:@"id"];
                if (userIds) {
                    [socket subscribeUsers:userIds];
                }

                [self.collectionView reloadData];
                [self.indicatorView stopAnimating];
            }];

    [[[UserStatusStore store] changeSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self.collectionView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.nt_tabBarController hideBottomBar:YES];
    [self parentViewController].navigationItem.title = self.event.title;
    [super viewDidAppear:animated];
}

- (void)dealloc {
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    _progressProxy.progressDelegate = nil;
    _webView.delegate = nil;

    NTSocket *socket = [NTSocket sharedSocket];

    NSArray *ids = [self.users valueForKey:@"id"];
    if (ids) {
        [socket unSubscribeUsers:ids];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}


#pragma mark - UICollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(self.users.count, MAX_NUM_OF_USERS);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserAvatarCollectionCell *cell = [collectionView
            dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    // configure cell
    NTUser *user = [self.users objectAtIndex:indexPath.item];
    NTUserStatus *status = [NTUserStatus objectInRealm:[UserStatusStore store].realm
                                         forPrimaryKey:user.id];

    [cell.imageView setAvatarWithUser:user];
    cell.textLabel.text = user.name;
    cell.onlineStatus = status.onlineStatus;

    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.indicatorView startAnimating];
    NTUser *user = [self.users objectAtIndex:indexPath.item];
    
    /*Subview triggered by selection on user*/
    CGRect userMessageSubviewFrame = CGRectMake(0, 0, self.view.bounds.size.width, _collectionView.frame.size.height);

    @weakify(self);
    [[[NTSocket sharedSocket] createRoomWithEventID:self.event.id andUserID:user.id]
            subscribeNext:^(id message) {
                @strongify(self);
                NSString *roomID = message[@"roomid"];
                UIViewController *nextViewController = [NTSingleLineMessagesController initWithUser:user
                                                                                          withFrame:userMessageSubviewFrame
                                                                                         withRoomID:roomID];
                [self.indicatorView stopAnimating];
                [(NTNavigationController *) self.parentViewController pushViewController:nextViewController animated:YES];
            }];

}


#pragma mark - UIWebView Progress delegate

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    if (progress > NJKInteractiveProgressValue) {
        [SVProgressHUD dismiss];
    } else {
        // todo: webView loading progress
//        [SVProgressHUD show];
    }
}

@end