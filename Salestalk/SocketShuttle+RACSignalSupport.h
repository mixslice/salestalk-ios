//
// Created by Zhang Zeqing on 4/21/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTSocketShuttle.h"

@class RACDelegateProxy;
@class RACSignal;

@interface NTSocketShuttle (RACSignalSupport)

@property (nonatomic, strong, readonly) RACDelegateProxy *rac_delegateProxy;

- (RACSignal *)rac_didReceiveMessageSignal;
- (RACSignal *)rac_didFailWithErrorSignal;

- (RACSignal *)rac_webSocketDidOpenSignal;
- (RACSignal *)rac_webSocketDidCloseSignal;
@end