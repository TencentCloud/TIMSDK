//
//  TUICallingManager.m
//  TUICalling
//
//  Created by noah on 2021/8/28.
//

#import "TUICallingManager.h"
#import "TRTCCallingUtils.h"
#import "TRTCCallingDelegate.h"
#import "TRTCCalling.h"
#import <TUICore/UIView+TUIToast.h>
#import "TUICommonUtil.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import "CallingLocalized.h"
#import "TRTCCalling+Signal.h"
#import "TUICallingBaseView.h"
#import "TUICallingView.h"
#import "TUIGroupCallingView.h"
#import "TRTCGCDTimer.h"
#import "TUICallingAudioPlayer.h"

typedef NS_ENUM(NSUInteger, TUICallingUserRemoveReason) {
    TUICallingUserRemoveReasonLeave,
    TUICallingUserRemoveReasonReject,
    TUICallingUserRemoveReasonNoresp,
    TUICallingUserRemoveReasonBusy
};

@interface TUICallingManager () <TRTCCallingDelegate, TUIInvitedActionProtocal>

/// 存储监听者对象
@property (nonatomic, weak) id<TUICallingListerner> listener;

///Calling 主视图
@property (nonatomic, strong) TUICallingBaseView *callingView;

/// 记录当前的呼叫类型  语音、视频
@property (nonatomic, assign) TUICallingType currentCallingType;

/// 记录当前的呼叫用户类型  主动、被动
@property (nonatomic, assign) TUICallingRole currentCallingRole;

/// 铃声的资源地址
@property (nonatomic, copy) NSString *bellFilePath;

/// 记录是否开启静音模式     需考虑恢复默认页面
@property (nonatomic, assign) BOOL enableMuteMode;

/// 记录是否开启悬浮窗
@property (nonatomic, assign) BOOL enableFloatWindow;

/// 记录是否自定义视图
@property (nonatomic, assign) BOOL enableCustomViewRoute;

/// 记录IM专属 groupID
@property (nonatomic, copy) NSString *groupID;

/// 记录原始userIDs数据（不包括自己）
@property (nonatomic, strong) NSArray<NSString *> *userIDs;

/// 记录计时器名称
@property (nonatomic, copy) NSString *timerName;

/// 记录通话时间 单位：秒
@property (nonatomic, assign) NSInteger totalTime;

@end

@implementation TUICallingManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TUICallingManager * t_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        t_sharedInstance = [[TUICallingManager alloc] init];
    });
    return t_sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enableMuteMode = NO;
        _enableFloatWindow = NO;
        _currentCallingRole = NO;
        [[TRTCCalling shareInstance] addDelegate:self];
    }
    return self;
}

#pragma mark - Public method

- (void)call:(NSArray<NSString *> *)userIDs type:(TUICallingType)type {
    if (![TUICommonUtil checkArrayValid:userIDs]) return;
    
    self.userIDs = [NSArray arrayWithArray:userIDs];
    
    if (self.listener && [self.listener respondsToSelector:@selector(shouldShowOnCallView)]) {
        if (![self.listener shouldShowOnCallView]) {
            [self onLineBusy:@""]; // 仅仅提示用户忙线，不做calling处理
            return;
        }
    }
    
    self.currentCallingType = type;
    self.currentCallingRole = TUICallingRoleCall;
    
    if ([self checkAuthorizationStatusIsDenied]) return;
    if (!self.currentUserId) return;
    
    [[TRTCCalling shareInstance] groupCall:userIDs type:[self transformCallingType:type] groupID:self.groupID ?: nil];
    __weak typeof(self)weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[self.currentUserId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        if (infoList.count != 1) {
            return;
        }
        __strong typeof(weakSelf)self = weakSelf;
        CallUserModel *model = [self covertUser:infoList.firstObject];
        
        if (userIDs.count >= 2 || self.groupID.length > 0) {
            [self initCallingViewWithUser:model isGroup:YES];
            NSMutableArray *ids = [NSMutableArray arrayWithArray:userIDs];
            [ids addObject:self.currentUserId];
            [self configCallViewWithUserIDs:[ids copy] sponsor:nil];
        } else {
            [self initCallingViewWithUser:nil isGroup:NO];
            [self configCallViewWithUserIDs:userIDs sponsor:nil];
        }
        
        [self callStartWithUserIDs:userIDs type:type role:TUICallingRoleCall];
    } fail:^(int code, NSString *desc) {
        NSLog(@"Calling Error: code %d, msg %@", code, desc);
    }];
}

