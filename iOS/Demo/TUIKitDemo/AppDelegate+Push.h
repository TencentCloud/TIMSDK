//
//  AppDelegate+Push.h
//  TUIKitDemo
//
//  Created by harvy on 2021/12/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

//apns
#ifdef DEBUG
#define sdkBusiId 0
#else
#define sdkBusiId 0
#endif

@interface AppDelegate (Push)

- (void)push_registNotification;
- (void)push_onLoginSucc;

- (void)push_applicationDidEnterBackground:(UIApplication *)application;
- (void)push_applicationWillEnterForeground:(UIApplication *)application;

#pragma mark - 未读数相关
// 总的未读数发生了变化
- (void)onTotalUnreadCountChanged:(UInt64)totalUnreadCount;
// 清空所有未读
- (void)clearUnreadMessage;

@end

NS_ASSUME_NONNULL_END
