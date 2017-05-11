//
//  NTSingleLineMessagesController.h
//  Salestalk
//
//  Created by Leo Jiang on 5/25/15.
//  Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import UIKit;
@class NTUser;

@interface NTSingleLineMessagesController : UIViewController
@property (nonatomic,strong) UILabel *messageLabel;
+ (instancetype)initWithUser:(NTUser *)user
                   withFrame:(CGRect )frame
                  withRoomID:(NSString *)roomID;

@end

