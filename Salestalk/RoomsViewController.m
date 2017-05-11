//
// Created by Zhang Zeqing on 4/20/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <ReactiveCocoa/NSNotificationCenter+RACSupport.h>
#import <ReactiveCocoa/RACSignal.h>
#import <JSQMessagesViewController/JSQMessagesAvatarImage.h>
#import "RoomsViewController.h"
#import "MessageStore.h"
#import "UIColor+NTFactory.h"
#import "RoomCell.h"
#import "NTMessagesViewController.h"
#import "Constants.h"
#import "RoomStore.h"
#import "NTRoom.h"
#import "NTMessage.h"
#import "NTUser.h"
#import "NTEvent.h"
#import "UIImageView+NTAvatarView.h"
#import "UIImage+Resize.h"
#import <SDWebImage/UIImageView+WebCache.h>


static NSString *cellIdentifier = @"Cell";

@interface RoomsViewController ()
@property(nonatomic, strong) RoomStore *roomStore;
@property(nonatomic, strong) RLMResults *rooms;
@property(nonatomic, strong) UISegmentedControl *segmentedControl;
@end

@implementation RoomsViewController

#pragma mark - view cycle

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        @weakify(self);
        [[[MessageStore store] messageCountSignal] subscribeNext:^(id x) {
            @strongify(self);
            self.tabBarItem.badgeValue = x;
            [self.tableView reloadData];
        }];

    }

    return self;
}


- (void)loadView {
    [super loadView];

    self.view.backgroundColor = [UIColor nt_backgroundColor];
    self.tableView.rowHeight = [NTFactory tableViewRowHeight];
    self.tableView.tableFooterView = [UIView new];

    _segmentedControl = ({
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Event", @"User"]];
        segmentedControl.frame = CGRectMake(0, 0, 200, segmentedControl.bounds.size.height);
        segmentedControl.selectedSegmentIndex = 0;

        self.navigationItem.titleView = segmentedControl;
        segmentedControl;
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Rooms";
    [self.tableView registerClass:[RoomCell class] forCellReuseIdentifier:cellIdentifier];

    self.roomStore = [RoomStore store];

    //add observer React cocoa (key value observing)
    @weakify(self);
    void (^reloadRooms)(id x) = ^(id x) {
        @strongify(self);
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            self.rooms = [self.roomStore getAllEventRoom];
        } else {
            self.rooms = [self.roomStore getAllUserRoom];
        };
        [self.tableView reloadData];
    };


    [[self.roomStore changeSignal] subscribeNext:reloadRooms];
    [self.roomStore emit:CHANGE_EVENT];

    [[self.segmentedControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:reloadRooms];
}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rooms.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    NTRoom *room = [self.rooms objectAtIndex:indexPath.row];

    // configure cell
    if ([room.eventID isEqualToString:@""]) {
        // user
        cell.textLabel.text = room.id;
        cell.detailTextLabel.text = room.latestMessage.text;
        [cell.imageView setAvatarWithUser:room.latestMessage.from];
    } else {
        // event
        cell.textLabel.text = room.eventID;
        UIImage *placeholderImage = [NTFactory defaultBrandImage];
        cell.imageView.image = placeholderImage;
        [[self.roomStore getEventWithRoom:room] subscribeNext:^(NTEvent *event) {
            cell.textLabel.text = event.title;
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:event.logo]
                              placeholderImage:placeholderImage
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         if (image) {
                                             cell.imageView.image = [image resizedImageToFitInSize:placeholderImage.size scaleIfSmaller:NO];
                                         }
                                     }];
        }];
        cell.detailTextLabel.text = room.latestMessage.text;
    }

    NSInteger unreadCount = [[MessageStore store] countOfUnreadMessagesInRoom:room.id];
    cell.badgeValue = [NSString stringWithFormat:@"%d", unreadCount];

    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showThreadMessagesAtIndexPath:indexPath];
}

#pragma mark - selector

- (void)showThreadMessagesAtIndexPath:(NSIndexPath *)indexPath {
    NTRoom *room = [self.rooms objectAtIndex:indexPath.row];
    NTMessagesViewController *messagesViewController = [NTMessagesViewController controllerWithRoomID:room.id];
    [self.navigationController pushViewController:messagesViewController animated:YES];
}


@end