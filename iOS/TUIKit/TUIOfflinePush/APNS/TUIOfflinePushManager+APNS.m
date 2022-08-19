//
//  TUIOfflinePushManager+APNS.m
//  Pods
//
//  Created by harvy on 2022/5/6.
//

#import "TUIOfflinePushManager+APNS.h"
#import "TUIOfflinePushManager+Inner.h"

@implementation TUIOfflinePushManager (APNS)

- (void)applyPushToken
{
    if (@available(iOS 10.0, *)) {
        UNAuthorizationOptions options = UNAuthorizationOptionSound|UNAuthorizationOptionBadge|UNAuthorizationOptionAlert;
        UNUserNotificationCenter.currentNotificationCenter.delegate = self;
        [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error || granted == NO) {
                NSLog(@"[TUIOfflinePushManager][APNS] %s, granted:%d, error:%@", __func__, granted, error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication.sharedApplication registerForRemoteNotifications];
                });
            }
        }];
    } else {
        UIUserNotificationType type = UIUserNotificationTypeSound|UIUserNotificationTypeAlert|UIUserNotificationTypeBadge;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    NSLog(@"[TUIOfflinePushManager][APNS] %s", __func__);
}

- (void)unregisterService;
{
    /**
     * 恢复系统 delegate
     * Recover appdelegate
     */
    [self unloadApplicationDelegateIfNeeded];
    
    NSLog(@"[TUIOfflinePushManager][APNS] %s", __func__);
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"[TUIOfflinePushManager][APNS] %s", __func__);
    [self onReportToken:deviceToken];
    
    // Forward
    if ([self.applicationDelegate respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
        [self.applicationDelegate application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    NSLog(@"[TUIOfflinePushManager][APNS] %s, %@", __func__, userInfo);
    if (userInfo == nil ||
        ![userInfo.allKeys containsObject:@"ext"]) {
        return;
    }
    NSDictionary *extParam = [self jsonSring2Dictionary:userInfo[@"ext"]];
    if (extParam == nil ||
        ![extParam.allKeys containsObject:@"entity"]) {
        return;
    }
    
    NSDictionary *entity = extParam[@"entity"];
    [self onReceiveOfflinePushEntity:entity];
    
    // Forward
    if ([self.applicationDelegate respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
        [self.applicationDelegate application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)) {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSLog(@"[TUIOfflinePushManager][APNS] %s, %@", __func__, userInfo);
    if (userInfo == nil ||
        ![userInfo.allKeys containsObject:@"ext"]) {
        return;
    }
    NSDictionary *extParam = [self jsonSring2Dictionary:userInfo[@"ext"]];
    if (extParam == nil ||
        ![extParam.allKeys containsObject:@"entity"]) {
        return;
    }
    
    NSDictionary *entity = extParam[@"entity"];
    [self onReceiveOfflinePushEntity:entity];
    
    // Forward
    SEL selector = NSSelectorFromString(@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    [invocation setArgument:&center atIndex:2];
    [invocation setArgument:&response atIndex:3];
    [invocation setArgument:&completionHandler atIndex:4];
    [invocation invoke];
}

@end
