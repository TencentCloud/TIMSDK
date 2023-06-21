//
//  TUICallKit.m
//  TUICalling
//
//  Created by noah on 2021/8/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TUICallKit.h"
#import <AVFoundation/AVCaptureDevice.h>
#import "TUICallEngineHeader.h"
#import "CallingLocalized.h"
#import "TUICallingAudioPlayer.h"
#import "TUICallingFloatingWindowManager.h"
#import "TUILogin.h"
#import "TUIDefine.h"
#import "TUICallingUserManager.h"
#import "TUICallingViewManager.h"
#import "TUICallingCommon.h"
#import "TUICallingAction.h"
#import "TUICallingStatusManager.h"
#import "TUICallKitHeader.h"
#import "TUICallingUserModel.h"
#import "TUICallKitGCDTimer.h"
#import "TUICallKitOfflinePushInfoConfig.h"
#import "TUICallKitConstants.h"

typedef NS_ENUM(NSUInteger, TUICallingUserRemoveReason) {
    TUICallingUserRemoveReasonLeave,
    TUICallingUserRemoveReasonReject,
    TUICallingUserRemoveReasonNoResp,
    TUICallingUserRemoveReasonBusy
};

static NSString * const TUI_CALLING_BELL_KEY = @"CallingBell";

@interface TUICallKit () <TUICallObserver>

@property (nonatomic, strong) TUICallingViewManager *callingViewManager;
/// Calling Media Type: Audio/Video
@property (nonatomic, assign) TUICallMediaType currentCallingType;
@property (nonatomic, assign) TUICallRole currentCallingRole;
@property (nonatomic, assign) BOOL enableMuteMode;
@property (nonatomic, assign) BOOL enableCustomViewRoute;
@property (nonatomic, copy) NSString *timerName;
@property (nonatomic, assign) NSInteger totalTime;
@property (nonatomic, assign) BOOL needContinuePlaying;
@property (nonatomic, copy) NSString *groupID;

@end

@implementation TUICallKit

+ (instancetype)createInstance {
    static dispatch_once_t onceToken;
    static TUICallKit * t_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        t_sharedInstance = [[TUICallKit alloc] init];
    });
    return t_sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enableMuteMode = NO;
        _currentCallingRole = NO;
        _enableCustomViewRoute = NO;
        _callingViewManager = [[TUICallingViewManager alloc] init];
        [[TUICallingStatusManager shareInstance] setDelegate:self.callingViewManager];
        [self initCallEngine];
        [[TUICallEngine createInstance] addObserver:self];
        [self registerNotifications];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Method

- (void)call:(NSString *)userId callMediaType:(TUICallMediaType)callMediaType {
    TUILog(@"TUICallKit - call, userId:%@, callMediaType:%ld", userId, callMediaType);
    [self call:userId callMediaType:callMediaType params:[self getCallParams] succ:nil fail:nil];
}

- (void)call:(NSString *)userId
callMediaType:(TUICallMediaType)callMediaType
      params:(TUICallParams *)params
        succ:(TUICallSucc __nullable)succ
        fail:(TUICallFail __nullable)fail {
    TUILog(@"TUICallKit - call, userId:%@, callMediaType:%ld, params:%@", userId, callMediaType, params.description);
    if (!userId || ![userId isKindOfClass:[NSString class]] || userId.length <= 0) {
        if (fail) {
            fail(ERROR_PARAM_INVALID, @"call failed, invalid params 'userId'");
        }
        return;
    }
    if (![TUILogin getUserID]) {
        if (fail) {
            fail(ERROR_INIT_FAIL, @"call failed, please login");
        }
        return;
    }
    if ([[TUICallingFloatingWindowManager shareInstance] isFloating]) {
        if (fail) {
            fail(ERROR_PARAM_INVALID, @"call failed, Unable to restart the call");
        }
        [self makeToast:TUICallingLocalize(@"Demo.TRTC.Calling.UnableToRestartTheCall")];
        return;
    }
    if ([TUICallingCommon checkAuthorizationStatusIsDenied:callMediaType]) {
        [self showAuthorizationAlert:callMediaType];
        if (fail) {
            fail(ERROR_PARAM_INVALID, @"call failed, authorization status is denied");
        }
        return;
    }
    
    self.currentCallingType = callMediaType;
    self.currentCallingRole = TUICallRoleCall;
    __weak typeof(self) weakSelf = self;
    [[TUICallEngine createInstance] call:userId callMediaType:callMediaType params:params succ:^{
        __strong typeof(self) strongSelf = weakSelf;
        if (succ) {
            succ();
        }
        [strongSelf.callingViewManager createCallingView:callMediaType callRole:TUICallRoleCall callScene:TUICallSceneSingle];
        [strongSelf callStart:@[userId] type:callMediaType role:TUICallRoleCall];
        [strongSelf updateCallingView:@[userId] callScene:TUICallSceneSingle sponsor:[TUILogin getUserID]];
    } fail:^(int code, NSString *errMsg) {
        __strong typeof(self) strongSelf = weakSelf;
        if (fail) {
            fail(code, errMsg);
        }
        [strongSelf handleAbilityFailErrorMessage:code errorMessage:errMsg];
    }];
}

