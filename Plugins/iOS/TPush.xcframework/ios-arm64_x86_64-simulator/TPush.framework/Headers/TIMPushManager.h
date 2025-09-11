//
// Copyright (c) 2023 Tencent. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
@protocol TIMPushDelegate;
@protocol TIMPushListener;
@class TIMPushMessage;
NS_ASSUME_NONNULL_BEGIN

typedef void(^TIMPushCallback)(void);
typedef void(^TIMPushValueCallback)(NSString *value);
typedef void(^TIMPushSuccessCallback)(NSData * deviceToken);
typedef void(^TIMPushFailedCallback)(int code, NSString * desc);
typedef void(^TIMPushCallExperimentalAPISucc)(NSObject *object);
typedef void(^TIMPushNotificationExtensionCallback)(UNNotificationContent *content) API_AVAILABLE(macos(10.14), ios(10.0), watchos(3.0), tvos(10.0));

@interface TIMPushManager : NSObject
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                      （一）注册/反注册推送服务
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * 1.1 注册推送服务
 *
 * @param sdkAppId 应用的 SDKAPPID
 * @param appKey 控制台为您分配的 secretKey
 *
 * @note 请注意：
 * - 如果您单独使用推送服务，请正确传递 sdkAppId 和 appkey 两个参数，即可注册推送服务
 * - 如果您已经集成 IM 产品，请在 IM 登录成功后调用该接口，将 appKey 参数设置为 nil，接入离线推送能力.
 */
+ (void)registerPush:(int)sdkAppId appKey:(NSString *)appKey
                succ:(TIMPushSuccessCallback)successCallback
                fail:(TIMPushFailedCallback)failedCallback NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");
/**
 * 1.2 取消注册
 *
 * @note
 * - 在退出登录时调用
 * - 如果您使用了 [TUILogin](https://github.com/TencentCloud/TIMSDK/blob/master/iOS/TUIKit/TUICore/TUILogin.h) 提供的 login/logout，无需再调用该接口
 */
+ (void)unRegisterPush:(TIMPushCallback)successCallback
                  fail:(TIMPushFailedCallback)failedCallback
                                    NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");

/**
 * 1.3 注册离线推送服务成功后，获取注册 ID 标识, 即 RegistrationID
 *
 *  @note 请注意：
 *  - callback 回调值是 registerPush 时候传递的 userId
 *  - 若传递 userId 为空，则为设备的标识 ID，卸载重装会改变。
 *
 */
+ (void)getRegistrationID:(TIMPushValueCallback)callback NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");


/**
 * 1.4 设置注册离线推送服务使用的推送 ID 标识, 即 RegistrationID，需要在注册推送服务之前调用
 *
 *  @param  registrationID 为设备的推送标识 ID，卸载重装会改变。
 *
 */
+ (void)setRegistrationID:(NSString *)registrationID callback:(TIMPushCallback)callback NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");


/**
 * 1.5 设置应用前台是否展示推送
 *
 *  @param disable 如果值为 YES，则关闭前台推送；如果值为 NO，则开启前台推送展示。
 *
 */
+ (void)disablePostNotificationInForeground:(BOOL)disable NS_SWIFT_NAME(disablePostNotificationInForeground(disable:));

/**
 * 1.6 实验性 API 接口
 *
 *  @param api 接口名称
 *  @param param 接口参数
 *  @note 该接口提供一些实验性功能
 */
+ (void)callExperimentalAPI:(NSString *)api
                              param:(NSObject * _Nullable)param
                               succ:(TIMPushCallExperimentalAPISucc)succ
                               fail:(TIMPushFailedCallback)fail NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                      （二） Push 全局监听
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * 2.1 添加 Push 监听器
 */
+ (void)addPushListener:(id<TIMPushListener>)listener NS_SWIFT_NAME(addPushListener(listener:)) NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");

/**
 * 2.2. 移除 Push 监听器
 */
