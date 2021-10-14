//
//  TUICallingManager.h
//  TUICalling
//
//  Created by noah on 2021/8/28.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TUICallingType) {
    TUICallingTypeAudio, // 语音呼叫
    TUICallingTypeVideo, // 视频呼叫
};

typedef NS_ENUM(NSUInteger, TUICallingRole) {
    TUICallingRoleCall, // 主叫角色
    TTUICallingRoleCalled, // 被叫角色
};

typedef NS_ENUM(NSUInteger, TUICallingEvent) {
    TUICallingEventCallStart = 200, // 通话开始
    TUICallingEventCallEnd = 201, // 通话结束
    TUICallingEventCallSucceed = 300, // 接通成功
    // 接通失败，详细原因见message
    // 1、呼叫忙线，无人接听
    // 2、音视频通道建立失败（TRTC进房错误）
    // 3、其他原因
    TUICallingEventCallFailed = 400,
};

NS_ASSUME_NONNULL_BEGIN

@protocol TUICallingListerner <NSObject>

// 收到呼叫时，先通过此方法询问是否可以唤起被叫UI.
// 返回为true，直接唤起UI。返回为false，内部返回忙线
// 不实现默认直接可以唤起UI
- (BOOL)shouldShowOnCallView NS_SWIFT_NAME(shouldShowOnCallView());

/// 呼叫开始回调。主叫、被叫均会触发；
/// 被叫触发时，会将控制器通过监听回调出来，由接入方决定显示方案。
/// @param userIDs 本次通话用户id（自己除外）
/// @param type 通话类型:视频\音频
/// @param role 通话角色:主叫\被叫
/// @param viewController 提供Calling功能页面给调用方，可以让用户在此基础上自定义
- (void)callStart:(NSArray<NSString *> *)userIDs type:(TUICallingType)type role:(TUICallingRole)role viewController:(UIViewController * _Nullable)viewController NS_SWIFT_NAME(callStart(userIDs:type:role:viewController:));

/// 通话结束回调
/// @param userIDs 本次通话用户id（自己除外）
/// @param type 通话类型:视频\音频
/// @param role 通话角色:主叫\被叫
/// @param totalTime 通话时长
- (void)callEnd:(NSArray<NSString *> *)userIDs type:(TUICallingType)type role:(TUICallingRole)role totalTime:(float)totalTime NS_SWIFT_NAME(callEnd(userIDs:type:role:totalTime:));

/// 通话事件回调
/// @param event 回调事件类型
/// @param type 通话类型:视频\音频
/// @param role 通话角色:主叫\被叫
/// @param message 事件
- (void)onCallEvent:(TUICallingEvent)event type:(TUICallingType)type role:(TUICallingRole)role message:(NSString *)message NS_SWIFT_NAME(onCallEvent(event:type:role:message:));

@end

@interface TUICallingManager : NSObject

+ (instancetype)shareInstance;

/// +----------------------------+
/// +          通话接口           +
/// +----------------------------+
- (void)call:(NSArray<NSString *> *)userIDs type:(TUICallingType)type NS_SWIFT_NAME(call(userIDs:type:));

/// +----------------------------+
/// + 通话相关设置 +
/// +----------------------------+
- (void)setCallingListener:(id<TUICallingListerner>)listener NS_SWIFT_NAME(setCallingListener(listener:));

/// 设置铃声，建议在30s以内
/// @param filePath 音频文件路径
- (void)setCallingBell:(NSString *)filePath NS_SWIFT_NAME(setCallingBell(filePath:));

/// 开启静音模式（默认关）
- (void)enableMuteMode:(BOOL)enable NS_SWIFT_NAME(enableMuteMode(enable:));

/// 打开悬浮窗(默认关)
- (void)enableFloatWindow:(BOOL)enable NS_SWIFT_NAME(enableFloatWindow(enable:));

/**
 * 开启自定义路由（默认关）
 * 打开后，在onStart回调中，会收到对应的ViewController对象，可以自行决定视图展示方式
 */
- (void)enableCustomViewRoute:(BOOL)enable NS_SWIFT_NAME(enableCustomViewRoute(enable:));

@end

NS_ASSUME_NONNULL_END