- (void)groupCall:(NSString *)groupId userIdList:(NSArray<NSString *> *)userIdList callMediaType:(TUICallMediaType)callMediaType {
    TUILog(@"TUICallKit - groupCall, groupId:%@, userIdList:%@, callMediaType:%ld", groupId, userIdList, callMediaType);
    [self groupCall:groupId userIdList:userIdList callMediaType:callMediaType params:[self getCallParams] succ:nil fail:nil];
}

- (void)groupCall:(NSString *)groupId
       userIdList:(NSArray<NSString *> *)userIdList
    callMediaType:(TUICallMediaType)callMediaType
           params:(TUICallParams *)params
             succ:(TUICallSucc __nullable)succ
             fail:(TUICallFail __nullable)fail {
    TUILog(@"TUICallKit - groupCall, groupId:%@, userIdList:%@, callMediaType:%ld, params:%@", groupId, userIdList, callMediaType, params.description);
    if (![TUICallingCommon checkArrayValid:userIdList]) {
        if (fail) {
            fail(ERROR_PARAM_INVALID, @"groupCall failed, invalid params 'userIdList'");
        }
        return;
    }
    if (![TUILogin getUserID]) {
        if (fail) {
            fail(ERROR_PARAM_INVALID, @"groupCall failed, please login");
        }
        return;
    }
    if (!(groupId && [groupId isKindOfClass:[NSString class]] && groupId.length > 0)) {
        if (fail) {
            fail(ERROR_PARAM_INVALID, @"groupCall failed, invalid params 'groupId'");
        }
        return;
    }
    if ([[TUICallingFloatingWindowManager shareInstance] isFloating]) {
        if (fail) {
            fail(ERROR_PARAM_INVALID, @"groupCall failed, invalid params 'userIdList'");
        }
        [self makeToast:TUICallingLocalize(@"Demo.TRTC.Calling.UnableToRestartTheCall")];
        return;
    }
    // Maximum support 9 people More than 9 people cannot initiate a call
    if (userIdList.count >= 9) {
        if (fail) {
            fail(ERROR_PARAM_INVALID, @"groupCall failed, currently supports call with up to 9 people");
        }
        [self makeToast:TUICallingLocalize(@"Demo.TRTC.Calling.User.Exceed.Limit")];
        return;
    }
    if ([TUICallingCommon checkAuthorizationStatusIsDenied:callMediaType]) {
        [self showAuthorizationAlert:callMediaType];
        if (fail) {
            fail(ERROR_PARAM_INVALID, @"groupCall failed, authorization status is denied");
        }
        return;
    }
    
    self.groupID = groupId;
    self.currentCallingType = callMediaType;
    self.currentCallingRole = TUICallRoleCall;
    __weak typeof(self) weakSelf = self;
    [[TUICallEngine createInstance] groupCall:groupId
                                   userIdList:userIdList
                                callMediaType:callMediaType
                                       params:params
                                         succ:^{
        __strong typeof(self) strongSelf = weakSelf;
        if (succ) {
            succ();
        }
        TUICallScene callScene = [strongSelf getCallScene:userIdList];
        [strongSelf.callingViewManager createCallingView:callMediaType callRole:TUICallRoleCall callScene:callScene];
        [strongSelf callStart:userIdList type:callMediaType role:TUICallRoleCall];
        [strongSelf updateCallingView:userIdList callScene:callMediaType sponsor:[TUILogin getUserID]];
    } fail:^(int code, NSString *errMsg) {
        __strong typeof(self) strongSelf = weakSelf;
        if (fail) {
            fail(code, errMsg);
        }
        [strongSelf handleAbilityFailErrorMessage:code errorMessage:errMsg];
    }];
}

