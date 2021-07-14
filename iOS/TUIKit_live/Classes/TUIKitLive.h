//
//  TUIKitLive.h
//  Pods
//
//  Created by abyyxwang on 2020/9/20.
//

#import "TUILiveRoomAnchorViewController.h"
#import "TUILiveRoomAudienceViewController.h"
#import "TRTCLiveRoom.h"
#import "TXLiveBase.h"
#import "TUILiveConfig.h"
#import "TUICallManager.h"
#import "TUIKit.h"
#import "TLiveHeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUILiveRequestCallback)(int code, NSString * _Nullable message);

@interface TUIKitLive : NSObject

+ (instancetype)shareInstance;

/// 监听群直播创建、销毁状态
@property (nonatomic, weak) id<TUILiveRoomAnchorDelegate> groupLiveDelegate;

/// 获取当前的sdkAppId
@property (nonatomic, assign, readonly) int sdkAppId;

/// 启用视频通话 YES：启用  NO：关闭 默认：YES
@property(nonatomic, assign) BOOL enableVideoCall;

/// 启用语音通话 YES：启用  NO：关闭 默认：YES
@property(nonatomic, assign) BOOL enableAudioCall;

/// 启用群直播入口 YES：启用 NO：关闭 默认：YES
@property(nonatomic, assign) BOOL enableGroupLiveEntry;


/// 登录接口，如果已经使用TUIKit（IM UI组件库，本组件TUIKitLive 为直播UI组件库），只需要调用TUIKit的登录接口即可
/// @param callback 回调：code-0成功
- (void)login:(int)sdkAppID
       userID:(NSString *_Nonnull)userID
      userSig:(NSString *_Nonnull)userSig
     callback:(TUILiveRequestCallback _Nullable)callback;

/// 登出接口，如果已经使用TUIKit，只需要调用TUIKit的登出接口即可
/// @param callback 回调：code-0成功
- (void)logout:(TUILiveRequestCallback _Nullable)callback;

/// 收到音视频通话邀请推送
- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo;
@end

NS_ASSUME_NONNULL_END
