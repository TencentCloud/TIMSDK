//
//  TUIGroupCallingView.m
//  TUICalling
//
//  Created by noah on 2021/9/3.
//

#import "TUIGroupCallingView.h"
#import "TUIAudioUserContainerView.h"
#import "TUICallingDelegateManager.h"
#import "TUICalleeDelegateManager.h"
#import <TUICore/UIView+TUIToast.h>
#import "TUIDefine.h"

@interface TUIGroupCallingView ()

/// 记录Calling当前的状态
@property (nonatomic, assign) TUICallingState curCallingState;
/// 存储用户数据
@property (nonatomic, strong) NSMutableArray<CallUserModel *> *userList;
/// 组通话视图
@property (nonatomic, strong) UICollectionView *groupCollectionView;
/// 所有接收者提示文本
@property (nonatomic, strong) UILabel *calleeTipLabel;
/// 所有接收者视图
@property (nonatomic, strong) UICollectionView *calleeCollectionView;
/// UICollectionView 代理对象
@property (nonatomic, strong) TUICallingDelegateManager *delegateManager;
/// 所有接收者视图代理对象
@property (nonatomic, strong) TUICalleeDelegateManager *calleeDelegateManager;
/// 远程音频用户信息视图
@property (nonatomic, strong) TUIAudioUserContainerView *userContainerView;
/// 接听控制视图
@property (nonatomic, strong) TUIInvitedContainerView *invitedContainerView;
/// 通话时间按钮
@property (nonatomic, strong) UILabel *callingTime;
/// 关闭麦克风按钮
@property (nonatomic, strong) TUICallingControlButton *muteBtn;
/// 挂断按钮
@property (nonatomic, strong) TUICallingControlButton *hangupBtn;
/// 免提按钮
@property (nonatomic, strong) TUICallingControlButton *handsfreeBtn;
/// 关闭摄像头
@property (nonatomic, strong) TUICallingControlButton *closeCameraBtn;
/// 切换摄像头
@property (nonatomic, strong) UIButton *switchCameraBtn;
/// 记录本地用户
@property (nonatomic, strong) CallUserModel *currentUser;
/// 记录发起通话着
@property (nonatomic, strong) CallUserModel *curSponsor;
// 记录是否为前置相机,麦克风,听筒,摄像头开关
@property (nonatomic, assign) BOOL isFrontCamera;
@property (nonatomic, assign) BOOL isMicMute;
@property (nonatomic, assign) BOOL isHandsFreeOn;
@property (nonatomic, assign) BOOL isCloseCamera;

@end

@implementation TUIGroupCallingView

- (instancetype)initWithUser:(CallUserModel *)user isVideo:(BOOL)isVideo isCallee:(BOOL)isCallee {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.currentUser = user;
        self.userList = [NSMutableArray arrayWithObject:user];
        self.isVideo = isVideo;
        self.isCallee = isCallee;
        self.isFrontCamera = YES;
        self.isHandsFreeOn = YES;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
    for (int i = 0; i < 9; i++) {
        [self.groupCollectionView registerClass:NSClassFromString(@"TUICallingGroupCell") forCellWithReuseIdentifier:[NSString stringWithFormat:@"TUICallingGroupCell_%d", i]];
    }
    [self.calleeCollectionView registerClass:NSClassFromString(@"TUICalleeGroupCell") forCellWithReuseIdentifier:@"TUICalleeGroupCell"];
    _curCallingState = self.isCallee ? TUICallingStateOnInvitee : TUICallingStateDailing;
}

- (void)initUIForCaller {
    if (self.isVideo) {
        [self initUIForVideoCaller];
    } else {
        [self initUIForAudioCaller];
    }
}

/// 多人通话，主叫方/接听后 UI初始化
- (void)initUIForAudioCaller {
    [self addSubview:self.groupCollectionView];
    [self addSubview:self.callingTime];
    [self addSubview:self.muteBtn];
    [self addSubview:self.hangupBtn];
    [self addSubview:self.handsfreeBtn];
    // 视图约束
    [self.groupCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height + 38);
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(self.bounds.size.width);
    }];
    [self.callingTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.hangupBtn.mas_top).offset(-10);
        make.height.equalTo(@(20));
    }];
    [self.muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.hangupBtn.mas_left).offset(-5);
        make.centerY.equalTo(self.hangupBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_top).offset(self.frame.size.height - Bottom_SafeHeight - 20);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.handsfreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hangupBtn.mas_right).offset(5);
        make.centerY.equalTo(self.hangupBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self bringSubviewToFront:self.floatingWindowBtn];
}

