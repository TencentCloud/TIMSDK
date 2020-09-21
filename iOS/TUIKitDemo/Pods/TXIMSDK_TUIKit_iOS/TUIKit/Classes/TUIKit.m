#import "TUIKit.h"
#import "THeader.h"

@import ImSDK;

@interface TUIKit () <V2TIMSDKListener,V2TIMAdvancedMsgListener,V2TIMConversationListener,V2TIMGroupListener,V2TIMFriendshipListener>
@end

@implementation TUIKit
{
    UInt32    _sdkAppid;
    NSString  *_userID;
    NSString  *_userSig;
}

+ (instancetype)sharedInstance
{
    static TUIKit *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TUIKit alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _config = [TUIKitConfig defaultConfig];
        [self createCachePath];
    }
    return self;
}

- (void)createCachePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:TUIKit_Image_Path]){
        [fileManager createDirectoryAtPath:TUIKit_Image_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_Video_Path]){
        [fileManager createDirectoryAtPath:TUIKit_Video_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_Voice_Path]){
        [fileManager createDirectoryAtPath:TUIKit_Voice_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_File_Path]){
        [fileManager createDirectoryAtPath:TUIKit_File_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_DB_Path]){
        [fileManager createDirectoryAtPath:TUIKit_DB_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)setupWithAppId:(UInt32)sdkAppId
{
    _sdkAppid = sdkAppId;
    V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];
    config.logLevel = V2TIM_LOG_INFO;
    [[V2TIMManager sharedInstance] initSDK:(int)sdkAppId config:config listener:self];
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
    [[V2TIMManager sharedInstance] setConversationListener:self];
    [[V2TIMManager sharedInstance] setGroupListener:self];
    [[V2TIMManager sharedInstance] setFriendListener:self];
    [[TUICallManager shareInstance] initCall];
}

- (void)setupWithAppId:(UInt32)sdkAppId logLevel:(V2TIMLogLevel)logLevel
{
    _sdkAppid = sdkAppId;
    V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];
    config.logLevel = logLevel;
    [[V2TIMManager sharedInstance] initSDK:(int)sdkAppId config:config listener:self];
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
    [[V2TIMManager sharedInstance] setConversationListener:self];
    [[V2TIMManager sharedInstance] setGroupListener:self];
    [[V2TIMManager sharedInstance] setFriendListener:self];
    [[TUICallManager shareInstance] initCall];
}

- (void)login:(NSString *)userID userSig:(NSString *)sig succ:(TSucc)succ fail:(TFail)fail
{
    _userID = userID;
    _userSig = sig;
    [[V2TIMManager sharedInstance] login:_userID userSig:_userSig succ:^{
        succ();
    } fail:^(int code, NSString *msg) {
        fail(code,msg);
    }];
}

- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo {
    [[TUICallManager shareInstance] onReceiveGroupCallAPNs:signalingInfo];
}

- (UInt32)sdkAppId {
    return _sdkAppid;
}

- (NSString *)userID {
    return _userID;
}

- (NSString *)userSig {
    return _userSig;
}

#pragma mark  V2TIMSDKListener
- (void)onConnecting {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMConnListener object:[NSNumber numberWithInt:TNet_Status_Connecting]];
}

- (void)onConnectSuccess {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMConnListener object:[NSNumber numberWithInt:TNet_Status_Succ]];
}

- (void)onConnectFailed:(int)code err:(NSString*)err {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMConnListener object:[NSNumber numberWithInt:TNet_Status_ConnFailed]];
}

- (void)onKickedOffline {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMUserStatusListener object:[NSNumber numberWithInt:TUser_Status_ForceOffline]];
}

- (void)onUserSigExpired {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMUserStatusListener object:[NSNumber numberWithInt:TUser_Status_SigExpired]];
}

- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onSelfInfoUpdated object:Info];
}

#pragma mark V2TIMConversationListener