- (void)joinInGroupCall:(TUIRoomId *)roomId groupId:(NSString *)groupId callMediaType:(TUICallMediaType)callMediaType {
    TUILog(@"TUICallKit - joinInGroupCall, roomId:%u, groupId:%@, callMediaType:%ld", roomId.intRoomId, groupId, callMediaType);
    if (!(roomId)) {
        TUILog(@"TUICallKit - joinInGroupCall failed, roomId is invalid");
        return;
    }
    if (!groupId) {
        TUILog(@"TUICallKit - joinInGroupCall failed, groupId is invalid");
        return;
    }
    if ([TUICallingCommon checkAuthorizationStatusIsDenied:callMediaType]) {
        [self showAuthorizationAlert:callMediaType];
        TUILog(@"TUICallKit - joinInGroupCall failed, authorization status is denied");
        return;
    }
    
    self.groupID = groupId;
    self.currentCallingRole = TUICallRoleCalled;
    self.currentCallingType = callMediaType;
    [self.callingViewManager createGroupCallingAcceptView:callMediaType callRole:TUICallRoleCalled callScene:TUICallSceneGroup];
    [self showCallKitView];
    
    __weak typeof(self) weakSelf = self;
    [[TUICallEngine createInstance] joinInGroupCall:roomId groupId:groupId callMediaType:callMediaType succ:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf updateCallingView:@[[TUILogin getUserID]] callScene:TUICallSceneGroup sponsor:nil];
        if (!strongSelf.timerName.length) {
            [strongSelf startTimer];
        }
        [strongSelf enableAutoLockScreen:NO];
    } fail:^(int code, NSString *errMsg) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleAbilityFailErrorMessage:code errorMessage:errMsg];
    }];
}

- (void)updateCallingView:(NSArray<NSString *> *)userIDs callScene:(TUICallScene)callScene sponsor:(NSString *)sponsor {
    if (![TUICallingCommon checkArrayValid:userIDs]) {
        return;
    }
    
    NSMutableArray *allUserIDs = [NSMutableArray arrayWithArray:userIDs];
    if ((callScene != TUICallSceneSingle) && sponsor) {
        [allUserIDs addObject:sponsor];
    }
    
    NSMutableSet *userIDSet = [NSMutableSet setWithArray:[allUserIDs copy]];
    if (sponsor) {
        [userIDSet addObject:sponsor];
    }
    
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:[userIDSet allObjects] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        __strong typeof(self) strongSelf = weakSelf;
        if (infoList.count < 1) {
            return;
        }
        
        NSMutableArray <CallingUserModel *> *modelList = [NSMutableArray array];
        CallingUserModel *sponsorModel = nil;
        
        for (V2TIMUserFullInfo *userFullInfo in infoList) {
            CallingUserModel *userModel = [TUICallingCommon covertUser:userFullInfo];
            
            if (sponsor && [userModel.userId isEqualToString:sponsor]) {
                sponsorModel = userModel;
                
                if ([allUserIDs containsObject:sponsor]) {
                    [modelList addObject:userModel];
                }
            } else {
                [modelList addObject:userModel];
            }
            
            [TUICallingUserManager cacheUser:userModel];
        }
        
        [strongSelf.callingViewManager updateCallingView:[modelList copy] sponsor:sponsorModel];
    } fail:^(int code, NSString *desc) {
        
    }];
}

