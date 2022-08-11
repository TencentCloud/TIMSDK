//
//  TUICallingViewManager.m
//  TUICalling
//
//  Created by noah on 2022/5/17.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingViewManager.h"
#import "BaseCallViewProtocol.h"
#import "TUICallingGroupView.h"
#import "TUICallingSingleView.h"
#import "BaseUserViewProtocol.h"
#import "TUICallingUserView.h"
#import "TUICallingSingleVideoUserView.h"
#import "BaseFunctionViewProtocol.h"
#import "TUICallingWaitFunctionView.h"
#import "TUICallingAudioFunctionView.h"
#import "TUICallingVideoFunctionView.h"
#import "TUICallingVideoInviteFunctionView.h"
#import "TUICallingSwitchToAudioView.h"
#import "TUICallingTimerView.h"
#import "TUICallingVideoRenderView.h"
#import "UIWindow+TUICalling.h"
#import "Masonry.h"
#import "UIColor+TUICallingHex.h"
#import "TUICallingAction.h"
#import "TUICallingCalleeView.h"
#import "TUICallingFloatingWindowManager.h"
#import "TUICallingUserManager.h"
#import "TUIDefine.h"
#import "TUICallEngineHeader.h"

@interface TUICallingViewManager () <TUICallingFloatingWindowManagerDelegate>

@property (nonatomic, strong) UIWindow *callingWindow;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView <BaseUserViewProtocol> *callingUserView;
@property (nonatomic, strong) UIView <BaseFunctionViewProtocol> *callingFunctionView;
@property (nonatomic, strong) UIView <BaseCallViewProtocol> *backgroundView;
@property (nonatomic, strong) TUICallingSwitchToAudioView *switchToAudioView;
@property (nonatomic, strong) TUICallingTimerView *timerView;
@property (nonatomic, strong) TUICallingCalleeView *callingCalleeView;
@property (nonatomic, strong) TUICallingVideoRenderView *localPreView;
@property (nonatomic, strong) TUICallingVideoRenderView *remotePreView;
@property (nonatomic, strong) UIButton *floatingWindowBtn;
/// Add other user button
@property (nonatomic, strong) UIButton *addOtherUserBtn;
@property (nonatomic, strong) CallingUserModel *remoteUser;
/// Calling Role
@property (nonatomic, assign) TUICallRole callRole;
@property (nonatomic, assign) TUICallScene callScene;
/// Is Enable FloatWindow
@property (nonatomic, assign) BOOL enableFloatWindow;

@end

@implementation TUICallingViewManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [[TUICallingFloatingWindowManager shareInstance] setFloatingWindowManagerDelegate:self];
        self.containerView.backgroundColor = [UIColor t_colorWithHexString:@"#F2F2F2"];
        self.enableFloatWindow = NO;
    }
    return self;
}

#pragma mark - Initialize Waiting View

- (void)initSingleWaitingView {
    [self clearAllSubViews];
    
    switch ([TUICallingStatusManager shareInstance].callType) {
        case TUICallMediaTypeAudio:{
            [self initSingleAudioWaitingView];
        } break;
        case TUICallMediaTypeVideo:{
            [self initSingleVideoWaitingView];
        } break;
        case TUICallMediaTypeUnknown:
        default:
            break;
    }
}

- (void)initSingleAudioWaitingView {
    self.callingUserView = [[TUICallingUserView alloc] initWithFrame:CGRectZero];
    
    if (self.callRole == TUICallRoleCall) {
        self.callingFunctionView = [[TUICallingAudioFunctionView alloc] initWithFrame:CGRectZero];
    } else {
        self.callingFunctionView = [[TUICallingWaitFunctionView alloc] initWithFrame:CGRectZero];
    }
    
    [self.containerView addSubview:self.callingUserView];
    [self.containerView addSubview:self.callingFunctionView];
    [self makeUserViewConstraints:75.0f];
    [self makeFunctionViewConstraints:92.0f];
    [self initMicMute:YES];
    [self initHandsFree:TUIAudioPlaybackDeviceEarpiece];
}

