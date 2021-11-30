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

@interface TRTCCalling ()

@property(nonatomic,assign) BOOL isMicMute;
@property(nonatomic,assign) BOOL isHandsFreeOn;

@end

@implementation TRTCCalling {
    BOOL _isOnCalling;
    NSString *_curCallID;
}

+(TRTCCalling *)shareInstance {
    static dispatch_once_t onceToken;
    static TRTCCalling * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TRTCCalling alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.curLastModel = [[CallModel alloc] init];
        self.curLastModel.invitedList = [NSMutableArray array];
        self.curRespList = [NSMutableArray array];
        self.curRoomList = [NSMutableArray array];
        [self addSignalListener];
        self.isHandsFreeOn = YES;
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
        self.curLastModel.inviter = [TRTCCallingUtils loginUser];
        self.curLastModel.action = CallAction_Call;
        self.curLastModel.calltype = type;
        self.curRoomID = [TRTCCallingUtils generateRoomID];
        self.curGroupID = groupID;
        self.curType = type;
        self.isOnCalling = YES;
        [self enterRoom];
    }
    // 不在当前邀请列表，新增加的邀请
    NSMutableArray *newInviteList = [NSMutableArray array];
    for (NSString *userID in userIDs) {
        if (![self.curInvitingList containsObject:userID]) {
            [newInviteList addObject:userID];
        }
    }
    [self.curInvitingList addObjectsFromArray:newInviteList];
    
    // 更新已经回复的列表，移除正在邀请的人
    NSMutableArray *rmRespList = [NSMutableArray array];
    for (NSString *userID in self.curRespList) {
        if ([self.curInvitingList containsObject:userID]) {
            [rmRespList addObject:userID];
        }
    }
    [self.curRespList removeObjectsInArray:rmRespList];
    
    self.currentCallingUserID = newInviteList.firstObject;
    
    //通话邀请
    if (self.curGroupID.length > 0 && newInviteList.count > 0) {
        self.curCallID = [self invite:self.curGroupID action:CallAction_Call model:nil cmdInfo:nil];
    } else {
        for (NSString *userID in newInviteList) {
            self.curCallID = [self invite:userID action:CallAction_Call model:nil cmdInfo:nil userIds:userIDs];
        }
    }
}

// 接受当前通话
- (void)accept {
    [self enterRoom];
    self.currentCallingUserID = self.curGroupID.length > 0 ? self.curGroupID : self.curSponsorForMe;
    [self invite:self.curGroupID.length > 0 ? self.curGroupID : self.curSponsorForMe action:CallAction_Accept model:nil cmdInfo:nil];
    [self.curInvitingList removeObject:[TRTCCallingUtils loginUser]];
}

// 拒绝当前通话
- (void)reject {
    [self invite:self.curGroupID.length > 0 ? self.curGroupID : self.curSponsorForMe action:CallAction_Reject model:nil cmdInfo:nil];
    self.isOnCalling = NO;
    self.currentCallingUserID = nil;
}

// 主动挂断通话
- (void)hangup {
    if (!self.isOnCalling) {
        return;
    }
    if (!self.isInRoom) {
        [self reject];
        return;
    }
    // 没人在通话，取消通话
    // 这个函数供界面主动挂断使用，主动挂断的群通话，不能发 end 事件，end 事件由最后一名成员发出(记录通话时长)
    if (self.curRoomList.count == 0 && self.curInvitingList.count > 0) {
        if (self.curGroupID.length > 0) {
            [self invite:self.curGroupID action:CallAction_Cancel model:nil cmdInfo:nil];
        } else {
            [self invite:self.curInvitingList.firstObject action:CallAction_Cancel model:nil cmdInfo:nil];
        }
    }
    [self quitRoom];
    self.isOnCalling = NO;
}