- (void)setCallingBell:(NSString *)filePath {
    TUILog(@"TUICallKit - setCallingBell, filePath:%@", filePath);
    if(!(filePath && [filePath isKindOfClass:NSString.class] && filePath.length > 0)) {
        return;
    }
    
    if ([filePath hasPrefix:@"http"]) {
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:filePath]
                                                            completionHandler:^(NSURL * _Nullable location,
                                                                                NSURLResponse * _Nullable response,
                                                                                NSError * _Nullable error) {
            if (error != nil) {
                return;
            }
            
            if (location != nil) {
                NSString *oldBellFilePath = [NSUserDefaults.standardUserDefaults objectForKey:TUI_CALLING_BELL_KEY];
                [[NSFileManager defaultManager] removeItemAtPath:oldBellFilePath error:nil];
                NSString *filePathStr = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePathStr] error:nil];
                [NSUserDefaults.standardUserDefaults setObject:filePathStr ?: @"" forKey:TUI_CALLING_BELL_KEY];
                [NSUserDefaults.standardUserDefaults synchronize];
            }
        }];
        [downloadTask resume];
    } else {
        [NSUserDefaults.standardUserDefaults setObject:filePath forKey:TUI_CALLING_BELL_KEY];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

- (void)setSelfInfo:(NSString * _Nullable)nickname avatar:(NSString * _Nullable)avatar succ:(TUICallSucc)succ fail:(TUICallFail)fail {
    TUILog(@"TUICallKit - setSelfInfo, nickname:%@, avatar:%@", nickname, avatar);
    [[TUICallEngine createInstance] setSelfInfo:nickname avatar:avatar succ:succ fail:fail];
}

- (void)enableMuteMode:(BOOL)enable {
    TUILog(@"TUICallKit - enableMuteMode, enable:%d", enable);
    self.enableMuteMode = enable;
    if (enable) {
        [TUICallingAction openMicrophone];
    } else {
        [TUICallingAction closeMicrophone];
    }
}

- (void)enableFloatWindow:(BOOL)enable {
    TUILog(@"TUICallKit - enableFloatWindow, enable:%d", enable);
    [self.callingViewManager enableFloatWindow:enable];
}

- (void)enableCustomViewRoute:(BOOL)enable {
    TUILog(@"TUICallKit - enableCustomViewRoute, enable:%d", enable);
    self.enableCustomViewRoute = enable;
}

- (UIViewController * _Nullable)getCallViewController {
    TUILog(@"TUICallKit - getCallViewController");
    UIViewController *callViewController = nil;
    if (self.enableCustomViewRoute) {
        callViewController = [[UIViewController alloc] init];
        callViewController.view.backgroundColor = [UIColor clearColor];
        [callViewController.view addSubview:[self.callingViewManager getCallingView]];
    }
    return callViewController;
}

#pragma mark - TUICallObserver

- (void)onError:(int)code message:(NSString * _Nullable)message {
    NSString *toast = [NSString stringWithFormat:@"Error code: %d, Message: %@", code, message];
    
    if (code == ERR_ROOM_ENTER_FAIL) {
        [self makeToast:toast duration:3 position:TUICSToastPositionCenter];
    } else if(code == ERROR_REQUEST_REPEATED) {
        [self makeToast:TUICallingLocalize(@"Demo.TRTC.Calling.UnableToRestartTheCall")];
    } else if (code != ERR_INVALID_PARAMETERS) {
        [self makeToast:toast];
    }
}

- (void)onUserJoin:(nonnull NSString *)userId {
    CallingUserModel *userModel = [TUICallingUserManager getUser:userId];
    
    if (userModel) {
        [self.callingViewManager userEnter:userModel];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[userId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        __strong typeof(self) strongSelf = weakSelf;
        V2TIMUserFullInfo *userInfo = [infoList firstObject];
        if (!userInfo) {
            return;
        }
        CallingUserModel *userModel = [TUICallingCommon covertUser:userInfo];
        [strongSelf.callingViewManager userEnter:userModel];
        [TUICallingUserManager cacheUser:userModel];
    } fail:nil];
    
}

- (void)onUserLeave:(nonnull NSString *)userId {
    [self handleUserLeave:userId removeReason:TUICallingUserRemoveReasonLeave];
}

- (void)onUserReject:(nonnull NSString *)userId {
    [self handleUserLeave:userId removeReason:TUICallingUserRemoveReasonReject];
}

- (void)onUserNoResponse:(nonnull NSString *)userId {
    [self handleUserLeave:userId removeReason:TUICallingUserRemoveReasonNoResp];
}

- (void)onUserLineBusy:(nonnull NSString *)userId {
    [self handleUserLeave:userId removeReason:TUICallingUserRemoveReasonBusy];
}

- (void)onUserAudioAvailable:(nonnull NSString *)userId isAudioAvailable:(BOOL)isAudioAvailable {
    CallingUserModel *userModel = [TUICallingUserManager getUser:userId];
    
    if (userModel) {
        userModel.isEnter = YES;
        userModel.isAudioAvailable = isAudioAvailable;
        [self.callingViewManager updateUser:userModel];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[userId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        __strong typeof(self) strongSelf = weakSelf;
        CallingUserModel *userModel = [TUICallingUserManager getUser:userId];
        if (!userModel) {
            V2TIMUserFullInfo *userInfo = [infoList firstObject];
            userModel = [TUICallingCommon covertUser:userInfo];
        }
        userModel.isEnter = YES;
        userModel.isAudioAvailable = isAudioAvailable;
        if (isAudioAvailable) {
            [TUICallingUserManager cacheUser:userModel];
        }
        [strongSelf.callingViewManager updateUser:userModel];
    } fail:nil];
}

- (void)onUserVideoAvailable:(nonnull NSString *)userId isVideoAvailable:(BOOL)isVideoAvailable {
    CallingUserModel *userModel = [TUICallingUserManager getUser:userId];
    
    if (userModel) {
        userModel.isEnter = YES;
        userModel.isVideoAvailable = isVideoAvailable;
        [self.callingViewManager updateUser:userModel];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[userId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        __strong typeof(self) strongSelf = weakSelf;
        
        CallingUserModel *userModel = [TUICallingUserManager getUser:userId];
        if (!userModel) {
            V2TIMUserFullInfo *userInfo = [infoList firstObject];
            userModel = [TUICallingCommon covertUser:userInfo];
        }
        userModel.isEnter = YES;
        userModel.isVideoAvailable = isVideoAvailable;
        if (isVideoAvailable) {
            [TUICallingUserManager cacheUser:userModel];
        }
        [strongSelf.callingViewManager updateUser:userModel];
    } fail:nil];
}

- (void)onUserVoiceVolumeChanged:(nonnull NSDictionary<NSString *, NSNumber *> *)volumeMap {
    NSArray *keyArray = volumeMap.allKeys;
    
    for (NSString *userId in keyArray) {
        CallingUserModel *userModel = [TUICallingUserManager getUser:userId];
        if (userModel) {
            CallingUserModel *newUser = userModel;
            newUser.isEnter = YES;
            newUser.volume = [volumeMap[userId] floatValue] / 100;
            [self.callingViewManager updateUser:newUser];
        }
    }
}

- (void)onUserNetworkQualityChanged:(nonnull NSArray<TUINetworkQualityInfo *> *)networkQualityList {
    
}

- (void)onCallReceived:(nonnull NSString *)callerId
          calleeIdList:(nonnull NSArray<NSString *> *)calleeIdList
               groupId:(NSString *)groupId
         callMediaType:(TUICallMediaType)callMediaType
              userData:(NSString *)userData {
    if (![TUICallingCommon checkArrayValid:calleeIdList]) {
        return;
    }
    
    NSMutableArray *userArray = [NSMutableArray arrayWithArray:calleeIdList];
    [userArray addObject:callerId];
    [userArray removeObject:[TUILogin getUserID]];
    self.currentCallingRole = TUICallRoleCalled;
    self.currentCallingType = callMediaType;
    [TUICallingStatusManager shareInstance].groupId = groupId;
    TUICallScene callScene =  [self getCallScene:calleeIdList];
    if (groupId && [groupId isKindOfClass:NSString.class] && groupId.length > 0) {
        callScene = TUICallSceneGroup;
    }
    [self.callingViewManager createCallingView:callMediaType callRole:TUICallRoleCalled callScene:callScene];
    [self callStart:calleeIdList type:callMediaType role:TUICallRoleCalled];
    
    NSMutableArray *allUserIdList = [NSMutableArray arrayWithArray:calleeIdList];
    if ((callScene != TUICallSceneSingle) && callerId) {
        [allUserIdList addObject:callerId];
    }
    
    [self updateCallingView:calleeIdList callScene:callScene sponsor:callerId];
    
    if ((UIApplicationStateActive == [UIApplication sharedApplication].applicationState) &&
        [TUICallingCommon checkAuthorizationStatusIsDenied:callMediaType]) {
        [self showAuthorizationAlert:callMediaType];
    }
}

- (void)onCallCancelled:(nonnull NSString *)callerId {
    [self callEnd];
}

- (void)onCallBegin:(nonnull TUIRoomId *)roomId callMediaType:(TUICallMediaType)callMediaType callRole:(TUICallRole)callRole {
    [self stopAudio];
    [TUICallingStatusManager shareInstance].callStatus = TUICallStatusAccept;
    
    if (!self.timerName.length) {
        [self startTimer];
    }
    
    [self enableAutoLockScreen:NO];
}

- (void)onCallEnd:(nonnull TUIRoomId *)roomId
    callMediaType:(TUICallMediaType)callMediaType
         callRole:(TUICallRole)callRole
        totalTime:(float)totalTime {
    [self callEnd];
}

- (void)onCallMediaTypeChanged:(TUICallMediaType)oldCallMediaType newCallMediaType:(TUICallMediaType)newCallMediaType {
    if (oldCallMediaType == TUICallMediaTypeVideo && newCallMediaType == TUICallMediaTypeAudio) {
        self.currentCallingType = TUICallMediaTypeAudio;
        [TUICallingStatusManager shareInstance].audioPlaybackDevice = TUIAudioPlaybackDeviceEarpiece;
        [TUICallingStatusManager shareInstance].callMediaType = TUICallMediaTypeAudio;
    }
}

- (void)handleUserLeave:(NSString *)userId removeReason:(TUICallingUserRemoveReason)removeReason {
    if (!(userId && [userId isKindOfClass:NSString.class] && userId.length > 0)) {
        return;
    }
    
    CallingUserModel *userModel = [TUICallingUserManager getUser:userId];
    
    if (userModel) {
        userModel.isEnter = YES;
        [TUICallingUserManager removeUser:userId];
        [self.callingViewManager userLeave:userModel];
        [self handleUserLeaveToast:userModel reason:removeReason];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[userId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        __strong typeof(self) strongSelf = weakSelf;
        V2TIMUserFullInfo *userInfo = [infoList firstObject];
        if (!userInfo) {
            return;
        }
        CallingUserModel *userModel = [TUICallingCommon covertUser:userInfo];
        [strongSelf.callingViewManager userLeave:userModel];
        [strongSelf handleUserLeaveToast:userModel reason:removeReason];
    } fail:nil];
}

- (void)handleUserLeaveToast:(CallingUserModel *)userModel reason:(TUICallingUserRemoveReason)reason {
    NSString *toast = @"";
    switch (reason) {
        case TUICallingUserRemoveReasonReject:
            toast = TUICallingLocalize(@"Demo.TRTC.calling.callingrefuse");
            break;
        case TUICallingUserRemoveReasonNoResp:
            toast = TUICallingLocalize(@"Demo.TRTC.calling.callingnoresponse");
            break;
        case TUICallingUserRemoveReasonBusy:
            toast = TUICallingLocalize(@"Demo.TRTC.calling.callingbusy");
            break;
        case TUICallingUserRemoveReasonLeave:
            toast = TUICallingLocalize(@"Demo.TRTC.calling.callingleave");
            break;
        default:
            break;
    }
    
    if (toast && toast.length > 0) {
        NSString *userStr = userModel.name ?: userModel.userId;
        toast = [NSString stringWithFormat:@"%@ %@", userStr, toast];
        [self makeToast:toast];
    }
}

- (void)onKickedOffline {
    [self stopCurrentCall];
}

- (void)onUserSigExpired {
    [self stopCurrentCall];
}

#pragma mark - Notifications

- (void)registerNotifications {
    if (@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidBecomeActive)
                                                     name:UISceneDidActivateNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSuccessNotification)
                                                 name:TUILoginSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutSuccessNotification)
                                                 name:TUILogoutSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callStatusChanged)
                                                 name:EventSubCallStatusChanged object:nil];
}