- (void)setCallingListener:(id<TUICallingListerner>)listener {
    if (listener) {
        self.listener = listener;
    }
}

- (void)setCallingBell:(NSString *)filePath {
    if (filePath) {
        self.bellFilePath = filePath;
    }
}

- (void)enableMuteMode:(BOOL)enable {
    self.enableMuteMode = enable;
}

- (void)enableFloatWindow:(BOOL)enable {
    self.enableFloatWindow = enable;
}

- (void)enableCustomViewRoute:(BOOL)enable {
    self.enableCustomViewRoute = enable;
}

#pragma mark - Private method

- (void)setGroupID:(NSString *)groupID onlineUserOnly:(NSNumber *)onlineUserOnly {
    self.groupID = groupID;
    [TRTCCalling shareInstance].onlineUserOnly = [onlineUserOnly boolValue];
}

- (void)setGroupID:(NSString *)groupID {
    _groupID = groupID;
}

- (void)callStartWithUserIDs:(NSArray *)userIDs type:(TUICallingType)type role:(TUICallingRole)role {
    if (role == TUICallingRoleCall) {
        playAudio(CallingAudioTypeDial);
    } else {
        playAudio(CallingAudioTypeCalled);
    }
    
    if (self.enableCustomViewRoute) {
        if (self.listener && [self.listener respondsToSelector:@selector(callStart:type:role:viewController:)]) {
            UIViewController *callVC = [[UIViewController alloc] init];
            callVC.view.backgroundColor = [UIColor clearColor];
            [callVC.view addSubview:self.callingView];
            [self.listener callStart:userIDs type:type role:role viewController:callVC];
        }
    } else {
        [self.callingView show];
    }
}

- (void)handleCallEnd {
    if (self.enableCustomViewRoute) {
        if (self.listener && [self.listener respondsToSelector:@selector(callEnd:type:role:totalTime:)]) {
            [self.listener callEnd:self.userIDs type:self.currentCallingType role:self.currentCallingRole totalTime:(CGFloat)self.totalTime];
        }
    } else if (self.callingView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.callingView disMiss];
            self.callingView = nil;
        });
    }
    
    stopAudio();
    [TRTCGCDTimer canelTimer:self.timerName];
    self.timerName = nil;
    self.groupID = nil;
}

- (void)handleCallEvent:(TUICallingEvent)event message:(NSString *)message {
    if (self.enableCustomViewRoute) {
        if (self.listener && [self.listener respondsToSelector:@selector(onCallEvent:type:role:message:)]) {
            [self.listener onCallEvent:event type:self.currentCallingType role:self.currentCallingRole message:message];
        }
    }
}

#pragma mark - TUIInvitedActionProtocal

- (void)acceptCalling {
    stopAudio();
    [[TRTCCalling shareInstance] accept];
    [self.callingView acceptCalling];
    [self handleCallEvent:TUICallingEventCallSucceed message:CallingLocalize(@"Demo.TRTC.Calling.answer")];
    [self handleCallEvent:TUICallingEventCallStart message:CallingLocalize(@"Demo.TRTC.Calling.answer")];
    [self startTimer];
}

- (void)refuseCalling {
    [[TRTCCalling shareInstance] reject];
    [self.callingView refuseCalling];
    [self handleCallEvent:TUICallingEventCallFailed message:CallingLocalize(@"Demo.TRTC.Calling.decline")];
    [self handleCallEnd];
}

- (void)hangupCalling {
    [[TRTCCalling shareInstance] hangup];
    [self handleCallEvent:TUICallingEventCallEnd message:CallingLocalize(@"Demo.TRTC.Calling.hangup")];
    [self handleCallEnd];
}

#pragma mark - TRTCCallingDelegate

-(void)onError:(int)code msg:(NSString * _Nullable)msg {
    NSLog(@"onError: code %d, msg %@", code, msg);
    [self handleCallEvent:TUICallingEventCallFailed message:msg];
}

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality
           remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality {
    if (!self.callingView) {
        return;
    }
}

- (void)onSwitchToAudio:(BOOL)success
                message:(NSString *)message {
    if (success) {
        [self.callingView switchToAudio];
    }
    if (message && message.length > 0) {
        [self.callingView makeToast:message];
    }
}

