//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTStore.h"
#import "Constants.h"


@implementation NTStore

- (RACSignal *)changeSignal {
    return [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CHANGE_EVENT object:nil]
            takeUntil:self.rac_willDeallocSignal] filter:^BOOL(NSNotification *not) {
        return not.object == self;
    }];
}

- (void)emit:(id)event {
    [NSNotificationCenter.defaultCenter postNotificationName:event object:self];
}

@end