- (void)initSingleVideoWaitingView {
    self.backgroundView = [[TUICallingSingleView alloc] initWithFrame:self.containerView.frame localPreView:self.localPreView remotePreView:self.remotePreView];
    self.callingUserView = [[TUICallingSingleVideoUserView alloc] initWithFrame:CGRectZero];
    
    if (self.callRole == TUICallRoleCall) {
        self.callingFunctionView = [[TUICallingVideoInviteFunctionView alloc] initWithFrame:CGRectZero];
    } else {
        self.callingFunctionView = [[TUICallingWaitFunctionView alloc] initWithFrame:CGRectZero];
    }
    
    [self.containerView addSubview:self.backgroundView];
    [self.containerView addSubview:self.callingUserView];
    [self.containerView addSubview:self.switchToAudioView];
    [self.containerView addSubview:self.callingFunctionView];
    [self makeUserViewConstraints:20.0f];
    [self makeSwitchToAudioViewConstraints:8.0f];
    [self makeFunctionViewConstraints:92.0f];
}

- (void)initGroupWaitingView {
    [self clearAllSubViews];
    
    switch (self.callRole) {
        case TUICallRoleCall:{
            self.backgroundView = [[TUICallingGroupView alloc] initWithFrame:self.containerView.frame localPreView:self.localPreView];
            [self.containerView addSubview:self.backgroundView];
            self.callingFunctionView = nil;
            if ([TUICallingStatusManager shareInstance].callType == TUICallMediaTypeVideo) {
                self.callingFunctionView = [[TUICallingVideoFunctionView alloc] initWithFrame:CGRectZero];
            } else {
                self.callingFunctionView = [[TUICallingAudioFunctionView alloc] initWithFrame:CGRectZero];
            }
            [self.containerView addSubview:self.callingFunctionView];
            [self makeFunctionViewConstraints:190.0f];
        } break;
        case TUICallRoleCalled:{
            self.callingUserView = [[TUICallingUserView alloc] initWithFrame:CGRectZero];
            self.callingFunctionView = nil;
            self.callingFunctionView = [[TUICallingWaitFunctionView alloc] initWithFrame:CGRectZero];
            [self.containerView addSubview:self.callingUserView];
            [self.containerView addSubview:self.callingCalleeView];
            [self.containerView addSubview:self.callingFunctionView];
            [self makeUserViewConstraints:75.0f];
            [self makeCallingCalleeViewConstraints];
            [self makeFunctionViewConstraints:92.0f];
        } break;
        case TUICallRoleNone:
        default:
            break;
    }
    
    [self initMicMute:YES];
    [self initHandsFree:TUIAudioPlaybackDeviceSpeakerphone];
}

#pragma mark - Initialize Accept View

- (void)initSingleAcceptCallView {
    switch ([TUICallingStatusManager shareInstance].callType) {
        case TUICallMediaTypeAudio:{
            [self initSingleAudioAcceptCallView];
            [self initMicMute:[TUICallingStatusManager shareInstance].isMicMute];
            if (self.callRole == TUICallRoleCalled) {
                [self initHandsFree:TUIAudioPlaybackDeviceEarpiece];
            }
        } break;
        case TUICallMediaTypeVideo:{
            [self initSingleVideoAcceptCallView];
        } break;
        case TUICallMediaTypeUnknown:
        default:
            break;
    }
}

- (void)initSingleAudioAcceptCallView {
    if (!(self.callingUserView && [self.callingUserView isKindOfClass:[TUICallingUserView class]])) {
        [self clearCallingUserView];
        self.callingUserView = [[TUICallingUserView alloc] initWithFrame:CGRectZero];
    }
    
    if (!(self.callingFunctionView && [self.callingFunctionView isKindOfClass:[TUICallingAudioFunctionView class]])) {
        [self clearCallingFunctionView];
        self.callingFunctionView = [[TUICallingAudioFunctionView alloc] initWithFrame:CGRectZero];
    }
    
    [self.containerView addSubview:self.callingUserView];
    [self.containerView addSubview:self.timerView];
    [self.containerView addSubview:self.callingFunctionView];
    [self makeUserViewConstraints:75.0f];
    [self makeTimerViewConstraints:0.0f];
    [self makeFunctionViewConstraints:92.0f];
}