- (void)onInvited:(NSString *)sponsor
          userIds:(NSArray<NSString *> *)userIDs
      isFromGroup:(BOOL)isFromGroup
         callType:(CallType)callType {
    NSLog(@"log: onInvited sponsor:%@ userIds:%@", sponsor, userIDs);
    
    if (![TUICommonUtil checkArrayValid:userIDs]) return;
    
    self.userIDs = [NSArray arrayWithArray:userIDs];
    self.currentCallingRole = TTUICallingRoleCalled;
    self.currentCallingType = [self transformCallType:callType];
    
    if ([self checkAuthorizationStatusIsDenied]) return;
    
    NSMutableArray *userIds = [NSMutableArray arrayWithArray:userIDs];
    
    if (isFromGroup) {
        [userIds addObject:sponsor];
    }
    
    if (userIds.count >= 2 || isFromGroup) {
        if (!self.currentUserId) return;
        __weak typeof(self)weakSelf = self;
        NSMutableArray *users = [NSMutableArray arrayWithObject:self.currentUserId];
        if (userIds.count > 0) {
            [users addObjectsFromArray:userIds];
        }
        [[V2TIMManager sharedInstance] getUsersInfo:users succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            if (infoList.count == 0) {
                return;
            }
            __strong typeof(weakSelf)self = weakSelf;
            __block V2TIMUserFullInfo *currentInfo = nil;
            [infoList enumerateObjectsUsingBlock:^(V2TIMUserFullInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.userID isEqualToString:[self currentUserId]]) {
                    currentInfo = obj;
                    *stop = YES;
                }
            }];
            CallUserModel *model = [self covertUser:currentInfo];
            [self initCallingViewWithUser:model isGroup:YES];
            [self callStartWithUserIDs:userIDs type:[self transformCallType:callType] role:TTUICallingRoleCalled];
            [self refreshCallingViewWithUserIDs:userIDs sponsor:sponsor];
        } fail:^(int code, NSString *desc) {
            NSLog(@"V2TIMManager getUsersInfo: code %d, msg %@", code, desc);
        }];
    } else {
        [self initCallingViewWithUser:nil isGroup:NO];
        [self callStartWithUserIDs:userIDs type:[self transformCallType:callType] role:TTUICallingRoleCalled];
        [self refreshCallingViewWithUserIDs:userIDs sponsor:sponsor];
    }
}

- (void)initCallingViewWithUser:(CallUserModel *)userModel isGroup:(BOOL)isGroup {
    TUICallingBaseView *callingView = nil;
    BOOL isCallee = (self.currentCallingRole == TTUICallingRoleCalled);
    BOOL isVideo = (self.currentCallingType == TUICallingTypeVideo);
    
    if (isGroup) {
        callingView = (TUICallingBaseView *)[[TUIGroupCallingView alloc] initWithUser:userModel isVideo:isVideo isCallee:isCallee];
    } else {
        callingView = (TUICallingBaseView *)[[TUICallingView alloc] initWithIsVideo:isVideo isCallee:isCallee];
    }
    
    callingView.actionDelegate = self;
    self.callingView =  callingView;
}

- (void)refreshCallingViewWithUserIDs:(NSArray<NSString *> *)userIDs sponsor:(NSString *)sponsor {
    // 查询用户信息，调用IM
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[sponsor] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *curUserInfo = [infoList firstObject];
        if (!curUserInfo) return;
        [weakSelf configCallViewWithUserIDs:userIDs sponsor:[weakSelf covertUser:curUserInfo isEnter:true]];
    } fail:nil];
}

- (void)onGroupCallInviteeListUpdate:(NSArray *)userIds {
    NSLog(@"log: onGroupCallInviteeListUpdate userIds:%@", userIds);
}

- (void)onUserEnter:(NSString *)uid {
    NSLog(@"log: onUserEnter: %@", uid);
    stopAudio();
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[uid] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *userInfo = [infoList firstObject];
        if (!userInfo) return;
        [weakSelf startTimer];
        CallUserModel *userModel = [weakSelf covertUser:userInfo];
        [weakSelf.callingView enterUser:userModel];
        [self.callingView makeToast: [NSString stringWithFormat:@"%@ %@", userModel.name,  CallingLocalize(@"Demo.TRTC.calling.callingbegan")] ];
    } fail:nil];
}

- (void)onUserLeave:(NSString *)uid {
    NSLog(@"log: onUserLeave: %@", uid);
    [self removeUserFromCallVC:uid removeReason:TUICallingUserRemoveReasonLeave];
}

