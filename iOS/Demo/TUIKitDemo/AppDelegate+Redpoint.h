//
//  AppDelegate+Redpoint.h
//  TUIKitDemo
//
//  Created by harvy on 2022/5/5.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (Redpoint)

/**
 * 1. Setting unread number
 */
- (void)redpoint_setupTotalUnreadCount;

/**
 * 2. Clear all unread messages
 */
- (void)redpoint_clearUnreadMessage;

@end

NS_ASSUME_NONNULL_END
