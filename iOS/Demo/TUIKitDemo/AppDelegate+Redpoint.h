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

#pragma mark - 未读数相关
// 1. 设置未读数
- (void)redpoint_setupTotalUnreadCount;

// 2. 清空所有未读消息数
- (void)redpoint_clearUnreadMessage;

@end

NS_ASSUME_NONNULL_END
