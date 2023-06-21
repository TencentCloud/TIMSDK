//
//  TUIOfflinePushManager+APNS.h
//  Pods
//
//  Created by harvy on 2022/5/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

#import "TUIOfflinePushManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIOfflinePushManager (APNS) <UNUserNotificationCenterDelegate>

@end

NS_ASSUME_NONNULL_END
