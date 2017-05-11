//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTAPIConstants.h"


#ifdef DEBUG
NSString * const kAPIBaseURLString = @"http://dctars01.digitwalk.com:8080/gw/";
NSString * const kSocketBaseURLString = @"ws://183.131.78.120:9999";
#else
NSString * const kAPIBaseURLString = @"http://dctars01.digitwalk.com:8080/gw/";
NSString * const kSocketBaseURLString = @"ws://183.131.78.120:9999";
#endif

// RESTful API
NSString * const kDeviceTokenURLString = @"devicetokens";
NSString * const kRegisterURLString = @"reg2";
NSString * const kLoginURLString = @"login2";
NSString * const kFeatureBrandsURLString = @"s/brands";
NSString * const kMyBrandsURLString = @"s/mybrands";
NSString * const kBrandFollowURLString = @"s/brand/%@/follow";
NSString * const kBrandUnFollowURLString = @"s/brand/%@/unfollow";
NSString * const kBrandEventsURLFormatString = @"s/brand/%@/events";
NSString * const kEventsURLFormatString = @"s/event/%@";