- (void)initSingleVideoAcceptCallView {
    if (!(self.backgroundView && [self.backgroundView isKindOfClass:[TUICallingSingleView class]])) {
        [self clearBackgroundView];
        self.backgroundView = [[TUICallingSingleView alloc] initWithFrame:self.containerView.frame localPreView:self.localPreView remotePreView:self.remotePreView];
    }
    
    if (!(self.callingFunctionView && [self.callingFunctionView isKindOfClass:[TUICallingVideoFunctionView class]])) {
        [self clearCallingFunctionView];
        self.callingFunctionView = [[TUICallingVideoFunctionView alloc] initWithFrame:CGRectZero];
        self.callingFunctionView.localPreView = self.localPreView;
    }
    
    [self.containerView addSubview:self.backgroundView];
    [self.containerView addSubview:self.switchToAudioView];
    [self.containerView addSubview:self.timerView];
    [self.containerView addSubview:self.callingFunctionView];
    [self makeSwitchToAudioViewConstraints:0.0f];
    [self makeTimerViewConstraints:54.0f];
    [self makeFunctionViewConstraints:190.0f];
    [self initMicMute:YES];
    [self initHandsFree:TUIAudioPlaybackDeviceSpeakerphone];
}

- (void)initGroupAcceptCallView {
    [self clearCallingUserView];
    [self clearCallingCalleeView];
    
    if (!(self.backgroundView && [self.backgroundView isKindOfClass:[TUICallingGroupView class]])) {
        [self clearBackgroundView];
        self.backgroundView = [[TUICallingGroupView alloc] initWithFrame:self.containerView.frame localPreView:self.localPreView];
    }
    
    CGFloat functionViewHeight = 0.0;
    if ([TUICallingStatusManager shareInstance].callType == TUICallMediaTypeVideo) {
        functionViewHeight = 190.0f;
        if (!(self.callingFunctionView && [self.callingFunctionView isKindOfClass:[TUICallingVideoFunctionView class]])) {
            [self clearCallingFunctionView];
            self.callingFunctionView = [[TUICallingVideoFunctionView alloc] initWithFrame:CGRectZero];
            self.callingFunctionView.localPreView = self.localPreView;
        }
    } else {
        functionViewHeight = 92.0f;
        if (!(self.callingFunctionView && [self.callingFunctionView isKindOfClass:[TUICallingAudioFunctionView class]])) {
            [self clearCallingFunctionView];
            self.callingFunctionView = [[TUICallingAudioFunctionView alloc] initWithFrame:CGRectZero];
        }
    }
    
    [self.containerView addSubview:self.backgroundView];
    [self.containerView addSubview:self.timerView];
    [self.containerView addSubview:self.callingFunctionView];
    [self makeTimerViewConstraints:0.0f];
    [self makeFunctionViewConstraints:functionViewHeight];
    [self initMicMute:[TUICallingStatusManager shareInstance].isMicMute];
    [self initHandsFree:[TUICallingStatusManager shareInstance].audioPlaybackDevice];
    [self initAddOtherUserBtn];
}

- (void)initFloatingWindowBtn {
    if (!self.enableFloatWindow) {
        return;
    }
    [self.floatingWindowBtn removeFromSuperview];
    [self.containerView addSubview:self.floatingWindowBtn];
    [self makeFloatingWindowBtnConstraints];
    
    NSString *imageName = @"ic_min_window_dark";
    if ((self.callScene != TUICallSceneSingle) || ([TUICallingStatusManager shareInstance].callType == TUICallMediaTypeVideo)) {
        imageName = @"ic_min_window_white";
    }
    [self.floatingWindowBtn setBackgroundImage:[TUICallingCommon getBundleImageWithName:imageName]
                                      forState:UIControlStateNormal];
}

- (void)initMicMute:(BOOL)isMicMute {
    if (isMicMute) {
        [TUICallingAction openMicrophone];
    } else {
        [TUICallingAction closeMicrophone];
    }
}

- (void)initHandsFree:(TUIAudioPlaybackDevice)audioPlaybackDevice {
    [[TUICallEngine createInstance] selectAudioPlaybackDevice:audioPlaybackDevice];
    [TUICallingStatusManager shareInstance].audioPlaybackDevice = audioPlaybackDevice;
    [self updateAudioPlaybackDevice];
}

- (void)initAddOtherUserBtn {
    [self.addOtherUserBtn removeFromSuperview];
    [self.containerView addSubview:self.addOtherUserBtn];
    [self.addOtherUserBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(StatusBar_Height + 3);
        make.right.equalTo(self.containerView).offset(-10);
        make.width.height.equalTo(@(32));
    }];
}

