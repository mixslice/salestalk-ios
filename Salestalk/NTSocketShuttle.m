//
// Created by Zhang Zeqing on 6/1/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Reachability/Reachability.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "NTSocketShuttle.h"
#import "Reachability+RACExtensions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>


NSString * const NTSocketConnectErrorDomain = @"com.nysnetech.error.socket.connect";


@interface NTSocketShuttle () <SRWebSocketDelegate>
@property (nonatomic, readwrite) NTSocketState socketState;
@property (nonatomic, readwrite) BOOL isActive;
@end

@implementation NTSocketShuttle {
    SRWebSocket *_socket;
    Reachability *_reachability;
    BOOL _tryReconnectImmediatly;
    BOOL _observerWasAdded;
    id _waitForCardDealBlock;
    id _connectionTimeoutBlock;
}

-(id)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        _request = request;
        _observerWasAdded = NO;

        DDLogVerbose(@"SocketService#init");

        @weakify(self);

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        [[center rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] subscribeNext:^(id x) {
            @strongify(self);
            self.isActive = YES;

            if (self.isLogin) {
                [self ensureConnected];
            }
        }];

        [[center rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil] subscribeNext:^(id x) {
            @strongify(self);
            self.isActive = NO;

            [self disconnect];
        }];

        _reachability = [Reachability reachabilityForInternetConnection];
        _reachability.unreachableBlock = ^(Reachability *reachability) {
            DDLogVerbose(@"Reachability: Network is unreachable");
            @strongify(self);
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.socketState = NTSocketStateOffline;
            });
        };

        _reachability.reachableBlock = ^(Reachability *reachability) {
            DDLogVerbose(@"Reachability: Network is reachable");
            @strongify(self);
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (self.socketState == NTSocketStateOffline && self.isLogin && self.isActive) {
                    self.socketState = NTSocketStateDisconnected;
                    [self reconnect];
                } else if ((self.socketState == NTSocketStateConnected || self.socketState == NTSocketStateConnecting)) {
                    self.socketState = NTSocketStateDisconnected;
                    [self disconnect];
                }
            });
        };
        [_reachability startNotifier];

        _tryReconnectImmediatly = YES;
        _timeoutInterval = 30;

        self.socketState = NTSocketStateConnecting;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self connect];
        });
    }
    return self;
}

- (void)dealloc {
    [self cancelConnectingTimer];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NTGameService

- (void)ensureConnected {
    DDLogVerbose(@"ensureConnected, _socket.readyState = %d", _socket.readyState);
    switch (_socket.readyState) {
        case SR_CLOSING:
        case SR_CLOSED:
            [self connect];
            break;
        default:
            break;
    }
}

- (void)connect {
    DDLogVerbose(@"connect");
    if(![_reachability isReachable]) {
        NSDictionary *userInfo = @{
                NSLocalizedFailureReasonErrorKey: NSStringFromSocketConnectionErrorReason(NTSocketServiceConnectionErrorReasonOffline)
        };
        NSError *error = [[NSError alloc] initWithDomain:NTSocketConnectErrorDomain
                                                    code:NTSocketServiceConnectionErrorReasonOffline
                                                userInfo:userInfo];
        // todo: error

        self.socketState = NTSocketStateOffline;
        return;
    }
    self.socketState = NTSocketStateConnecting;
    [self disconnect:NO];
    DDLogVerbose(@"SocketService#connect serverURL = %@", self.request);
    [self startConnectingTimer];
    _socket.delegate = nil;
    _socket = [[SRWebSocket alloc] initWithURLRequest:self.request];
    if(!_observerWasAdded) {
        [RACObserve(self, socketState) subscribeNext:^(id x) {
            [self cancelConnectingTimer];
        }];
        _observerWasAdded = YES;
    }
    _socket.delegate = self;
    [_socket open];
}

- (void)disconnect {
    [self disconnect:YES];
}

- (void)disconnect:(BOOL)updateState {
    DDLogVerbose(@"SocketService#disconnect");
    if(_socket) {
        [_socket close];
    }
    if(updateState) {
        self.socketState = NTSocketStateDisconnected;
    }
}

- (void)reconnect {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self connect];
    });
}

- (void)startConnectingTimer {
    // this will be cancelled once the connection succeeds
    [self cancelConnectingTimer];
    [self performSelector:@selector(postConnectionTimeoutNotification) withObject:nil afterDelay:_timeoutInterval];
}

