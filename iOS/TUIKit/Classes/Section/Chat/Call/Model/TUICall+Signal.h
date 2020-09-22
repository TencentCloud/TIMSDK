//
//  TRTCCall+Signal.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/3.
//

#import "TUICall.h"

@interface TUICall (Signal)

///添加信令监听
- (void)addSignalListener;

///移除信令监听
- (void)removeSignalListener;

///通过信令发起通话邀请
- (NSString *)invite:(NSString *)receiver action:(CallAction)action model:(CallModel *)model;

///收到通话邀请推送通知
- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo;

///检查是否满足自动挂断逻辑
- (void)checkAutoHangUp;
@end

