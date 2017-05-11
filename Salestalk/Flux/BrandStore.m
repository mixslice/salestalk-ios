//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "BrandStore.h"
#import "NTAppDispatcher.h"
#import "Constants.h"
#import "NTBrand.h"
#import "RLMObject+JSON.h"


@implementation BrandStore

+ (instancetype)store {
    static BrandStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [self new];
    });

    return store;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.realm = [RLMRealm inMemoryRealmWithIdentifier:kInMemoryRealmIdentifier];

        NTAppDispatcher *dispatcher = [NTAppDispatcher sharedDispatcher];

        @weakify(self);
        self.dispatchToken = [dispatcher registerCallback:^(NSDictionary *payload) {
            @strongify(self);
            NSString *actionType = payload[kActionTypeKey];

            if (actionType == kActionTypeReceiveRawBrands) {
                NSArray *rawBrands = payload[@"rawBrands"];
                [self initBrands:rawBrands];
                [self emit:CHANGE_EVENT];
            }
        }];
    }

    return self;
}

- (void)initBrands:(NSArray *)rawBrands {
    [self.realm beginWriteTransaction];
    [NTBrand createOrUpdateInRealm:self.realm
                     withJSONArray:rawBrands];
    [self.realm commitWriteTransaction];
}

- (RLMResults *)getAll {
    return [NTBrand allObjectsInRealm:self.realm];
}

@end