- (void)postConnectionTimeoutNotification {
    [self disconnect:YES];
    NSDictionary *userInfo = @{
            NSLocalizedFailureReasonErrorKey: NSStringFromSocketConnectionErrorReason(NTSocketServiceConnectionErrorReasonTimeout)
    };
    NSError *error = [[NSError alloc] initWithDomain:NTSocketConnectErrorDomain
                                                code:NTSocketServiceConnectionErrorReasonTimeout
                                            userInfo:userInfo];
    // todo: error
}

- (void)cancelConnectingTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(postConnectionTimeoutNotification) object:nil];
}


- (NSError *)socketErrorWithCode:(NSUInteger)code reason:(NSString *)reason {
    return [NSError errorWithDomain:[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleIdentifierKey]
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey:reason}];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Internal

NSString *NSStringFromSocketState(NTSocketState state) {
    switch (state) {
        case NTSocketStateOffline:
            return @"No Internet Connection";
        case NTSocketStateDisconnected:
            return @"Disconnected";
        case NTSocketStateConnecting:
            return @"Connecting…";
        case NTSocketStateConnected:
            return @"Connected";
        default:
            return @"(Invalid Socket State)";
    }
}

NSString *NSStringFromSocketConnectionErrorReason(NTSocketServiceConnectionErrorReason reason) {
    switch (reason) {
        case NTSocketServiceConnectionErrorReasonOffline:
            return @"No Internet Connection";
        case NTSocketServiceConnectionErrorReasonServerDown:
            return @"Server Down";
        case NTSocketServiceConnectionErrorReasonTimeout:
            return @"Connection Timeout";
        case NTSocketServiceConnectionErrorReasonGeneric:
            return @"Generic";
        default:
            return @"(Invalid Socket State)";
    }
}

- (void)send:(id)message {
    if (_socketState != NTSocketStateConnected) {
        DDLogWarn(@"SocketService is not sending message '%@' because it's in state: %d", message, _socketState);
        return;
    }
    [_socket send:message];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SRWebSocketDelegate



- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    _tryReconnectImmediatly = YES;
    DDLogVerbose(@"socket opened: %@", webSocket);
    self.socketState = NTSocketStateConnected;

    if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidOpen:)])
        [self.delegate socketDidOpen:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id) message {
    DDLogVerbose(@"=> %@", message);

    if(self.delegate && [self.delegate respondsToSelector:@selector(socket:didReceiveMessage:)])
        [self.delegate socket:self didReceiveMessage:message];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    DDLogWarn(@"webSocket:%@ didFailWithError:%@", webSocket, error);
    if(error.code == 57) { // socket closed, mostly when in background, try reconncet
        [self ensureConnected];
    } else if(error.code == 61) { // connection refused, looks like the server is down
        NSDictionary *userInfo = @{
                NSLocalizedFailureReasonErrorKey: NSStringFromSocketConnectionErrorReason(NTSocketServiceConnectionErrorReasonServerDown)
        };
        error = [[NSError alloc] initWithDomain:NTSocketConnectErrorDomain
                                                    code:error.code
                                                userInfo:userInfo];
        self.socketState = NTSocketStateDisconnected;
    } else {
        NSDictionary *userInfo = @{
                NSLocalizedFailureReasonErrorKey: NSStringFromSocketConnectionErrorReason(NTSocketServiceConnectionErrorReasonGeneric)
        };
        error = [[NSError alloc] initWithDomain:NTSocketConnectErrorDomain
                                                    code:NTSocketServiceConnectionErrorReasonGeneric
                                                userInfo:userInfo];
        self.socketState = NTSocketStateDisconnected;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didFailWithError:)])
        [self.delegate socket:self didFailWithError:error];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    DDLogInfo(@"webSocket:%@ didCloseWithCode:%d reason:%@ wasClean:%d", webSocket, code, reason, wasClean);

    [self ensureConnected];

    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didCloseWithCode:reason:wasClean:)])
        [self.delegate socket:self didCloseWithCode:code reason:reason wasClean:wasClean];
}

#pragma  mark - Getters

- (NSURL *)serverURL {
    return self.request.URL;
}

#pragma mark - Setters

- (void)setSocketState:(NTSocketState)socketState {
    if (socketState == _socketState) {
        return;
    }

    _socketState = socketState;
}

- (void)setRequest:(NSURLRequest *)request {
    if (request == self.request) {
        _socketState = NTSocketStateDisconnected;
        return;
    }

    _request = request;

    if (self.socketState == NTSocketStateConnected || self.socketState == NTSocketStateConnecting) {
        [_socket close];
    }

    _socket.delegate = nil;
    _socket = nil;
    _socket = [[SRWebSocket alloc] initWithURLRequest:request];
    _socket.delegate = self;
    self.socketState = NTSocketStateConnecting;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self connect];
    });
}

@end