/// 多人通话，主叫方/接听后 UI初始化
- (void)initUIForVideoCaller {
    [self addSubview:self.groupCollectionView];
    [self addSubview:self.callingTime];
    [self addSubview:self.muteBtn];
    [self addSubview:self.handsfreeBtn];
    [self addSubview:self.closeCameraBtn];
    [self addSubview:self.hangupBtn];
    [self addSubview:self.switchCameraBtn];
    // 视图约束
    [self.groupCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height + 38);
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(self.bounds.size.width);
    }];
    [self.callingTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.handsfreeBtn.mas_top).offset(5);
        make.height.equalTo(@(20));
    }];
    [self.muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.handsfreeBtn.mas_left);
        make.centerY.equalTo(self.handsfreeBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.handsfreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.hangupBtn.mas_top).offset(-10);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.closeCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.handsfreeBtn.mas_right);
        make.centerY.equalTo(self.handsfreeBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_top).offset(self.frame.size.height - Bottom_SafeHeight - 20);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.hangupBtn);
        make.left.equalTo(self.hangupBtn.mas_right).offset(20);
        make.size.equalTo(@(CGSizeMake(36, 36)));
    }];
    [self bringSubviewToFront:self.floatingWindowBtn];
}

/// 多人通话，被呼叫方UI初始化
- (void)initUIForAudioCallee {
    [self addSubview:self.userContainerView];
    [self addSubview:self.calleeTipLabel];
    [self addSubview:self.calleeCollectionView];
    [self addSubview:self.invitedContainerView];
    // 视图约束
    [self.userContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height + 74);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    [self.calleeTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.equalTo(@(20));
    }];
    [self.calleeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.calleeTipLabel.mas_bottom).offset(15);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.equalTo(@(32));
    }];
    [self.invitedContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerX.equalTo(self).offset(60);
        make.right.centerX.equalTo(self).offset(-60);
        make.height.equalTo(@(94));
        make.bottom.equalTo(self).offset(-Bottom_SafeHeight - 20);
    }];
    [self bringSubviewToFront:self.floatingWindowBtn];
}

- (void)setCurCallingState:(TUICallingState)curCallingState {
    _curCallingState = curCallingState;
    [self clearAllSubViews];
    
    switch (curCallingState) {
        case TUICallingStateOnInvitee: {
            [self initUIForAudioCallee];
            NSString *waitingText = TUICallingLocalize(@"Demo.TRTC.calling.invitetoaudiocall");
            if (self.isVideo) {
                waitingText = TUICallingLocalize(@"Demo.TRTC.calling.invitetovideocall");
            }
            [self.userContainerView configUserInfoViewWith:self.curSponsor showWaitingText:waitingText];
        } break;
        case TUICallingStateDailing: {
            [self initUIForCaller];
            self.callingTime.hidden = YES;
            [self.userContainerView configUserInfoViewWith:self.curSponsor showWaitingText:TUICallingLocalize(@"Demo.TRTC.calling.waitaccept")];
        } break;
        case TUICallingStateCalling: {
            [self initUIForCaller];
            self.callingTime.hidden = NO;
            self.userContainerView.hidden = YES;
            [self handleLocalRenderView];
        } break;
        default:
            break;
    }
    
    if ([TUICallingFloatingWindowManager shareInstance].isFloating) {
        [[TUICallingFloatingWindowManager shareInstance] updateMicroWindowText:@"" callingState:self.curCallingState];
    }
}

#pragma mark - Public

