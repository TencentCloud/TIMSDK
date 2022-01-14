//
//  AppDelegate+APNS.m
//  TUIKitDemo
//
//  Created by harvy on 2021/12/22.
//  Copyright © 2021 Tencent. All rights reserved.
//
// 收到推送普通信息推送（普通消息推送设置代码请参考 TUIMessageController -> sendMessage）
//普通消息推送格式（C2C）：
//@"ext" :
//@"{\"entity\":{\"action\":1,\"chatType\":1,\"content\":\"Hhh\",\"sendTime\":0,\"sender\":\"2019\",\"version\":1}}"
//普通消息推送格式（Group）：
//@"ext"
//@"{\"entity\":{\"action\":1,\"chatType\":2,\"content\":\"Hhh\",\"sendTime\":0,\"sender\":\"@TGS#1PWYXLTGA\",\"version\":1}}"

// 收到推送音视频推送（音视频推送设置代码请参考 TUICall+Signal -> sendAPNsForCall）
//音视频通话推送格式（C2C）：
//@"ext" :
//@"{\"entity\":{\"action\":2,\"chatType\":1,\"content\":\"{\\\"action\\\":1,\\\"call_id\\\":\\\"144115224193193423-1595225880-515228569\\\",\\\"call_type\\\":1,\\\"code\\\":0,\\\"duration\\\":0,\\\"invited_list\\\":[\\\"10457\\\"],\\\"room_id\\\":1688911421,\\\"timeout\\\":30,\\\"timestamp\\\":0,\\\"version\\\":4}\",\"sendTime\":1595225881,\"sender\":\"2019\",\"version\":1}}"
//音视频通话推送格式（Group）：
//@"ext"
//@"{\"entity\":{\"action\":2,\"chatType\":2,\"content\":\"{\\\"action\\\":1,\\\"call_id\\\":\\\"144115212826565047-1595506130-2098177837\\\",\\\"call_type\\\":2,\\\"code\\\":0,\\\"duration\\\":0,\\\"group_id\\\":\\\"@TGS#1BUBQNTGS\\\",\\\"invited_list\\\":[\\\"10457\\\"],\\\"room_id\\\":1658793276,\\\"timeout\\\":30,\\\"timestamp\\\":0,\\\"version\\\":4}\",\"sendTime\":1595506130,\"sender\":\"vinson1\",\"version\":1}}"

#if ENABLETPNS
#else

#import "AppDelegate+APNS.h"
#import "TCUtil.h"

@implementation AppDelegate (APNS)

- (void)push_init
{
    UIUserNotificationType type = UIUserNotificationTypeSound|UIUserNotificationTypeAlert|UIUserNotificationTypeBadge;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    NSLog(@"[APNS] %s", __func__);
}

- (void)push_unregisterIfLogouted
{
    // apns 无需处理
    NSLog(@"[APNS] %s", __func__);
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.deviceToken = deviceToken;
    NSLog(@"[APNS] %s", __func__);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    NSLog(@"[APNS] %s, %@", __func__, userInfo);
    if (userInfo == nil ||
        ![userInfo.allKeys containsObject:@"ext"]) {
        return;
    }
    NSDictionary *extParam = [TCUtil jsonSring2Dictionary:userInfo[@"ext"]];
    if (extParam == nil ||
        ![extParam.allKeys containsObject:@"entity"]) {
        return;
    }
    
    NSDictionary *entity = extParam[@"entity"];
    [self onReceiveOfflinePushEntity:entity];
}


@end

#endif
