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
    UIUserNotificationType type = UIUserNotificationTypeSound|UIUserNotificationTypeAlert|UIUserNotificationTypeBadge;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    NSLog(@"[TUIOfflinePushManager][APNS] %s", __func__);
}

- (void)unregisterService;
{
    // 恢复系统 delegate
    [self unloadApplicationDelegateIfNeeded];
    
    // apns 无需处理
    NSLog(@"[TUIOfflinePushManager][APNS] %s", __func__);
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"[TUIOfflinePushManager][APNS] %s", __func__);
    [self onReportToken:deviceToken];
    
    // 透传中转
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
    
    // 透传中转
    if ([self.applicationDelegate respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
        [self.applicationDelegate application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
}


- (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Json parse failed: %@", jsonString);
        return nil;
    }
    return dic;
}

@end
