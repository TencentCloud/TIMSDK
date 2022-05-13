//
//  TUIOfflinePushManager+Advance.h
//  Pods
//
//  Created by harvy on 2022/5/10.
//
// ================ Apple 提供的 APNs 高级用法 ================
// 1. 如果您不需要使用 TUILogin 的登录/登出，但依然想实现离线推送，您只需：
// - 在您的 APP/IM 登录完成后，调用 registerService 方法注册推送
// - 由于 IM 已实现了「退出账号解绑推送」的逻辑，您无需调用 unregisterService 方法
//
// 2. 关于合规
// - TUIOfflinePush 在您未主动调用 registerService 之前，不会其他任何操作，符合相关规定
// - 如果您使用了 TUILogin 的登录登出，TUIOfflinePush 会在内部自动调用 registerService。
//
// 如果 TUIOfflinePush 依然满足不了您的需求，欢迎加入 QQ 群（592465424）反馈。
// ================================================================


// ======================= TPNS 推送通道高级用法 ========================
// 1. 如果您不需要使用 TUILogin 的登录/登出，但依然想实现离线推送，您只需：
// - 在您的 APP/IM 登录完成后，调用 registerService 方法注册推送
// - 在您的 APP/IM 退出登录时，调用 unregisterService 方法取消注册
//
// 2. 关于合规
// - TUIOfflinePush 在您未主动调用 registerService 之前，不会其他任何操作，符合相关规定
// - 如果您使用了 TUILogin 的登录登出，TUIOfflinePush 会在内部自动调用 registerService/unregisterService。
//
// 如果 TUIOfflinePush 依然满足不了您的需求，欢迎加入 QQ 群（592465424）反馈。
// ===================================================================

#import "TUIOfflinePushManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIOfflinePushManager ()

+ (instancetype)shareManager;

#pragma mark - 离线推送高级 API
/**
 * 1. 注册服务
 *
 * @note
 * - 在登录完成之后调用
 * - 如果您使用了其他 TUI 组件，无需再调用该接口
 */
- (void)registerService;

/**
 * 2. 取消注册
 *
 * @note
 * - 在退出登录时调用
 * - 如果您使用了其他的 TUI 组件，无需再调用该接口
 */
- (void)unregisterService;

@end

NS_ASSUME_NONNULL_END
