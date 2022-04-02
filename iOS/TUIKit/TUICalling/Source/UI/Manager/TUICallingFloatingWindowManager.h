//
//  TUICallingFloatingWindowManager.h
//  TUICalling
//
//  Created by noah on 2022/1/13.
//

#import <Foundation/Foundation.h>
#import "TUICallingConstants.h"

@class TUICallingVideoRenderView;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUICallingFloatingWindowType) {
    TUICallingFloatingWindowTypeAudio,          // 语音悬浮窗类型
    TUICallingFloatingWindowTypeVideo,          // 视频悬浮窗类型
};

@protocol TUICallingFloatingWindowManagerDelegate <NSObject>

/// 点击悬浮窗回调
- (void)floatingWindowDidClickView;

/// 关闭悬浮窗回调
- (void)closeFloatingWindow;

@end

@interface TUICallingFloatingWindowManager : NSObject

// 是否显示小悬浮框
@property (nonatomic, assign) BOOL isFloating;

/// 单例
+ (instancetype)shareInstance;

/// 设置回调监听
- (void)setFloatingWindowManagerDelegate:(id<TUICallingFloatingWindowManagerDelegate>)delegagte;

/// 显示小窗口悬浮窗
/// @param callingWindow 源calling窗口
/// @param renderView 渲染视图, 没有则可为空
/// @param completion 结果回调
- (void)showMicroFloatingWindowWithCallingWindow:(nullable UIWindow *)callingWindow VideoRenderView:(TUICallingVideoRenderView *)renderView Completion:(void (^ __nullable)(BOOL finished))completion;

/// 关闭悬浮窗
/// @param completion 结果回调
- (void)closeWindowCompletion:(void (^ __nullable)(BOOL finished))completion;

/// 切换视频悬浮窗到音频悬浮窗
/// @param callingState   拨打状态
- (void)switchToAudioMicroWindowWith:(TUICallingState)callingState;

/// 更新文本悬浮窗-语音、多人通话小窗
/// @param textStr 文本展示（时间、状态）
/// @param callingState   拨打状态
- (void)updateMicroWindowText:(NSString *)textStr callingState:(TUICallingState)callingState;

/// 更新视频悬浮窗-视频通话小窗
/// @param renderView 视频视图（本地、远程）
- (void)updateMicroWindowRenderView:(TUICallingVideoRenderView *)renderView;

@end

NS_ASSUME_NONNULL_END
