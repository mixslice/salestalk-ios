//
// Created by Zhang Zeqing on 4/20/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "SettingsViewController.h"
#import "UIColor+NTFactory.h"
#import "NTGroupedTableViewCell.h"
#import "Constants.h"
#import "UIViewController+NTTabBarController.h"


static NSString *cellIdentifier = @"Cell";
static NSString *centeredCellIdentifier = @"CenterCell";


#define LOGOUT_SECTION 1

@interface SettingsViewController ()
@end

@implementation SettingsViewController

#pragma mark - init

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"SETTINGS_PAGE_TITLE", @"SETTINGS_PAGE_TITLE");
    }

    return self;
}

#pragma mark - view cycle

- (void)loadView {
    [super loadView];

    self.view.backgroundColor = [UIColor nt_groupedTableViewBackground];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[NTGroupedTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.tableView registerClass:[NTGroupedTableViewCell class] forCellReuseIdentifier:centeredCellIdentifier];
}


#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NTGroupedTableViewCell *tableViewCell;
    if (indexPath.section == LOGOUT_SECTION) {
        tableViewCell = [tableView dequeueReusableCellWithIdentifier:centeredCellIdentifier forIndexPath:indexPath];
        tableViewCell.textLabel.textAlignment = NSTextAlignmentCenter;
        tableViewCell.textLabel.text = NSLocalizedString(@"LOGOUT_TITLE", @"LOGOUT_TITLE");
    } else {
        tableViewCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        tableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        tableViewCell.textLabel.text = NSLocalizedString(@"ACCOUNT_SETTINGS_TITLE", @"ACCOUNT_SETTINGS_TITLE");
    }

    return tableViewCell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == LOGOUT_SECTION) {
        [self logoutPressed];
    }
}

- (void)logoutPressed {
    UIAlertController *alertController = [UIAlertController
            alertControllerWithTitle:nil
                             message:nil
                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction
            actionWithTitle:NSLocalizedString(@"LOGOUT_TITLE", @"LOGOUT_TITLE")
                      style:UIAlertActionStyleDestructive
                    handler:^(UIAlertAction *action) {
                        [NSNotificationCenter.defaultCenter postNotificationName:kNTDidLogoutNotification object:nil];
                    }]];

    [alertController addAction:[UIAlertAction
            actionWithTitle:NSLocalizedString(@"CANCEL", @"CANCEL")
                      style:UIAlertActionStyleCancel
                    handler:nil]];

    alertController.view.tintColor = [UIColor nt_primaryColor];
    [self.nt_tabBarController presentViewController:alertController animated:YES completion:NULL];
}


@end