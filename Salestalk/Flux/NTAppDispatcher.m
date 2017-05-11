//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTAppDispatcher.h"


@implementation NTAppDispatcher

+ (instancetype)sharedDispatcher {
    static NTAppDispatcher *sharedDispatcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDispatcher = [self new];
    });

    return sharedDispatcher;
}

@end