- (void)clearAllSubViews {
    [self clearCallingUserView];
    [self clearCallingFunctionView];
    [self clearBackgroundView];
    [self clearSwitchToAudioView];
    [self clearTimerView];
    [self clearCallingCalleeView];
    [self clearAddOtherUserBtn];
}

- (void)clearCallingUserView{
    if (self.callingUserView != nil && self.callingUserView.superview != nil) {
        [self.callingUserView removeFromSuperview];
        self.callingUserView = nil;
    }
}

- (void)clearCallingFunctionView{
    if (self.callingFunctionView != nil && self.callingFunctionView.superview != nil) {
        [self.callingFunctionView removeFromSuperview];
        self.callingFunctionView = nil;
    }
}

- (void)clearBackgroundView{
    if (self.backgroundView != nil && self.backgroundView.superview != nil) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
}

- (void)clearSwitchToAudioView{
    if (self.switchToAudioView != nil && self.switchToAudioView.superview != nil) {
        [self.switchToAudioView removeFromSuperview];
        self.switchToAudioView = nil;
    }
}

- (void)clearTimerView{
    if (self.timerView != nil && self.timerView.superview != nil) {
        [self.timerView removeFromSuperview];
        self.timerView = nil;
    }
}

- (void)clearCallingCalleeView{
    if (self.callingCalleeView != nil && self.callingCalleeView.superview != nil) {
        [self.callingCalleeView removeFromSuperview];
        self.callingCalleeView = nil;
    }
}

- (void)clearAddOtherUserBtn{
    if (self.addOtherUserBtn != nil && self.addOtherUserBtn.superview != nil) {
        [self.addOtherUserBtn removeFromSuperview];
        self.addOtherUserBtn = nil;
    }
}

#pragma mark - View Constraints

- (void)makeUserViewConstraints:(CGFloat)topOffset {
    [self.callingUserView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(StatusBar_Height + topOffset);
        make.left.equalTo(self.containerView).offset(20);
        make.right.equalTo(self.containerView).offset(-20);
    }];
}

- (void)makeFunctionViewConstraints:(CGFloat)height {
    [self.callingFunctionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.bottom.equalTo(self.containerView.mas_top).offset(self.containerView.frame.size.height - Bottom_SafeHeight - 20);
        make.height.equalTo(@(height));
        make.width.equalTo(self.containerView.mas_width);
    }];
}

- (void)makeCallingCalleeViewConstraints {
    [self.callingCalleeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.containerView);
        make.height.equalTo(@(68));
        make.width.equalTo(self.containerView.mas_width);
    }];
}

- (void)makeSwitchToAudioViewConstraints:(CGFloat)bottomOffset {
    [self.switchToAudioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.height.equalTo(@(46));
        make.width.equalTo(self.containerView.mas_width);
        make.bottom.equalTo(self.callingFunctionView.mas_top).offset(-bottomOffset);
    }];
}

- (void)makeTimerViewConstraints:(CGFloat)bottomOffset {
    [self.timerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.height.equalTo(@(30));
        make.width.equalTo(self.containerView.mas_width);
        make.bottom.equalTo(self.callingFunctionView.mas_top).offset(-bottomOffset);
    }];
}

- (void)makeFloatingWindowBtnConstraints {
    [self.floatingWindowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(StatusBar_Height + 3);
        make.left.equalTo(self.containerView).offset(10);
        make.width.height.equalTo(@(32));
    }];
}

#pragma mark - Public Method

- (void)createCallingView:(TUICallMediaType)callType callRole:(TUICallRole)callRole callScene:(TUICallScene)callScene {
    [TUICallingStatusManager shareInstance].callStatus = TUICallStatusWaiting;
    [TUICallingStatusManager shareInstance].callType = callType;
    _callRole = callRole;
    _callScene = callScene;
    
    if (self.callScene == TUICallSceneSingle) {
        [self initSingleWaitingView];
    } else {
        [self initGroupWaitingView];
    }
    
    [self updateCallingUserView];
    [self updateContainerViewBgColor];
    [self updateViewTextColor];
    [self initFloatingWindowBtn];
}

- (void)createGroupCallingAcceptView:(TUICallMediaType)callType callRole:(TUICallRole)callRole callScene:(TUICallScene)callScene {
    [TUICallingStatusManager shareInstance].callStatus = TUICallStatusAccept;
    [TUICallingStatusManager shareInstance].callType = callType;
    _callRole = callRole;
    _callScene = callScene;
    [self initGroupAcceptCallView];
    [self updateViewTextColor];
    [self initFloatingWindowBtn];
}

