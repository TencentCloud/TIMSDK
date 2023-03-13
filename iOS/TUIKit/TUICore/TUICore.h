/**
 *  TUI 插件核心类
 *  该模块主要负责 TUI 插件间数据的传递，通知的广播，功能的扩展等
 *
 *  TUICore
 *  This module is mainly responsible for data transfer, event notification and extension between TUI components.
 */

#import <Foundation/Foundation.h>
@import UIKit;

@protocol TUIServiceProtocol;
@protocol TUIObjectProtocol;
@protocol TUINotificationProtocol;
@protocol TUIExtensionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface TUICore : NSObject

+ (void)registerService:(NSString *)serviceName object:(id<TUIServiceProtocol>)object;
+ (id<TUIServiceProtocol>)getService:(NSString *)serviceName;
+ (id)callService:(NSString *)serviceName method:(NSString *)method param:(nullable NSDictionary *)param;


+ (void)registerEvent:(NSString *)key subKey:(NSString *)subKey object:(id<TUINotificationProtocol>)object;
+ (void)unRegisterEventByObject:(id<TUINotificationProtocol>)object;
+ (void)unRegisterEvent:(nullable NSString *)key subKey:(nullable NSString *)subKey object:(nullable id<TUINotificationProtocol>)object;
+ (void)notifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param;

+ (void)registerExtension:(NSString *)key object:(id<TUIExtensionProtocol>)object;
+ (void)unRegisterExtension:(NSString *)key object:(id<TUIExtensionProtocol>)object;
+ (NSDictionary *)getExtensionInfo:(NSString *)key param:(nullable NSDictionary *)param;

@end


@protocol TUIServiceProtocol<NSObject>
@optional
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param;
@end

@protocol TUIObjectProtocol<NSObject>
@optional
- (void)onCreate:(NSDictionary *)param;
- (NSArray<NSDictionary *> *)onGetInfo:(NSString *)key param:(NSDictionary *)param;
@end

@protocol TUINotificationProtocol<NSObject>
@optional
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param;
@end

@protocol TUIExtensionProtocol<NSObject>
@optional
- (NSDictionary *)getExtensionInfo:(NSString *)key param:(nullable NSDictionary *)param;
@end

@interface TUIWeakProxy : NSProxy

@property (nonatomic, weak, readonly, nullable) id target;

- (nonnull instancetype)initWithTarget:(nonnull id)target;
+ (nonnull instancetype)proxyWithTarget:(nonnull id)target;

@end

NS_ASSUME_NONNULL_END
