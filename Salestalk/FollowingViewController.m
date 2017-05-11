//
// Created by Zhang Zeqing on 4/20/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Realm/Realm.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "FollowingViewController.h"
#import "UIColor+NTFactory.h"
#import "NTFactory.h"
#import "ContactCell.h"
#import "NTSectionHeaderView.h"
#import "ProfileViewController.h"
#import "BrandCell.h"
#import "NTBrand.h"
#import "NTUser.h"
#import "BrandStore.h"
#import "UserStore.h"
#import "BrandDetailViewController.h"
#import "NTHTTPSessionManager.h"

static NSString *cellIdentifierForUser = @"UserCell";
static NSString *cellIdentifierForBrand = @"BrandCell";
static NSString *headerIdentifier = @"Header";

@interface FollowingViewController ()
@property(nonatomic, strong) RLMResults *myBrands;
@property(nonatomic, strong) RLMResults *contacts;
@property(nonatomic, strong) UISegmentedControl *segmentedControl;
@end

@implementation FollowingViewController

- (void)loadView {
    [super loadView];

    self.navigationItem.titleView = [NTFactory titleLogoView];
    self.view.backgroundColor = [UIColor nt_backgroundColor];
    self.tableView.rowHeight = [NTFactory tableViewRowHeight];
    self.tableView.tableFooterView = [UIView new];

    _segmentedControl = ({
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"My Brands", @"Contacts"]];
        segmentedControl.frame = CGRectMake(0, 0, 200, segmentedControl.bounds.size.height);
        segmentedControl.selectedSegmentIndex = 0;

        self.navigationItem.titleView = segmentedControl;
        segmentedControl;
    });
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Contacts";
    [self.tableView registerClass:[ContactCell class] forCellReuseIdentifier:cellIdentifierForUser];
    [self.tableView registerClass:[BrandCell class] forCellReuseIdentifier:cellIdentifierForBrand];
    [self.tableView registerClass:[NTSectionHeaderView class] forHeaderFooterViewReuseIdentifier:headerIdentifier];

    @weakify(self);
    [[self.segmentedControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];

    // fetch all data
    [[[NTHTTPSessionManager sharedManager] getMyBrands] subscribeNext:^(id x) {
        @strongify(self);
        RACTupleUnpack(id responseObject, NSURLResponse *response) = x;
        [BrandStore.store initBrands:responseObject];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id IN %@", [responseObject valueForKey:@"id"]];
        self.myBrands = [NTBrand objectsInRealm:BrandStore.store.realm
                                  withPredicate:predicate];
    }];
}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        return self.myBrands.count;
    }
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierForBrand forIndexPath:indexPath];

    // configure cell
    NTBrand *brand = [self.myBrands objectAtIndex:indexPath.row];
    cell.textLabel.text = brand.name;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:brand.logo] placeholderImage:[NTFactory defaultBrandImage]];

    return cell;
}


#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self showBrandAtIndexPath:indexPath];
    } else {
        [self showProfileAtIndexPath:indexPath];
    }
}

#pragma mark - selector

- (void)showBrandAtIndexPath:(NSIndexPath *)indexPath {
    NTBrand *brand = [self.myBrands objectAtIndex:indexPath.row];
    BrandDetailViewController *brandDetailViewController = [BrandDetailViewController controllerWithBrand:brand];
    [self.navigationController pushViewController:brandDetailViewController animated:YES];
}

- (void)showProfileAtIndexPath:(NSIndexPath *)indexPath {
    NTUser *user = [self.contacts objectAtIndex:indexPath.row];
    ProfileViewController *profileViewController = [ProfileViewController controllerWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}


@end