- (void)updateCallingView:(NSArray<CallingUserModel *> *)inviteeList sponsor:(CallingUserModel *)sponsor {
    self.remoteUser = sponsor;
    if (self.callRole == TUICallRoleCall) {
        self.remoteUser = [inviteeList firstObject];
    }
    
    [self updateCallingUserView];
    [self updateCallingBackgroundView:sponsor];
    [self.callingCalleeView updateViewWithUserList:inviteeList];
}

- (void)updateCallingUserView {
    [self updateCallingUserView:nil];
}

- (void)updateCallingUserView:(NSString *)text {
    if (self.callingUserView && [self.callingUserView respondsToSelector:@selector(updateUserInfo:hint:)]) {
        [self.callingUserView updateUserInfo:self.remoteUser hint:text ?: [self getWaitingText]];
    }
}

- (void)updateCallingBackgroundView:(CallingUserModel *)sponsor {
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(updateViewWithUserList:sponsor:callType:callRole:)]) {
        [self.backgroundView updateViewWithUserList:[TUICallingUserManager allUserList]
                                            sponsor:sponsor
                                           callType:[TUICallingStatusManager shareInstance].callType
                                           callRole:self.callRole];
    }
}

- (void)showCallingView {
    [self.callingWindow addSubview:self.containerView];
    self.callingWindow.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_callingWindow != nil) {
            [self.callingWindow t_makeKeyAndVisible];
        }
    });
}

- (void)closeCallingView {
    [self clearAllSubViews];
    [self.containerView removeFromSuperview];
    self.callingWindow.hidden = YES;
    self.callingWindow = nil;
    
    if ([TUICallingFloatingWindowManager shareInstance].isFloating) {
        [[TUICallingFloatingWindowManager shareInstance] closeWindowCompletion:nil];
    }
}

- (UIView *)getCallingView {
    return self.containerView;
}

- (void)updateCallingTimeStr:(NSString *)timeStr {
    [self.timerView updateTimerText:timeStr];
    
    if ([TUICallingFloatingWindowManager shareInstance].isFloating) {
        [[TUICallingFloatingWindowManager shareInstance] updateMicroWindowText:timeStr
                                                                    callStatus:[TUICallingStatusManager shareInstance].callType
                                                                      callRole:self.callRole];
    }
}

- (void)userEnter:(CallingUserModel *)userModel {
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(userEnter:)]) {
        [self.backgroundView userEnter:userModel];
    }
}

- (void)userLeave:(CallingUserModel *)userModel {
    if (self.callingCalleeView) {
        [self.callingCalleeView userLeave:userModel];
    }
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(userLeave:)]) {
        [self.backgroundView userLeave:userModel];
    }
    
}

- (void)updateUser:(CallingUserModel *)userModel {
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(updateUserInfo:)]) {
        [self.backgroundView updateUserInfo:userModel];
    }
}

- (void)enableFloatWindow:(BOOL)enable {
    self.enableFloatWindow = enable;
}

#pragma mark - Action Event

- (void)floatingWindowTouchEvent:(UIButton *)sender {
    TUICallingVideoRenderView *renderView = nil;
    
    if (self.callScene == TUICallSceneSingle && [TUICallingStatusManager shareInstance].callType == TUICallMediaTypeVideo) {
        if ([TUICallingStatusManager shareInstance].callStatus == TUICallStatusAccept) {
            renderView = self.remotePreView;
        } else {
            renderView = self.localPreView;
        }
    }
    
    self.localPreView.delegate = [TUICallingFloatingWindowManager shareInstance].floatWindow;
    self.remotePreView.delegate = [TUICallingFloatingWindowManager shareInstance].floatWindow;
    __weak typeof(self) weakSelf = self;
    [[TUICallingFloatingWindowManager shareInstance] showMicroFloatingWindowWithCallingWindow:self.callingWindow VideoRenderView:renderView Completion:^(BOOL finished) {
        if (finished && ([TUICallingStatusManager shareInstance].callType == TUICallMediaTypeAudio || !renderView)) {
            [[TUICallingFloatingWindowManager shareInstance] updateMicroWindowText:@""
                                                                        callStatus:[TUICallingStatusManager shareInstance].callStatus
                                                                          callRole:weakSelf.callRole];
        }
    }];
}

