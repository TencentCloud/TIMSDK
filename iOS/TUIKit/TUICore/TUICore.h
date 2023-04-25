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
@class TUIExtensionInfo;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIExtensionClickCallback)(NSDictionary *param);
typedef void(^TUICallServiceResultCallback)(NSInteger errorCode, NSString* errorMessage, NSDictionary *param);

@interface TUICore : NSObject

+ (void)registerService:(NSString *)serviceName object:(id<TUIServiceProtocol>)object;
+ (nullable id<TUIServiceProtocol>)getService:(NSString *)serviceName;
+ (id)callService:(NSString *)serviceName method:(NSString *)method param:(nullable NSDictionary *)param;
+ (id)callService:(NSString *)serviceName method:(NSString *)method param:(nullable NSDictionary *)param resultCallback:(nullable TUICallServiceResultCallback)resultCallback;

+ (void)registerEvent:(NSString *)key subKey:(NSString *)subKey object:(id<TUINotificationProtocol>)object;
+ (void)unRegisterEventByObject:(id<TUINotificationProtocol>)object;
+ (void)unRegisterEvent:(nullable NSString *)key subKey:(nullable NSString *)subKey object:(nullable id<TUINotificationProtocol>)object;
+ (void)notifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param;

+ (void)registerExtension:(NSString *)extensionID object:(id<TUIExtensionProtocol>)object;
+ (void)unRegisterExtension:(NSString *)extensionID object:(id<TUIExtensionProtocol>)object;
+ (NSArray<TUIExtensionInfo *> *)getExtensionList:(NSString *)extensionID param:(nullable NSDictionary *)param;
+ (void)raiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param;
// deprecated
+ (NSDictionary *)getExtensionInfo:(NSString *)extensionID param:(nullable NSDictionary *)param  __attribute__((deprecated("use getExtensionList:param: instead")));

+ (void)registerObjectFactoryName:(NSString *)factoryName objectFactory:(id<TUIObjectProtocol>)objectFactory;
+ (void)unRegisterObjectFactory:(NSString *)factoryName;
+ (id)createObject:(NSString *)factoryName key:(NSString *)method param:(NSDictionary *)param;

@end


@protocol TUIServiceProtocol<NSObject>
@optional
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param;
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param resultCallback:(TUICallServiceResultCallback) resultCallback;
@end

@protocol TUIObjectProtocol<NSObject>
@optional
- (id)onCreateObject:(NSString *)method param:(nullable NSDictionary *)param;
@end

@protocol TUINotificationProtocol<NSObject>
@optional
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param;
@end

@protocol TUIExtensionProtocol<NSObject>
@optional
- (NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(nullable NSDictionary *)param;
- (void)onRaiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param;
// deprecated
- (NSDictionary *)getExtensionInfo:(NSString *)extensionID param:(nullable NSDictionary *)param __attribute__((deprecated("use onGetExtension:param: instead")));
@end

@interface TUIWeakProxy : NSProxy

@property (nonatomic, weak, readonly, nullable) id target;

- (nonnull instancetype)initWithTarget:(nonnull id)target;
+ (nonnull instancetype)proxyWithTarget:(nonnull id)target;

@end

@interface TUIExtensionInfo: NSObject

@property(nonatomic, assign) NSInteger weight;
@property(nonatomic, strong) UIImage *icon;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, strong) NSDictionary *data;
@property(nonatomic, copy) TUIExtensionClickCallback onClicked;

@end

NS_ASSUME_NONNULL_END