- (void)onReject:(NSString *)uid {
    NSLog(@"log: onReject: %@", uid);
    [self removeUserFromCallVC:uid removeReason:TUICallingUserRemoveReasonReject];
}

- (void)onNoResp:(NSString *)uid {
    NSLog(@"log: onNoResp: %@", uid);
    [self removeUserFromCallVC:uid removeReason:TUICallingUserRemoveReasonNoresp];
}

- (void)onLineBusy:(NSString *)uid {
    NSLog(@"log: onLineBusy: %@", uid);
    [self removeUserFromCallVC:uid removeReason:TUICallingUserRemoveReasonBusy];
}

- (void)onCallingCancel:(NSString *)uid {
    NSLog(@"log: onCallingCancel: %@", uid);
    [[TUICommonUtil getRootWindow] makeToast:CallingLocalize(@"Demo.TRTC.calling.callingcancel")];
    [self handleCallEnd];
    [self handleCallEvent:TUICallingEventCallFailed message:CallingLocalize(@"Demo.TRTC.Calling.callingcancel")];
}

- (void)onCallingTimeOut {
    NSLog(@"log: onCallingTimeOut");
    [[TUICommonUtil getRootWindow] makeToast:CallingLocalize(@"Demo.TRTC.calling.callingtimeout")];
    [self handleCallEnd];
    [self handleCallEvent:TUICallingEventCallFailed message:CallingLocalize(@"Demo.TRTC.Calling.callingtimeout")];
}

- (void)onCallEnd {
    NSLog(@"onCallEnd \n %s", __FUNCTION__);
    [self handleCallEnd];
    [self handleCallEvent:TUICallingEventCallEnd message:CallingLocalize(@"Demo.TRTC.Calling.hangup")];
}

- (void)onUserAudioAvailable:(NSString *)uid available:(BOOL)available {
    NSLog(@"log: onUserAudioAvailable: %@, available: %d",uid, available);
}

- (void)onUserVoiceVolume:(NSString *)uid volume:(UInt32)volume {
    if (!self.callingView) return;
    CallUserModel *user = [self.callingView getUserById:uid];
    
    if (user) {
        CallUserModel *newUser = user;
        newUser.volume = (CGFloat)volume / 100;
        [self.callingView updateUserVolume:newUser];
    }
}

- (void)onUserVideoAvailable:(NSString *)uid available:(BOOL)available {
    NSLog(@"log: onUserLeave: %@", uid);
    if (self.callingView) {
        CallUserModel *userModel = [self.callingView getUserById:uid];
        
        if (userModel) {
            userModel.isEnter = YES;
            userModel.isVideoAvaliable = available;
            [self.callingView updateUser:userModel animated:NO];
        } else {
            [[V2TIMManager sharedInstance] getUsersInfo:@[uid] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                V2TIMUserFullInfo *userInfo =  [infoList firstObject];
                CallUserModel *newUser = [self covertUser:userInfo];
                newUser.isVideoAvaliable = available;
                [self.callingView enterUser:newUser];
            } fail:nil];
        }
    }
}

- (void)removeUserFromCallVC:(NSString *)uid removeReason:(TUICallingUserRemoveReason)removeReason {
    if (!self.callingView) return;
    
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[uid] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *userInfo = [infoList firstObject];
        if (!userInfo) return;
        
        CallUserModel *callUserModel = [weakSelf covertUser:userInfo];
        [weakSelf.callingView leaveUser:callUserModel];
        NSString *toast = callUserModel.name ?: @"";
        
        switch (removeReason) {
            case TUICallingUserRemoveReasonLeave:
                toast = [NSString stringWithFormat:@"%@%@", toast, CallingLocalize(@"Demo.TRTC.calling.callingleave")];
                break;
            case TUICallingUserRemoveReasonReject:
                toast = [NSString stringWithFormat:@"%@%@", toast, CallingLocalize(@"Demo.TRTC.calling.callingrefuse")];
                [self handleCallEvent:TUICallingEventCallFailed message:toast];
                break;
            case TUICallingUserRemoveReasonNoresp:
                toast = [NSString stringWithFormat:@"%@%@", toast, CallingLocalize(@"Demo.TRTC.calling.callingnoresponse")];
                [self handleCallEvent:TUICallingEventCallFailed message:toast];
                break;
            case TUICallingUserRemoveReasonBusy:
                toast = [NSString stringWithFormat:@"%@%@", toast, CallingLocalize(@"Demo.TRTC.calling.callingbusy")];
                [self handleCallEvent:TUICallingEventCallFailed message:toast];
                break;
            default:
                break;
        }
        
        if (toast && toast.length > 0) {
            [[TUICommonUtil getRootWindow] makeToast:toast];
        }
    } fail:nil];
}