- (void)addOtherUserTouchEvent:(UIButton *)sender {
    [TUICallingAction inviteUser:@[@"131313", @"141414"] succ:^(NSArray * _Nonnull userIDs) {
        __weak typeof(self) weakSelf = self;
        [[V2TIMManager sharedInstance] getUsersInfo:userIDs succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            __strong typeof(self) strongSelf = weakSelf;
            for (V2TIMUserFullInfo *userInfo in infoList) {
                CallingUserModel *userModel = [TUICallingCommon covertUser:userInfo];
                [TUICallingUserManager cacheUser:userModel];
                if (strongSelf.backgroundView && [strongSelf.backgroundView respondsToSelector:@selector(userAdd:)]) {
                    [strongSelf.backgroundView userAdd:userModel];
                }
            }
        } fail:nil];
    } fail:^(int code, NSString * _Nonnull desc) {
        TRTCLog(@"Calling - addOtherUserTouchEvent error code:%@ desc:%@", code, desc);
    }];
}

#pragma mark - TUICallingStatusManagerProtocol

- (void)updateCallType {
    [self clearAllSubViews];
    
    if ([TUICallingStatusManager shareInstance].callStatus == TUICallStatusAccept) {
        [self initSingleAcceptCallView];
        [self initHandsFree:[TUICallingStatusManager shareInstance].audioPlaybackDevice];
        [[TUICallingFloatingWindowManager shareInstance] switchToAudioMicroWindowWith:[TUICallingStatusManager shareInstance].callStatus
                                                                             callRole:self.callRole];
    } else {
        [self initSingleWaitingView];
    }
    
    [self updateContainerViewBgColor];
    [self updateCallingUserView];
    [self updateViewTextColor];
    [self initFloatingWindowBtn];
    
}

- (void)updateCallStatus {
    if ([TUICallingStatusManager shareInstance].callStatus == TUICallStatusAccept) {
        TUICallingVideoRenderView *renderView = nil;
        
        if (self.callScene == TUICallSceneSingle) {
            [self initSingleAcceptCallView];
            if ([TUICallingStatusManager shareInstance].callType == TUICallMediaTypeVideo) {
                renderView = self.remotePreView;
            }
        } else {
            [self initGroupAcceptCallView];
        }
        
        [self updateCallingUserView:@""];
        [self updateCallingBackgroundView:self.remoteUser];
        [self updateContainerViewBgColor];
        [self updateViewTextColor];
        [self initFloatingWindowBtn];
        [[TUICallingFloatingWindowManager shareInstance] updateMicroWindowRenderView:renderView];
        
        if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(updateRemoteView)]) {
            [self.backgroundView updateRemoteView];
        }
    }
}

- (void)updateIsCloseCamera {
    if (self.callingFunctionView && [self.callingFunctionView respondsToSelector:@selector(updateCameraOpenStatus)]) {
        [self.callingFunctionView updateCameraOpenStatus];
    }
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(updateCameraOpenStatus:)]) {
        [self.backgroundView updateCameraOpenStatus:![TUICallingStatusManager shareInstance].isCloseCamera];
    }
}

- (void)updateMicMute {
    if (self.callingFunctionView && [self.callingFunctionView respondsToSelector:@selector(updateMicMuteStatus)]) {
        [self.callingFunctionView updateMicMuteStatus];
    }
}

- (void)updateAudioPlaybackDevice {
    if (self.callingFunctionView && [self.callingFunctionView respondsToSelector:@selector(updateHandsFreeStatus)]) {
        [self.callingFunctionView updateHandsFreeStatus];
    }
}

#pragma mark - TUICallingFloatingWindowManagerDelegate

- (void)floatingWindowDidClickView {
    self.localPreView.delegate = self.backgroundView;
    self.remotePreView.delegate = self.backgroundView;
    
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(updateCallingSingleView)]) {
        [self.backgroundView updateCallingSingleView];
    }
}

- (void)closeFloatingWindow {
    [TUICallingAction hangup];
}

#pragma mark - Private Method

- (void)updateContainerViewBgColor {
    UIColor *backgroundColor = [UIColor t_colorWithHexString:@"#F2F2F2"];
    if ((self.callScene != TUICallSceneSingle) || ([TUICallingStatusManager shareInstance].callType == TUICallMediaTypeVideo)) {
        backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
    }
    self.containerView.backgroundColor = backgroundColor;
}

