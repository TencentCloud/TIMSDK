
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  TUI 插件核心类
 *  该模块主要负责 TUI 插件间数据的传递，通知的广播，功能的扩展等
 *
 *  TUICore
 *  This module is mainly responsible for data transfer, event notification and extension between TUI components.
 */

#import <UIKit/UIKit.h>

@protocol TUIServiceProtocol;
@protocol TUIObjectProtocol;
@protocol TUINotificationProtocol;
@protocol TUIExtensionProtocol;
@class TUIExtensionInfo;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TUICallServiceResultCallback)(NSInteger errorCode, NSString *errorMessage, NSDictionary *param);

#pragma mark - TUICore
/////////////////////////////////////////////////////////////////////////////////
//
//             Definition of TUICore, APIs
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUICore : NSObject

+ (void)registerService:(NSString *)serviceName object:(id<TUIServiceProtocol>)object;
+ (void)unregisterService:(NSString *)serviceName;
+ (nullable id<TUIServiceProtocol>)getService:(NSString *)serviceName;
+ (nullable id)callService:(NSString *)serviceName method:(NSString *)method param:(nullable NSDictionary *)param;
+ (nullable id)callService:(NSString *)serviceName
                    method:(NSString *)method
                     param:(nullable NSDictionary *)param
            resultCallback:(nullable TUICallServiceResultCallback)resultCallback;

