//
//  TUIOfflinePushManager.h
//  TUIOfflinePush
//
//  Created by harvy on 2022/5/6.
//
// ================ Apple 提供的 APNs 推送通道接入步骤 ================
// 1. 集成 APNS 离线推送库。
//    在您的 Podfile 中添加， pod 'TUIOfflinePush'，然后执行 pod install
// 2. 配置 APNS 证书 ID。
//    在您的 AppDelegate 的 @implementation 中，调用 TUIOfflinePushCertificateIDForAPNS(证书ID)，配置您的证书 ID。
//    其中证书 ID 可在 IM 控制台查询。
// 3. 实现上述 2 个步骤后，您的 App 就具备离线推送功能了，可以正常接收离线消息了。
// 4. 本组件已支持离线推送内容解析，如果您想实现自定义跳转，您只需要在您的 AppDelegate 中实现如下方法即可：
//    - (void)navigateToTUIChatViewController:(NSString *)userID groupID:(NSString *)groupID
//
// 注意：如果您登录后依然收不到推送，请检查您的 App 是否使用了 TUI 组件（TUIChat、TUIContact、TUIConversation、TUIGroup、TUISearch、TUICore、TUICalling 中的任意一个）。
//  - 如果您不想使用 TUI 组件，但依然想接收离线推送，可参考 TUIOfflinePushManager+Advance 的高级用法。
//  - 如果您使用了 TUI 组件，依然收不到推送，请加入 QQ 群（592465424）反馈。
// ================================================================

// ======================= TPNS 推送通道接入步骤 ========================
// 1. 集成 TPNS 离线推送库。
//    在您的 Podfile 中添加， pod 'TUIOfflinePush/TPNS'，然后执行 pod install
// 2. 配置 TPNS 的 accessID、accesskey 和自定义域名。
//    在您的 AppDelegate 的 @implementation 中，调用 TUIOfflinePushConfigForTPNS(1000,"key", "domain")，配置您的信息。
//    其中配置信息可在 TPNS 控制台查询。
// 3. 实现上述 2 个步骤后，您的 App 就具备离线推送功能了，可以正常接收离线消息了。
// 4. 本组件已支持离线推送内容解析，如果您想实现自定义跳转，您只需要在您的 AppDelegate 中实现如下方法即可：
//    - (void)navigateToTUIChatViewController:(NSString *)userID groupID:(NSString *)groupID
//
// 注意：如果您登录后依然收不到推送，请检查您的 App 是否使用了 TUI 组件（TUIChat、TUIContact、TUIConversation、TUIGroup、TUISearch、TUICore、TUICalling 中的任意一个）。
//  - 如果您不想使用 TUI 组件，但依然想接收离线推送，可参考 TUIOfflinePushManager+Advance 的高级用法。
//  - 如果您使用了 TUI 组件，依然收不到推送，请加入 QQ 群（592465424）反馈。
// ===================================================================



// ================ The access steps of APNS ================
// 1. Integrate APNS offline push component.
//    Add pod 'TUIOfflinePush' to your Podfile, then do 'pod install'
//
// 2. Configure the certificate ID for APNS.
//    In your AppDelegate's @implementation, call TUIOfflinePushCertificateIDForAPNS(certificateID) to configure your certificate ID.
//    The certificateID can be queried in the IM console.
//
// 3. After implementing the above two steps, your app has the offline push function and can receive offline messages normally.
//
// 4. This component already supports offline push content parsing.
//    If you want to redirect to a custom page after clicking an offline push notification, you only need to implement the following method in your AppDelegate:
//    - (void)navigateToTUIChatViewController:(NSString *)userID groupID:(NSString *)groupID
//
// Note:
//  If you still cannot receive push notifications after logging in,
//  please check if your app uses TUI components (any of TUIChat, TUIContact, TUIConversation, TUIGroup, TUISearch, TUICore, TUICalling).
//  - If you don't want to use the above TUI components, but still want to receive offline push, you can refer to the advanced usage of TUIOfflinePushManager+Advance.
//  - If you are using the TUI component and still cannot receive the push, please issue.
// =======================================================================================

