//
// Created by Zhang Zeqing on 3/29/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <Realm/Realm.h>


@interface NTBrand : RLMObject

@property NSString *id;
@property NSString *logo;
@property NSString *coverPic;
@property NSString *name;
@property NSString *desc;

@end

RLM_ARRAY_TYPE(NTBrand)