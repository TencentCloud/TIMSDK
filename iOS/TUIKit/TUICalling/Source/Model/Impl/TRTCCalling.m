//
//  TRTCCall.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/2.
//

#import "TRTCCalling.h"
#import "TRTCCallingUtils.h"
#import "TRTCCalling+Signal.h"
#import "TRTCCallingHeader.h"
#import "CallingLocalized.h"
#import "TUILogin.h"
#import "TUICallingConstants.h"

@interface TRTCCalling ()

@property (nonatomic, assign) BOOL isMicMute;
@property (nonatomic, assign) BOOL isHandsFreeOn;

@end

@implementation TRTCCalling {
    BOOL _isOnCalling;
    NSString *_curCallID;
}

+ (TRTCCalling *)shareInstance {
    static dispatch_once_t onceToken;
    static TRTCCalling * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TRTCCalling alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.curLastModel = [[CallModel alloc] init];
        self.curLastModel.invitedList = [NSMutableArray array];
        self.curRoomList = [NSMutableArray array];
        [self addSignalListener];
        self.isHandsFreeOn = YES;
        self.isBeingCalled = YES;
    }
    return self;
}

- (void)dealloc {
    [self removeSignalListener];
}

- (void)addDelegate:(id<TRTCCallingDelegate>)delegate {
    self.delegate = delegate;
}

- (void)call:(NSString *)userID type:(CallType)type {
    [self call:@[userID] groupID:nil type:type];
}

- (void)groupCall:(NSArray *)userIDs type:(CallType)type groupID:(NSString *)groupID {
    [self call:userIDs groupID:groupID type:type];
}

- (void)call:(NSArray *)userIDs groupID:(NSString *)groupID type:(CallType)type {
    if (!self.isOnCalling) {
        self.curLastModel.inviter = TUILogin.getUserID;
        self.curLastModel.action = CallAction_Call;
        self.curLastModel.calltype = type;
        self.curRoomID = [TRTCCallingUtils generateRoomID];
        self.curCallIdDic = [NSMutableDictionary dictionary];
        self.calleeUserIDs = [@[] mutableCopy];
        self.curGroupID = groupID;
        self.curType = type;
        self.isOnCalling = YES;
        self.isBeingCalled = NO;
        [self enterRoom];
    }
    
    // 如果不在当前邀请列表，则新增
    NSMutableArray *newInviteList = [NSMutableArray array];
    for (NSString *userID in userIDs) {
        if (![self.curInvitingList containsObject:userID]) {
            [newInviteList addObject:userID];
        }
    }
    
    [self.curInvitingList addObjectsFromArray:newInviteList];
    [self.calleeUserIDs addObjectsFromArray:newInviteList];
    
    if (!(self.curInvitingList && self.curInvitingList.count > 0)) return;
    
    //  处理通话邀请 存在GroupID
    if ([self checkIsHasGroupIDCall]) {
        self.curCallID = [self invite:self.curGroupID action:CallAction_Call model:nil cmdInfo:nil];
        return;
    }
    
    // 1v1 使用，多人通话不使用，作用：音视频切换
    self.currentCallingUserID = newInviteList.firstObject;
    
    for (NSString *userID in self.curInvitingList) {
        NSString *callID = [self invite:userID action:CallAction_Call model:nil cmdInfo:nil userIds:userIDs];
        
        if (callID && callID.length > 0) {
            [self.curCallIdDic setValue:callID forKey:userID];
        }
    }
}

// 接受当前通话
- (void)accept {
    TRTCLog(@"Calling - accept");
    [self enterRoom];
    self.isProcessedBySelf = YES;
    self.currentCallingUserID = [self checkIsHasGroupIDCall] ? self.curGroupID : self.curSponsorForMe;
}

// 拒绝当前通话
- (void)reject {
    TRTCLog(@"Calling - reject");
    [self invite:[self checkIsHasGroupIDCall] ? self.curGroupID : self.curSponsorForMe action:CallAction_Reject model:nil cmdInfo:nil];
    self.isOnCalling = NO;
    self.currentCallingUserID = nil;
}

