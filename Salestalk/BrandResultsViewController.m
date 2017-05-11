//
// Created by Zhang Zeqing on 5/5/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Realm/Realm.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "BrandResultsViewController.h"
#import "BrandCell.h"
#import "NTBrand.h"
#import "NTFactory.h"

static NSString *CellIdentifier = @"Cell";

@interface BrandResultsViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@end

@implementation BrandResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.tableView.backgroundColor = [[UIColor nt_primaryColor] colorWithAlphaComponent:0.95];
    self.tableView.rowHeight = [NTFactory tableViewRowHeight];
    self.tableView.tableFooterView = [UIView new];

    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;

    // register cell
    [self.tableView registerClass:[BrandCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)dealloc {
    self.tableView.emptyDataSetSource = nil;
    self.tableView.emptyDataSetDelegate = nil;
}

#pragma mark - UITableView Data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredBrands count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BrandCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // configure cell
    NTBrand *brand = self.filteredBrands[indexPath.row];
    cell.textLabel.text = brand.name;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:brand.logo]
                      placeholderImage:[NTFactory defaultBrandImage]];

    return cell;
}

#pragma mark - Empty Data Set

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [NTFactory emptySetTitle:@"No results"];
}

@end