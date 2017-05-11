//
// Created by Zhang Zeqing on 5/7/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <JSQMessagesViewController/JSQMessage.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#import <JSQMessagesViewController/UIColor+JSQMessages.h>
#import <JSQMessagesViewController/JSQMessagesAvatarImage.h>
#import "NTUser.h"
#import <JSQMessagesViewController/JSQSystemSoundPlayer+JSQMessages.h>
#import <JSQMessagesViewController/JSQMessagesToolbarButtonFactory.h>
#import <JSQMessagesViewController/JSQMessagesTimestampFormatter.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <SDWebImage/SDWebImageManager.h>
#import <JSQMessagesViewController/JSQMessagesAvatarImageFactory.h>
#import "NTSocket.h"
#import "NTMessagesViewController.h"
#import "MessageStore.h"
#import "NTMessage.h"
#import "UIColor+NTFactory.h"
#import "UIViewController+NTTabBarController.h"
#import "Constants.h"
#import "MessageActions.h"
#import "UserStore.h"
#import "NTFactory.h"
#import "ProfileViewController.h"


#define DEFAULT_GAP_INTERVALS 180

#define FETCH_LIMIT 20

@interface NTMessagesViewController ()
@property (nonatomic, strong) MessageStore *messageStore;
@property(nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageData;
@property(nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property(nonatomic, weak) NTSocket *socket;
@property(nonatomic, strong) NSDictionary *avatars;

@property (nonatomic, strong) NSArray *messages;
@property(nonatomic, strong) RLMResults *ntmessages;

@property(nonatomic, strong) NTUser *user;

@property(nonatomic) NSUInteger fetchLimit;

- (NSArray *)processMessages:(RLMResults *)messages;
@end

@implementation NTMessagesViewController

#pragma mark - view cycle

- (instancetype)initWithRoomID:(NSString *)roomID {
    self = [super init];
    if (self) {
        self.roomID = roomID;
        self.title = self.roomID;
    }

    return self;
}

+ (instancetype)controllerWithRoomID:(NSString *)roomID {
    return [[self alloc] initWithRoomID:roomID];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self customize];

    // Demo
    [self initialize];
    self.view.frame = [[UIScreen mainScreen] bounds]; 

    self.messages = @[];


    // init message store
    @weakify(self);
    self.messageStore = [MessageStore store];
    [[self.messageStore changeSignal] subscribeNext:^(id x) {
        @strongify(self);
        RLMResults *results = [self.messageStore getAllWithRoomID:self.roomID];
        results = [results sortedResultsUsingProperty:@"createdAt" ascending:NO];
        self.ntmessages = results;

        self.messages = [self processMessages:results];
        [self.collectionView reloadData];
        [self finishReceivingMessage];
    }];

    [self.messageStore emit:CHANGE_EVENT];

    // socket
    self.socket = [NTSocket sharedSocket];
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"NEW_MESSAGE", @"NEW_MESSAGE");

    [RACObserve(self.socket, socketState) subscribeNext:^(NSNumber *socketStateValue) {
        @strongify(self);
        NTSocketState socketState = socketStateValue.integerValue;
        if (socketState == NTSocketStateConnected) {
            self.inputToolbar.contentView.textView.backgroundColor = [UIColor whiteColor];
            self.inputToolbar.contentView.textView.editable = YES;
        } else {
            self.inputToolbar.contentView.textView.backgroundColor = [UIColor nt_yellowColor];
            self.inputToolbar.contentView.textView.editable = NO;
        }
    }];

}



- (void)viewDidAppear:(BOOL)animated {
    [self.nt_tabBarController hideBottomBar:YES];
    [super viewDidAppear:animated];
}


#pragma mark - Helper

- (NSArray *)processMessages:(RLMResults *)messages {
    // process image
    NSMutableDictionary *mutableAvatars = [self.avatars ?: @{} mutableCopy];

    // load earlier
    self.showLoadEarlierMessagesHeader = messages.count > self.fetchLimit;

    NSUInteger count = MIN(messages.count, self.fetchLimit);
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger idx = 0; idx < count; idx++) {
        NTMessage *message = [messages objectAtIndex:count - idx - 1];
        JSQMessage *msg = [[JSQMessage alloc] initWithSenderId:message.from.id
                                             senderDisplayName:message.from.name
                                                          date:message.createdAt
                                                          text:message.text];
        [mutableArray addObject:msg];

        // download avatar
        id value = [mutableAvatars valueForKey:message.from.id];
        if (!value) {
            NSString *userID = message.from.id;
            mutableAvatars[userID] = message.from.messageAvatarImage;
            [[SDWebImageManager sharedManager] downloadImageWithURL:message.from.avatarURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                JSQMessagesAvatarImage *avatarImage = mutableAvatars[userID];
                if (image) {
                    avatarImage.avatarImage = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                    [self.collectionView reloadData];
                }
            }];
        }
    }

    self.avatars = [mutableAvatars copy];

    return [mutableArray copy];
}

