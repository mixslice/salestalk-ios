//
// Created by Zhang Zeqing on 5/11/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NTAccountManager : NSObject
+ (instancetype)sharedManager;

- (void)startManage;
@end