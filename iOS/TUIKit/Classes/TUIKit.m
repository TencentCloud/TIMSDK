#import "TUIKit.h"

@interface TUIKit () <V2TIMSDKListener,V2TIMAdvancedMsgListener,V2TIMConversationListener,V2TIMGroupListener,V2TIMFriendshipListener>
@end

@implementation TUIKit
{
    UInt32    _sdkAppid;
    NSString  *_userID;
    NSString  *_userSig;
    NSString  *_nickName;
    NSString  *_faceUrl;
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
        _enableToast = YES;
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
}

- (void)login:(NSString *)userID userSig:(NSString *)sig succ:(TSucc)succ fail:(TFail)fail
{
    _userID = userID;
    _userSig = sig;
    
    int sdkAppId = self.sdkAppId;
    NSString *loginUserId = userID.copy;
    NSString *loginSig = sig.copy;
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] login:_userID userSig:_userSig succ:^{
        Class liveClass = NSClassFromString(@"TUIKitLive");
        if (liveClass) {
            /// TUIKitLive obeject
            SEL shareSel = NSSelectorFromString(@"shareInstance");
            NSMethodSignature *shareMethod = [liveClass methodSignatureForSelector:shareSel];
            NSInvocation *shareInvocation = [NSInvocation invocationWithMethodSignature:shareMethod];
            shareInvocation.target = liveClass;
            shareInvocation.selector = shareSel;
            [shareInvocation invoke];
            __autoreleasing NSObject *tuikitObj = nil;
            [shareInvocation getReturnValue:&tuikitObj];
            if (tuikitObj && [NSStringFromClass(tuikitObj.class) isEqualToString:@"TUIKitLive"]) {
                /// 调用[[TUIKitLive shareInstance] setIsAttachedTUIKit:YES]
                SEL isAttachedSel = NSSelectorFromString(@"setIsAttachedTUIKit:");
                NSMethodSignature *isAttachedMehtod = [liveClass instanceMethodSignatureForSelector:isAttachedSel];
                NSInvocation *isAttachedInvocation = [NSInvocation invocationWithMethodSignature:isAttachedMehtod];
                isAttachedInvocation.target = tuikitObj;
                isAttachedInvocation.selector = isAttachedSel;
                BOOL isAttachedTUIKit = YES;
                [isAttachedInvocation setArgument:&isAttachedTUIKit atIndex:2];
                [isAttachedInvocation invoke];
                /// 登录TUIKitLive
                SEL loginSel = NSSelectorFromString(@"login:userID:userSig:callback:");
                NSMethodSignature *loginMethodSig = [liveClass instanceMethodSignatureForSelector:loginSel];
                NSInvocation *loginInvocation = [NSInvocation invocationWithMethodSignature:loginMethodSig];
                loginInvocation.target = tuikitObj;
                loginInvocation.selector = loginSel;
                [loginInvocation setArgument:&sdkAppId atIndex:2];
                [loginInvocation setArgument:(void *)&loginUserId atIndex:3];
                [loginInvocation setArgument:(void *)&loginSig atIndex:4];
                void(^loginCallBack)(int code, NSString * _Nullable message) = ^(int code, NSString * _Nullable message) {
                    NSLog(@"登录结果：%d，%@", code, message);
                };
                [loginInvocation setArgument:&(loginCallBack) atIndex:5];
                [loginInvocation invoke];
            }
        }
        
        // 获取当前登录用户的信息
        [[V2TIMManager sharedInstance] getUsersInfo:@[weakSelf.userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            V2TIMUserFullInfo *info = infoList.firstObject;
            weakSelf.nickName = info.nickName;
            weakSelf.faceUrl = info.faceURL;
        } fail:nil];
        succ();
    } fail:^(int code, NSString *msg) {
        fail(code,msg);
    }];
}

- (void)logout:(TSucc)succ fail:(TFail)fail {
    // 退出
    [[V2TIMManager sharedInstance] logout:^{
        
        Class liveClass = NSClassFromString(@"TUIKitLive");
        if (liveClass) {
            /// TUIKitLive obeject
            SEL shareSel = NSSelectorFromString(@"shareInstance");
            NSMethodSignature *shareMethod = [liveClass methodSignatureForSelector:shareSel];
            NSInvocation *shareInvocation = [NSInvocation invocationWithMethodSignature:shareMethod];
            shareInvocation.target = liveClass;
            shareInvocation.selector = shareSel;
            [shareInvocation invoke];
            __autoreleasing NSObject *tuikitObj = nil;
            [shareInvocation getReturnValue:&tuikitObj];
            if (tuikitObj && [NSStringFromClass(tuikitObj.class) isEqualToString:@"TUIKitLive"]) {
                /// 调用[[TUIKitLive shareInstance] logout:nil]

                SEL loginSel = NSSelectorFromString(@"logout:");
                NSMethodSignature *logoutMethodSig = [liveClass instanceMethodSignatureForSelector:loginSel];
                NSInvocation *logoutInvocation = [NSInvocation invocationWithMethodSignature:logoutMethodSig];
                logoutInvocation.target = tuikitObj;
                logoutInvocation.selector = loginSel;
                [logoutInvocation invoke];
            }
        }
        
        succ();
        
        NSLog(@"登出成功！");
    } fail:fail];
}

- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo {
    Class callClass = NSClassFromString(@"TUIKitLive");
    if (callClass) {
        SEL shareSel = NSSelectorFromString(@"shareInstance");
        NSMethodSignature *shareMethod = [callClass methodSignatureForSelector:shareSel];
        NSInvocation *shareInovation = [NSInvocation invocationWithMethodSignature:shareMethod];
        shareInovation.target = callClass;
        shareInovation.selector = shareSel;
        [shareInovation invoke];
        __autoreleasing NSObject *callObj = nil;
        [shareInovation getReturnValue:&callObj];
        if (callObj && [NSStringFromClass(callObj.class) isEqualToString:@"TUIKitLive"]) {
            /// 调用 [[TUIKitLive shareInstance] onReceiveGroupCallAPNs:signalingInfo];
            SEL isAttachedSel = NSSelectorFromString(@"onReceiveGroupCallAPNs:");
            NSMethodSignature *isAttachedMehtod = [callClass instanceMethodSignatureForSelector:isAttachedSel];
            NSInvocation *isAttachedInvocation = [NSInvocation invocationWithMethodSignature:isAttachedMehtod];
            isAttachedInvocation.target = callObj;
            isAttachedInvocation.selector = isAttachedSel;
            [isAttachedInvocation setArgument:(void *)&signalingInfo atIndex:2];
            [isAttachedInvocation invoke];
        }
    }
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

- (NSString *)faceUrl {
    return _faceUrl;
}

- (void)setFaceUrl:(NSString *)faceUrl {
    _faceUrl = faceUrl;
}

- (NSString *)nickName {
    return _nickName;
}

- (void)setNickName:(NSString *)nickName {
    _nickName = nickName;
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

- (void)onTotalUnreadMessageCountChanged:(UInt64)totalUnreadCount {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onTotalUnreadMessageCountChanged object:@(totalUnreadCount)];
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

- (void)onRecvMessageModified:(V2TIMMessage *)msg {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMMessageModifiedListener object:msg];
}

#pragma mark V2TIMGroupListener
/// 群消息因为只能添加一个setGroupListener，所以需要通知给TUIKit_Live
- (void)notify:(NSString *)notifyName buildInfo:(void (^)(void(^safeAddKeyValue)(id key, id value)))infoBuilder {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    void(^safeAdd)(id key, id value) = ^(id key, id value) {
        if (key && value) {
            userInfo[key] = value;
        }
    };
    infoBuilder(safeAdd);
    [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:nil userInfo:userInfo];
}

- (void)onMemberEnter:(NSString *)groupID memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    // onMemberEnter
    [self notify:@"V2TIMGroupNotify_onMemberEnter" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"memberList", memberList);
    }];
}

- (void)onMemberLeave:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member {
    // onMemberLeave
    [self notify:@"V2TIMGroupNotify_onMemberLeave" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"member", member);
    }];
}

- (void)onMemberInvited:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    // onMemberInvited
    [self notify:@"V2TIMGroupNotify_onMemberInvited" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"opUser", opUser);
        safeAddKeyValue(@"memberList", memberList);
    }];
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
    [self notify:@"V2TIMGroupNotify_onGroupDismissed" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"opUser", opUser);
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onGroupDismissed object:groupID];
}

- (void)onGroupRecycled:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    [self notify:@"V2TIMGroupNotify_onGroupRecycled" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"opUser", opUser);
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onGroupRecycled object:groupID];
}

- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupChangeInfo *> *)changeInfoList {
    // onGroupInfoChanged
    [self notify:TUIKitNotification_onGroupInfoChanged buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"changeInfoList", changeInfoList);
    }];
}

- (void)onGroupAttributeChanged:(NSString *)groupID attributes:(NSMutableDictionary<NSString *,NSString *> *)attributes {
    // onGroupAttributeChanged
    [self notify:@"V2TIMGroupNotify_onGroupAttributeChanged" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"attributes", attributes);
    }];
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
    [self notify:@"V2TIMGroupNotify_onRevokeAdministrator" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"opUser", opUser);
        safeAddKeyValue(@"memberList", memberList);
    }];
}

- (void)onQuitFromGroup:(NSString *)groupID {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onLeaveFromGroup object:groupID];
}

- (void)onReceiveRESTCustomData:(NSString *)groupID data:(NSData *)data {
    // onReceiveRESTCustomData
    [self notify:@"V2TIMGroupNotify_onReceiveRESTCustomData" buildInfo:^(void (^safeAddKeyValue)(id key, id value)) {
        safeAddKeyValue(@"groupID", groupID);
        safeAddKeyValue(@"data", data);
    }];
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
