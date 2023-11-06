//
//  TUIOfflinePushManager+APNS.m
//  Pods
//
//  Created by harvy on 2022/5/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIOfflinePushManager+APNS.h"
#import "TUIOfflinePushManager+Inner.h"

@implementation TUIOfflinePushManager (APNS)

- (void)applyPushToken {
    if (@available(iOS 10.0, *)) {
        UNAuthorizationOptions options = UNAuthorizationOptionSound | UNAuthorizationOptionBadge | UNAuthorizationOptionAlert;
        UNUserNotificationCenter.currentNotificationCenter.delegate = self;
        [UNUserNotificationCenter.currentNotificationCenter
            requestAuthorizationWithOptions:options
                          completionHandler:^(BOOL granted, NSError *_Nullable error) {
                            if (error || granted == NO) {
                                NSLog(@"[TUIOfflinePushManager][APNS] %s, granted:%d, error:%@", __func__, granted, error);
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                  [UIApplication.sharedApplication registerForRemoteNotifications];
                                });
                            }
                          }];
    } else {
        UIUserNotificationType type = UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    NSLog(@"[TUIOfflinePushManager][APNS] %s", __func__);
}

- (void)unregisterService;
{
    self.serviceRegistered = NO;

    /**
     * Continue to take over, for the following reasons：
     * 1. The UIApplication not keep strong refrence to the delegate object, and When UIApplication.sharedApplication.delegate is set to
     * self.applicationDelegate, the reference count of the delegate object will not be incremented.
     * 2. The delegate object will be dealloced if TUIOfflinePush try to recover delegate and self.applicationDelegate setted to nil.
     *
     * For component stability considerations，delegate recovery is ignored. Do noting...
     * // [self unloadApplicationDelegateIfNeeded];
     */
    NSLog(@"[TUIOfflinePushManager][APNS] %s", __func__);
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"[TUIOfflinePushManager][APNS] %s", __func__);

    if (self.serviceRegistered) {
        [self onReportToken:deviceToken];
    }

    // Forward
    if ([self.applicationDelegate respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
        [self.applicationDelegate application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    NSLog(@"[TUIOfflinePushManager][APNS] %s, %@", __func__, userInfo);
    if (self.serviceRegistered && userInfo && [userInfo.allKeys containsObject:@"ext"]) {
        NSDictionary *extParam = [self jsonSring2Dictionary:userInfo[@"ext"]];
        if (extParam && [extParam.allKeys containsObject:@"entity"]) {
            NSDictionary *entity = extParam[@"entity"];
            [self onReceiveOfflinePushEntity:entity];
        }
    }

    // Forward
    __block BOOL callback = NO;
    if ([self.applicationDelegate respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
        [self.applicationDelegate application:application
                 didReceiveRemoteNotification:userInfo
                       fetchCompletionHandler:^(UIBackgroundFetchResult result) {
                         completionHandler(result);
                         callback = YES;
                       }];
    }

    if (!callback) {
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)) {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSLog(@"[TUIOfflinePushManager][APNS] %s, %@", __func__, userInfo);
    if (self.serviceRegistered && userInfo && [userInfo.allKeys containsObject:@"ext"]) {
        NSDictionary *extParam = [self jsonSring2Dictionary:userInfo[@"ext"]];
        if (extParam && [extParam.allKeys containsObject:@"entity"]) {
            NSDictionary *entity = extParam[@"entity"];
            [self onReceiveOfflinePushEntity:entity];
        }
    }

    __block BOOL callback = NO;
    void (^handler)(void) = ^{
      completionHandler();
      callback = YES;
    };

    // Forward
    SEL selector = NSSelectorFromString(@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = self.applicationDelegate;
        invocation.selector = selector;
        [invocation setArgument:&center atIndex:2];
        [invocation setArgument:&response atIndex:3];
        [invocation setArgument:&handler atIndex:4];
        [invocation invoke];
    }

    if (!callback) {
        completionHandler();
    }
}

@end