// 主动挂断通话
- (void)hangup {
    // 如果还没有在通话中，说明还没有接通，所以直接拒绝了
    if (!self.isOnCalling) {
        [self reject];
        TRTCLog(@"Calling - Hangup -> Reject");
        return;
    }
    
    __block BOOL hasCallUser = NO;
    [self.curRoomList enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((user && user.length > 0) && ![self.curInvitingList containsObject:user]) {
            // 还有正在通话的用户
            hasCallUser = YES;
            *stop = YES;
        }
    }];
    
    // 非GroupID 组通话处理，主叫需要取消未接通的通话
    if (![self checkIsHasGroupIDCall] || hasCallUser == NO) {
        TRTCLog(@"Calling - GroupHangup Send CallAction_Cancel");
        [self.curInvitingList enumerateObjectsUsingBlock:^(NSString *invitedId, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *receiver = [self checkIsHasGroupIDCall] ? @"" : invitedId;
            [self invite:receiver action:CallAction_Cancel model:nil cmdInfo:nil];
        }];
    }
    
    [self quitRoom];
    self.isOnCalling = NO;
}

- (void)lineBusy {
    TRTCLog(@"Calling - lineBusy");
    [self invite:[self checkIsHasGroupIDCall] ? self.curGroupID : self.curSponsorForMe action:CallAction_Linebusy model:nil cmdInfo:nil];
    self.isOnCalling = NO;
    self.currentCallingUserID = nil;
}

- (void)switchToAudio {
    self.isProcessedBySelf = YES;
    int res = [self checkAudioStatus];
    
    if (res == 0) {
        self.switchToAudioCallID = [self invite:self.currentCallingUserID action:CallAction_SwitchToAudio model:nil cmdInfo:nil];
    } else {
        if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
            [self.delegate onSwitchToAudio:NO message:@"Local status error"];
        }
    }
}

- (int)checkAudioStatus {
    if (self.currentCallingUserID.length <= 0) {
        return -1;
    }
    return 0;
}

#pragma mark - Data

- (void)setIsOnCalling:(BOOL)isOnCalling {
    if (isOnCalling && _isOnCalling != isOnCalling) {
        // 开始通话
    } else if (!isOnCalling && _isOnCalling != isOnCalling) { // 退出通话
        self.curCallID = @"";
        self.curRoomID = 0;
        self.curType = CallAction_Unknown;
        self.curSponsorForMe = @"";
        self.startCallTS = 0;
        self.curLastModel = [[CallModel alloc] init];
        self.curInvitingList = [NSMutableArray array];
        self.curRoomList = [NSMutableArray array];
        self.curCallIdDic = [NSMutableDictionary dictionary];
        self.calleeUserIDs = [@[] mutableCopy];
        self.isProcessedBySelf = NO;
    }
    _isOnCalling = isOnCalling;
}

- (BOOL)isOnCalling {
    return _isOnCalling;
}

- (void)setCurCallID:(NSString *)curCallID {
    self.curLastModel.callid = curCallID;
}

- (NSString *)curCallID {
    return self.curLastModel.callid;
}

- (void)setCurInvitingList:(NSMutableArray *)curInvitingList {
    self.curLastModel.invitedList = curInvitingList;
}

- (NSMutableArray *)curInvitingList {
    return self.curLastModel.invitedList;
}

- (void)setCurRoomID:(UInt32)curRoomID {
    self.curLastModel.roomid = curRoomID;
}

- (UInt32)curRoomID {
    return self.curLastModel.roomid;
}

- (void)setCurType:(CallType)curType {
    self.curLastModel.calltype = curType;
}

- (CallType)curType {
    return self.curLastModel.calltype;
}

- (void)setCurGroupID:(NSString *)curGroupID {
    self.curLastModel.groupid = curGroupID;
}

- (NSString *)curGroupID {
    return self.curLastModel.groupid;
}

#pragma mark - TRTC Delegate

