//
// Created by Zhang Zeqing on 15/2/14.
// Copyright (c) 2014 teambition. All rights reserved.
//

#import "JSONResponseSerializerWithData.h"

@implementation JSONResponseSerializerWithData {
@private
    NSSet *_acceptableContentTypes;
}

- (NSSet *)acceptableContentTypes {
    if (!_acceptableContentTypes) {
        _acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
    }
    return _acceptableContentTypes;
}


- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (*error != nil) {
            NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];

            id responseObject = nil;
            NSError *serializationError = nil;
            if (data) {
                responseObject = [NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:&serializationError];
                id msg = responseObject[@"displayMessage"];
                if (msg) {
                    userInfo[NSLocalizedRecoverySuggestionErrorKey] = msg;
                }
            }

            NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
            (*error) = newError;
        }

        return (nil);
    }

    return ([super responseObjectForResponse:response data:data error:error]);
}

@end