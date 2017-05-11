//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "BrandActions.h"
#import "Constants.h"
#import "NTAppDispatcher.h"
#import "BrandStore.h"


@implementation BrandActions

+ (void)receiveAll:(NSArray *)rawBrands {
    [BrandStore store];
    [[NTAppDispatcher sharedDispatcher] dispatch:@{
            kActionTypeKey: kActionTypeReceiveRawBrands,
            @"rawBrands": rawBrands
    }];
}

@end