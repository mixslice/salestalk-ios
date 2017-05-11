//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Realm/Realm.h>

@class NTBrand;


@interface NTEvent : RLMObject

@property NSString *id;
@property NSString *title;
@property NSString *logo;
@property NSString *contentURL;
@property NSString *summary;
@property NTBrand *brand;

@end

RLM_ARRAY_TYPE(NTEvent)