- (void)appDidBecomeActive {
    if ([TUICallingStatusManager shareInstance].callStatus != TUICallStatusNone) {
        [self showCallKitView];
        
        if ((TUICallStatusWaiting == [TUICallingStatusManager shareInstance].callStatus) &&
            [TUICallingCommon checkAuthorizationStatusIsDenied:[TUICallingStatusManager shareInstance].callMediaType]) {
            [self showAuthorizationAlert:[TUICallingStatusManager shareInstance].callMediaType];
        }
    }
    if (self.needContinuePlaying) {
        [self playAudioToCalled];
    }
    self.needContinuePlaying = NO;
}

- (void)loginSuccessNotification {
    [self initCallEngine];
    [[TUICallEngine createInstance] addObserver:self];
}

- (void)logoutSuccessNotification {
    [self stopCurrentCall];
}

- (void)callStatusChanged {
    if ([TUICallingStatusManager shareInstance].callStatus == TUICallStatusNone) {
        [self callEnd];
    }
}

#pragma mark - Private method

- (void)showCallKitView {
    if (!self.enableCustomViewRoute) {
        [self.callingViewManager showCallingView];
    }
}

- (void)handleAbilityFailErrorMessage:(int)errorCode errorMessage:(NSString *)errorMessage {
    NSString *errMsg = errorMessage;
    if (errorCode == ERROR_PACKAGE_NOT_PURCHASED) {
        errMsg = TUICallingLocalize(@"TUICallKit.package.not.purchased");
    } else if (errorCode == ERROR_PACKAGE_NOT_SUPPORTED) {
        errMsg = TUICallingLocalize(@"TUICallKit.package.not.support");
    }
    [self makeToast:errMsg duration:4 position:nil];
}

