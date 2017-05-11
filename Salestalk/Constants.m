//
// Created by Zhang Zeqing on 3/28/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "Constants.h"

// NSUserDefaults keys
NSString *const kAuthTokenKey = @"auth_token";
NSString *const kAuthUserIDKey = @"user_id";
NSString *const kLastOfflineDateTimeKey = @"last_offline";
NSString *const kDeviceTokenKey = @"device_token";

// Realm in memory identifier
NSString *const kInMemoryRealmIdentifier = @"in_memory_realm";

// ActionType
NSString *const kActionTypeKey = @"action_type";
NSString *const kActionTypeClickRoom = @"click_thread";
NSString *const kActionTypeCreateMessage = @"create_message";
NSString *const kActionTypeReceiveCreatedMessage = @"receive_create_message";
NSString *const kActionTypeReceiveRawMessages = @"receive_raw_messages";
NSString *const kActionTypeReceiveRawRooms = @"receive_raw_rooms";
NSString *const kActionTypeMarkAsRead = @"mark_as_read";
NSString *const kActionTypeReceiveRawBrands = @"receive_raw_brands";
NSString *const kActionTypeReceiveRawUsers = @"receive_raw_users";
NSString *const kActionTypeReceiveRawUser = @"receive_raw_user";
NSString *const kActionTypeUpdateUserStatus = @"update_user_status";
NSString *const kActionTypeReceiveRawEvents = @"receive_raw_events";

// change event
NSString *const CHANGE_EVENT = @"change";

// notification key
NSString *const kNTDidLoginNotification = @"did_login";
NSString *const kNTDidLogoutNotification = @"did_logout";
NSString *const kNTShowLoginNotification = @"show_login";
NSString *const kNTMessageCountChangeNotification = @"msg_count_change";