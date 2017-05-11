//
// Created by Zhang Zeqing on 5/8/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTStore.h"


@interface UserStore : NTStore

- (void)initUsers:(NSArray *)rawUsers;

- (void)initUser:(NSDictionary *)rawUser;

+ (instancetype)store;

@end