- (void)switchToAudio {
    int res = [self checkAudioStatus];
    if (res == 0) {
        self.switchToAudioCallID = [self invite:self.currentCallingUserID action:CallAction_SwitchToAudio model:nil cmdInfo:nil];
    }
    else {
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

#pragma mark data
- (void)setIsOnCalling:(BOOL)isOnCalling {
    if (isOnCalling && _isOnCalling != isOnCalling) {
        //开始通话
    } else if (!isOnCalling && _isOnCalling != isOnCalling) { //退出通话
        self.curCallID = @"";
        self.curRoomID = 0;
        self.curType = CallAction_Unknown;
        self.curSponsorForMe = @"";
        self.isInRoom = NO;
        self.startCallTS = 0;
        self.curLastModel = [[CallModel alloc] init];
        self.curInvitingList = [NSMutableArray array];
        self.curRespList = [NSMutableArray array];
        self.curRoomList = [NSMutableArray array];
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
    [self setFramework:5];
    [[TRTCCloud sharedInstance] enterRoom:param appScene:TRTCAppSceneVideoCall];
    [[TRTCCloud sharedInstance] startLocalAudio];
    [[TRTCCloud sharedInstance] enableAudioVolumeEvaluation:300];
    self.isMicMute = NO;
    self.isHandsFreeOn = YES;
    self.isInRoom = YES;
}

- (void)setFramework:(int)framework {
    NSDictionary *jsonDic = @{@"api": @"setFramework",
                              @"params":@{@"framework": @(framework)}};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    TRTCLog(@"jsonString = %@",jsonString);
    [[TRTCCloud sharedInstance] callExperimentalAPI: jsonString];
}

- (void)quitRoom {
    [[TRTCCloud sharedInstance] stopLocalAudio];
    [[TRTCCloud sharedInstance] stopLocalPreview];
    [[TRTCCloud sharedInstance] exitRoom];
    self.isMicMute = NO;
    self.isHandsFreeOn = YES;
    self.isInRoom = NO;
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
    }
}

#pragma mark  TRTCCloudDelegate

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality {
    if ([self canDelegateRespondMethod:@selector(onNetworkQuality:remoteQuality:)]) {
        [self.delegate onNetworkQuality:localQuality remoteQuality:remoteQuality];
    }
}

- (void)onError:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg
        extInfo:(nullable NSDictionary*)extInfo {
    self.curLastModel.code = errCode;
    if ([self canDelegateRespondMethod:@selector(onCallEnd)]) {
        [self.delegate onCallEnd];
    }
    [self hangup];
}

- (void)onRemoteUserEnterRoom:(NSString *)userID {
    // C2C curInvitingList 不要移除 userID，如果是自己邀请的对方，这里移除后，最后发结束信令的时候找不到人
    if ([self.curInvitingList containsObject:userID] && self.curGroupID.length > 0) {
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
    // C2C curInvitingList 不要移除 userID，如果是自己邀请的对方，这里移除后，最后发结束信令的时候找不到人
    if ([self.curInvitingList containsObject:userID] && self.curGroupID.length > 0) {
        [self.curInvitingList removeObject:userID];
    }
    if ([self.curRoomList containsObject:userID]) {
        [self.curRoomList removeObject:userID];
    }
    if ([self canDelegateRespondMethod:@selector(onUserLeave:)]) {
        [self.delegate onUserLeave:userID];
    }
    [self checkAutoHangUp];
}

- (void)onUserAudioAvailable:(NSString *)userID available:(BOOL)available {
    if ([self canDelegateRespondMethod:@selector(onUserAudioAvailable:available:)]) {
        [self.delegate onUserAudioAvailable:userID available:available];
    }
}

- (void)onUserVideoAvailable:(NSString *)userID available:(BOOL)available {
    if ([self canDelegateRespondMethod:@selector(onUserVideoAvailable:available:)]) {
        [self.delegate onUserVideoAvailable:userID available:available];
    }
}

- (void)onUserVoiceVolume:(NSArray <TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    if ([self canDelegateRespondMethod:@selector(onUserVoiceVolume:volume:)]) {
        for (TRTCVolumeInfo *info in userVolumes) {
            if (info.userId) {
                [self.delegate onUserVoiceVolume:info.userId volume:(UInt32)info.volume];
            } else {
                [self.delegate onUserVoiceVolume:[TRTCCallingUtils loginUser] volume:(UInt32)info.volume];
            }
        }
    }
}

#pragma mark - private method
- (BOOL)canDelegateRespondMethod:(SEL)selector {
    return self.delegate && [self.delegate respondsToSelector:selector];
}

@end