- (void)initCallEngine {
    [[TUICallEngine createInstance] init:[TUILogin getSdkAppID] userId:[TUILogin getUserID] userSig:[TUILogin getUserSig] succ:^{
    } fail:^(int code, NSString *errMsg) {
    }];
    
    TUIVideoEncoderParams *videoEncoderParams = [[TUIVideoEncoderParams alloc] init];
    videoEncoderParams.resolution = TUIVideoEncoderParamsResolution_640_360;
    videoEncoderParams.resolutionMode = TUIVideoEncoderParamsResolutionModePortrait;
    [[TUICallEngine createInstance] setVideoEncoderParams:videoEncoderParams succ:nil fail:nil];
    
    TUIVideoRenderParams *videoRenderParams = [[TUIVideoRenderParams alloc] init];
    videoRenderParams.fillMode = TUIVideoRenderParamsFillModeFill;
    videoRenderParams.rotation = TUIVideoRenderParamsRotation_0;
    [[TUICallEngine createInstance] setVideoRenderParams:[TUILogin getUserID] params:videoRenderParams succ:nil fail:nil];
    
    TXBeautyManager *beauty = [[[TUICallEngine createInstance] getTRTCCloudInstance] getBeautyManager];
    [beauty setBeautyStyle:TXBeautyStyleNature];
    [beauty setBeautyLevel:6];
}

