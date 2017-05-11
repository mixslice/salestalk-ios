//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTStore.h"

@class RLMResults;

@interface BrandStore : NTStore

- (void)initBrands:(NSArray *)rawBrands;

+ (instancetype)store;

- (RLMResults *)getAll;

@end