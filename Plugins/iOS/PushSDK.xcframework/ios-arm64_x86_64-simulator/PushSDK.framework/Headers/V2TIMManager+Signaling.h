
#import "V2TIMManager.h"
#import "V2TIMManager+Message.h"

/////////////////////////////////////////////////////////////////////////////////
//                         信令
/////////////////////////////////////////////////////////////////////////////////
/// 信令信息
@class V2TIMSignalingInfo;
/// 信令监听
V2TIM_EXPORT @protocol V2TIMSignalingListener;

V2TIM_EXPORT @interface V2TIMManager (Signaling)

/**
 *  获取信令信息成功回调
 */
typedef void (^V2TIMSignalingInfoSucc)(V2TIMSignalingInfo * signalInfo);

/**
 *  添加信令监听
 */
- (void)addSignalingListener:(id<V2TIMSignalingListener>)listener NS_SWIFT_NAME(addSignalingListener(listener:));

/**
 *  移除信令监听
 */
- (void)removeSignalingListener:(id<V2TIMSignalingListener>)listener NS_SWIFT_NAME(removeSignalingListener(listener:));

/**
 *  邀请某个人
 *
 *  @param invitee   被邀请人用户 ID
 *  @param data      自定义数据
 *  @param timeout   超时时间，单位 s，如果设置为 0，SDK 不会做超时检测，也不会触发 onInvitationTimeout 回调
 *  @param onlineUserOnly 是否只有在线用户才能收到邀请，如果设置为 YES，只有在线用户才能收到，并且 invite 操作也不会产生历史消息（针对该次 invite 的后续 cancel、accept、reject、timeout 操作也同样不会产生历史消息）。
 *  @param offlinePushInfo 苹果 APNS 离线推送时携带的标题和声音，其中 desc 为必填字段，推送的时候会默认展示 desc 信息。
 *  @return inviteID 邀请 ID，如果邀请失败，返回 nil
 *  
 */
- (NSString* _Nullable)invite:(NSString *)invitee
               data:(NSString * _Nullable)data
     onlineUserOnly:(BOOL)onlineUserOnly
    offlinePushInfo:(V2TIMOfflinePushInfo * _Nullable)offlinePushInfo
            timeout:(int)timeout
               succ:(_Nullable V2TIMSucc)succ
               fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(invite(invitee:data:onlineUserOnly:offlinePushInfo:timeout:succ:fail:));
/**
 *  邀请群内的某些人
 *
 *  @param groupID     发起邀请所在群组
 *  @param inviteeList 被邀请人列表，inviteeList 必须已经在 groupID 群里，否则邀请无效
 *  @param timeout     超时时间，单位 s，如果设置为 0，SDK 不会做超时检测，也不会触发 onInvitationTimeout 回调
 *  @param onlineUserOnly 是否只有在线用户才能收到邀请，如果设置为 YES，只有在线用户才能收到，并且 invite 操作也不会产生历史消息（针对该次 invite 的后续 cancel、accept、reject、timeout 操作也同样不会产生历史消息）。
 *  @return inviteID   邀请 ID，如果邀请失败，返回 nil
 *
 *  @note 群邀请暂不支持离线推送，如果您需要离线推送，可以针对被邀请的用户单独发离线推送自定义消息。
 */
- (NSString* _Nullable)inviteInGroup:(NSString *)groupID
               inviteeList:(NSArray *)inviteeList
                      data:(NSString * _Nullable)data
            onlineUserOnly:(BOOL)onlineUserOnly
                   timeout:(int)timeout
                      succ:(_Nullable V2TIMSucc)succ
                      fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(inviteInGroup(groupID:inviteeList:data:onlineUserOnly:timeout:succ:fail:));

/**
 *  邀请方取消邀请
 *
 *  @param inviteID 邀请 ID
 *
 *  @note 如果所有被邀请人都已经处理了当前邀请（包含超时），不能再取消当前邀请。
 */
- (void)cancel:(NSString *)inviteID data:(NSString * _Nullable)data succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(cancel(inviteID:data:succ:fail:));

/**
 *  接收方接受邀请
 *
 *  @note 不能接受不是针对自己的邀请，请在收到 onReceiveNewInvitation 回调的时候先判断 inviteeList 有没有自己，如果没有自己，不能 accept 邀请。
 */
- (void)accept:(NSString *)inviteID data:(NSString * _Nullable)data succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(accept(inviteID:data:succ:fail:));

/**
 *  接收方拒绝邀请
 *
 *  @note 不能拒绝不是针对自己的邀请，请在收到 onReceiveNewInvitation 回调的时候先判断 inviteeList 有没有自己，如果没有自己，不能 reject 邀请。
 */
- (void)reject:(NSString *)inviteID data:(NSString * _Nullable)data succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(reject(inviteID:data:succ:fail:));

/**
 *  获取信令信息
 *
 *  如果 invite 设置 onlineUserOnly 为 NO，每次信令操作（包括 invite、cancel、accept、reject、timeout）都会产生一条自定义消息，该消息会通过 V2TIMAdvancedMsgListener -> onRecvNewMessage 抛给用户，用户也可以通过历史消息拉取，如果需要根据信令信息做自定义化文本展示，可以调用下面接口获取信令信息。
 *
 *  @param msg 消息对象
 *  @return V2TIMSignalingInfo 信令信息，如果为 nil，则 msg 不是一条信令消息。
 */
