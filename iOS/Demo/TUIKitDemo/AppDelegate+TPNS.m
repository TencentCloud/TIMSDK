//
//  AppDelegate+TPNS.m
//  TUIKitDemo
//
//  Created by harvy on 2021/12/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#if ENABLETPNS

#import "AppDelegate+TPNS.h"
#import <TPNS-iOS/XGPush.h>
#import <TPNS-iOS/XGPushPrivate.h>
#import "TCUtil.h"
#import "Aspects.h"

@implementation AppDelegate (TPNS)

NSString * _currentAccount;

+ (void)load
{
    // 向 TPNS 上报当前的 APP 未读数
    // 1. hook AppDelegate 中监听的 onTotalUnreadMessageCountChanged: 事件，从而设置设置 APP 角标并更新 _unReadCount
    id onTPNSBadgeChangedBlock = ^(id<AspectInfo> aspectInfo, UInt64 totalUnreadCount){
        AppDelegate *app = (AppDelegate *)UIApplication.sharedApplication.delegate;
        [app onTPNSBadgeChanged:totalUnreadCount];
        NSLog(@"[PUSH] onTotalUnreadMessageCountChanged, unReadCount:%zd", app.unReadCount);
    };
    [AppDelegate aspect_hookSelector:@selector(onTotalUnreadMessageCountChanged:)
                         withOptions:AspectPositionAfter
                          usingBlock:onTPNSBadgeChangedBlock
                               error:nil];
}

- (void)push_init
{
    //打开 debug 开关
#if DEBUG
    [[XGPush defaultManager] setEnableDebug:YES];
#endif
    /**
     * 如果您的应用服务接入点为广州，SDK 默认实现该配置，可不调用 configureClusterDomainName 设置。
     * 如果您的应用服务接入点为上海、新加坡或中国香港，请按照下文步骤完成其他服务接入点域名配置：
     * https://cloud.tencent.com/document/product/548/36663
     *
    */
    [[XGPush defaultManager] configureClusterDomainName:tpnsDomain];
    [[XGPush defaultManager] startXGWithAccessID:tpnsAccessID accessKey:tpnsAccessKey delegate:self];
    NSLog(@"[PUSH][TPNS] %s", __func__);
}

- (void)push_unregisterIfLogouted
{
    // 解绑账号
    [XGPushTokenManager.defaultTokenManager delAccountsByKeys:[NSSet setWithObject:@(0)]];
    NSLog(@"[PUSH][TPNS] %s", __func__);
}

- (BOOL)supportTPNS:(NSString *)userID
{
    _currentAccount = userID;
    
    // 异步，确保上报token在此之前执行
    dispatch_async(dispatch_get_main_queue(), ^{
        // 1. 绑定账号
        [XGPushTokenManager.defaultTokenManager upsertAccountsByDict:@{ @(0): _currentAccount?:@"" }];
        NSLog(@"[PUSH][TPNS] %s, bindAccount:%@", __func__, userID);
    });
    return YES;
}

- (void)onTPNSBadgeChanged:(UInt64)totalUnreadCount
{
    // 上报本地的未读数给 tpns
    [[XGPush defaultManager] setBadge:totalUnreadCount];
    NSLog(@"[PUSH][TPNS] %s, badge:%llu", __func__, totalUnreadCount);
}

/**
@brief 注册推送服务回调
@param deviceToken APNs 生成的 Device Token
@param xgToken TPNS 生成的 Token，推送消息时需要使用此值。TPNS 维护此值与 APNs 的 Device Token 的映射关系
@param error 错误信息，若 error 为 nil 则注册推送服务成功
@note TPNS SDK1.2.6.0+
*/
- (void)xgPushDidRegisteredDeviceToken:(nullable NSString *)deviceToken xgToken:(nullable NSString *)xgToken error:(nullable NSError *)error
{
    NSLog(@"[PUSH][TPNS] %s, deviceToken:%@, xgToken:%@, error:%@", __func__, deviceToken, xgToken, error);
    if (error == nil) {
        // 上报 token
        NSData *data = [xgToken dataUsingEncoding:NSUTF8StringEncoding];
        self.deviceToken = data;
        [self push_registerIfLogined:_currentAccount];
    }
}

/// 注册推送服务失败回调
/// @param error 注册失败错误信息
/// @note TPNS SDK1.2.7.1+
- (void)xgPushDidFailToRegisterDeviceTokenWithError:(nullable NSError *)error
{
    NSLog(@"[PUSH][TPNS] %s, %@", __func__, error);
}


/// 统一接收消息的回调
/// @param notification 消息对象(有2种类型NSDictionary和UNNotification具体解析参考示例代码)
/// @note 此回调为前台收到通知消息及所有状态下收到静默消息的回调（消息点击需使用统一点击回调）
/// 区分消息类型说明：xg字段里的msgtype为1则代表通知消息msgtype为2则代表静默消息
- (void)xgPushDidReceiveRemoteNotification:(nonnull id)notification withCompletionHandler:(nullable void (^)(NSUInteger))completionHandler
{
    /// code
    NSLog(@"[PUSH][TPNS] %s, %@", __func__, notification);
}
 /// 统一点击回调
/// @param response 如果iOS 10+/macOS 10.14+则为UNNotificationResponse，低于目标版本则为NSDictionary
- (void)xgPushDidReceiveNotificationResponse:(nonnull id)response withCompletionHandler:(nonnull void (^)(void))completionHandler {
    /// code
    NSDictionary *custom = nil;
    if (@available(iOS 10.0, *)) {
        /// iOS10+消息体获取
        if ([response isKindOfClass:UNNotificationResponse.class]) {
            NSDictionary *userInfo = ((UNNotificationResponse *)response).notification.request.content.userInfo;
            if ([userInfo.allKeys containsObject:@"custom"]) {
                NSString *customStr = userInfo[@"custom"];
                custom = [TCUtil jsonSring2Dictionary:customStr];
            }
        }
    } else {
        /// <IOS10消息体获取
        NSLog(@"notification dic: %@", response);
        custom = response;
    }
    
    if (custom == nil || ![custom isKindOfClass:NSDictionary.class]) {
        completionHandler();
        return;
    }
    
    if (![custom.allKeys containsObject:@"entity"]) {
        completionHandler();
        return;
    }
    
    [self onReceiveOfflinePushEntity:custom[@"entity"]];
    
    completionHandler();
}

@end

#endif
