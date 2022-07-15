//
//  TRTCCall+Signal.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/3.
//

#import "TRTCCalling.h"

@protocol TRTCCallingDelegate;

@interface TRTCCalling (Signal)

/// 添加信令监听
- (void)addSignalListener;

/// 移除信令监听
- (void)removeSignalListener;

/// 通过信令发起通话邀请
- (NSString *)invite:(NSString *)receiver action:(CallAction)action model:(CallModel *)model cmdInfo:(NSString *)cmdInfo;
- (NSString *)invite:(NSString *)receiver action:(CallAction)action model:(CallModel *)model cmdInfo:(NSString *)cmdInfo userIds:(NSArray<NSString *> *)userIds;

/// 收到通话邀请推送通知
- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo;

/// 检查是否满足自动挂断逻辑
/// @param leaveUser 离开的房间的用户id
- (void)preExitRoom:(NSString *)leaveUser;

/// 直接退房
- (void)exitRoom;

/// 发送 C2C 自定义（信令）消息
- (void)sendInviteAction:(CallAction)action user:(NSString *)user model:(CallModel *)model;

@end

/// TRTCCalling扩展参数
@interface TRTCCalling ()

/// 邀请人 ID，如果邀请失败，为nil
@property (nonatomic, copy) NSString *curCallID;
/// 不存在GroupID的处理
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *curCallIdDic;
/// 群邀请的群 ID
@property (nonatomic, copy) NSString *curGroupID;
/// 被邀请的所有用户 ID
@property (nonatomic, strong) NSMutableArray<NSString *> *calleeUserIDs;
/// 记录当前正在邀请成员的列表(被叫：会拼接上主动呼叫者。。。    主叫：不包含主叫者)
@property (nonatomic, strong) NSMutableArray *curInvitingList;
/// 记录当前已经进入房间成功的成员列表
@property (nonatomic, strong) NSMutableArray *curRoomList;
/// 对自己发起通话邀请的人
@property (nonatomic, copy) NSString *curSponsorForMe;
/// 音视频邀请都需要展示消息，这个参数最好做成可配置，如果设置为 false 信令邀请就会产生 IM 消息
@property (nonatomic, assign) BOOL onlineUserOnly;
/// 用于区分主叫、被叫  默认是被叫   「被叫」：YES   「主叫」：NO
@property (nonatomic, assign) BOOL isBeingCalled;
/// 记录类型  Unknown、Audio、Video  （ 未知类型  、语音邀请  、视频邀请）
@property (nonatomic, assign) CallType curType;
/// 记录当前的房间ID
@property (nonatomic, assign) UInt32 curRoomID;
/// 记录「自己」是否已经进房成功 （进房成功、退房成功后 赋值）
@property (nonatomic, assign) BOOL isInRoom;
/// 记录「自己」是否正在通话中…
@property (nonatomic, assign) BOOL isOnCalling;
/// 是否为前置摄像头
@property (nonatomic, assign) BOOL isFrontCamera;
/// 通话要计算通话时长,  记录一下
@property (nonatomic, assign) UInt64 startCallTS;
/// 多端登录增加字段:用于标记当前是否是自己发给自己的请求(多端触发),以及自己是否处理了该请求.
@property (nonatomic, assign) BOOL isProcessedBySelf;

@property (nonatomic, strong) CallModel *curLastModel;
@property (nonatomic, strong) NSString *callID;
@property (nonatomic, copy) NSString *switchToAudioCallID;
@property (nonatomic, copy) NSString *currentCallingUserID;

@property (nonatomic, weak) id<TRTCCallingDelegate> delegate;

- (void)enterRoom;

- (void)quitRoom;

@end
