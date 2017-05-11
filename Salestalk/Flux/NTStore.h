//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Realm/Realm.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@class RLMRealm;


@interface NTStore : NSObject

@property (nonatomic, strong) RLMRealm *realm;
@property(nonatomic, strong) id dispatchToken;

- (RACSignal *)changeSignal;

- (void)emit:(id)event;
@end