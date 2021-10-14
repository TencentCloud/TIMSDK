/////////////////////////////////////////////////////////////////////
//
//                     TUI 插件核心类
//
//  模块名称：TUICore
//
//  该模块主要负责 TUI 插件间数据的传递，通知的广播，功能的扩展等
//
/////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
@import UIKit;

@protocol TUIServiceProtocol;
@protocol TUIObjectProtocol;
@protocol TUINotificationProtocol;
@protocol TUIExtensionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface TUICore : NSObject
/**
 *  注册 Service 服务
 *
 *  @param serviceName 服务名
 *  @param object 服务对象
 */
+ (void)registerService:(NSString *)serviceName object:(id<TUIServiceProtocol>)object;

/**
 *  唤起 Service 服务
 *
 *  @param serviceName 服务名
 *  @param method 方法名
 *  @param param 透传给服务方的数据
 *  @return 返回对象
 */
+ (id)callService:(NSString *)serviceName method:(NSString *)method param:(nullable NSDictionary *)param;

/**
 *  注册通知
 */
+ (void)registerEvent:(NSString *)key subKey:(NSString *)subKey object:(id<TUINotificationProtocol>)object;

/**
 *  移除 object 所有通知
 */
+ (void)unRegisterEventByObject:(id<TUINotificationProtocol>)object;

/**
 *  移除 object 指定 key 和 subKey 的通知
 */
+ (void)unRegisterEvent:(nullable NSString *)key subKey:(nullable NSString *)subKey object:(nullable id<TUINotificationProtocol>)object;

/**
 *  触发通知
 */
+ (void)notifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param;

/**
 *  注册扩展
 */
+ (void)registerExtension:(NSString *)key object:(id<TUIExtensionProtocol>)object;

/**
 *  移除扩展
 */
+ (void)unRegisterExtension:(NSString *)key object:(id<TUIExtensionProtocol>)object;

/**
 *  获取扩展信息
 */
+ (NSDictionary *)getExtensionInfo:(NSString *)key param:(nullable NSDictionary *)param;
@end

/////////////////////////////////////////////////////////////////////////////////
//        协议
/////////////////////////////////////////////////////////////////////////////////

/// Service 服务协议
@protocol TUIServiceProtocol<NSObject>
@optional
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param;
@end

/// Object 创建协议
@protocol TUIObjectProtocol<NSObject>
@optional
- (void)onCreate:(NSDictionary *)param;
- (NSArray<NSDictionary *> *)onGetInfo:(NSString *)key param:(NSDictionary *)param;
@end

/// Notification 协议
@protocol TUINotificationProtocol<NSObject>
@optional
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param;
@end

/// Extension 协议
@protocol TUIExtensionProtocol<NSObject>
@optional
- (NSDictionary *)getExtensionInfo:(NSString *)key param:(nullable NSDictionary *)param;
@end

NS_ASSUME_NONNULL_END
