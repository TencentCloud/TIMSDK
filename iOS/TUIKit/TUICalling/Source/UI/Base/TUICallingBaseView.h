//
//  TUICallingBaseView.h
//  TUICalling
//
//  Created by noah on 2021/9/3.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>
#import <TUICore/UIView+TUIToast.h>
#import "TRTCCalling.h"
#import "TUICommonUtil.h"
#import "UIColor+TUIHex.h"
#import "CallingLocalized.h"
#import "TUICallingVideoRenderView.h"
#import "TUIInvitedContainerView.h"
#import "TUICallingControlButton.h"
#import "TUICallingConstants.h"
#import "TUICallingFloatingWindowManager.h"
#import "TUIDefine.h"

@class TUIInvitedActionProtocal;
@class CallUserModel;

#define kControlBtnSize CGSizeMake(100, 92)
#define kBtnLargeSize CGSizeMake(64, 64)
#define kBtnSmallSize CGSizeMake(52, 52)

NS_ASSUME_NONNULL_BEGIN

@interface TUICallingBaseView : UIView

@property (nonatomic, weak) id<TUIInvitedActionProtocal> actionDelegate;

/// 是否是视频聊天
@property (nonatomic, assign) BOOL isVideo;
/// 是否是被呼叫方
@property (nonatomic, assign) BOOL isCallee;
/// 是否是自定义视图
@property (nonatomic, assign) BOOL disableCustomView;
/// 开启悬浮窗按钮
@property (nonatomic, strong) UIButton *floatingWindowBtn;

/// 展示Calling视图，默认Calling页面展示方式，用户自定义路由不会调用此方法。
/// @param enable 是否允许展示悬浮窗
- (void)showCalingViewEnableFloatWindow:(BOOL)enable;
- (void)disMissCalingView;

- (void)configViewWithUserList:(NSArray<CallUserModel *> *)userList sponsor:(CallUserModel *)sponsor;

/// 数据相关处理
- (void)enterUser:(CallUserModel *)user;

- (void)leaveUser:(CallUserModel *)user;

- (void)updateUser:(CallUserModel *)user animated:(BOOL)animated;

- (void)updateUserVolume:(CallUserModel *)user;

- (CallUserModel *)getUserById:(NSString *)userId;

// 语音通话独有（视频切换语音）
- (void)switchToAudio;

// 被叫接听
- (void)acceptCalling;

// 被叫拒绝
- (void)refuseCalling;

// 刷新接通时间
- (void)setCallingTimeStr:(NSString *)timeStr;

/// 处理悬浮窗播放 -  显示小窗口悬浮窗
/// @param callingState  通话目前状态
- (void)showMicroFloatingWindow:(TUICallingState)callingState;

/// 处理悬浮窗播放 -  显示小窗口悬浮窗
/// @param renderView  视频窗口
/// @param callingState  通话目前状态
/// @param completion  结果回调
- (void)showMicroFloatingWindowWithVideoRenderView:(nullable TUICallingVideoRenderView *)renderView callingState:(TUICallingState)callingState completion:(void (^ __nullable)(BOOL finished))completion;

/// 开启悬浮窗的按钮事件，子类重写
/// @param sender UIButton
- (void)floatingWindowTouchEvent:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
