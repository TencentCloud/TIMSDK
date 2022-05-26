//
//  TUIOfflinePushManager+Inner.h
//  Pods
//
//  Created by harvy on 2022/5/10.
//

#import "TUIOfflinePushManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIOfflinePushManager ()

#pragma mark - 私有方法 - 各推送通道重写该方法
/**
 * 是否支持 TPNS
 */
- (BOOL)supportTPNS;

/**
 * 申请 token
 */
- (void)applyPushToken;

#pragma mark - 私有方法 - 响应

/**
 * 上报 token
 */
- (void)onReportToken:(NSData *)deviceToken;

/**
 * 收到了离线推送的实体
 *
 * @param entity 解析过后的离线推送实体
 */
- (void)onReceiveOfflinePushEntity:(NSDictionary *)entity;

/**
 * 托管的系统 appDelegate
 */
@property (nonatomic, strong, nullable) id<UIApplicationDelegate> applicationDelegate;

/**
 * APNS 的配置信息 - 证书 ID
 */
@property (nonatomic, assign, readonly) int apnsCertificateID;

/**
 * TPNS 的配置信息
 */
@property (nonatomic, copy, readonly) NSString *tpnsConfigDomain;
@property (nonatomic, assign, readonly) int tpnsConfigAccessID;
@property (nonatomic, copy, readonly) NSString *tpnsConfigAccessKey;

// 接管系统代理
- (void)loadApplicationDelegateIfNeeded;

// 恢复系统代理
- (void)unloadApplicationDelegateIfNeeded;

@end

NS_ASSUME_NONNULL_END
