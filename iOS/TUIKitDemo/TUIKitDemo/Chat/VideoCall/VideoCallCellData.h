//
//  VideoCallCellData.h
//  TUIKitDemo
//
//  Created by xcoderliu on 9/29/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TUITextMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

#define VIDEOCALL_TIMEOUT 20 //超时时间

typedef NS_ENUM(UInt32, videoCallState)
{
    VIDEOCALL_REQUESTING = 0,         //请求发起 - 不展示UI                                            状态 action
    VIDEOCALL_USER_CANCEL,            //用户取消 (视频发起端：用户取消 接收端： 未接听)                     结果 result
    VIDEOCALL_USER_REJECT,            //用户拒绝 (视频发起端：对方已拒绝 接收端： 未接听)                   结果 result
    VIDEOCALL_USER_NO_RESP,           //用户未应答 (视频发起端：对方未应答 接收端： 未接听)                  结果 result
    VIDEOCALL_USER_CONNECTTING,       //用户同意并进行连接 (视频发起端：enterRoom 接收端：enterRoom)       状态 action
    VIDEOCALL_USER_HANUGUP,           //用户挂断 (视频发起端：已结束 接收端： 已结束)                      结果 result
    VIDEOCALL_USER_ONCALLING          //用户通话中 (视频发起端：对方通话中 接收端： 未接听)                 结果 result
};

@interface VideoCallCellData : TUITextMessageCellData
@property (nonatomic, strong) NSString* requestUser;
@property (nonatomic, assign) UInt32 roomID;
@property (nonatomic, assign) videoCallState videoState;
@property (nonatomic, assign) UInt32 duration;
@property (nonatomic, assign) BOOL isSelf;
- (BOOL)isOutGoingResult;
@end

NS_ASSUME_NONNULL_END
