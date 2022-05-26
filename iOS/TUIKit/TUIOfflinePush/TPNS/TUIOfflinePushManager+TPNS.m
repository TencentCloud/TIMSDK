//
//  TUIOfflinePushManager+TPNS.m
//  Pods
//
//  Created by harvy on 2022/5/6.
//

#import "TUIOfflinePushManager+TPNS.h"
#import "TUIOfflinePushManager+Inner.h"
#import <TPNS-iOS/XGPushPrivate.h>

@implementation TUIOfflinePushManager (TPNS)

// 申请 token
- (void)applyPushToken;
{
    // 向 TPNS 上报当前 IM 的未读数，用于 TPNS 推送时角标累加
    [V2TIMManager.sharedInstance addConversationListener:self];
    
    //打开 debug 开关
#if DEBUG
    [[XGPush defaultManager] setEnableDebug:YES];
#endif
    /**
     * 如果您的应用服务接入点为广州，SDK 默认实现该配置，可不调用 configureClusterDomainName 设置。
     * 如果您的应用服务接入点为上海、新加坡或中国香港，请按照下文步骤完成其他服务接入点域名配置：
     * https://cloud.tencent.com/document/product/548/36663
     *
     * 其他服务接入点域名如下：
     * 上海：tpns.sh.tencent.com
     * 新加坡：tpns.sgp.tencent.com
     * 中国香港：tpns.hk.tencent.com
    */
    
    // 检查参数
    if (self.tpnsConfigAccessID == 0 || self.tpnsConfigAccessKey.length == 0) {
        NSLog(@"[TUIOfflinePushManager][TPNS][Error] invalid config, check it!!!!!!!!");
    }
    
    if (self.tpnsConfigDomain.length) {
        [[XGPush defaultManager] configureClusterDomainName:self.tpnsConfigDomain];
    }
    [[XGPush defaultManager] startXGWithAccessID:self.tpnsConfigAccessID accessKey:self.tpnsConfigAccessKey delegate:self];
    NSLog(@"[TUIOfflinePushManager][TPNS] %s", __func__);
}

- (void)unregisterService
{
    // 恢复系统 delegate
    [self unloadApplicationDelegateIfNeeded];
    
    // 移除前后台监听
    [V2TIMManager.sharedInstance removeConversationListener:self];
    
    // 解绑账号
    [self unbindAccount];
    
    // 反初始化
    [[XGPush defaultManager] stopXGNotification];
}

- (BOOL)supportTPNS
{
    return YES;
}

#pragma mark - 账号绑定/解绑
// 绑定账号
- (void)bindAccount
{
    NSString *userID = V2TIMManager.sharedInstance.getLoginUser;
    [XGPushTokenManager.defaultTokenManager upsertAccountsByDict:@{ @(0): userID?:@"" }];
    NSLog(@"[TUIOfflinePushManager][TPNS] %s:%@", __func__, userID);
}

// 解绑账号
- (void)unbindAccount
{
    [XGPushTokenManager.defaultTokenManager delAccountsByKeys:[NSSet setWithObject:@(0)]];
    NSLog(@"[TUIOfflinePushManager][TPNS] %s", __func__);
}

#pragma mark - IM 和 TPNS 角标同步
- (void)onTotalUnreadMessageCountChanged:(UInt64)totalUnreadCount
{
    [[XGPush defaultManager] setBadge:totalUnreadCount];
    NSLog(@"[TUIOfflinePushManager][TPNS] %s, badge:%llu", __func__, totalUnreadCount);
}

#pragma mark - 系统的通知相关回调
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSDictionary *custom = nil;
    if ([userInfo.allKeys containsObject:@"custom"]) {
        NSString *customStr = userInfo[@"custom"];
        custom = [self jsonSring2Dictionary:customStr];
    }
    
    if (custom == nil || ![custom isKindOfClass:NSDictionary.class]) {
        completionHandler(UIBackgroundFetchResultFailed);
        return;
    }
    
    if (![custom.allKeys containsObject:@"entity"]) {
        completionHandler(UIBackgroundFetchResultFailed);
        return;
    }
    
    [self onReceiveOfflinePushEntity:custom[@"entity"]];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - TPNS 回调

/**
@brief 注册推送服务回调
@param deviceToken APNs 生成的 Device Token
@param xgToken TPNS 生成的 Token，推送消息时需要使用此值。TPNS 维护此值与 APNs 的 Device Token 的映射关系
@param error 错误信息，若 error 为 nil 则注册推送服务成功
@note TPNS SDK1.2.6.0+
*/
- (void)xgPushDidRegisteredDeviceToken:(nullable NSString *)deviceToken xgToken:(nullable NSString *)xgToken error:(nullable NSError *)error
{
    NSLog(@"[TUIOfflinePushManager][TPNS] %s, deviceToken:%@, xgToken:%@, error:%@", __func__, deviceToken, xgToken, error);
    if (error == nil) {
        // 1. 上报 token
        NSData *data = [xgToken dataUsingEncoding:NSUTF8StringEncoding];
        [self onReportToken:data];
        
        // 2. 绑定账号
        [self bindAccount];
    }
}

/// 注册推送服务失败回调
/// @param error 注册失败错误信息
/// @note TPNS SDK1.2.7.1+
- (void)xgPushDidFailToRegisterDeviceTokenWithError:(nullable NSError *)error
{
    NSLog(@"[TUIOfflinePushManager][TPNS] %s, %@", __func__, error);
}


/// 统一接收消息的回调
/// @param notification 消息对象(有2种类型NSDictionary和UNNotification具体解析参考示例代码)
/// @note 此回调为前台收到通知消息及所有状态下收到静默消息的回调（消息点击需使用统一点击回调）
/// 区分消息类型说明：xg字段里的msgtype为1则代表通知消息msgtype为2则代表静默消息
- (void)xgPushDidReceiveRemoteNotification:(nonnull id)notification withCompletionHandler:(nullable void (^)(NSUInteger))completionHandler
{
    /// code
    NSLog(@"[TUIOfflinePushManager][TPNS] %s, %@", __func__, notification);
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
                custom = [self jsonSring2Dictionary:customStr];
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
