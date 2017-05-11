//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "MessageActions.h"
#import "NTAppDispatcher.h"
#import "Constants.h"
#import "NTSocket.h"
#import "NTMessage.h"
#import "MessageStore.h"


@implementation MessageActions

+ (void)createMessage:(id)message {
    [MessageStore store];
    [[NTAppDispatcher sharedDispatcher] dispatch:@{
            kActionTypeKey: kActionTypeCreateMessage,
            @"message": message
    }];
}

+ (void)receiveAll:(id)rawMessages {
    [MessageStore store];
    [[NTAppDispatcher sharedDispatcher] dispatch:@{
            kActionTypeKey: kActionTypeReceiveRawMessages,
            @"rawMessages": rawMessages
    }];
}

+ (void)markAsRead:(NTMessage *)message {
    [MessageStore store];
    [[NTAppDispatcher sharedDispatcher] dispatch:@{
            kActionTypeKey: kActionTypeMarkAsRead,
            @"message": message
    }];
}
@end