- (void)enterRoom {
    TRTCLog(@"Calling - enterRoom");
    TXBeautyManager *beauty = [[TRTCCloud sharedInstance] getBeautyManager];
    [beauty setBeautyStyle:TXBeautyStyleNature];
    [beauty setBeautyLevel:6];
    TRTCParams *param = [[TRTCParams alloc] init];
    
    param.sdkAppId = [TUILogin getSdkAppID];
    param.userId = [TUILogin getUserID];
    param.userSig = [TUILogin getUserSig];
    param.roomId = self.curRoomID;
    
    TRTCVideoEncParam *videoEncParam = [[TRTCVideoEncParam alloc] init];
    videoEncParam.videoResolution = TRTCVideoResolution_960_540;
    videoEncParam.videoFps = 15;
    videoEncParam.videoBitrate = 1000;
    videoEncParam.resMode = TRTCVideoResolutionModePortrait;
    videoEncParam.enableAdjustRes = true;
    [[TRTCCloud sharedInstance] setVideoEncoderParam:videoEncParam];
    
    [[TRTCCloud sharedInstance] setDelegate:self];
    [self setFramework];
    [[TRTCCloud sharedInstance] enterRoom:param appScene:TRTCAppSceneVideoCall];
    [[TRTCCloud sharedInstance] startLocalAudio];
    [[TRTCCloud sharedInstance] enableAudioVolumeEvaluation:300];
    self.isMicMute = NO;
    self.isHandsFreeOn = YES;
}

- (void)setFramework {
    NSDictionary *jsonDic = @{@"api": @"setFramework",
                              @"params":@{@"framework": @(TC_TRTC_FRAMEWORK),
                                          @"component": @(TUICallingConstants.component)}};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[TRTCCloud sharedInstance] callExperimentalAPI: jsonString];
}

- (void)quitRoom {
    TRTCLog(@"Calling - quitRoom");
    [[TRTCCloud sharedInstance] stopLocalAudio];
    [[TRTCCloud sharedInstance] stopLocalPreview];
    [[TRTCCloud sharedInstance] exitRoom];
    self.isMicMute = NO;
    self.isHandsFreeOn = YES;
    self.currentCallingUserID = nil;
}

- (void)startRemoteView:(NSString *)userID view:(UIView *)view {
    [[TRTCCloud sharedInstance] startRemoteView:userID view:view];
}

- (void)stopRemoteView:(NSString *)userID {
    [[TRTCCloud sharedInstance] stopRemoteView:userID];
}

- (void)openCamera:(BOOL)frontCamera view:(UIView *)view {
    self.isFrontCamera = frontCamera;
    [[TRTCCloud sharedInstance] startLocalPreview:frontCamera view:view];
}

- (void)closeCamara {
    [[TRTCCloud sharedInstance] stopLocalPreview];
}

- (void)switchCamera:(BOOL)frontCamera {
    if (self.isFrontCamera != frontCamera) {
        [[TRTCCloud sharedInstance] switchCamera];
        self.isFrontCamera = frontCamera;
    }
}

- (void)setMicMute:(BOOL)isMute {
    if (self.isMicMute != isMute) {
        [[TRTCCloud sharedInstance] muteLocalAudio:isMute];
        self.isMicMute = isMute;
    }
}

- (void)setHandsFree:(BOOL)isHandsFree {
    [[TRTCCloud sharedInstance] setAudioRoute:isHandsFree ? TRTCAudioModeSpeakerphone : TRTCAudioModeEarpiece];
    self.isHandsFreeOn = isHandsFree;
}

- (BOOL)micMute {
    return self.isMicMute;
}

- (BOOL)handsFreeOn {
    return self.isHandsFreeOn;
}

- (void)onEnterRoom:(NSInteger)result {
    if (result < 0) {
        self.curLastModel.code = result;
        if ([self canDelegateRespondMethod:@selector(onCallEnd)]) {
            [self.delegate onCallEnd];
        }
        [self hangup];
    } else {
        self.isInRoom = YES;
        // 移除当前登录的用户UserId（如果存在）
        if ([self.curInvitingList containsObject:[self currentLoginUserId]]) {
            [self.curInvitingList removeObject:[self currentLoginUserId]];
        }
        
        if (self.isBeingCalled) {
            [self invite:[self checkIsHasGroupIDCall] ? self.curGroupID : self.curSponsorForMe action:CallAction_Accept model:nil cmdInfo:nil];
        }
    }
}