- (void)configViewWithUserList:(NSArray<CallUserModel *> *)userList sponsor:(CallUserModel *)sponsor {
    if (userList) {
        [self.userList removeAllObjects];
        [self.userList addObjectsFromArray:userList];
    }
    
    if (sponsor) {
        self.curSponsor = sponsor;
        self.curCallingState = TUICallingStateOnInvitee;
    } else {
        self.curCallingState = TUICallingStateDailing;
    }
    
    if (self.isCallee && (self.curCallingState == TUICallingStateOnInvitee)) {
        NSMutableArray *userArray = [NSMutableArray array];
        [self.userList enumerateObjectsUsingBlock:^(CallUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj.userId isEqualToString:self.currentUser.userId]) {
                [userArray addObject:obj];
            }
        }];
        self.calleeTipLabel.hidden = !userArray.count;
        [self.calleeDelegateManager reloadCallingGroupWithModel:[userArray copy]];
        [self.calleeCollectionView reloadData];
    }
    
    [self.delegateManager reloadCallingGroupWithModel:self.userList];
    [self.groupCollectionView reloadData];
    [self.groupCollectionView layoutIfNeeded];
    self.switchCameraBtn.hidden = !self.isVideo;
    [self handleLocalRenderView];
}

- (void)enterUser:(CallUserModel *)user {
    if (!user) return;
    
    NSInteger index = [self getIndexForUser:user];
    if (index < 0) return;
    
    self.curCallingState = TUICallingStateCalling;
    user.isEnter = YES;
    self.userList[index] = user;
    [self.delegateManager reloadCallingGroupWithModel:self.userList];
    [self.delegateManager reloadGroupCellWithIndex:index];
    
    if (self.isVideo) {
        UIView *renderView = [self.delegateManager getRenderViewFromUser:user.userId];
        [[TRTCCalling shareInstance] startRemoteView:user.userId view:renderView];
    }
}

