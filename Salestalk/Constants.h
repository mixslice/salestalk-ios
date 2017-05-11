// Constants.h
//
// Created by Zhang Zeqing on 3/28/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <UIKit/UIKit.h>


// NSUserDefaults keys
UIKIT_EXTERN NSString *const kAuthTokenKey;
UIKIT_EXTERN NSString *const kAuthUserIDKey;
UIKIT_EXTERN NSString *const kLastOfflineDateTimeKey;
UIKIT_EXTERN NSString *const kDeviceTokenKey;

// Realm in memory identifier
UIKIT_EXTERN NSString *const kInMemoryRealmIdentifier;

// ActionType
UIKIT_EXTERN NSString *const kActionTypeKey;
UIKIT_EXTERN NSString *const kActionTypeClickRoom;
UIKIT_EXTERN NSString *const kActionTypeCreateMessage;
UIKIT_EXTERN NSString *const kActionTypeReceiveCreatedMessage;
UIKIT_EXTERN NSString *const kActionTypeReceiveRawMessages;
UIKIT_EXTERN NSString *const kActionTypeReceiveRawRooms;
UIKIT_EXTERN NSString *const kActionTypeMarkAsRead;
UIKIT_EXTERN NSString *const kActionTypeReceiveRawBrands;
UIKIT_EXTERN NSString *const kActionTypeReceiveRawUsers;
UIKIT_EXTERN NSString *const kActionTypeReceiveRawUser;
UIKIT_EXTERN NSString *const kActionTypeUpdateUserStatus;
UIKIT_EXTERN NSString *const kActionTypeReceiveRawEvents;

// change event
UIKIT_EXTERN NSString *const CHANGE_EVENT;

// notification key
UIKIT_EXTERN NSString *const kNTDidLoginNotification;
UIKIT_EXTERN NSString *const kNTDidLogoutNotification;
UIKIT_EXTERN NSString *const kNTShowLoginNotification;
UIKIT_EXTERN NSString *const kNTMessageCountChangeNotification;