// ======================= The access steps of TPNS ========================
// 1. Integrate TPNS offline push component.
//    Add pod 'TUIOfflinePush/TPNS' to your Podfile, then do 'pod install'
//
// 2. Configure the accessID, accesskey and custom domain name of TPNS.
//    In your AppDelegate's @implementation, call TUIOfflinePushConfigForTPNS(1000, "key", "domain") to configure your information.
//    The configuration information can be queried in the TPNS console.
//
// 3. After implementing the above two steps, your app has the offline push function and can receive offline messages normally.
//
// 4. This component already supports offline push content parsing.
//    If you want to redirect to a custom page after clicking an offline push notification, you only need to implement the following method in your AppDelegate:
//    - (void)navigateToTUIChatViewController:(NSString *)userID groupID:(NSString *)groupID
//
// Note:
//  If you still cannot receive push notifications after logging in,
//  please check if your app uses TUI components (any of TUIChat, TUIContact, TUIConversation, TUIGroup, TUISearch, TUICore, TUICalling).
//  - If you don't want to use the above TUI components, but still want to receive offline push, you can refer to the advanced usage of TUIOfflinePushManager+Advance.
//  - If you are using the TUI component and still cannot receive the push, please issue.
// ===================================================================

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 您只需要在您的 AppDelegate 中实现如下代理方法，就可以自定义处理收到的离线推送，包括：
 * 1. 点击导航栏的离线推送后跳转到您自己的聊天页面
 * 2. 点击导航栏的离线推送后，自定义解析并处理
 *
 * You only need to implement the following callback in your AppDelegate to customize the processing of received offline pushes, including:
 * 1. Redirect to your own chat page after clicking offline push in navigation bar
 * 2. After clicking the offline push of the navigation bar, customize the parsing and processing
 */
@protocol TUIOfflinePushProcessProtocol

@optional

/**
 * 点击通知栏离线推送的通知后，跳转到自定义页面
 * 如果要实现跳转到聊天列表，请在您的 AppDelegate 中实现如下方法
 *
 * @note
 *  - TUIOfflinePush 组件默认已经从离线推送中解析出当前推送的 userID 和 groupID
 *  - 如果 groupID 不为空，说明当前点击的是群聊离线消息
 *  - 如果 groupID 为空且 userID 不为空，说明当前点击的是单聊离线消息
 *
 *
 * After clicking the notification pushed offline in the notification bar, redirect to a custom page
 * If you want to redirect to the chat list, please implement the following method in your AppDelegate
 *
 * @note
 * - The TUIOfflinePush component has parsed the currently pushed userID and groupID from the offline push by default
 * - If the groupID is not empty, it means the group chat offline message is currently clicked
 * - If the groupID is empty and the userID is not empty, it means that the current click is a one-to-one chat offline message
 */
- (void)navigateToTUIChatViewController:(NSString *)userID groupID:(NSString *)groupID;

/**
 * 点击通知栏离线推送的通知后，自定义处理离线推送
 * 如果要自定义解析收到的离线推送，请在您的 AppDelegate 中实现如下方法
 *
 * @note
 *  - 如果返回 YES，那么组件将不再执行默认解析逻辑，完全交由业务层自行处理
 *  - 如果返回 NO，组件会继续执行默认解析逻辑，继续回调 - navigateToTUIChatViewController:groupID: 方法
 *
 *
 * After clicking the offline push notification in the notification bar, customize the offline push process
 * If you want to custom parse the received offline push, please implement the following method in your AppDelegate
 *
 * @note
 * - If YES is returned, the component will no longer execute the default parsing logic, and will be completely handled by the business layer
 * - If it returns NO, the component will continue to execute the default resolution logic and continue to call back - navigateToTUIChatViewController:groupID: method
 */
- (BOOL)processTUIOfflinePushNotification:(NSDictionary *)notification;

@end

@interface TUIOfflinePushManager : UIResponder <UIApplicationDelegate>


@end

NS_ASSUME_NONNULL_END
