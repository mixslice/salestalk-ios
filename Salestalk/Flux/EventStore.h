//
// Created by Zhang Zeqing on 5/8/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTStore.h"


@interface EventStore : NTStore

+ (instancetype)store;

- (RLMResults *)getAllWithBrandID:(NSString *)brandID;
@end