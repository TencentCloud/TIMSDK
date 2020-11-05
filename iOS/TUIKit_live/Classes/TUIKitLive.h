//
//  TUIKitLive.h
//  Pods
//
//  Created by abyyxwang on 2020/9/20.
//

#import "TUILiveRoomAnchorViewController.h"
#import "TUILiveRoomAudienceViewController.h"
#import "TRTCLiveRoom.h"
#import "TUILiveConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUILiveRequestCallback)(int code, NSString * _Nullable message);

@interface TUIKitLive : NSObject

+ (instancetype)shareInstance;

/// 获取当前的sdkAppId
@property (nonatomic, assign, readonly) int sdkAppId;

/// 登录接口，如果已经使用TUIKit（IM UI组件库，本组件TUIKitLive 为直播UI组件库），只需要调用TUIKit的登录接口即可
/// @param callback 回调：code-0成功
- (void)login:(int)sdkAppID
       userID:(NSString *_Nonnull)userID
      userSig:(NSString *_Nonnull)userSig
     callback:(TUILiveRequestCallback _Nullable)callback;

/// 登出接口，如果已经使用TUIKit，只需要调用TUIKit的登出接口即可
/// @param callback 回调：code-0成功
- (void)logout:(TUILiveRequestCallback _Nullable)callback;

@end

NS_ASSUME_NONNULL_END
