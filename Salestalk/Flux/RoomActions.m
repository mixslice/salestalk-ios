//
// Created by Zhang Zeqing on 6/7/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "RoomActions.h"
#import "NTAppDispatcher.h"
#import "Constants.h"
#import "RoomStore.h"


@implementation RoomActions

+ (void)receiveAll:(id)rawRooms {
    [RoomStore store];
    [[NTAppDispatcher sharedDispatcher] dispatch:@{
            kActionTypeKey: kActionTypeReceiveRawRooms,
            @"rawRooms": rawRooms
    }];
}

@end