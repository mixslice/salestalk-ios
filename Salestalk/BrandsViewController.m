//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "BrandsViewController.h"
#import "BrandResultsViewController.h"
#import "BrandStore.h"
#import "NTHTTPSessionManager.h"
#import "BrandCell.h"
#import "UIColor+NTFactory.h"
#import "NTFactory.h"
#import "NTBrand.h"
#import "BrandDetailViewController.h"
#import "NTSearchController.h"
#import "UIView+UIImageEffects.h"
#import "BrandCoverCell.h"
#import "Constants.h"
#import "NTAPIConstants.h"
#import "AFHTTPSessionManager+RACSupport.h"
#import "BrandActions.h"

@interface BrandsViewController () <UISearchResultsUpdating, UISearchControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property(nonatomic, strong) BrandStore *brandStore;
@property(nonatomic, strong) RLMResults *brands;
@property(nonatomic, strong) NTSearchController *searchController;
@property(nonatomic, strong) BrandResultsViewController *searchResultsController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation BrandsViewController {
    UIImageView *_snapshotView;
}

NSString *const CellIdentifierForCoverCell = @"CoverCell";
NSString *const CellIdentifier = @"Cell";

#pragma mark - view cycle

- (void)loadView {
    [super loadView];

    // customize
    [self customize];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"BRANDS_PAGE_TITLE", @"BRANDS_PAGE_TITLE");

    // init event store
    self.brandStore = [BrandStore store];
    [[self.brandStore changeSignal] subscribeNext:^(id x) {
        DDLogVerbose(@"BrandsViewController update");
        self.brands = [self.brandStore getAll];
    }];

    [[NTHTTPSessionManager sharedManager] getAllBrands];
    [self loadDataWithSignal:[NSNotificationCenter.defaultCenter rac_addObserverForName:kNTDidLoginNotification object:nil]];
    [self loadDataWithSignal:[self.refreshControl rac_signalForControlEvents:UIControlEventValueChanged]];

    // observe data
    [RACObserve(self, brands) subscribeNext:^(NSString *newBrands) {
        [self.tableView reloadData];
    }];

    // register cell
    [self.tableView registerClass:[BrandCoverCell class] forCellReuseIdentifier:CellIdentifierForCoverCell];
    [self.tableView registerClass:[BrandCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)loadDataWithSignal:(RACSignal *)signal {
    @weakify(self);
    [[signal
            flattenMap:^RACStream *(id value) {
                return [[NTHTTPSessionManager sharedManager] rac_GET:kFeatureBrandsURLString parameters:nil];
            }]
            subscribeNext:^(id x) {
                @strongify(self);
                RACTupleUnpack(id responseObject, NSURLResponse *response) = x;
                [BrandActions receiveAll:responseObject];
                [self.refreshControl endRefreshing];
            }
                    error:^(NSError *error) {
                        [self.refreshControl endRefreshing];
                    }];
}

- (void)dealloc {
    self.tableView.emptyDataSetSource = nil;
    self.tableView.emptyDataSetDelegate = nil;
    self.searchResultsController.tableView.delegate = nil;
    self.searchController.searchResultsUpdater = nil;
    self.searchController.delegate = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [self.searchResultsController.tableView
            deselectRowAtIndexPath:[self.searchResultsController.tableView indexPathForSelectedRow]
                          animated:animated];

    // call super
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;

        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}


#pragma mark - selector

- (void)customize {
    self.extendedLayoutIncludesOpaqueBars = YES;

    self.view.backgroundColor = [UIColor nt_backgroundColor];
    self.tableView.rowHeight = [NTFactory tableViewRowHeight];

    // empty data set
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];


    // refreshControl and backgroundColor
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor nt_primaryForegroundColor];

    UIView *bgView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor nt_primaryColor];
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        view.frame = CGRectOffset(screenBounds, 0, -screenBounds.size.height);
        view;
    });

    [self.tableView insertSubview:bgView atIndex:0];

    // search controller
    _searchResultsController = [[BrandResultsViewController alloc] init];
    _searchResultsController.tableView.delegate = self;
    self.searchController = [[NTSearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;

    [self.searchController.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchController.searchBar;
}

#pragma mark - UITableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.brands count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NTBrand *brand = [self.brands objectAtIndex:indexPath.row];

    if (indexPath.row == 0) {
        BrandCoverCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierForCoverCell forIndexPath:indexPath];

        // configure cell
//        cell.textLabel.text = brand.name;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:brand.coverPic]
                          placeholderImage:[NTFactory defaultBrandCover]];

        return cell;
    }
    else {
        BrandCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

        // configure cell
        cell.textLabel.text = brand.name;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:brand.logo]
                          placeholderImage:[NTFactory defaultBrandImage]];

        return cell;
    }
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView && indexPath.row == 0) {
        return 165;
    }
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        [self showBrandDetailAtIndexPath:indexPath];
    } else {
        [self showFilteredBrandDetailAtIndexPath:indexPath];
    }
}

#pragma mark - UITableView EmptyDataSet

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [NTFactory emptySetTitle:@"No brands yet"];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"icon-brand-default"];
}

#pragma mark - selector


- (void)showBrandDetailAtIndexPath:(NSIndexPath *)indexPath {
    NTBrand *brand = [self.brands objectAtIndex:indexPath.row];
    BrandDetailViewController *brandDetailViewController = [BrandDetailViewController controllerWithBrand:brand];
    [self.navigationController pushViewController:brandDetailViewController animated:YES];
}

- (void)showFilteredBrandDetailAtIndexPath:(NSIndexPath *)indexPath {
    NTBrand *brand = self.searchResultsController.filteredBrands[indexPath.row];
    BrandDetailViewController *brandDetailViewController = [BrandDetailViewController controllerWithBrand:brand];
    [self.navigationController pushViewController:brandDetailViewController animated:YES];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (!searchController.active) {
        return;
    }

    NSString *searchString = self.searchController.searchBar.text;

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.brands.count];
    for (RLMObject *object in self.brands) {
        [array addObject:object];
    }

    NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
    NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
    NSArray *searchResults = [array
            filteredArrayUsingPredicate:[NSComparisonPredicate
                    predicateWithLeftExpression:lhs
                                rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                           type:NSContainsPredicateOperatorType
                                        options:NSCaseInsensitivePredicateOption]];


    self.searchResultsController.filteredBrands = searchResults;
    [self.searchResultsController.tableView reloadData];

    self.searchResultsController.tableView.backgroundView = _snapshotView;
}

#pragma mark - SearchController Delegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    _snapshotView = [self.navigationController.view blurredViewWithTintColor:[UIColor nt_primaryColor]];
}


#pragma mark - UIStateRestoration

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];

    // encode the view state so it can be restored later

    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];

    UISearchController *searchController = self.searchController;

    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];

    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }

    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];

    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];

    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];

    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];

    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}

@end
