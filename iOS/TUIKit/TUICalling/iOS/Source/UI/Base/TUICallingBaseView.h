//
//  TUICallingBaseView.h
//  TUICalling
//
//  Created by noah on 2021/9/3.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import <TUICore/UIView+TUIToast.h>
#import "TRTCCalling.h"
#import "TUICommonUtil.h"
#import "UIColor+TUIHex.h"
#import "CallingLocalized.h"
#import "TUICallingVideoRenderView.h"
#import "TUIInvitedContainerView.h"
#import "TUICallingControlButton.h"

@class TUIInvitedActionProtocal;

@class CallUserModel;

#define kControlBtnSize CGSizeMake(100, 94)
#define kBtnLargeSize CGSizeMake(64, 64)
#define kBtnSmallSize CGSizeMake(52, 52)

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TUICallingState) {
    TUICallingStateDailing = 0, // 正在拨打中（主动）
    TUICallingStateOnInvitee,   // 等待接听状态（被动）
    TUICallingStateCalling      // 正在通话中状态(已接听)
};

@interface TUICallingBaseView : UIView

/// 是否是视频聊天
@property (nonatomic, assign) BOOL isVideo;

/// 是否是被呼叫方
@property (nonatomic, assign) BOOL isCallee;

/// 是否是自定义视图
@property (nonatomic, assign) BOOL disableCustomView;

@property (nonatomic, weak) id<TUIInvitedActionProtocal> actionDelegate;

/// 页面相关处理
- (void)show;

- (void)disMiss;

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

@end

NS_ASSUME_NONNULL_END