+ (void)removePushListener:(id<TIMPushListener>)listener NS_SWIFT_NAME(removePushListener(listener:)) NS_EXTENSION_UNAVAILABLE_IOS("This API is not supported in App Extension");

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                      （三）统计 TIMPush 的推送抵达率
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * 3.1 统计 TIMPush 的推送抵达率 （按照需求选择启用）
 *
 * @note 请注意：
 * - 仅支持在 Notification Service Extension 的 '- didReceiveNotificationRequest:withContentHandler:' 方法中调用；
 * - appGroup 标识当前主 APP 和 Extension 之间共享的 APP Group，需要在主 APP 的 Capability 中配置 App Groups 能力。
 * - 可以点击[https://cloud.tencent.com/document/product/269/100627#a76b331f-3d49-48c9-99a9-5301c7d7fa99]查阅详细步骤
 */
+ (void)handleNotificationServiceRequest:(UNNotificationRequest *)request appGroupID:(NSString *)appGroupID callback:(TIMPushNotificationExtensionCallback)callback NS_SWIFT_NAME(handleNotificationServiceRequest(request:appGroupID:callback:));

@end

@protocol TIMPushListener <NSObject>
/**
 * 收到 Push 消息
 *
 * @param message 消息
 */
- (void)onRecvPushMessage:(TIMPushMessage *)message;


/**
 * 收到 Push 消息撤回的通知
 *
 * @param messageID 消息唯一标识
 */
- (void)onRevokePushMessage:(NSString *)messageID;


/**
 * 点击通知栏消息回调
 *
 * @param ext 离线消息透传字段
 *
 */
- (void)onNotificationClicked:(NSString *)ext;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                  离线推送证书配置 与 点击事件处理回调
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol TIMPushDelegate <UIApplicationDelegate>
@optional
/**
 * 离线推送证书的 ID
 * 您需要在 AppDelegate.m 中实现该方法，返回值为 IM 控制台分配的证书 ID
 *
 * 特别注意的是，该证书ID使用时需要对应您的运行环境：
 * 使用开发环境的证书ID，可以直接在Xcode上运行测试（Debug 即可调试推送）。
 * 使用生产环境的证书ID，需要您 Archive 出 release 包后进行测试。
 */
- (int)businessID;

/**
 * 主 APP 和 NSNotification Service Extension 所属的 App Group ID  [可选]
 * 注意: 当您需要借助 iOS 10 特性来统计消息的抵达率时，推荐您设置此属性。
 * 详细步骤可查阅：https://cloud.tencent.com/document/product/269/100624#ae5590eb-b974-4226-9f1b-720fb0201c85
 */
- (NSString *)applicationGroupID;

/**
 * 收到远程推送（在线收到后触发、离线时点击通知栏通知触发）
 * 如果要自定义解析收到的远程推送通知，请在您的 AppDelegate 中实现该方法
 *
 * @note
 *  - 如果返回 YES， TIMPush 将不在执行内置的 TUIKit 离线推送解析逻辑，完全交由您自行处理；
 *  - 如果返回 NO，TIMPush 将继续执行内置的 TUIKit 离线推送解析逻辑，继续回调 - navigateToBuiltInChatViewController:groupID: 方法。
 */
- (BOOL)onRemoteNotificationReceived:(nullable NSString *)notice;

/**
 * 点击通知栏离线推送的通知后，跳转到自定义页面
 * 如果要实现跳转到聊天列表，请在您的 AppDelegate 中实现如下方法
 *
 * @note
 *  - TIMPush 默认已经从离线推送中解析出当前推送的 userID 和 groupID
 *  - 如果 groupID 不为空，说明当前点击的是群聊离线消息
 *  - 如果 groupID 为空且 userID 不为空，说明当前点击的是单聊离线消息
 */
- (void)navigateToBuiltInChatViewController:(nullable NSString *)userID
                                    groupID:(nullable NSString *)groupID NS_SWIFT_NAME(navigateToBuiltInChatViewController(userID:groupID:));
@end

@interface TIMPushMessage : NSObject
// 离线推送标题
@property (nonatomic, copy) NSString *title;
// 离线推送内容
@property (nonatomic, copy) NSString *desc;
// 离线推送透传内容
@property (nonatomic, copy) NSString *ext;
// 消息唯一标识 ID
@property (nonatomic, copy) NSString *messageID;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                              状态码
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, TIMPushErrorCode) {
    TIMPushErrorUndefinedCode                             = -1,      ///< 未知错误
    TIMPushErrorNotLogined                                = 800001,  ///< 注册 Push 之前，未登录 IM 账号
    TIMPushErrorInvalidSdkAppId                           = 800002,  ///< 注册 Push 参数 sdkAppID 不合法
    TIMPushErrorRegisterPushInitFailed                    = 800003,  ///< 初始化 SDK 失败
    TIMPushErrorCallExperimentalApiFailed                 = 800015,  ///< 实验性接口调用失败
    TIMPushErrortNotificationAuthorizationDenied          = 800016,  ///< 用户拒绝推送获取弹窗权限
};

NS_ASSUME_NONNULL_END

