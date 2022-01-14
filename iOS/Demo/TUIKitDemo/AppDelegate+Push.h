//
//  AppDelegate+Push.h
//  TUIKitDemo
//
//  Created by harvy on 2021/12/22.
//  Copyright © 2021 Tencent. All rights reserved.
//
// Apple 提供的 APNS 推送通道接入步骤
// 1. 将 AppDelegate+Push / AppDelegate+APNS 头文件和实现文件拷入自己的工程
// 2. 默认提供了 APNS 的推送，修改本文件中的 APNS 证书 ID，在 IM 云控制台上传证书后会自动生成对应的证书 ID
// 3. 代码接入步骤
//    - 在 application:didFinishLaunchingWithOptions: 中调用 push_init 方法初始化推送
//    - 在 APP/IM 登录完成后，调用 push_registerIfLogined: 方法注册推送
//    - 在 APP/IM 退出登录时，调用 push_unregisterIfLogouted 方法取消推送
// 4. 本文件提供了未读数以及 APP 的 badge 更新功能，您只需作如下处理即可
//    - 在您的 AppDelegate.m 文件中监听 V2TIMConversationListener 并空实现 onTotalUnreadMessageCountChanged:即可
//    - 如果您的 APP 提供了一键清空未读消息的功能，只需在合适的地方调用 push_clearUnreadMessage 方法即可
//
//
// TPNS 推送通道接入步骤
// 1. 将 AppDelegate+Push / AppDelegate+TPNS 头文件和实现文件拷入自己的工程
// 2. 默认是 APNS 接入，想要开启 TPNS 推送，有两种方法可选择 (以下二选一)
//    - 在您的工程 target -> Build Settings -> Preprocessor Macros 中新增宏 ENABLETPNS=1
//    - 删除 AppDelegate+TPNS.h 和 AppDelegate+TPNS.m 文件中的 ```#if ENABLETPNS``` 以及对应的 ```#endif``` 字样
// 3. 修改本文件中的 TPNS 推送信息，在 TPNS 云控制台上创建应用后会自动生成
// 4. 代码接入步骤
//    - 在 application:didFinishLaunchingWithOptions: 中调用 push_init 方法初始化推送
//    - 在 APP/IM 登录完成后，调用 push_registerIfLogined: 方法注册推送
//    - 在 APP/IM 退出登录时，调用 push_unregisterIfLogouted 方法取消推送
// 5. 本文件提供了未读数以及 APP 的 badge 更新功能，您只需作如下处理即可
//    - 在您的 AppDelegate.m 文件中监听 V2TIMConversationListener 并空实现 onTotalUnreadMessageCountChanged:即可
//    - 如果您的 APP 提供了一键清空未读消息的功能，只需在合适的地方调用 push_clearUnreadMessage 方法即可
//

#import "AppDelegate.h"
#import "TCConstants.h"

NS_ASSUME_NONNULL_BEGIN

// ********************** 推送信息设置 ************************
//apns 推送证书ID，在 IM 控制台可以查看
#define sdkBusiId 0

//tpns
#define tpnsAccessID  0
#define tpnsAccessKey @""
// **********************************************************

@interface AppDelegate (Push)

/**
 * 1. 初始化推送服务，在 application:didFinishLaunchingWithOptions: 中调用.
 * @note 根据需要，自行对该方法覆盖来加载 APNS 通道或者 TPNS 通道的初始化服务
 */
- (void)push_init;

/**
 * 2.  注册服务，在登录完成之后调用
 *
 * @param userID 当前登录账号的 userID
 *
 * @note 该方法实现了着重处理以下场景：
 * - 注册 token
 * - 登录后更新未读，包括消息未读和新增联系人未读
 * - 从通知栏启动 APP，登录完成之后，打开通知详情
 */
- (void)push_registerIfLogined:(NSString *)userID;

/**
 * 3. 取消注册，再退出登录之后调用
 */
- (void)push_unregisterIfLogouted;

/**
 * 是否支持 TPNS
 */
- (BOOL)supportTPNS:(NSString *)userID;

/**
 * 收到了离线推送的实体
 *
 * @param entity 解析过后的离线推送实体
 */
- (void)onReceiveOfflinePushEntity:(NSDictionary *)entity;

#pragma mark - 未读数相关
// 4. 清空所有未读消息数
- (void)push_clearUnreadMessage;

@end

NS_ASSUME_NONNULL_END
