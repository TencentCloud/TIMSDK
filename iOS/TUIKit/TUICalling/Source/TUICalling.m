//
//  TUICalling.m
//  TUICalling
//
//  Created by noah on 2021/8/28.
//

#import "TUICalling.h"
#import "TRTCCallingUtils.h"
#import "TRTCCallingDelegate.h"
#import "TRTCCalling.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import "CallingLocalized.h"
#import "TRTCCalling+Signal.h"
#import "TUICallingBaseView.h"
#import "TUICallingView.h"
#import "TUIGroupCallingView.h"
#import "TRTCGCDTimer.h"
#import "TUICallingAudioPlayer.h"
#import "TUICallingConstants.h"
#import "TRTCCallingHeader.h"
#import <TUICore/TUIDefine.h>
#import <TUICore/TUILogin.h>

typedef NS_ENUM(NSUInteger, TUICallingUserRemoveReason) {
    TUICallingUserRemoveReasonLeave,
    TUICallingUserRemoveReasonReject,
    TUICallingUserRemoveReasonNoresp,
    TUICallingUserRemoveReasonBusy
};

@interface TUICalling () <TRTCCallingDelegate, TUIInvitedActionProtocal>

/// 存储监听者对象
@property (nonatomic, weak) id<TUICallingListerner> listener;
///Calling 主视图
@property (nonatomic, strong) TUICallingBaseView *callingView;
/// 记录当前的呼叫类型  语音、视频
@property (nonatomic, assign) TUICallingType currentCallingType;
/// 记录当前的呼叫用户类型  主动、被动
@property (nonatomic, assign) TUICallingRole currentCallingRole;
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
/// 记录是否需要继续播放来电铃声
@property (nonatomic, assign) BOOL needContinuePlaying;

@end

@implementation TUICalling

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TUICalling * t_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        t_sharedInstance = [[TUICalling alloc] init];
    });
    return t_sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enableMuteMode = NO;
        _enableFloatWindow = NO;
        _currentCallingRole = NO;
        _enableCustomViewRoute = NO;
        [[TRTCCalling shareInstance] addDelegate:self];
        [self registerNotifications];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public method

