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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 您只需要在您的 AppDelegate 中实现如下代理方法，就可以自定义处理收到的离线推送，包括：
 * 1. 点击导航栏的离线推送后跳转到您自己的聊天页面
 * 2. 点击导航栏的离线推送后，自定义解析并处理
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
 */
- (void)navigateToTUIChatViewController:(NSString *)userID groupID:(NSString *)groupID;

/**
 * 点击通知栏离线推送的通知后，自定义处理离线推送
 * 如果要自定义解析收到的离线推送，请在您的 AppDelegate 中实现如下方法
 *
 * @param notification 收到的推送的内容
 *
 * @note
 *  - 如果返回 YES，那么组件将不再执行默认解析逻辑，完全交由业务层自行处理
 *  - 如果返回 NO，组件会继续执行默认解析逻辑，继续回调 - navigateToTUIChatViewController:groupID: 方法
 */
- (BOOL)processTUIOfflinePushNotification:(NSDictionary *)notification;

@end

@interface TUIOfflinePushManager : UIResponder <UIApplicationDelegate>


@end

NS_ASSUME_NONNULL_END
