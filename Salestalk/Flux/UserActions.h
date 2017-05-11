//
// Created by Zhang Zeqing on 5/8/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserActions : NSObject
+ (void)receiveAll:(NSArray *)rawUsers;

+ (void)receiveUser:(NSDictionary *)rawUser;

+ (void)updateStatusForUser:(id)message;

@end