- (void)leaveUser:(CallUserModel *)user {
    NSInteger index = [self getIndexForUser:user];
    if (index < 0) return;
    
    if (self.isVideo) {
        [[TRTCCalling shareInstance] stopRemoteView:user.userId];
    }
    
    [self.groupCollectionView performBatchUpdates:^{
        [self.groupCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        [self.userList removeObjectAtIndex:index];
        [self.delegateManager reloadCallingGroupWithModel:self.userList];
    } completion:nil];
}

- (void)updateUserVolume:(CallUserModel *)user {
    [self updateUser:user animated:NO];
}

- (void)updateUser:(CallUserModel *)user animated:(BOOL)animated {
    NSInteger index = [self getIndexForUser:user];
    if (index < 0) return;
    self.userList[index] = user;
    [self.delegateManager reloadCallingGroupWithModel:self.userList];
    [self.delegateManager reloadGroupCellWithIndex:index];
}

/// 用户用户在用户数组中的位置。没有获取到返回 -1
/// @param user 目标用户
- (NSInteger)getIndexForUser:(CallUserModel *)user {
    if (!user) return -1;
    __block NSInteger index = -1;
    [self.userList enumerateObjectsUsingBlock:^(CallUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:user.userId]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (CallUserModel *)getUserById:(NSString *)userId {
    for (CallUserModel *userModel in self.userList) {
        if ([userModel.userId isEqualToString:userId]) {
            return userModel;
        }
    }
    return nil;
}

- (void)acceptCalling {
    self.curCallingState = TUICallingStateCalling;
}

- (void)setCallingTimeStr:(NSString *)timeStr {
    if (timeStr && timeStr.length > 0) {
        self.callingTime.text = timeStr;
        
        if ([TUICallingFloatingWindowManager shareInstance].isFloating) {
            [[TUICallingFloatingWindowManager shareInstance] updateMicroWindowText:timeStr callingState:self.curCallingState];
        }
    }
}

#pragma mark - Private

- (void)handleLocalRenderView {
    if (!self.isVideo) return;
    
    UIView *localRenderView = [self.delegateManager getRenderViewFromUser:self.currentUser.userId];
    
    if (!self.isCloseCamera && localRenderView != nil) {
        [[TRTCCalling shareInstance] openCamera:self.isFrontCamera view:localRenderView];
    }
    
    self.currentUser.isVideoAvaliable = !self.isCloseCamera;
    self.currentUser.isEnter = YES;
    self.currentUser.isAudioAvaliable = YES;
    [self updateUser:self.currentUser animated:NO];
}

- (void)clearAllSubViews {
    if (_invitedContainerView != nil && self.invitedContainerView.superview != nil) {
        [self.invitedContainerView removeFromSuperview];
    }
    if (_calleeTipLabel != nil && self.calleeTipLabel.superview != nil) {
        [self.calleeTipLabel removeFromSuperview];
    }
    if (_calleeCollectionView != nil && self.calleeCollectionView.superview != nil) {
        [self.calleeCollectionView removeFromSuperview];
    }
    if (_muteBtn != nil && self.muteBtn.superview != nil) {
        [self.muteBtn removeFromSuperview];
    }
    if (_hangupBtn != nil && self.hangupBtn.superview != nil) {
        [self.hangupBtn removeFromSuperview];
    }
    if (_handsfreeBtn != nil && self.handsfreeBtn.superview != nil) {
        [self.handsfreeBtn removeFromSuperview];
    }
    if (_closeCameraBtn != nil && self.closeCameraBtn.superview != nil) {
        [self.closeCameraBtn removeFromSuperview];
    }
    if (_switchCameraBtn != nil && self.switchCameraBtn.superview != nil) {
        [self.switchCameraBtn removeFromSuperview];
    }
    if (_userContainerView != nil && self.userContainerView.superview != nil) {
        [self.userContainerView removeFromSuperview];
    }
}

#pragma mark - Event Action

- (void)muteTouchEvent:(UIButton *)sender {
    self.isMicMute = !self.isMicMute;
    [[TRTCCalling shareInstance] setMicMute:self.isMicMute];
    [self.muteBtn configBackgroundImage:[TUICommonUtil getBundleImageWithName:self.isMicMute ? @"ic_mute_on" : @"ic_mute"]];
    self.currentUser.isAudioAvaliable = !self.isMicMute;
    [self updateUser:self.currentUser animated:NO];
}

- (void)hangupTouchEvent:(UIButton *)sender {
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(hangupCalling)]) {
        [self.actionDelegate hangupCalling];
    }
}

- (void)hangsfreeTouchEvent:(UIButton *)sender {
    self.isHandsFreeOn = !self.isHandsFreeOn;
    [[TRTCCalling shareInstance] setHandsFree:self.isHandsFreeOn];
    [self.handsfreeBtn configBackgroundImage:[TUICommonUtil getBundleImageWithName:self.isHandsFreeOn ? @"ic_handsfree_on" : @"ic_handsfree"]];
}

- (void)switchCameraTouchEvent:(UIButton *)sender {
    self.isFrontCamera = !self.isFrontCamera;
    [[TRTCCalling shareInstance] switchCamera:self.isFrontCamera];
}

- (void)closeCameraTouchEvent:(UIButton *)sender {
    self.isCloseCamera = !self.isCloseCamera;
    [self.closeCameraBtn setUserInteractionEnabled:NO];
    [self.closeCameraBtn configBackgroundImage:[TUICommonUtil getBundleImageWithName:self.isCloseCamera ? @"camera_off" : @"camera_on"]];
    
    if (self.isCloseCamera) {
        [[TRTCCalling shareInstance] closeCamara];
        self.switchCameraBtn.hidden = YES;
    } else {
        self.switchCameraBtn.hidden = NO;
    }
    
    [self handleLocalRenderView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.closeCameraBtn setUserInteractionEnabled:YES];
    });
}

- (void)floatingWindowTouchEvent:(UIButton *)sender {
    [self showMicroFloatingWindow:self.curCallingState];
}

#pragma mark - Lazy

