//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import <AVFoundation/AVFoundation.h>
#import <Realm/Realm.h>
#import <JDStatusBarNotification/JDStatusBarNotification.h>
#import "NTSocket.h"
#import "NTAPIConstants.h"
#import "Constants.h"
#import "MessageActions.h"
#import "UserActions.h"
#import "NTFactory.h"
#import "RoomActions.h"
#import "MessageStore.h"


@interface NTSocket ()

- (void)sendJSON:(NSDictionary *)JSON;

- (RACSignal *)rac_didReceiveMessageSignalWithCmd:(NSString *)cmd andTimeID:(NSString *)timeID;

- (void)processMessage:(id)message;

- (NSURLRequest *)getAuthRequest;
@end

static NSString *kHeaderTokenFieldKey = @"TOKEN";

@implementation NTSocket

+ (instancetype)sharedSocket {
    static NTSocket *sharedSocket = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSocket = [[self alloc] init];
    });

    return sharedSocket;
}

- (instancetype)init {
    self = [super initWithRequest:[self getAuthRequest]];
    if (self) {
        self.isLogin = YES;

        @weakify(self);
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        [[center rac_addObserverForName:kNTDidLoginNotification object:nil] subscribeNext:^(id x) {
            @strongify(self);
            self.isLogin = YES;
            self.request = [self getAuthRequest];
        }];

        [[self rac_webSocketDidOpenSignal] subscribeNext:^(id x) {
            @strongify(self);
            [self sendOfflineMessageRequest];
        }];

        [[self rac_webSocketDidCloseSignal] subscribeNext:^(NSString *reason) {
            @strongify(self);
            DDLogError(@"socket close: %@", reason);
        }];

        [[[self rac_didReceiveMessageSignal] filter:^BOOL(id JSON) {
            return ![JSON[@"cmd"] isEqualToString:@"ping"];
        }] subscribeNext:^(id message) {
            @strongify(self);
            DDLogVerbose(@"got some text: %@", message);
            [self processMessage:message];
        }];

        [[self rac_didFailWithErrorSignal] subscribeNext:^(NSError *error) {
            @strongify(self);
            DDLogVerbose(@"did write error: %@", error);
        }];

        [RACObserve(self, socketState) subscribeNext:^(NSNumber *socketStateValue) {
            @strongify(self);
            NTSocketState socketState = socketStateValue.integerValue;
            switch (socketState) {
                case NTSocketStateOffline:
                    [JDStatusBarNotification showWithStatus:@"offline"];
                    break;
                case NTSocketStateConnecting:
                    [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleWhite];
                    break;
                case NTSocketStateConnected:
                    [JDStatusBarNotification showWithStatus:@"connected" dismissAfter:1];
                    break;
                case NTSocketStateDisconnected:
                    break;
            }
        }];
    }

    return self;
}

#pragma mark - Helper

- (NSURLRequest *)getAuthRequest {
    // init
    NSURL *url = [NSURL URLWithString:kSocketBaseURLString];
    NSMutableURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] mutableCopy];

    // set token
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults valueForKey:kAuthTokenKey];
    if (token) {
        [request setValue:token forHTTPHeaderField:kHeaderTokenFieldKey];
    }

    return [request copy];
}

- (void)sendJSON:(NSDictionary *)JSON {
    NSError *serializerError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:JSON
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&serializerError];
    if (!data) {
        DDLogError(@"serializer error: %@", serializerError);
    } else {
        DDLogVerbose(@"send data: %@", JSON);
        [self send:data];
    }
}

- (RACSignal *)rac_didReceiveMessageSignalWithCmd:(NSString *)cmd andTimeID:(NSString *)timeID {
    return [[[self rac_didReceiveMessageSignal] filter:^BOOL(id JSON) {
        return [JSON[@"cmd"] isEqualToString:cmd]
                && [JSON[@"timeid"] isEqualToString:timeID];
    }] take:1];
}

#pragma mark - API