- (void)call:(NSArray<NSString *> *)userIDs type:(TUICallingType)type {
    if (![TUICommonUtil checkArrayValid:userIDs]) {
        return;
    }
    if ([[TUICallingFloatingWindowManager shareInstance] isFloating]) {
        [self makeToast:CallingLocalize(@"Demo.TRTC.Calling.UnableToRestartTheCall")];
        return;
    }
    // 最大支持9人超过9人不能发起通话
    if (userIDs.count > MAX_USERS) {
        [self makeToast:CallingLocalize(@"Demo.TRTC.Calling.User.Exceed.Limit")];
        return;
    }
    
    self.userIDs = [NSArray arrayWithArray:userIDs];
    self.currentCallingType = type;
    self.currentCallingRole = TUICallingRoleCall;
    
    if ([self checkAuthorizationStatusIsDenied] || !self.currentUserId) {
        return;
    }
    
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
    if(!(filePath && [filePath isKindOfClass:NSString.class] && filePath.length > 0)) {
        return;
    }
    
    if ([filePath hasPrefix:@"http"]) {
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:filePath] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                TRTCLog(@"SetCallingBell Error: %@", error.localizedDescription);
                return;
            }
            
            if (location != nil) {
                NSString *oldBellFilePath = [NSUserDefaults.standardUserDefaults objectForKey:CALLING_BELL_KEY];
                [[NSFileManager defaultManager] removeItemAtPath:oldBellFilePath error:nil];
                NSString *filePathStr = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePathStr] error:nil];
                [NSUserDefaults.standardUserDefaults setObject:filePathStr ?: @"" forKey:CALLING_BELL_KEY];
                [NSUserDefaults.standardUserDefaults synchronize];
            }
        }];
        [downloadTask resume];
    } else {
        [NSUserDefaults.standardUserDefaults setObject:filePath forKey:CALLING_BELL_KEY];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

- (void)setUserNickname:(NSString *)nickname callback:(TUICallingCallback)callback {
    [self setUserNickname:nickname avatar:nil callback:callback];
}

- (void)setUserAvatar:(NSString *)avatar callback:(TUICallingCallback)callback {
    [self setUserNickname:nil avatar:avatar callback:callback];
}

- (void)enableMuteMode:(BOOL)enable {
    self.enableMuteMode = enable;
    [[TRTCCalling shareInstance] setMicMute:enable];
}

- (void)enableFloatWindow:(BOOL)enable {
    self.enableFloatWindow = enable;
}

- (void)enableCustomViewRoute:(BOOL)enable {
    self.enableCustomViewRoute = enable;
}

#pragma mark - Private method

- (void)registerNotifications {
    if (@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForeground)
                                                     name:UISceneWillEnterForegroundNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

- (void)appWillEnterForeground {
    if (self.needContinuePlaying) {
        [self playAudioToCalled];
    }
    self.needContinuePlaying = NO;
}

- (void)setGroupID:(NSString *)groupID onlineUserOnly:(NSNumber *)onlineUserOnly {
    self.groupID = groupID;
    [TRTCCalling shareInstance].onlineUserOnly = [onlineUserOnly boolValue];
}

- (void)setGroupID:(NSString *)groupID {
    _groupID = groupID;
}

- (void)callStartWithUserIDs:(NSArray *)userIDs type:(TUICallingType)type role:(TUICallingRole)role {
    if (self.enableCustomViewRoute && self.listener && [self.listener respondsToSelector:@selector(callStart:type:role:viewController:)]) {
        UIViewController *callVC = [[UIViewController alloc] init];
        callVC.view.backgroundColor = [UIColor clearColor];
        [callVC.view addSubview:self.callingView];
        [self.listener callStart:userIDs type:type role:role viewController:callVC];
    } else {
        [self.callingView showCalingViewEnableFloatWindow:self.enableFloatWindow];
    }
    
    if (self.enableMuteMode) {
        return;
    }
    
    if (role == TUICallingRoleCall) {
        playAudio(CallingAudioTypeDial);
        return;
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        self.needContinuePlaying = YES;
        return;
    }
    
    [self playAudioToCalled];
}


- (void)playAudioToCalled {
    NSString *bellFilePath = [NSUserDefaults.standardUserDefaults objectForKey:CALLING_BELL_KEY];
    if (bellFilePath && playAudioWithFilePath(bellFilePath)) {
        return;
    }
    playAudio(CallingAudioTypeCalled);
}

- (void)handleStopAudio {
    stopAudio();
    self.needContinuePlaying = NO;
}

- (void)handleCallEnd {
    if (self.enableCustomViewRoute && self.listener && [self.listener respondsToSelector:@selector(callEnd:type:role:totalTime:)]) {
        [self.listener callEnd:self.userIDs type:self.currentCallingType role:self.currentCallingRole totalTime:(CGFloat)self.totalTime];
    }
    
    [self.callingView disMissCalingView];
    self.callingView = nil;
    [self handleStopAudio];
    [TRTCGCDTimer canelTimer:self.timerName];
    [self enableAutoLockScreen:YES];
    self.timerName = nil;
    self.groupID = nil;
}

- (void)handleCallEvent:(TUICallingEvent)event message:(NSString *)message {
    if (self.enableCustomViewRoute && self.listener && [self.listener respondsToSelector:@selector(onCallEvent:type:role:message:)]) {
        [self.listener onCallEvent:event type:self.currentCallingType role:self.currentCallingRole message:message];
    }
}

- (void)enableAutoLockScreen:(BOOL)isEnable {
    [UIApplication sharedApplication].idleTimerDisabled = !isEnable;
}

- (void)setUserNickname:(NSString *)nickname avatar:(NSString *)avatar callback:(TUICallingCallback)callback {
    [[V2TIMManager sharedInstance] getUsersInfo:@[TUILogin.getUserID ?: @""] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *info = infoList.firstObject;
        
        if ((nickname && [nickname isKindOfClass:NSString.class] && [nickname isEqualToString:info.nickName]) ||
            (avatar && [avatar isKindOfClass:NSString.class] && [avatar isEqualToString:info.faceURL])) {
            callback(0, @"success");
            return;
        }
        if ([nickname isKindOfClass:NSString.class] && nickname.length > 0) {
            info.nickName = nickname;
        }
        if ([avatar isKindOfClass:NSString.class] && avatar.length > 0) {
            info.faceURL = avatar;
        }
        
        [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
            callback(0, @"success");
        } fail:^(int code, NSString *desc) {
            callback(code, desc);
        }];
    } fail:^(int code, NSString *desc) {
        callback(code, desc);
    }];
}

#pragma mark - TUIInvitedActionProtocal

- (void)acceptCalling {
    [self handleStopAudio];
    [[TRTCCalling shareInstance] accept];
    [self.callingView acceptCalling];
    [self startTimer];
    [self enableAutoLockScreen:NO];
}

- (void)refuseCalling {
    [[TRTCCalling shareInstance] reject];
    [self.callingView refuseCalling];
    [self handleCallEvent:TUICallingEventCallFailed message:EVENT_CALL_DECLINE];
    [self handleCallEnd];
}

- (void)hangupCalling {
    [[TRTCCalling shareInstance] hangup];
    [self handleCallEvent:TUICallingEventCallEnd message:EVENT_CALL_HANG_UP];
    [self handleCallEnd];
}

#pragma mark - TRTCCallingDelegate

