//
// Created by Zhang Zeqing on 6/1/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <SocketRocket/SRWebSocket.h>

@protocol NTSocketShuttleDelegate;

typedef NS_ENUM(NSUInteger, NTSocketState) {
    NTSocketStateOffline,       // no network, set via reachability callbacks
    NTSocketStateConnecting,
    NTSocketStateConnected,
    NTSocketStateDisconnected
};

typedef NS_ENUM(NSInteger, NTSocketServiceConnectionErrorReason) {
    NTSocketServiceConnectionErrorReasonOffline = 0,
    NTSocketServiceConnectionErrorReasonServerDown = 1,
    NTSocketServiceConnectionErrorReasonTimeout = 2,
    NTSocketServiceConnectionErrorReasonGeneric = 3,
};

NSString *NSStringFromSocketState(NTSocketState state);
NSString *NSStringFromSocketConnectionErrorReason(NTSocketServiceConnectionErrorReason reason);

@interface NTSocketShuttle : NSObject

-(id)initWithRequest:(NSURLRequest *)request;

-(void)send:(id)message;
-(void)disconnect;
-(void)ensureConnected;


@property (nonatomic, readonly) NTSocketState socketState;
@property (nonatomic, readwrite) BOOL isLogin;
@property (nonatomic, readonly) BOOL isActive;

@property (nonatomic, assign) id <NTSocketShuttleDelegate> delegate;
@property (nonatomic)   NSTimeInterval  timeoutInterval; // defaults to 30 seconds
@property (nonatomic, readonly) NSURL *serverURL;
@property (nonatomic, strong) NSURLRequest *request;

@end


@protocol NTSocketShuttleDelegate <NSObject>

// message will either be an NSString if the server is using text
// or NSData if the server is using binary

@required
- (void)socket:(NTSocketShuttle *)socket didReceiveMessage:(id)message;

@optional
- (void)socketDidOpen:(NTSocketShuttle *)socket;
- (void)socket:(NTSocketShuttle *)socket didFailWithError:(NSError *)error;
- (void)socket:(NTSocketShuttle *)socket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

@end