- (V2TIMSignalingInfo * _Nullable)getSignallingInfo:(V2TIMMessage *)msg NS_SWIFT_NAME(getSignallingInfo(msg:));

/**
 *  添加邀请信令
 *
 *  主要用于邀请者在被邀请者离线期间，发送了群聊邀请，被邀请者上线后将该信令同步给 SDK，从而正常使用信令功能。
 *
 *  当被邀请者点击离线推送提示，拉起 App 时：
 *  1. 如果被邀请者离线期间，邀请者发送的是 1V1 信令，SDK 可以自动同步邀请信令。邀请未超时，回调 onReceiveNewInvitation。
 *  2. 如果被邀请者离线期间，邀请者发送的是群聊信令，不同 SDK 版本表现如下：
 *  - 6.7 以前的版本：
 *  SDK 无法自动同步邀请信令（信令本质上就是一条自定义消息，群离线消息在程序启动后无法自动同步）。
 *  如果被邀请者需要处理该邀请信令，可以让邀请者在发起信令时，向每个被邀请者额外发送一条 C2C 离线推送消息，消息携带 V2TIMSignalingInfo 信息。
 *  被邀请者收到离线推送时通过 addInvitedSignaling 将 V2TIMSignalingInfo 信息告知 SDK。
 *  - 6.7 及以后的版本：
 *  SDK 会自动同步最近 30 秒的消息。如果其中包含了未超时的邀请信令，回调 onReceiveNewInvitation。您无需再调用本接口同步邀请信令。
 *
 *  @note 如果添加的信令信息已存在，fail callback 会抛 ERR_SDK_SIGNALING_ALREADY_EXISTS 错误码。
 */
- (void)addInvitedSignaling:(V2TIMSignalingInfo *)signallingInfo succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(addInvitedSignaling(signallingInfo:succ:fail:));

/**
 *  修改邀请信令（6.7 及其以上版本支持）
 *
 *  @note 仅支持修改邀请信令的自定义字段 data。只有在线用户才能收到的邀请信令不能被修改。
 */
- (void)modifyInvitation:(NSString *)inviteID data:(NSString *)data succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(modifyInvitation(inviteID:data:succ:fail:));

@end

V2TIM_EXPORT @protocol V2TIMSignalingListener <NSObject>
@optional
/// 收到邀请的回调
-(void)onReceiveNewInvitation:(NSString *)inviteID inviter:(NSString * _Nullable)inviter groupID:(NSString * _Nullable)groupID inviteeList:(NSArray<NSString *> *)inviteeList data:(NSString * _Nullable)data NS_SWIFT_NAME(onReceiveNewInvitation(inviteID:inviter:groupID:inviteeList:data:));

/// 被邀请者接受邀请
-(void)onInviteeAccepted:(NSString *)inviteID invitee:(NSString * _Nullable)invitee data:(NSString * _Nullable)data NS_SWIFT_NAME(onInviteeAccepted(inviteID:invitee:data:));

/// 被邀请者拒绝邀请
-(void)onInviteeRejected:(NSString *)inviteID invitee:(NSString * _Nullable)invitee data:(NSString * _Nullable)data NS_SWIFT_NAME(onInviteeRejected(inviteID:invitee:data:));

/// 邀请被取消
-(void)onInvitationCancelled:(NSString *)inviteID inviter:(NSString * _Nullable)inviter data:(NSString * _Nullable)data NS_SWIFT_NAME(onInvitationCancelled(inviteID:inviter:data:));

/// 邀请超时
-(void)onInvitationTimeout:(NSString *)inviteID inviteeList:(NSArray<NSString *> *)inviteeList NS_SWIFT_NAME(onInvitationTimeout(inviteID:inviteeList:));

/// 邀请被修改（6.7 及其以上版本支持）
-(void)onInvitationModified:(NSString *)inviteID data:(NSString * _Nullable)data NS_SWIFT_NAME(onInvitationModified(inviteID:data:));

@end


// 操作类型
typedef NS_ENUM(NSInteger,SignalingActionType) {
    SignalingActionType_Invite           = 1,  // 邀请方发起邀请
    SignalingActionType_Cancel_Invite    = 2,  // 邀请方取消邀请
    SignalingActionType_Accept_Invite    = 3,  // 被邀请方接受邀请
    SignalingActionType_Reject_Invite    = 4,  // 被邀请方拒绝邀请
    SignalingActionType_Invite_Timeout   = 5,  // 邀请超时
};

V2TIM_EXPORT @interface V2TIMSignalingInfo : NSObject
@property(nonatomic,strong,nullable) NSString *inviteID;
@property(nonatomic,strong,nullable) NSString *groupID;
@property(nonatomic,strong,nullable) NSString *inviter;
@property(nonatomic,strong) NSMutableArray *inviteeList;
@property(nonatomic,strong,nullable) NSString *data;
@property(nonatomic,assign) uint32_t timeout;
@property(nonatomic,assign) SignalingActionType actionType;
@end
