
#import "V2TIMManager.h"
#import "V2TIMManager+Message.h"
/////////////////////////////////////////////////////////////////////////////////
//                         信令
/////////////////////////////////////////////////////////////////////////////////
/// 信令信息
@class V2TIMSignalingInfo;
/// 信令监听
@protocol V2TIMSignalingListener;

@interface V2TIMManager (Signaling)

/**
 *  获取信令信息成功回调
 */
typedef void (^V2TIMSignalingInfoSucc)(V2TIMSignalingInfo * signalInfo);

/**
 *  添加信令监听
 */
- (void)addSignalingListener:(id<V2TIMSignalingListener>)listener
NS_SWIFT_NAME(addSignalingListener(listener:));

/**
 *  移除信令监听
 */
- (void)removeSignalingListener:(id<V2TIMSignalingListener>)listener
NS_SWIFT_NAME(removeSignalingListener(listener:));

/**
 *  邀请某个人
 *
 *  @param invitee   被邀请人用户 ID
 *  @param data      自定义数据
 *  @param timeout   超时时间，单位 s，如果设置为 0，SDK 不会做超时检测，也不会触发 onInvitationTimeout 回调
 *  @return inviteID 邀请 ID，如果邀请失败，返回 nil
 *  
 */
- (NSString*)invite:(NSString *)invitee
               data:(NSString *)data
            timeout:(int)timeout
               succ:(V2TIMSucc)succ
               fail:(V2TIMFail)fail;
/**
 *  邀请群内的某些人
 *
 *  @param groupID     发起邀请所在群组
 *  @param inviteeList 被邀请人列表，inviteeList 必须已经在 groupID 群里，否则邀请无效
 *  @param timeout     超时时间，单位 s，如果设置为 0，SDK 不会做超时检测，也不会触发 onInvitationTimeout 回调
 *  @return inviteID   邀请 ID，如果邀请失败，返回 nil
 */
- (NSString*)inviteInGroup:(NSString *)groupID
               inviteeList:(NSArray *)inviteeList
                      data:(NSString *)data
                   timeout:(int)timeout
                      succ:(V2TIMSucc)succ
                      fail:(V2TIMFail)fail;

/**
 *  邀请方取消邀请
 *
 *  @param inviteID 邀请 ID
 *
 *  @note 如果所有被邀请人都已经处理了当前邀请（包含超时），不能再取消当前邀请。
 */
- (void)cancel:(NSString *)inviteID data:(NSString *)data succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  接收方接受邀请
 *
 *  @note 不能接受不是针对自己的邀请，请在收到 onReceiveNewInvitation 回调的时候先判断 inviteeList 有没有自己，如果没有自己，不能 accept 邀请。
 */
- (void)accept:(NSString *)inviteID data:(NSString *)data succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  接收方拒绝邀请
 *
 *  @note 不能拒绝不是针对自己的邀请，请在收到 onReceiveNewInvitation 回调的时候先判断 inviteeList 有没有自己，如果没有自己，不能 reject 邀请。
 */
- (void)reject:(NSString *)inviteID data:(NSString *)data succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  获取信令信息
 *
 *  每次信令操作在 SDK 内部都会产生一条自定义消息，消息会存本地和漫游，如果您需要解析并展示这条自定义消息，可以调用下面接口。
 */
- (V2TIMSignalingInfo *)getSignallingInfo:(V2TIMMessage *)msg;

/**
 *  添加邀请信令（可以用于群离线推送消息触发的邀请信令）
 *
 *  在离线推送的场景：
 *  对于1V1邀请，被邀请者 APP 如果被杀死，当程序重启后，SDK 可以自动同步到邀请信令信息，不需再单独调用该接口。
 *  对于群邀请，被邀请者 APP 如果被杀死，当程序重启后，SDK 无法自动同步到邀请信令信息，此时请主动调用该接口添加邀请信令信息，此后才能正常调用 accept 或则 reject 等接口。
 *  1V1和群邀请，accept 和 reject 操作都必须在邀请超时时间内处理。
 *
 *  TUIKit 音视频通话离线推送功能基于这个接口实现，详细实现方法请参考文档：[集成音视频通话](https://cloud.tencent.com/document/product/269/39167)
 *
 *  @note 如果添加的信令信息已存在，fail callback 会抛 ERR_SDK_SIGNALING_ALREADY_EXISTS 错误码。
 */
- (void)addInvitedSignaling:(V2TIMSignalingInfo *)signallingInfo succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

@end

@protocol V2TIMSignalingListener <NSObject>
@optional
/// 收到邀请的回调
-(void)onReceiveNewInvitation:(NSString *)inviteID inviter:(NSString *)inviter groupID:(NSString *)groupID inviteeList:(NSArray<NSString *> *)inviteeList data:(NSString *)data;

/// 被邀请者接受邀请
-(void)onInviteeAccepted:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data;

/// 被邀请者拒绝邀请
-(void)onInviteeRejected:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data;

/// 邀请被取消
-(void)onInvitationCancelled:(NSString *)inviteID inviter:(NSString *)inviter data:(NSString *)data;

/// 邀请超时
-(void)onInvitationTimeout:(NSString *)inviteID inviteeList:(NSArray<NSString *> *)inviteeList;

@end


// 操作类型
typedef NS_ENUM(NSInteger,SignalingActionType) {
    SignalingActionType_Invite           = 1,  // 邀请方发起邀请
    SignalingActionType_Cancel_Invite    = 2,  // 邀请方取消邀请
    SignalingActionType_Accept_Invite    = 3,  // 被邀请方接受邀请
    SignalingActionType_Reject_Invite    = 4,  // 被邀请方拒绝邀请
    SignalingActionType_Invite_Timeout   = 5,  // 邀请超时
};

@interface V2TIMSignalingInfo : NSObject
@property(nonatomic,strong) NSString *inviteID;
@property(nonatomic,strong) NSString *groupID;
@property(nonatomic,strong) NSString *inviter;
@property(nonatomic,strong) NSMutableArray *inviteeList;
@property(nonatomic,strong) NSString *data;
@property(nonatomic,assign) uint32_t timeout;
@property(nonatomic,assign) SignalingActionType actionType;
@end