-(void)onError:(int)code msg:(NSString * _Nullable)msg {
    NSLog(@"onError: code %d, msg %@", code, msg);
    NSString *toast = [NSString stringWithFormat:@"Error code: %d, Message: %@", code, msg];
    if (code == ERR_ROOM_ENTER_FAIL) {
        [self makeToast:toast duration:3 position:TUICSToastPositionCenter];
    } else if (code != ERR_INVALID_PARAMETERS) {
        [self makeToast:toast];
    }
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
        self.currentCallingType = TUICallingTypeAudio;
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
    
    if (![TUICommonUtil checkArrayValid:userIDs]) {
        return;
    }
    
    if (self.listener && [self.listener respondsToSelector:@selector(shouldShowOnCallView)]) {
        if (![self.listener shouldShowOnCallView]) {
            [[TRTCCalling shareInstance] lineBusy];
            [self onLineBusy:@""]; // 仅仅提示用户忙线，不做calling处理
            return;
        }
    }
    
    self.userIDs = [NSArray arrayWithArray:userIDs];
    self.currentCallingRole = TTUICallingRoleCalled;
    self.currentCallingType = [self transformCallType:callType];
    
    if ([self checkAuthorizationStatusIsDenied]) {
        return;
    }
    
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
    [self handleStopAudio];
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[uid] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *userInfo = [infoList firstObject];
        if (!userInfo) return;
        [weakSelf startTimer];
        [weakSelf enableAutoLockScreen:NO];
        CallUserModel *userModel = [weakSelf covertUser:userInfo];
        [weakSelf.callingView enterUser:userModel];
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
    [self makeToast:CallingLocalize(@"Demo.TRTC.calling.callingcancel") uid:uid];
    [self handleCallEnd];
    [self handleCallEvent:TUICallingEventCallFailed message:EVENT_CALL_CNACEL];
}

- (void)onCallingTimeOut {
    NSLog(@"log: onCallingTimeOut");
    [self makeToast:CallingLocalize(@"Demo.TRTC.calling.callingtimeout")];
    [self handleCallEnd];
    [self handleCallEvent:TUICallingEventCallFailed message:EVENT_CALL_TIMEOUT];
}

- (void)onCallEnd {
    NSLog(@"onCallEnd \n %s", __FUNCTION__);
    [self handleCallEnd];
    [self handleCallEvent:TUICallingEventCallEnd message:EVENT_CALL_HANG_UP];
}

- (void)onUserAudioAvailable:(NSString *)uid available:(BOOL)available {
    NSLog(@"log: onUserAudioAvailable: %@, available: %d",uid, available);
    if (self.callingView) {
        CallUserModel *userModel = [self.callingView getUserById:uid];
        if (userModel) {
            userModel.isEnter = YES;
            userModel.isAudioAvaliable = available;
            [self.callingView updateUser:userModel animated:NO];
        }
    }
}

- (void)onUserVoiceVolume:(NSString *)uid volume:(UInt32)volume {
    if (!self.callingView) return;
    CallUserModel *user = [self.callingView getUserById:uid];
    
    if (user) {
        CallUserModel *newUser = user;
        newUser.isEnter = YES;
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
        
        NSString *toast = @"";
        switch (removeReason) {
            case TUICallingUserRemoveReasonReject:
                if (![TRTCCalling shareInstance].isBeingCalled) {
                    toast = CallingLocalize(@"Demo.TRTC.calling.callingrefuse");
                }
                [weakSelf handleCallEvent:TUICallingEventCallFailed message:EVENT_CALL_HANG_UP];
                break;
            case TUICallingUserRemoveReasonNoresp:
                toast = CallingLocalize(@"Demo.TRTC.calling.callingnoresponse");
                [weakSelf handleCallEvent:TUICallingEventCallFailed message:EVENT_CALL_NO_RESP];
                break;
            case TUICallingUserRemoveReasonBusy:
                toast = CallingLocalize(@"Demo.TRTC.calling.callingbusy");
                [weakSelf handleCallEvent:TUICallingEventCallFailed message:EVENT_CALL_LINE_BUSY];
                break;
            default:
                break;
        }
        
        if (toast && toast.length > 0) {
            NSString *userStr = callUserModel.name ?: callUserModel.userId;
            toast = [NSString stringWithFormat:@"%@ %@", userStr, toast];
            [weakSelf makeToast:toast];
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

- (void)makeToast:(NSString *)toast uid:(NSString *)uid {
    if (uid && uid.length > 0) {
        __weak typeof(self) weakSelf = self;
        [[V2TIMManager sharedInstance] getUsersInfo:@[uid] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            V2TIMUserFullInfo *userFullInfo = [infoList firstObject];
            NSString *toastStr = [NSString stringWithFormat:@"%@ %@", userFullInfo.nickName ?: userFullInfo.userID, toast];
            [weakSelf makeToast:toastStr duration:3 position:nil];
        } fail:nil];
        return;
    }
    [self makeToast:toast duration:3 position:nil];
}

- (void)makeToast:(NSString *)toast {
    [self makeToast:toast duration:3 position:nil];
}

- (void)makeToast:(NSString *)toast duration:(NSTimeInterval)duration position:(id)position {
    if (!toast || toast.length <= 0)  return;
    
    if (self.callingView) {
        [self.callingView makeToast:toast duration:duration position:position];
    } else {
        [[TUICommonUtil getRootWindow] makeToast:toast duration:duration position:position];
    }
}

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
    
    [self handleCallEvent:TUICallingEventCallSucceed message:EVENT_CALL_SUCCEED];
    [self handleCallEvent:TUICallingEventCallStart message:EVENT_CALL_START];
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
