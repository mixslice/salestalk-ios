//
// Created by Zhang Zeqing on 5/7/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "EventActions.h"
#import "Constants.h"
#import "NTAppDispatcher.h"
#import "EventStore.h"


@implementation EventActions

+ (void)receiveAll:(NSArray *)rawEvents {
    [EventStore store];
    [[NTAppDispatcher sharedDispatcher] dispatch:@{
            kActionTypeKey: kActionTypeReceiveRawEvents,
            @"rawEvents": rawEvents
    }];
}

@end