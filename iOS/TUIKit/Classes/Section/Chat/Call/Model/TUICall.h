//
//  TRTCCall.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/2.
//

#import <Foundation/Foundation.h>
#import "TUICallModel.h"
#import "TRTCCloud.h"
@import ImSDK;
@protocol TUICallDelegate;

@interface TUICall : NSObject<TRTCCloudDelegate,V2TIMSignalingListener>

@property(nonatomic,weak) id<TUICallDelegate> delegate;

+(TUICall *)shareInstance;

/// 通话邀请，如果是 C2C 邀请，userIDs 传被邀请者 userID，groupID 传 nil
- (void)call:(NSArray *)userIDs groupID:(NSString *)groupID type:(CallType)type;

/// 接受当前通话
- (void)accept;

/// 拒绝当前通话
- (void)reject;

/// 主动挂断通话
- (void)hangup;

@end

@protocol TUICallDelegate <NSObject>
@optional
/// sdk内部发生了错误 | sdk error
/// - Parameters:
///   - code: 错误码
///   - msg: 错误消息
-(void)onError:(int)code msg:(NSString *)msg;
   
/// 被邀请通话回调 | invitee callback
/// - Parameter userIds: 邀请列表 (invited list)
-(void)onInvited:(NSString *)sponsor userIds:(NSArray *)userIds isFromGroup:(BOOL)isFromGroup callType:(CallType)callType;
   
/// 群聊更新邀请列表回调 | update current inviteeList in group calling
/// - Parameter userIds: 邀请列表 | inviteeList
-(void)onGroupCallInviteeListUpdate:(NSArray *)userIds;
   
/// 进入通话回调 | user enter room callback
/// - Parameter uid: userid
-(void)onUserEnter:(NSString *)uid;
   
/// 离开通话回调 | user leave room callback
/// - Parameter uid: userid
-(void)onUserLeave:(NSString *)uid;
   
/// 用户是否开启音频上行回调 | is user audio available callback
/// - Parameters:
///   - uid: 用户ID | userID
///   - available: 是否有效 | available
-(void)onUserAudioAvailable:(NSString *)uid available:(BOOL)available;
   
/// 用户是否开启视频上行回调 | is user video available callback
/// - Parameters:
///   - uid: 用户ID | userID
///   - available: 是否有效 | available
-(void)onUserVideoAvailable:(NSString *)uid available:(BOOL)available;
   
/// 用户音量回调
/// - Parameter uid: 用户ID | userID
/// - Parameter volume: 说话者的音量, 取值范围0 - 100
-(void)onUserVoiceVolume:(NSString *)uid volume:(UInt32)volume;
   
/// 拒绝通话回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// reject callback only worked for Sponsor, others should use onUserEnter)
/// - Parameter uid: userid
-(void)onReject:(NSString *)uid;
   
/// 无回应回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// no response callback only worked for Sponsor, others should use onUserEnter)
/// - Parameter uid: userid
-(void)onNoResp:(NSString *)uid;
   
/// 通话占线回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// linebusy callback only worked for Sponsor, others should use onUserEnter
/// - Parameter uid: userid
-(void)onLineBusy:(NSString *)uid;
   
// invitee callback

/// 当前通话被取消回调 | current call had been canceled callback
-(void)onCallingCancel:(NSString *)uid;
   
/// 通话超时的回调 | timeout callback
-(void)onCallingTimeOut;
   
/// 通话结束 | end callback
-(void)onCallEnd;

@end

///TUICall 扩展参数
@interface TUICall()
@property(nonatomic,copy) NSString *curCallID;
@property(nonatomic,strong) NSMutableArray *curInvitingList;
@property(nonatomic,strong) NSMutableArray *curRoomList;
@property(nonatomic,strong) NSMutableArray *curRespList;
@property(nonatomic,strong) CallModel *curLastModel;
@property(nonatomic,copy) NSString *curGroupID;        //群邀请的群 ID
@property(nonatomic,copy) NSString *curSponsorForMe;   //对自己发起通话邀请的人
@property(nonatomic,assign) CallType curType;
@property(nonatomic,assign) UInt32 curRoomID;
@property(nonatomic,assign) BOOL isMicMute;
@property(nonatomic,assign) BOOL isHandsFreeOn;
@property(nonatomic,assign) BOOL isInRoom;
@property(nonatomic,assign) BOOL isOnCalling;
@property(nonatomic,assign) BOOL isFrontCamera;
@property(nonatomic,assign) UInt64 startCallTS;
@property(nonatomic,strong) NSString *callID;
@end
