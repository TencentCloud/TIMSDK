//
//  TRTCCall.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/2.
//

#import <Foundation/Foundation.h>
#import "TRTCCallingModel.h"
#import "TUICallingKit.h"
#import "TRTCCallingDelegate.h"

@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN

typedef void(^CallingActionCallback)(void);
typedef void(^ErrorCallback)(int code, NSString *des);

@interface TRTCCalling : NSObject<TRTCCloudDelegate, V2TIMSignalingListener, V2TIMSimpleMsgListener>

/// 单例对象
+ (TRTCCalling *)shareInstance;

/// 设置TRTCCallingDelegate回调
/// @param delegate 回调实例
- (void)addDelegate:(id<TRTCCallingDelegate>)delegate;

/// 发起1v1通话接口
/// @param userID 被邀请方ID
/// @param type 通话类型：视频/语音
- (void)call:(NSString *)userID
        type:(CallType)type
NS_SWIFT_NAME(call(userID:type:));

/// 发起多人通话
/// @param userIDs 被邀请方ID列表
/// @param type 通话类型:视频/语音
/// @param groupID 群组ID，可选参数
- (void)groupCall:(NSArray *)userIDs
             type:(CallType)type
          groupID:(NSString * _Nullable)groupID
NS_SWIFT_NAME(groupCall(userIDs:type:groupID:));

/// 接受当前通话
- (void)accept;

/// 拒绝当前通话
- (void)reject;

/// 主动挂断通话
- (void)hangup;

/// 主动操作 - 忙线通话（发送忙线信令到主叫者）
- (void)lineBusy;

/// 切换到语音通话
- (void)switchToAudio;

- (int)checkAudioStatus;

/// 开启远程用户视频渲染
- (void)startRemoteView:(NSString *)userId view:(UIView *)view
NS_SWIFT_NAME(startRemoteView(userId:view:));

/// 关闭远程用户视频渲染
- (void)stopRemoteView:(NSString *)userId
NS_SWIFT_NAME(stopRemoteView(userId:));

/// 打开摄像头
- (void)openCamera:(BOOL)frontCamera view:(UIView *)view
NS_SWIFT_NAME(openCamera(frontCamera:view:));

/// 关闭摄像头
- (void)closeCamara;

/// 切换摄像头
- (void)switchCamera:(BOOL)frontCamera;

/// 静音操作
- (void)setMicMute:(BOOL)isMute;

/// 免提操作
- (void)setHandsFree:(BOOL)isHandsFree;

@end

NS_ASSUME_NONNULL_END