- (void)updateViewTextColor {
    UIColor *textColor = [UIColor t_colorWithHexString:@"#000000"];
    if ((self.callScene != TUICallSceneSingle) || ([TUICallingStatusManager shareInstance].callType == TUICallMediaTypeVideo)) {
        textColor = [UIColor t_colorWithHexString:@"#F2F2F2"];
    }
    [self.timerView setTimerTextColor:textColor];
    [self updateFunctionViewTextColor:textColor];
    [self updateUserViewTextColor:textColor];
}

- (void)updateFunctionViewTextColor:(UIColor *)textColor {
    if (self.callingFunctionView && [self.callingFunctionView respondsToSelector:@selector(updateTextColor:)]) {
        [self.callingFunctionView updateTextColor:textColor];
    }
}

- (void)updateUserViewTextColor:(UIColor *)textColor {
    if (self.callingUserView && [self.callingUserView respondsToSelector:@selector(updateTextColor:)]) {
        [self.callingUserView updateTextColor:textColor];
    }
}

- (NSString *)getWaitingText {
    NSString *waitingText = @"";
    switch ([TUICallingStatusManager shareInstance].callType) {
        case TUICallMediaTypeAudio:{
            if (self.callRole == TUICallRoleCall) {
                waitingText = TUICallingLocalize(@"Demo.TRTC.Calling.waitaccept");
            } else {
                waitingText = TUICallingLocalize(@"Demo.TRTC.calling.invitetoaudiocall");
            }
        } break;
        case TUICallMediaTypeVideo:{
            if (self.callRole == TUICallRoleCall) {
                waitingText = TUICallingLocalize(@"Demo.TRTC.Calling.waitaccept");
            } else {
                waitingText = TUICallingLocalize(@"Demo.TRTC.calling.invitetovideocall");
            }
        } break;
        case TUICallMediaTypeUnknown:
        default:
            break;
    }
    return waitingText;
}

#pragma mark - Lazy

- (TUICallingTimerView *)timerView {
    if (!_timerView) {
        _timerView = [[TUICallingTimerView alloc] initWithFrame:CGRectZero];
    }
    return _timerView;
}

- (TUICallingSwitchToAudioView *)switchToAudioView {
    if (!_switchToAudioView) {
        _switchToAudioView = [[TUICallingSwitchToAudioView alloc] initWithFrame:CGRectZero];
    }
    return _switchToAudioView;
}

- (TUICallingCalleeView *)callingCalleeView {
    if (!_callingCalleeView) {
        _callingCalleeView = [[TUICallingCalleeView alloc] initWithFrame:CGRectZero];
        _callingCalleeView.backgroundColor = [UIColor clearColor];
    }
    return _callingCalleeView;
}

- (UIWindow *)callingWindow {
    if (!_callingWindow) {
        _callingWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _callingWindow.windowLevel = UIWindowLevelAlert - 1;
        _callingWindow.backgroundColor = [UIColor clearColor];
    }
    return _callingWindow;
}

- (TUICallingVideoRenderView *)localPreView {
    if (!_localPreView) {
        _localPreView = [[TUICallingVideoRenderView alloc] initWithFrame:CGRectZero];
        _localPreView.backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
        _localPreView.delegate = self.backgroundView;
    }
    return _localPreView;
}

- (TUICallingVideoRenderView *)remotePreView {
    if (!_remotePreView) {
        _remotePreView = [[TUICallingVideoRenderView alloc] initWithFrame:CGRectZero];
        _remotePreView.backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
        _remotePreView.delegate = self.backgroundView;
    }
    return _remotePreView;
}

- (UIButton *)floatingWindowBtn {
    if (!_floatingWindowBtn) {
        _floatingWindowBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_floatingWindowBtn setBackgroundImage:[TUICallingCommon getBundleImageWithName:@"ic_min_window_white"]
                                      forState:UIControlStateNormal];
        [_floatingWindowBtn addTarget:self action:@selector(floatingWindowTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _floatingWindowBtn;
}

- (UIButton *)addOtherUserBtn {
    if (!_addOtherUserBtn) {
        _addOtherUserBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_addOtherUserBtn setBackgroundImage:[TUICallingCommon getBundleImageWithName:@"add_user"] forState:UIControlStateNormal];
        [_addOtherUserBtn addTarget:self action:@selector(addOtherUserTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addOtherUserBtn;
}

@end