- (TUIAudioUserContainerView *)userContainerView {
    if (!_userContainerView) {
        _userContainerView = [[TUIAudioUserContainerView alloc] initWithFrame:CGRectZero];
        [_userContainerView setUserNameTextColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _userContainerView;
}

- (UILabel *)callingTime {
    if (!_callingTime) {
        _callingTime = [[UILabel alloc] initWithFrame:CGRectZero];
        _callingTime.font = [UIFont boldSystemFontOfSize:14.0f];
        [_callingTime setTextColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
        [_callingTime setBackgroundColor:[UIColor clearColor]];
        [_callingTime setText:@"00:00"];
        _callingTime.hidden = YES;
        [_callingTime setTextAlignment:NSTextAlignmentCenter];
    }
    return _callingTime;
}

- (TUICallingControlButton *)muteBtn {
    if (!_muteBtn) {
        __weak typeof(self) weakSelf = self;
        _muteBtn = [TUICallingControlButton createViewWithFrame:CGRectZero titleText:TUICallingLocalize(@"Demo.TRTC.Calling.mic") buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf muteTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_muteBtn configBackgroundImage:[TUICommonUtil getBundleImageWithName:@"ic_mute"]];
        [_muteBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _muteBtn;
}

- (TUICallingControlButton *)handsfreeBtn {
    if (!_handsfreeBtn) {
        __weak typeof(self) weakSelf = self;
        _handsfreeBtn = [TUICallingControlButton createViewWithFrame:CGRectZero titleText:TUICallingLocalize(@"Demo.TRTC.Calling.speaker") buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf hangsfreeTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_handsfreeBtn configBackgroundImage:[TUICommonUtil getBundleImageWithName:@"ic_handsfree_on"]];
        [_handsfreeBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _handsfreeBtn;
}

- (TUICallingControlButton *)closeCameraBtn {
    if (!_closeCameraBtn) {
        __weak typeof(self) weakSelf = self;
        _closeCameraBtn = [TUICallingControlButton createViewWithFrame:CGRectZero titleText:TUICallingLocalize(@"Demo.TRTC.Calling.camera") buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf closeCameraTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_closeCameraBtn configBackgroundImage:[TUICommonUtil getBundleImageWithName:@"camera_on"]];
        [_closeCameraBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _closeCameraBtn;
}

- (TUICallingControlButton *)hangupBtn {
    if (!_hangupBtn) {
        __weak typeof(self) weakSelf = self;
        
        _hangupBtn = [TUICallingControlButton createViewWithFrame:CGRectZero titleText:TUICallingLocalize(@"Demo.TRTC.Calling.hangup") buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf hangupTouchEvent:sender];
        } imageSize:kBtnLargeSize];
        [_hangupBtn configBackgroundImage:[TUICommonUtil getBundleImageWithName:@"ic_hangup"]];
        [_hangupBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _hangupBtn;
}

- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_switchCameraBtn setBackgroundImage:[TUICommonUtil getBundleImageWithName:@"switch_camera"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (TUIInvitedContainerView *)invitedContainerView {
    if (!_invitedContainerView) {
        _invitedContainerView = [[TUIInvitedContainerView alloc] initWithFrame:CGRectZero];
        _invitedContainerView.delegate = self.actionDelegate;
        [_invitedContainerView configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _invitedContainerView;
}

- (TUICallingDelegateManager *)delegateManager {
    if (!_delegateManager) {
        _delegateManager = [[TUICallingDelegateManager alloc] init];
    }
    return _delegateManager;
}

- (TUICalleeDelegateManager *)calleeDelegateManager {
    if (!_calleeDelegateManager) {
        _calleeDelegateManager = [[TUICalleeDelegateManager alloc] init];
    }
    return _calleeDelegateManager;
}

- (UICollectionView *)groupCollectionView {
    if (!_groupCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        _groupCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _groupCollectionView.delegate = self.delegateManager;
        _groupCollectionView.dataSource = self.delegateManager;
        self.delegateManager.collectionView = _groupCollectionView;
        _groupCollectionView.showsVerticalScrollIndicator = NO;
        _groupCollectionView.showsHorizontalScrollIndicator = NO;
        _groupCollectionView.backgroundColor = [UIColor clearColor];
    }
    return _groupCollectionView;
}

- (UILabel *)calleeTipLabel {
    if (!_calleeTipLabel) {
        _calleeTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _calleeTipLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [_calleeTipLabel setTextColor:[UIColor t_colorWithHexString:@"#999999"]];
        [_calleeTipLabel setText:TUICallingLocalize(@"Demo.TRTC.Calling.calleeTip")];
        [_calleeTipLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _calleeTipLabel;
}

- (UICollectionView *)calleeCollectionView {
    if (!_calleeCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _calleeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _calleeCollectionView.delegate = self.calleeDelegateManager;
        _calleeCollectionView.dataSource = self.calleeDelegateManager;
        _calleeCollectionView.showsVerticalScrollIndicator = NO;
        _calleeCollectionView.showsHorizontalScrollIndicator = NO;
        _calleeCollectionView.backgroundColor = [UIColor clearColor];
    }
    return _calleeCollectionView;
}

@end