- (void)stopCurrentCall {
    __weak typeof(self) weakSelf = self;
    [[TUICallEngine createInstance] hangup:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf callEnd];
        [TUICallEngine destroyInstance];
    } fail:^(int code, NSString *errMsg) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf callEnd];
        [TUICallEngine destroyInstance];
    }];
}

- (void)callStart:(NSArray *)userIDs type:(TUICallMediaType)type role:(TUICallRole)role {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self showCallKitView];
    }
    
    if (self.enableMuteMode) {
        return;
    }
    
    if (role == TUICallRoleCall) {
        playAudio(CallingAudioTypeDial);
        return;
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        self.needContinuePlaying = YES;
        return;
    }
    
    [self playAudioToCalled];
}

- (void)callEnd {
    [self.callingViewManager closeCallingView];
    [TUICallingUserManager clearCache];
    [self stopAudio];
    [TUICallKitGCDTimer cancelTimer:self.timerName];
    [self enableAutoLockScreen:YES];
    self.timerName = nil;
    self.groupID = nil;
    [[TUICallEngine createInstance] selectAudioPlaybackDevice:TUIAudioPlaybackDeviceSpeakerphone];
    [[TUICallingStatusManager shareInstance] clearAllStatus];
}

- (void)setGroupID:(NSString *)groupID {
    _groupID = groupID;
    [TUICallingStatusManager shareInstance].groupId = groupID;
}

