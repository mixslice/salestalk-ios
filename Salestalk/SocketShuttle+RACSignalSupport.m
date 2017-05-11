//
// Created by Zhang Zeqing on 4/21/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "SocketShuttle+RACSignalSupport.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <objc/runtime.h>
#import <ReactiveCocoa/RACDelegateProxy.h>
#import <CocoaLumberjack/CocoaLumberjack.h>


@implementation NTSocketShuttle (RACSignalSupport)

static void RACUseDelegateProxy(NTSocketShuttle *self) {
    if (self.delegate == self.rac_delegateProxy) return;

    self.rac_delegateProxy.rac_proxiedDelegate = self.delegate;
    self.delegate = (id)self.rac_delegateProxy;
}

- (RACDelegateProxy *)rac_delegateProxy {
    RACDelegateProxy *proxy = objc_getAssociatedObject(self, _cmd);
    if (proxy == nil) {
        proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(NTSocketShuttleDelegate)];
        objc_setAssociatedObject(self, _cmd, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return proxy;
}

- (RACSignal *)rac_didReceiveMessageSignal {
    @weakify(self);
    RACSignal *signal = [[[[[self.rac_delegateProxy
            signalForSelector:@selector(socket:didReceiveMessage:)]
            reduceEach:^id (NTSocketShuttle *webSocket, NSString *message) {
                @strongify(self);
                NSError *serializerError = nil;
                NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
                id JSON = [NSJSONSerialization JSONObjectWithData:data
                                                          options:0
                                                            error:&serializerError];

                if (JSON) {
                    return JSON;
                }
                DDLogError(@"error: %@", serializerError);
                return nil;
            }]
            filter:^BOOL(id value) {
                return nil != value;
            }]
            takeUntil:self.rac_willDeallocSignal]
            setNameWithFormat:@"%@ -rac_didReceiveMessageSignal", self.class];

    RACUseDelegateProxy(self);

    return signal;
}

- (RACSignal *)rac_didFailWithErrorSignal {
    RACSignal *signal = [[[[self.rac_delegateProxy
            signalForSelector:@selector(socket:didFailWithError:)]
            reduceEach:^(NTSocketShuttle *webSocket, NSError *error) {
                return error;
            }]
            takeUntil:self.rac_willDeallocSignal]
            setNameWithFormat:@"%@ -rac_didFailWithErrorSignal", self.class];

    RACUseDelegateProxy(self);

    return signal;
}

- (RACSignal *)rac_webSocketDidOpenSignal {
    RACSignal *signal = [[[self.rac_delegateProxy
            signalForSelector:@selector(socketDidOpen:)]
            takeUntil:self.rac_willDeallocSignal]
            setNameWithFormat:@"%@ -rac_webSocketDidOpenSignal", self.class];

    RACUseDelegateProxy(self);

    return signal;
}

- (RACSignal *)rac_webSocketDidCloseSignal {
    RACSignal *signal = [[[[self.rac_delegateProxy
            signalForSelector:@selector(socket:didCloseWithCode:reason:wasClean:)]
            reduceEach:^(NTSocketShuttle *webSocket, NSNumber *code, NSString *reason, NSNumber *wasClean) {
                return reason;
            }]
            takeUntil:self.rac_willDeallocSignal]
            setNameWithFormat:@"%@ -rac_webSocketDidCloseSignal", self.class];

    RACUseDelegateProxy(self);

    return signal;
}



@end