- (void)configCallViewWithUserIDs:(NSArray<NSString *> *)userIDs sponsor:(CallUserModel *)sponsor {
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:userIDs succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        NSMutableArray <CallUserModel *> *modleList = [NSMutableArray array];
        for (V2TIMUserFullInfo *model in infoList) {
            [modleList addObject:[weakSelf covertUser:model]];
        }
        if (sponsor) {
            [modleList addObject:sponsor];
        }
        [weakSelf.callingView configViewWithUserList:[modleList copy] sponsor:sponsor];
    } fail:nil];
}

#pragma mark - Private method

- (NSString *)currentUserId {
    return [[V2TIMManager sharedInstance] getLoginUser];
}

- (CallType)transformCallingType:(TUICallingType)type {
    CallType callType = CallType_Unknown;
    switch (type) {
        case TUICallingTypeVideo:
            callType = CallType_Video;
            break;
        case TUICallingTypeAudio:
        default:
            callType = CallType_Audio;
            break;
    }
    return callType;
}

- (TUICallingType)transformCallType:(CallType)type {
    TUICallingType callingType = TUICallingTypeAudio;
    if (type == CallType_Video) {
        callingType = TUICallingTypeVideo;
    }
    return callingType;
}

- (CallUserModel *)covertUser:(V2TIMUserFullInfo *)user {
    return [self covertUser:user volume:0 isEnter:NO];
}

- (CallUserModel *)covertUser:(V2TIMUserFullInfo *)user isEnter:(BOOL)isEnter {
    return [self covertUser:user volume:0 isEnter:isEnter];
}

- (CallUserModel *)covertUser:(V2TIMUserFullInfo *)user volume:(NSUInteger)volume isEnter:(BOOL)isEnter {
    CallUserModel *dstUser = [[CallUserModel alloc] init];
    dstUser.name = user.nickName;
    dstUser.avatar = user.faceURL;
    dstUser.userId = user.userID;
    dstUser.isEnter = isEnter ? YES : NO;
    dstUser.volume = (CGFloat)volume / 100.0f;
    CallUserModel *oldUser = [self.callingView getUserById:user.userID];
    
    if (oldUser) {
        dstUser.isVideoAvaliable = oldUser.isVideoAvaliable;
    }
    
    return dstUser;
}

- (BOOL)checkAuthorizationStatusIsDenied {
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusAudio == AVAuthorizationStatusDenied) {
        [[TUICommonUtil getRootWindow] makeToast:CallingLocalize(@"Demo.TRTC.Calling.failedtogetmicrophonepermission")];
        return YES;
    }
    if ((self.currentCallingType == TUICallingTypeVideo) && (statusVideo == AVAuthorizationStatusDenied)) {
        [[TUICommonUtil getRootWindow] makeToast:CallingLocalize(@"Demo.TRTC.Calling.failedtogetcamerapermission")];
        return YES;
    }
    return NO;
}

- (void)startTimer {
    if (self.timerName.length) return;
    
    [self handleCallEvent:TUICallingEventCallSucceed message:CallingLocalize(@"Demo.TRTC.Calling.answer")];
    [self handleCallEvent:TUICallingEventCallStart message:CallingLocalize(@"Demo.TRTC.Calling.answer")];
    
    self.totalTime = 0;
    NSTimeInterval interval = 1.0;
    __weak typeof(self) weakSelf = self;
    self.timerName = [TRTCGCDTimer timerTask:^{
        self.totalTime += (NSInteger)interval;
        NSString *minutes = [NSString stringWithFormat:@"%@%ld", (weakSelf.totalTime / 60 < 10) ? @"0" : @"" , (NSInteger)(self.totalTime / 60)];
        NSString *seconds = [NSString stringWithFormat:@"%@%ld", (weakSelf.totalTime % 60 < 10) ? @"0" : @"" , weakSelf.totalTime % 60];
        [weakSelf.callingView setCallingTimeStr:[NSString stringWithFormat:@"%@ : %@", minutes, seconds]];
    } start:0 interval:interval repeats:YES async:NO];
}

@end