- (void)onSyncServerStart {
    // onSyncServerStart
}


- (void)onSyncServerFinish {
    // onSyncServerStart
}


- (void)onSyncServerFailed {
    // onSyncServerFailed
}

- (void)onNewConversation:(NSArray<V2TIMConversation*> *) conversationList {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMRefreshListener_Add object:conversationList];
}

- (void)onConversationChanged:(NSArray<V2TIMConversation*> *) conversationList {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMRefreshListener_Changed object:conversationList];
}

#pragma mark V2TIMAdvancedMsgListener

- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMMessageListener object:msg];
}

- (void)onRecvC2CReadReceipt:(NSArray<V2TIMMessageReceipt *> *)receiptList {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onRecvMessageReceipts object:receiptList];
}

- (void)onRecvMessageRevoked:(NSString *)msgID {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMMessageRevokeListener object:msgID];
}

#pragma mark V2TIMGroupListener

- (void)onMemberEnter:(NSString *)groupID memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    // onMemberEnter
}

- (void)onMemberLeave:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member {
    // onMemberLeave
}

- (void)onMemberInvited:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    // onMemberInvited
}

- (void)onMemberKicked:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    for (V2TIMGroupMemberInfo *info in memberList) {
        if ([info.userID isEqualToString:loginUser]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onKickOffFromGroup object:groupID];
            return;
        }
    }
}

- (void)onMemberInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupMemberChangeInfo *> *)changeInfoList {
    // onMemberInfoChanged
}


- (void)onGroupCreated:(NSString *)groupID {
    // onGroupCreated
}

- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onGroupDismissed object:groupID];
}

- (void)onGroupRecycled:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onGroupRecycled object:groupID];
}

- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupChangeInfo *> *)changeInfoList {
    // onGroupInfoChanged
}

- (void)onGroupAttributeChanged:(NSString *)groupID attributes:(NSMutableDictionary<NSString *,NSString *> *)attributes {
    // onGroupAttributeChanged
}

- (void)onReceiveJoinApplication:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member opReason:(NSString *)opReason {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onReceiveJoinApplication object:groupID];
}

- (void)onApplicationProcessed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser opResult:(BOOL)isAgreeJoin opReason:(NSString *)opReason {
    // onApplicationProcessed
}

- (void)onGrantAdministrator:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray <V2TIMGroupMemberInfo *> *)memberList {
    // onGrantAdministrator
}

- (void)onRevokeAdministrator:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray <V2TIMGroupMemberInfo *> *)memberList {
    // onRevokeAdministrator
}

- (void)onQuitFromGroup:(NSString *)groupID {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onLeaveFromGroup object:groupID];
}

- (void)onReceiveRESTCustomData:(NSString *)groupID data:(NSData *)data {
    // onReceiveRESTCustomData
}


#pragma mark V2TIMFriendshipListener
- (void)onFriendApplicationListAdded:(NSArray<V2TIMFriendApplication *> *)applicationList {
   [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onFriendApplicationListAdded object:applicationList];
}

- (void)onFriendApplicationListDeleted:(NSArray *)userIDList {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onFriendApplicationListDeleted object:userIDList];
}

- (void)onFriendApplicationListRead {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onFriendApplicationListRead object:nil];
}

- (void)onFriendListAdded:(NSArray<V2TIMFriendInfo *>*)infoList {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onFriendListAdded object:infoList];
}

- (void)onFriendListDeleted:(NSArray*)userIDList {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onFriendListDeleted object:userIDList];
}

- (void)onBlackListAdded:(NSArray<V2TIMFriendInfo *>*)infoList {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onBlackListAdded object:infoList];
}

- (void)onBlackListDeleted:(NSArray*)userIDList {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onBlackListDeleted object:userIDList];
}

- (void)onFriendProfileChanged:(NSArray<V2TIMFriendInfo *> *)infoList {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onFriendInfoUpdate object:infoList];
}


@end
