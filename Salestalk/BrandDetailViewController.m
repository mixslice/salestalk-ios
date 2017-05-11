//
// Created by Zhang Zeqing on 4/21/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <CocoaLumberjack/DDLog.h>
#import <CSStickyHeaderFlowLayout/CSStickyHeaderFlowLayout.h>
#import <ReactiveCocoa/RACTuple.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "BrandDetailViewController.h"
#import "EventStore.h"
#import "UIColor+NTFactory.h"
#import "NTBrand.h"
#import "EventSeatCell.h"
#import "NTCollectionSupplementaryView.h"
#import "BrandDetailFlowLayout.h"
#import "EventDetailViewController.h"
#import "BrandDescriptionCell.h"
#import "BrandHeaderView.h"
#import "NTFactory.h"
#import "NTHTTPSessionManager.h"
#import "NTEvent.h"
#import "UserToEventAnimator.h"
#import "NTSingleLineMessagesController.h"
#import "NTMessageToEventAnimator.h"
#import "NTNavigationController.h"
#import "EventContainerViewController.h"


static NSString *cellIdentifierForSeat = @"EventSeatCell";
static NSString *cellIdentifierForDesc = @"DescCell";
static NSString *headerViewIdentifier = @"Header";

@interface BrandDetailViewController ()
@property(nonatomic, strong) RLMResults *events;
@property(nonatomic, strong) EventStore *eventStore;
@property(nonatomic, strong) UIBarButtonItem *followButton;
@property(nonatomic, strong) UIBarButtonItem *unfollowButton;
@end

@implementation BrandDetailViewController

#pragma mark - init

- (instancetype)initWithBrand:(NTBrand *)brand {
    self = [super initWithCollectionViewLayout:[BrandDetailFlowLayout new]];
    if (self) {
        self.brand = brand;
    }

    return self;
}

+ (instancetype)controllerWithBrand:(NTBrand *)brand {
    return [[self alloc] initWithBrand:brand];
}

#pragma mark - selector

- (void)followBrand {
    [[[NTHTTPSessionManager sharedManager] followBrandWithID:self.brand.id follow:YES] subscribeNext:^(id x) {
        [SVProgressHUD showSuccessWithStatus:@"Followed"];
        self.navigationItem.rightBarButtonItem = self.unfollowButton;
    }];
}

- (void)unFollowBrand {
    [[[NTHTTPSessionManager sharedManager] followBrandWithID:self.brand.id follow:NO] subscribeNext:^(id x) {
        [SVProgressHUD showSuccessWithStatus:@"UnFollowed"];
        self.navigationItem.rightBarButtonItem = self.followButton;
    }];
}

#pragma mark - view cycle

- (void)loadView {
    [super loadView];

    self.navigationItem.titleView = [NTFactory titleLogoView];
    self.followButton = [[UIBarButtonItem alloc]
            initWithTitle:@"Follow" style:UIBarButtonItemStyleDone target:self action:@selector(followBrand)];
    self.unfollowButton = [[UIBarButtonItem alloc]
            initWithTitle:@"UnFollow" style:UIBarButtonItemStyleDone target:self action:@selector(unFollowBrand)];

    self.collectionView.backgroundColor = [UIColor nt_backgroundColor];
    self.collectionView.alwaysBounceVertical = YES;

    // Locate your layout
    CSStickyHeaderFlowLayout *layout = (id) self.collectionViewLayout;
    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        CGSize size = CGSizeMake(self.collectionView.bounds.size.width, 160);
        layout.parallaxHeaderReferenceSize = size;
        layout.parallaxHeaderMinimumReferenceSize = size;
        layout.disableStickyHeaders = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.followButton;

    [self.collectionView registerClass:[EventSeatCell class] forCellWithReuseIdentifier:cellIdentifierForSeat];
    [self.collectionView registerClass:[BrandDescriptionCell class] forCellWithReuseIdentifier:cellIdentifierForDesc];
    [self.collectionView registerClass:[BrandHeaderView class]
            forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader withReuseIdentifier:@"header"];
    [self.collectionView registerClass:[NTCollectionSupplementaryView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerViewIdentifier];


    // init event store
    self.eventStore = [EventStore store];
    [[self.eventStore changeSignal] subscribeNext:^(id x) {
        self.events = [self.eventStore getAllWithBrandID:self.brand.id];
    }];

    // fetch all data
    [[NTHTTPSessionManager sharedManager] getEventsByBrandID:self.brand.id];

    // observe data
    [RACObserve(self, events) subscribeNext:^(NSString *newBrands) {
        [self.collectionView reloadData];
    }];
}


#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.events.count;
    }
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        EventSeatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifierForSeat forIndexPath:indexPath];

        // configure cell
        NTEvent *event = [self.events objectAtIndex:indexPath.row];
        cell.textLabel.text = event.title;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:event.logo]
                          placeholderImage:[NTFactory defaultBrandImage]];

        return cell;
    } else {
        BrandDescriptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifierForDesc forIndexPath:indexPath];

        // configure cell
        cell.textLabel.text = self.brand.desc;

        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        BrandHeaderView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                   withReuseIdentifier:@"header"
                                                                          forIndexPath:indexPath];

        // configure header
        cell.textLabel.text = self.brand.name;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.brand.logo]
                          placeholderImage:[NTFactory defaultBrandImage]];
        [cell.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:self.brand.coverPic]
                                    placeholderImage:[NTFactory defaultBrandCover]];

        return cell;

    } else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NTCollectionSupplementaryView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                 withReuseIdentifier:headerViewIdentifier
                                                                                        forIndexPath:indexPath];

        // custom content
        if (indexPath.section == 0) {
            cell.textLabel.text = NSLocalizedString(@"BRAND_EVENTS_SECTION_HEADER", @"BRAND_EVENTS_SECTION_HEADER");
        } else {
            cell.textLabel.text = NSLocalizedString(@"BRAND_DESCRIPTION_SECTION_HEADER", @"BRAND_DESCRIPTION_SECTION_HEADER");
        }

        return cell;
    }

    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets result = ((UICollectionViewFlowLayout *) collectionViewLayout).sectionInset;
    if (section != 0) {
        result = UIEdgeInsetsZero;
    }
    return result;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        CGFloat height = [BrandDescriptionCell heightWithString:self.brand.desc];
        return CGSizeMake(self.view.bounds.size.width, height);
    }

    return ((UICollectionViewFlowLayout *) collectionViewLayout).itemSize;
}


#pragma mark - UICollection delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NTEvent *event = [self.events objectAtIndex:indexPath.item];

        EventDetailViewController *eventVC = [EventDetailViewController controllerWithEvent:event];
        EventContainerViewController *nc = [[EventContainerViewController alloc] initWithRootViewController:eventVC];
        [self.navigationController presentViewController:nc
                                                animated:YES
                                              completion:nil];

    }
}


@end