- (void)onExitRoom:(NSInteger)reason {
    self.isInRoom = NO;
}

#pragma mark - TRTCCloudDelegate

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality {
    if ([self canDelegateRespondMethod:@selector(onNetworkQuality:remoteQuality:)]) {
        [self.delegate onNetworkQuality:localQuality remoteQuality:remoteQuality];
    }
}

- (void)onError:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg
        extInfo:(nullable NSDictionary*)extInfo {
    TRTCLog(@"Calling - onRemoteUserLeaveRoom errCode: %ld errMsg: %@", errCode, errMsg);
    self.curLastModel.code = errCode;
    if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
        [self.delegate onError:errCode msg:errMsg];
    };
    if ([self canDelegateRespondMethod:@selector(onCallEnd)]) {
        [self.delegate onCallEnd];
    }
    [self hangup];
}

- (void)onRemoteUserEnterRoom:(NSString *)userID {
    TRTCLog(@"Calling - onRemoteUserEnterRoom userID: %@", userID);
    // C2C curInvitingList 不要移除 userID，如果是自己邀请的对方，这里移除后，最后发结束信令的时候找不到人
    if ([self.curInvitingList containsObject:userID]) {
        [self.curInvitingList removeObject:userID];
    }
    if (![self.curRoomList containsObject:userID]) {
        [self.curRoomList addObject:userID];
    }
    // C2C 通话要计算通话时长
    if (self.curGroupID == nil) {
        self.startCallTS = [[NSDate date] timeIntervalSince1970];
    }
    if ([self canDelegateRespondMethod:@selector(onUserEnter:)]) {
        [self.delegate onUserEnter:userID];
    }
}

- (void)onRemoteUserLeaveRoom:(NSString *)userID reason:(NSInteger)reason {
    TRTCLog(@"Calling - onRemoteUserLeaveRoom userID: %@ reason: %d", userID, reason);
    // C2C 多人通话添加 - A呼叫B、C， B接通后挂断，C接听，C需要知道B的Accept 和 Reject回调。
    [self sendInviteAction:CallAction_Reject user:userID model:nil];
    
    // C2C curInvitingList 不要移除 userID，如果是自己邀请的对方，这里移除后，最后发结束信令的时候找不到人
    if ([self.curInvitingList containsObject:userID]) {
        [self.curInvitingList removeObject:userID];
    }
    if ([self.curRoomList containsObject:userID]) {
        [self.curRoomList removeObject:userID];
    }
    if ([self canDelegateRespondMethod:@selector(onUserLeave:)]) {
        [self.delegate onUserLeave:userID];
    }
    [self preExitRoom:userID];
}

- (void)onUserAudioAvailable:(NSString *)userID available:(BOOL)available {
    TRTCLog(@"Calling - onUserAudioAvailable userID: %@ available: %d", userID, available);
    if ([self canDelegateRespondMethod:@selector(onUserAudioAvailable:available:)]) {
        [self.delegate onUserAudioAvailable:userID available:available];
    }
}

- (void)onUserVideoAvailable:(NSString *)userID available:(BOOL)available {
    TRTCLog(@"Calling - onUserVideoAvailable userID: %@ available: %d", userID, available);
    if ([self canDelegateRespondMethod:@selector(onUserVideoAvailable:available:)]) {
        [self.delegate onUserVideoAvailable:userID available:available];
    }
}

- (void)onUserVoiceVolume:(NSArray <TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    if ([self canDelegateRespondMethod:@selector(onUserVoiceVolume:volume:)]) {
        for (TRTCVolumeInfo *info in userVolumes) {
            [self.delegate onUserVoiceVolume:info.userId ?: TUILogin.getUserID volume:(UInt32)info.volume];
        }
    }
}

#pragma mark - Private Method

// 检查是否为存在GroupID的群通话
- (BOOL)checkIsHasGroupIDCall {
    return (self.curGroupID.length > 0);
}

- (NSString *)currentLoginUserId {
    return [[V2TIMManager sharedInstance] getLoginUser];
}

- (BOOL)canDelegateRespondMethod:(SEL)selector {
    return self.delegate && [self.delegate respondsToSelector:selector];
}

@end