- (void)customize {
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.inputToolbar.contentView.textView.selectable = NO;
    self.inputToolbar.contentView.rightBarButtonItem = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];

    self.hidesBottomBarWhenPushed = YES;

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor nt_primaryColor]];
}


- (void)initialize {
    self.senderId = [NTFactory currentUserID];
    self.user = [NTUser objectInRealm:[UserStore store].realm forPrimaryKey:self.senderId];
    self.senderDisplayName = self.user.name ?: @"Me";
    self.fetchLimit = FETCH_LIMIT;
}

- (NTMessage *)getMessageWithIndexPath:(NSIndexPath *)indexPath {
    NSUInteger count = MIN(self.ntmessages.count, self.fetchLimit);
    return [self.ntmessages objectAtIndex:count - indexPath.item - 1];
}

#pragma mark - JSQMessages CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    return message;
}

- (id <JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
              messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {

    JSQMessage *message = self.messages[indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }

    return self.incomingBubbleImageData;
}

- (id <JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                     avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {

    NTMessage *message = [self getMessageWithIndexPath:indexPath];
    return self.avatars[message.from.id];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
        attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    /**
    *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
    *  The other label text delegate methods should follow a similar pattern.
    *
    */
    JSQMessage *message = self.messages[indexPath.item];

    if (indexPath.item == 0) {
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = self.messages[indexPath.item - 1];
        if ([message.date timeIntervalSinceDate:previousMessage.date] > DEFAULT_GAP_INTERVALS) {
            return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
        }
    }

    /**
    *  Don't specify attributes to use the defaults.
    */
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
    *  Override point for customizing cells
    */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    /**
    *  Configure almost *anything* on the cell
    *
    *  Text colors, label text, label colors, etc.
    *
    *
    *  DO NOT set `cell.textView.font` !
    *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
    *
    *
    *  DO NOT manipulate cell layout information!
    *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
    */

    JSQMessage *msg = self.messages[indexPath.item];

    if (!msg.isMediaMessage) {

        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }

        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }

    // mark as read
    NTMessage *ntMessage = [self getMessageWithIndexPath:indexPath];
    if (!ntMessage.isRead) {
        [MessageActions markAsRead:ntMessage];
    }

    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
        heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    /**
    *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
    */

    /**
    *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
    *  The other label height delegate methods should follow similarly
    *
    *  Show a timestamp for every 3rd message
    */
    JSQMessage *message = self.messages[indexPath.item];

    if (indexPath.item == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = self.messages[indexPath.item - 1];
        if ([message.date timeIntervalSinceDate:previousMessage.date] > 60) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
    }

    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
    NSInteger earlierMessagesCount = self.messages.count;
    if (earlierMessagesCount < self.fetchLimit) {
        return;
    }

    self.fetchLimit += FETCH_LIMIT;
    self.messages = [self processMessages:self.ntmessages];
    [self.collectionView reloadData];

    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath
            indexPathForItem:self.messages.count - earlierMessagesCount inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:NO];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath {
    NTMessage *message = [self getMessageWithIndexPath:indexPath];
    ProfileViewController *profileViewController = [ProfileViewController controllerWithUser:message.from];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

#pragma mark - Action

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
    *  Sending a message. Your implementation of this method should do *at least* the following:
    *
    *  1. Play sound (optional)
    *  2. Add new id<JSQMessageData> object to your data source
    *  3. Call `finishSendingMessage`
    */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];

    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSMutableDictionary *message = [@{
            @"id" : uuid,
            @"roomID" : self.roomID,
            @"isRead" : @YES,
            @"text" : text,
            @"from" : @{
                    @"id" : self.senderId
            }
    } mutableCopy];

    [MessageActions createMessage:message];
    [[NTSocket sharedSocket] sendMessageWithRoomID:self.roomID text:text uuid:uuid];
    [self finishSendingMessageAnimated:YES];
}

@end