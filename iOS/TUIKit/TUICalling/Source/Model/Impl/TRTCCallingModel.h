//
//  TRTCCallingModel.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/2.
//

#import <Foundation/Foundation.h>

extern int SIGNALING_EXTRA_KEY_TIME_OUT;

typedef void(^DismissBlock)(void);

typedef NS_ENUM(NSInteger, CallType) {
    CallType_Unknown,        // 未知类型
    CallType_Audio,          // 语音邀请
    CallType_Video,          // 视频邀请
};

typedef NS_ENUM(NSInteger, CallAction) {
    CallAction_Error = -1,    // 系统错误
    CallAction_Unknown,       // 未知流程
    CallAction_Call,          // 邀请方发起请求
    CallAction_Cancel,        // 邀请方取消请求（只有在被邀请方还没处理的时候才能取消）
    CallAction_Reject,        // 被邀请方拒绝邀请
    CallAction_Timeout,       // 被邀请方超时未响应
    CallAction_End,           // 通话中断
    CallAction_Linebusy,      // 被邀请方正忙
    CallAction_Accept,        // 被邀请方接受邀请
    CallAction_SwitchToAudio,           // 切换到语音通话
    CallAction_AcceptSwitchToAudio,     // 对方接受
    CallAction_RejectSwitchToAudio,     // 对方拒绝
};


@interface CallModel : NSObject<NSCopying>

@property(nonatomic, assign) UInt32 version;      // 版本
@property(nonatomic, assign) CallType calltype;   // call 类型
@property(nonatomic, copy) NSString *groupid;     // 邀请群 ID
@property(nonatomic, copy) NSString *callid;      // call 唯一 ID
@property(nonatomic, assign) UInt32 roomid;       // 房间 ID
@property(nonatomic, assign) CallAction action;   // call 事件
@property(nonatomic, assign) BOOL code;           // 进房错误码
@property(nonatomic, strong) NSMutableArray *invitedList;  // 被邀请者列表
@property(nonatomic, copy) NSString *inviter;     // 邀请者

@end

@interface TRTCCallingUserModel : NSObject<NSCopying>

@property(nonatomic, copy) NSString *userId;  // userId
@property(nonatomic, copy) NSString *name;    // 昵称
@property(nonatomic, copy) NSString *avatar;  // 头像

@end

@interface CallUserModel : TRTCCallingUserModel

@property(nonatomic, assign) BOOL isEnter;           // 是否进房
@property(nonatomic, assign) BOOL isAudioAvaliable;  // 音频是否可用
@property(nonatomic, assign) BOOL isVideoAvaliable;  // 视频是否可用
@property(nonatomic, assign) float volume;           // 声音大小

@end