- (void)playAudioToCalled {
    NSString *bellFilePath = [NSUserDefaults.standardUserDefaults objectForKey:TUI_CALLING_BELL_KEY];
    if (bellFilePath && playAudioWithFilePath(bellFilePath)) {
        return;
    }
    playAudio(CallingAudioTypeCalled);
}

- (void)stopAudio {
    stopAudio();
    self.needContinuePlaying = NO;
}

- (void)enableAutoLockScreen:(BOOL)isEnable {
    [UIApplication sharedApplication].idleTimerDisabled = !isEnable;
}

- (void)makeToast:(NSString *)toast userId:(NSString *)userId {
    if (userId && [userId isKindOfClass:NSString.class] && userId.length > 0) {
        __weak typeof(self) weakSelf = self;
        [[V2TIMManager sharedInstance] getUsersInfo:@[userId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            __strong typeof(self) strongSelf = weakSelf;
            V2TIMUserFullInfo *userFullInfo = [infoList firstObject];
            NSString *toastStr = [NSString stringWithFormat:@"%@ %@", userFullInfo.nickName ?: userFullInfo.userID, toast];
            [strongSelf makeToast:toastStr duration:3 position:nil];
        } fail:nil];
        return;
    }
    [self makeToast:toast duration:3 position:nil];
}

- (void)makeToast:(NSString *)toast {
    [self makeToast:toast duration:3 position:nil];
}

- (void)makeToast:(NSString *)toast duration:(NSTimeInterval)duration position:(id)position {
    if (!toast || toast.length <= 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TUICallingCommon getKeyWindow] makeToast:toast duration:duration position:position];
    });
}

- (TUICallScene)getCallScene:(NSArray <NSString *> *)userList {
    if (self.groupID && self.groupID.length > 0) {
        return TUICallSceneGroup;
    }
    
    if (userList && [userList isKindOfClass:NSArray.class] && userList.count  >= 2) {
        return TUICallSceneMulti;
    }
    
    return TUICallSceneSingle;
}

- (void)showAuthorizationAlert:(TUICallMediaType)callMediaType {
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AuthorizationDeniedType deniedType = AuthorizationDeniedTypeAudio;
    
    if ((callMediaType == TUICallMediaTypeVideo) && (statusVideo == AVAuthorizationStatusDenied)) {
        deniedType = AuthorizationDeniedTypeVideo;
    }
    
    [TUICallingCommon showAuthorizationAlert:deniedType openSettingHandler:^{
        [[TUICallEngine createInstance] hangup:nil fail:nil];
    } cancelHandler:^{
        [[TUICallEngine createInstance] hangup:nil fail:nil];
    }];
}

- (void)startTimer {
    self.totalTime = 0;
    NSTimeInterval interval = 1.0;
    __weak typeof(self) weakSelf = self;
    self.timerName = [TUICallKitGCDTimer timerTask:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.totalTime += (NSInteger)interval;
        NSString *minutes = [NSString stringWithFormat:@"%@%ld", (strongSelf.totalTime / 60 < 10) ? @"0" : @"", (NSInteger)(strongSelf.totalTime / 60)];
        NSString *seconds = [NSString stringWithFormat:@"%@%ld", (strongSelf.totalTime % 60 < 10) ? @"0" : @"", strongSelf.totalTime % 60];
        [strongSelf.callingViewManager updateCallingTimeStr:[NSString stringWithFormat:@"%@ : %@", minutes, seconds]];
    } start:0 interval:interval repeats:YES async:NO];
}

- (TUICallParams *)getCallParams {
    TUIOfflinePushInfo *offlinePushInfo = [TUICallKitOfflinePushInfoConfig createOfflinePushInfo];
    TUICallParams *callParams = [TUICallParams new];
    callParams.offlinePushInfo = offlinePushInfo;
    callParams.timeout = TUI_CALLKIT_SIGNALING_MAX_TIME;
    return callParams;
}

@end
