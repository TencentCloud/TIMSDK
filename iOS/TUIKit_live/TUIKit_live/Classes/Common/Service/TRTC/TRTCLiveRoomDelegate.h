//
//  TRTCLiveRoomDelegate.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/8.
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef TRTCLiveRoomDelegate_h
#define TRTCLiveRoomDelegate_h

#import <Foundation/Foundation.h>
#import "TRTCLiveRoomDef.h"
NS_ASSUME_NONNULL_BEGIN

@class TRTCLiveRoom;
@protocol TRTCLiveRoomDelegate <NSObject>

@optional
/// 日志回调
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
          onDebugLog:(NSString *)log
NS_SWIFT_NAME(trtcLiveRoom(_:onDebugLog:));

/// 出错回调
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
             onError:(NSInteger)code
             message:(NSString  *)message
NS_SWIFT_NAME(trtcLiveRoom(_:onError:message:));
/// 出错回调
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
           onWarning:(NSInteger)code
             message:(NSString *)message
NS_SWIFT_NAME(trtcLiveRoom(_:onWarning:message:));

/// 房间销毁回调
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
       onRoomDestroy:(NSString *)roomID
NS_SWIFT_NAME(trtcLiveRoom(_:onRoomDestroy:));

/// 直播房间信息变更回调
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
    onRoomInfoChange:(TRTCLiveRoomInfo *)info
NS_SWIFT_NAME(trtcLiveRoom(_:onRoomInfoChange:));

/// 主播进房回调
/// - Note: 主播包括房间大主播、连麦观众和跨房PK主播
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
       onAnchorEnter:(NSString *)userID
NS_SWIFT_NAME(trtcLiveRoom(_:onAnchorEnter:));

/// 主播离开回调
/// - Note: 主播包括房间大主播、连麦观众和跨房PK主播
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
        onAnchorExit:(NSString *)userID
NS_SWIFT_NAME(trtcLiveRoom(_:onAnchorExit:));

/// 观众进房回调
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
     onAudienceEnter:(TRTCLiveUserInfo *)user
NS_SWIFT_NAME(trtcLiveRoom(_:onAudienceEnter:));

/// 观众离开回调
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
      onAudienceExit:(TRTCLiveUserInfo *)user
NS_SWIFT_NAME(trtcLiveRoom(_:onAudienceExit:));

/// 主播收到观众的连麦申请
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
 onRequestJoinAnchor:(TRTCLiveUserInfo *)user
             reason:(NSString * _Nullable)reason
NS_SWIFT_NAME(trtcLiveRoom(_:onRequestJoinAnchor:reason:));

/// 主播端收到观众的取消连麦申请回调
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
  onCancelJoinAnchor:(TRTCLiveUserInfo *)user
              reason:(NSString *)reason
NS_SWIFT_NAME(trtcLiveRoom(_:onCancelJoinAnchor:reason:));

/// 观众请求上麦超时
/// @param userID 超时观众ID
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
audienceRequestJoinAnchorTimeout:(NSString *)userID
NS_SWIFT_NAME(trtcLiveRoom(_:audienceRequestJoinAnchorTimeout:));

/// 观众收到主播发来的下麦通知
- (void)trtcLiveRoomOnKickoutJoinAnchor:(TRTCLiveRoom *)liveRoom
NS_SWIFT_NAME(trtcLiveRoomOnKickoutJoinAnchor(_:));

/// 主播收到其他主播的跨房PK申请
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
     onRequestRoomPK:(TRTCLiveUserInfo *)user
NS_SWIFT_NAME(trtcLiveRoom(_:onRequestRoomPK:));

/// 其他主播申请PK房间超时
/// @param userID 超时主播ID
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
anchorRequestRoomPKTimeout:(NSString *)userID
NS_SWIFT_NAME(trtcLiveRoom(_:anchorRequestJoinAnchorTimeout:));

/// 主播端收到其他主播的取消跨房PK申请
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
     onCancelRoomPK:(TRTCLiveUserInfo *)user
NS_SWIFT_NAME(trtcLiveRoom(_:onCancelRoomPK:));

/// 主播收到PK中对方主播结束PK的通知
- (void)trtcLiveRoomOnQuitRoomPK:(TRTCLiveRoom *)liveRoom
NS_SWIFT_NAME(trtcLiveRoomOnQuitRoomPK(_:));

/// 房间成员收到群发的文本消息
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
   onRecvRoomTextMsg:(NSString *)message
            fromUser:(TRTCLiveUserInfo *)user
NS_SWIFT_NAME(trtcLiveRoom(_:onRecvRoomTextMsg:fromUser:));

/// 房间成员收到群发的自定义消息
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom
onRecvRoomCustomMsgWithCommand:(NSString *)command
             message:(NSString *)message
            fromUser:(TRTCLiveUserInfo *)user
NS_SWIFT_NAME(trtcLiveRoom(_:onRecvRoomCustomMsg:message:fromUser:));





@end

NS_ASSUME_NONNULL_END

#endif /* TRTCLiveRoomDelegate_h */
