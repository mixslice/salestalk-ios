//
// Created by Zhang Zeqing on 5/8/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "UserActions.h"
#import "NTAppDispatcher.h"
#import "Constants.h"
#import "UserStore.h"


@implementation UserActions

+ (void)receiveAll:(NSArray *)rawUsers {
    [UserStore store];
    [[NTAppDispatcher sharedDispatcher] dispatch:@{
            kActionTypeKey : kActionTypeReceiveRawUsers,
            @"rawUsers" : rawUsers
    }];
}

+ (void)receiveUser:(NSDictionary *)rawUser {
    [UserStore store];
    [[NTAppDispatcher sharedDispatcher] dispatch:@{
            kActionTypeKey: kActionTypeReceiveRawUser,
            @"rawUser": rawUser
    }];
}

+ (void)updateStatusForUser:(id)message {
    [UserStore store];
    [[NTAppDispatcher sharedDispatcher] dispatch:@{
            kActionTypeKey: kActionTypeUpdateUserStatus,
            @"message": message,
    }];
}
@end