- (void)sendOfflineMessageRequest {
    NSDate *minDate = [[MessageStore store] getLatestMessageCreatedAt];
    NSDate *maxDate = [NSDate date];

    NSDateFormatter *dateFormatter = [NTFactory dateFormatter];

    NSMutableDictionary *obj = [@{} mutableCopy];
    [obj setValue:@"message.history" forKey:@"cmd"];
    [obj setValue:[dateFormatter stringFromDate:minDate] forKey:@"mindate"];
    [obj setValue:[dateFormatter stringFromDate:maxDate] forKey:@"maxdate"];

    [self sendJSON:obj];
}

- (RACSignal *)getEventUsersSignalWithEventID:(NSString *)eventID {
    RACSubject *subject = [RACSubject subject];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *cmd = @"event.getuser";

    [self sendJSON:@{
            @"cmd" : cmd,
            @"timeid" : uuid,
            @"eventid" : eventID
    }];

    @weakify(self);

    [[self rac_didReceiveMessageSignalWithCmd:cmd andTimeID:uuid]
            subscribeNext:^(id message) {
                @strongify(self);
                NSArray *rawUsers = [message valueForKey:@"eventusers"];
                if ([rawUsers isKindOfClass:[NSArray class]]) {
                    [subject sendNext:rawUsers];
                }
            }
                completed:^{
                    [subject sendCompleted];
                }];

    return subject;
}

#pragma mark - subscribe/unsubscribe users

- (void)subscribeUsers:(NSArray *)userIds {
    [self sendJSON:@{
            @"cmd" : @"user.subscribe",
            @"users": userIds
    }];
}

- (void)unSubscribeUsers:(NSArray *)userIds {
    [self sendJSON:@{
            @"cmd" : @"user.unsubscribe",
            @"users": userIds
    }];
}

#pragma mark - room actions

- (RACSignal *)createRoomWithEventID:(NSString *)eventID andUserID:(NSString *)userID {
    RACSubject *subject = [RACSubject subject];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *cmd = @"room.create";

    [self sendJSON:@{
            @"cmd" : cmd,
            @"timeid": uuid,
            @"eventid": eventID,
            @"eventuser": userID
    }];

    @weakify(self);
    [[self rac_didReceiveMessageSignalWithCmd:cmd andTimeID:uuid]
            subscribeNext:^(id message) {
                @strongify(self);
                [subject sendNext:message];
            }
                completed:^{
                    [subject sendCompleted];
                }];

    return subject;
}

- (void)sendMessageWithRoomID:(NSString *)roomID text:(NSString *)text uuid:(NSString *)uuid {
    [self sendJSON:@{
            @"cmd" : @"message.send",
            @"roomid" : roomID,
            @"msg" : text,
            @"format" : @"TEXT",
            @"timeid" : uuid
    }];
}

- (void)processMessage:(id)message {
    if ([message[@"cmd"] isEqualToString:@"message.recv"]) {
        if ([message[@"msgid"] isEqualToString:@"2015072111135939096"]) {
            DDLogVerbose(@"1");
        }
        [MessageActions receiveAll:message];
    }
    else if ([message[@"cmd"] isEqualToString:@"message.history"]) {
        id rawMessages = [message valueForKey:@"msg"];
        [MessageActions receiveAll:rawMessages];
    }
    else if ([message[@"cmd"] isEqualToString:@"room.history"]) {
        id rawRooms = [message valueForKey:@"room"];
        [RoomActions receiveAll:rawRooms];
    }
    else if ([message[@"cmd"] isEqualToString:@"room.join"] && [message[@"cmd"] isEqualToString:@"room.create"]) {
        [RoomActions receiveAll:@[message]];
    }
    else if ([message[@"cmd"] isEqualToString:@"user.status"]) {
        [UserActions updateStatusForUser:message];
    }
}

#pragma mark - logout signal

- (RACSignal *)logoutSignal {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        self.isLogin = NO;
        [self disconnect];
        [subscriber sendCompleted];
        return nil;
    }];

}
@end