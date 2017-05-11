//
// Created by Zhang Zeqing on 6/8/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesAvatarImageFactory.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "NTUser.h"
#import "UIImageView+NTAvatarView.h"
#import "NTUser.h"


@implementation UIImageView (NTAvatarView)

- (void)setAvatarWithUser:(NTUser *)user {
    [self sd_setImageWithURL:user.avatarURL
                      placeholderImage:user.avatarImage
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 // Avatar styling
                                 if (image) {
                                     self.image = [JSQMessagesAvatarImageFactory
                                             circularAvatarImage:image withDiameter:50];
                                 }
                             }];
}

- (void)setLargeAvatarWithUser:(NTUser *)user {
    [self sd_setImageWithURL:user.avatarURL
            placeholderImage:user.largeAvatarImage
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       // Avatar styling
                       if (image) {
                           self.image = [JSQMessagesAvatarImageFactory
                                   circularAvatarImage:image withDiameter:75];
                       }
                   }];
}

@end