+ (void)registerEvent:(NSString *)key subKey:(NSString *)subKey object:(id<TUINotificationProtocol>)object;
+ (void)unRegisterEventByObject:(id<TUINotificationProtocol>)object;
+ (void)unRegisterEvent:(nullable NSString *)key subKey:(nullable NSString *)subKey object:(nullable id<TUINotificationProtocol>)object;
+ (void)notifyEvent:(NSString *)key subKey:(nullable NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param;

+ (void)registerExtension:(NSString *)extensionID object:(id<TUIExtensionProtocol>)object;
+ (void)unRegisterExtension:(NSString *)extensionID object:(id<TUIExtensionProtocol>)object;
+ (NSArray<TUIExtensionInfo *> *)getExtensionList:(NSString *)extensionID param:(nullable NSDictionary *)param;
+ (BOOL)raiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param;
// deprecated
+ (nullable NSDictionary *)getExtensionInfo:(NSString *)extensionID
                                      param:(nullable NSDictionary *)param __attribute__((deprecated("use getExtensionList:param: instead")));

+ (void)registerObjectFactory:(NSString *)factoryName objectFactory:(id<TUIObjectProtocol>)objectFactory;
+ (void)unRegisterObjectFactory:(NSString *)factoryName;
+ (nullable id)createObject:(NSString *)factoryName key:(NSString *)method param:(nullable NSDictionary *)param;

@end

#pragma mark - TUIRoute
/////////////////////////////////////////////////////////////////////////////////
//
//             Definition of TUIRoute, APIs
//
/////////////////////////////////////////////////////////////////////////////////

typedef void (^TUIValueResultCallback)(NSDictionary *param);

@interface NSObject (TUIRoute)

@property(nonatomic, copy) TUIValueResultCallback navigateValueCallback;

@end

@interface UIViewController (TUIRoute)

- (void)pushViewController:(NSString *)viewControllerKey param:(nullable NSDictionary *)param forResult:(nullable TUIValueResultCallback)callback;

- (void)presentViewController:(NSString *)viewControllerKey param:(nullable NSDictionary *)param forResult:(nullable TUIValueResultCallback)callback;
- (void)presentViewController:(NSString *)viewControllerKey
                        param:(nullable NSDictionary *)param
                     embbedIn:(nullable UINavigationController *)navigationVC
                    forResult:(nullable TUIValueResultCallback)callback;

@end

#pragma mark - TUIService
/////////////////////////////////////////////////////////////////////////////////
//
//             Definition of TUIService, APIs
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIServiceProtocol <NSObject>

@optional
- (nullable id)onCall:(NSString *)method param:(nullable NSDictionary *)param;
- (nullable id)onCall:(NSString *)method param:(nullable NSDictionary *)param resultCallback:(TUICallServiceResultCallback)resultCallback;

@end

@interface TUIServiceManager : NSObject

+ (instancetype)shareInstance;

- (void)registerService:(NSString *)serviceName service:(id<TUIServiceProtocol>)service;
- (void)unregisterService:(NSString *)serviceName;

- (nullable id<TUIServiceProtocol>)getService:(NSString *)serviceName;

- (nullable id)callService:(NSString *)serviceName
                    method:(NSString *)method
                     param:(nullable NSDictionary *)param
            resultCallback:(nullable TUICallServiceResultCallback)resultCallback;

@end

#pragma mark - TUIEvent
/////////////////////////////////////////////////////////////////////////////////
//
//             Definition of TUIEvent, APIs
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUINotificationProtocol <NSObject>
@optional
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param;

@end

@interface TUIEventManager : NSObject

+ (instancetype)shareInstance;

- (void)registerEvent:(NSString *)key subKey:(NSString *)subKey object:(id<TUINotificationProtocol>)object;
- (void)unRegisterEvent:(id<TUINotificationProtocol>)object;
- (void)unRegisterEvent:(nullable NSString *)key subKey:(nullable NSString *)subKey object:(nullable id<TUINotificationProtocol>)object;

- (void)notifyEvent:(NSString *)key subKey:(nullable NSString *)subKey object:(nullable id)object param:(nullable NSDictionary *)param;

@end

#pragma mark - TUIExtension
/////////////////////////////////////////////////////////////////////////////////
//
//             Definition of TUIExtension, APIs
//
/////////////////////////////////////////////////////////////////////////////////

typedef void (^TUIExtensionClickCallback)(NSDictionary *param);

@interface TUIExtensionInfo : NSObject

@property(nonatomic, assign) NSInteger weight;
@property(nonatomic, strong, nullable) UIImage *icon;
@property(nonatomic, copy, nullable) NSString *text;
@property(nonatomic, strong, nullable) NSDictionary *data;
@property(nonatomic, copy, nullable) TUIExtensionClickCallback onClicked;

@end

@protocol TUIExtensionProtocol <NSObject>
@optional

- (nullable NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(nullable NSDictionary *)param;

// If there exist responser, return YES
- (BOOL)onRaiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param;

// deprecated
- (nullable NSDictionary *)onGetExtensionInfo:(NSString *)extensionID
                                        param:(nullable NSDictionary *)param __attribute__((deprecated("use onGetExtension:param: instead")));

@end

@interface TUIExtensionManager : NSObject

+ (instancetype)shareInstance;

- (void)registerExtension:(NSString *)extensionID extension:(id<TUIExtensionProtocol>)extension;
- (void)unRegisterExtension:(NSString *)extensionID extension:(id<TUIExtensionProtocol>)extension;

- (NSArray<TUIExtensionInfo *> *)getExtensionList:(NSString *)extensionID param:(nullable NSDictionary *)param;

- (BOOL)raiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param;

// deprecated
- (nullable NSDictionary *)getExtensionInfo:(NSString *)extensionID
                                      param:(nullable NSDictionary *)param __attribute__((deprecated("use getExtensionList:param: instead")));

@end

#pragma mark - TUIObjectFactory
/////////////////////////////////////////////////////////////////////////////////
//
//             Definition of TUIObjectFactory, APIs
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIObjectProtocol <NSObject>
@optional
- (nullable id)onCreateObject:(NSString *)method param:(nullable NSDictionary *)param;

@end

@interface TUIObjectFactoryManager : NSObject

+ (instancetype)shareInstance;

- (void)registerObjectFactory:(NSString *)factoryName objectFactory:(id<TUIObjectProtocol>)objectFactory;
- (void)unRegisterObjectFactory:(NSString *)factoryName;

- (nullable id)createObject:(NSString *)factoryName method:(NSString *)method param:(nullable NSDictionary *)param;

- (nullable id)createObject:(NSString *)method param:(NSDictionary *)param;

@end

NS_ASSUME_NONNULL_END
