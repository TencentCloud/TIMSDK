//
//  TUIAudioCallViewController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/7.
//

#import <AudioToolbox/AudioToolbox.h>
#import "TUIAudioCallViewController.h"
#import "TUIAudioCallUserCell.h"
#import "TUIAudioCalledView.h"
#import "TUICallUtils.h"
#import "THeader.h"
#import "THelper.h"
#import "TUICall.h"
#import "TUICall+TRTC.h"
#import "NSBundle+TUIKIT.h"

#define kUserCalledView_Width  200
#define kUserCalledView_Top  200

@interface TUIAudioCallViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,assign) AudioCallState curState;
@property(nonatomic,strong) NSMutableArray<CallUserModel *> *userList;
@property(nonatomic,strong) CallUserModel *curSponsor;
@property(nonatomic,strong) TUIAudioCalledView *calledView;
@property(nonatomic,strong) UICollectionView *userCollectionView;
@property(nonatomic,assign) NSInteger collectionCount;
@property(nonatomic,strong) UIButton *hangup;
@property(nonatomic,strong) UIButton *accept;
@property(nonatomic,strong) UIButton *mute;
@property(nonatomic,strong) UIButton *handsfree;
@property(nonatomic,strong) UILabel *callTimeLabel;
@property(nonatomic,strong) dispatch_source_t timer;
@property(nonatomic,assign) UInt32 callingTime;
@property(nonatomic,assign) BOOL playingAlerm; // 播放响铃
@end

@implementation TUIAudioCallViewController
{
    AudioCallState _curState;
    UIView *_onInviteePanel;
    UICollectionView *_userCollectionView;
    TUIAudioCalledView *_calledView;
    NSInteger _collectionCount;
    UIButton *_hangup;
    UIButton *_accept;
    UIButton *_mute;
    UIButton *_handsfree;
}

- (instancetype)initWithSponsor:(CallUserModel *)sponsor userList:(NSMutableArray<CallUserModel *> *)userList {
    self = [super init];
    if (self) {
        self.curSponsor = sponsor;
        if (sponsor) {
            self.curState = AudioCallState_OnInvitee;
        } else {
            self.curState = AudioCallState_Dailing;
        }
        [self resetUserList:^{
            for (CallUserModel *model in userList) {
                if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
                    if (self.curState == AudioCallState_Dailing) {
                        [self.userList addObject:model];
                    }
                }
            }
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self playAlerm];
}

- (void)disMiss {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
    
    [self stopAlerm];
}

#pragma mark logic

- (void)resetUserList:(void(^)(void))finished {
    self.userList = [NSMutableArray array];
    if (self.curSponsor) {
        [self.userList addObject:self.curSponsor];
        finished();
    } else {
        @weakify(self)
        [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
            @strongify(self)
            model.isEnter = YES;
            [self.userList addObject:model];
            finished();
        }];
    }
}

- (void)enterUser:(CallUserModel *)user {
    self.curState = AudioCallState_Calling;
    [self updateUser:user animate:YES];
    if (![user.userId isEqualToString:[TUICallUtils loginUser]]) {    
        [self stopAlerm];
    }
}

- (void)leaveUser:(NSString *)userId {
    for (CallUserModel *model in self.userList) {
        if ([model.userId isEqualToString:userId]) {
            [self.userList removeObject:model];
            break;
        }
    }
}

- (void)updateUser:(CallUserModel *)user animate:(BOOL)animate {
    BOOL findUser = NO;
    for (int i = 0; i < self.userList.count; i ++) {
        CallUserModel *model = self.userList[i];
        if ([model.userId isEqualToString:user.userId]) {
            model = user;
            findUser = YES;
            break;
        }
    }
    if (!findUser) {
        [self.userList addObject:user];
    }
    [self reloadData:animate];
}

- (void)reloadData:(BOOL)animate {
    CGFloat topPadding = 0;
    if (@available(iOS 11.0, *)) {
        topPadding = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }
    @weakify(self)
    [UIView performWithoutAnimation:^{
        @strongify(self)
        self.userCollectionView.mm_top(self.collectionCount == 1 ? (topPadding + 62) : topPadding).mm_flexToBottom(132);
        [self.userCollectionView reloadData];
    }];
}

#pragma mark UI
- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    CGFloat topPadding = 0;
    if (@available(iOS 11.0, *) ){
        topPadding = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }
    self.userCollectionView.mm_height(self.view.mm_w).mm_top(topPadding + 62);
    [self autoSetUIByState];
}

- (void)autoSetUIByState {
    switch (self.curState) {
        case AudioCallState_Dailing:
        {
            self.hangup.mm_width(50).mm_height(50).mm__centerX(self.view.mm_centerX).mm_bottom(32);
            self.calledView.hidden = YES;
            self.userCollectionView.hidden = NO;
        }
            break;
        case AudioCallState_OnInvitee:
        {
            self.hangup.mm_width(50).mm_height(50).mm__centerX(self.view.mm_centerX - 80).mm_bottom(32);
            self.accept.mm_width(50).mm_height(50).mm__centerX(self.view.mm_centerX + 80).mm_bottom(32);
            self.calledView.hidden = NO;
            self.userCollectionView.hidden = YES;
            [self.calledView fillWithData:self.curSponsor];
        }
            break;
        case AudioCallState_Calling:
        {
            self.hangup.mm_width(50).mm_height(50).mm__centerX(self.view.mm_centerX).mm_bottom(32);
            self.mute.mm_width(50).mm_height(50).mm__centerX(self.view.mm_centerX - 120).mm_bottom(32);
            self.handsfree.mm_width(50).mm_height(50).mm__centerX(self.view.mm_centerX + 120).mm_bottom(32);
            self.callTimeLabel.mm_width(50).mm_height(30).mm__centerX(self.view.mm_centerX).mm_bottom(self.hangup.mm_h + self.hangup.mm_b + 10);
            self.mute.hidden = NO;
            self.handsfree.hidden = NO;
            self.callTimeLabel.hidden = NO;
            self.calledView.hidden = YES;
            self.userCollectionView.hidden = NO;
            self.mute.alpha = 0.0;
            self.handsfree.alpha = 0.0;
            [self startCallTiming];
        }
            break;
        default:
            break;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        if (self.curState == AudioCallState_Calling) {
            self.mute.alpha = 1.0;
            self.handsfree.alpha = 1.0;
        }
    }];
}

- (void)startCallTiming {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
    self.callingTime = 0;
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.callTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)self.callingTime / 60, (int)self.callingTime % 60];
            self.callingTime += 1;
        });
    });
    dispatch_resume(self.timer);
}

- (UIButton *)hangup {
    if (!_hangup.superview) {
        _hangup = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hangup setImage:[UIImage imageNamed:TUIKitResource(@"ic_hangup")] forState:UIControlStateNormal];
        [_hangup addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_hangup];
    }
    return _hangup;
}

- (UIButton *)accept {
    if (!_accept.superview) {
        _accept = [UIButton buttonWithType:UIButtonTypeCustom];
        [_accept setImage:[UIImage imageNamed:TUIKitResource(@"ic_dialing")] forState:UIControlStateNormal];
        [_accept addTarget:self action:@selector(acceptClick) forControlEvents:UIControlEventTouchUpInside];
        _accept.hidden = (self.curSponsor == nil);
        [self.view addSubview:_accept];
    }
    return _accept;
}

- (UIButton *)mute {
    if (!_mute.superview) {
        _mute = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mute setImage:[UIImage imageNamed:TUIKitResource(@"ic_mute")] forState:UIControlStateNormal];
        [_mute addTarget:self action:@selector(muteClick) forControlEvents:UIControlEventTouchUpInside];
        _mute.hidden = YES;
        [self.view addSubview:_mute];
    }
    return _mute;
}

- (UIButton *)handsfree {
    if (!_handsfree.superview) {
        _handsfree = [UIButton buttonWithType:UIButtonTypeCustom];
        [_handsfree setImage:[UIImage imageNamed:TUIKitResource(@"ic_handsfree_on")] forState:UIControlStateNormal];
        [_handsfree addTarget:self action:@selector(handsfreeClick) forControlEvents:UIControlEventTouchUpInside];
        _handsfree.hidden = YES;
        [self.view addSubview:_handsfree];
    }
    return _handsfree;
}

- (UILabel *)callTimeLabel {
    if (!_callTimeLabel.superview) {
        _callTimeLabel = [[UILabel alloc] init];
        _callTimeLabel.backgroundColor = [UIColor clearColor];
        _callTimeLabel.text = @"00:00";
        _callTimeLabel.textColor = [UIColor whiteColor];
        _callTimeLabel.textAlignment = NSTextAlignmentCenter;
        _callTimeLabel.hidden = YES;
        [self.view addSubview:_callTimeLabel];
    }
    return _callTimeLabel;
}

- (TUIAudioCalledView *)calledView {
    if (!_calledView.superview) {
        _calledView = [[TUIAudioCalledView alloc] initWithFrame:CGRectMake((self.view.mm_w - kUserCalledView_Width) / 2, kUserCalledView_Top, kUserCalledView_Width, kUserCalledView_Width)];
        _calledView.hidden = YES;
        [self.view addSubview:_calledView];
    }
    return _calledView;
}

- (UICollectionView *)userCollectionView {
    if (!_userCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _userCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
        [_userCollectionView registerClass:[TUIAudioCallUserCell class] forCellWithReuseIdentifier:TUIAudioCallUserCell_ReuseId];
        if (@available(iOS 10.0, *)) {
            [_userCollectionView setPrefetchingEnabled:YES];
        } else {
            // Fallback on earlier versions
        }
        _userCollectionView.showsVerticalScrollIndicator = NO;
        _userCollectionView.showsHorizontalScrollIndicator = NO;
        _userCollectionView.contentMode = UIViewContentModeScaleToFill;
        _userCollectionView.dataSource = self;
        _userCollectionView.delegate = self;
        [self.view addSubview:_userCollectionView];
    }
    return _userCollectionView;
}

#pragma mark - 响铃🔔
// 播放铃声
- (void)playAlerm {
    self.playingAlerm = YES;
    [self loopPlayAlert];
}

// 结束播放铃声
- (void)stopAlerm {
    self.playingAlerm = NO;
}

// 循环播放声音
- (void)loopPlayAlert {
    if (!self.playingAlerm) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    AudioServicesPlaySystemSoundWithCompletion(1012, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loopPlayAlert];
        });
    });
}

#pragma mark Event
- (void)hangupClick {
    [[TUICall shareInstance] hangup];
    [self disMiss];
}

- (void)acceptClick {
    [[TUICall shareInstance] accept];
    @weakify(self)
    [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
        @strongify(self)
        model.isEnter = YES;
        [self enterUser:model];
        self.curState = AudioCallState_Calling;
        self.accept.hidden = YES;
    }];
}

- (void)muteClick {
    BOOL micMute = ![TUICall shareInstance].micMute;
    [[TUICall shareInstance] mute:micMute];
    [self.mute setImage:[TUICall shareInstance].isMicMute ? [UIImage imageNamed:TUIKitResource(@"ic_mute_on")] : [UIImage imageNamed:TUIKitResource(@"ic_mute")]  forState:UIControlStateNormal];
    if (micMute) {
        [THelper makeToast:TUILocalizableString(TUIKitCallTurningOnMute) duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    } else {
        [THelper makeToast:TUILocalizableString(TUIKitCallTurningOffMute) duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    }
}

- (void)handsfreeClick {
    BOOL handsFreeOn = ![TUICall shareInstance].handsFreeOn;
    [[TUICall shareInstance] handsFree:handsFreeOn];
    [self.handsfree setImage:[TUICall shareInstance].isHandsFreeOn ? [UIImage imageNamed:TUIKitResource(@"ic_handsfree_on")] : [UIImage imageNamed:TUIKitResource(@"ic_handsfree")]  forState:UIControlStateNormal];
    if (handsFreeOn) {
        [THelper makeToast:TUILocalizableString(TUIKitCallUsingSpeaker) duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    } else {
        [THelper makeToast:TUILocalizableString(TUIKitCallUsingHeadphone) duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    }
}

#pragma mark UICollectionViewDelegate

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self collectionCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIAudioCallUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TUIAudioCallUserCell_ReuseId forIndexPath:indexPath];
    if (indexPath.row < self.userList.count) {
        [cell fillWithData:self.userList[indexPath.row]];
    } else {
        [cell fillWithData:[[CallUserModel alloc] init]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat collectWidth = collectionView.frame.size.width;
    if (self.collectionCount <= 4) {
        CGFloat border = collectWidth / 2;
        if (self.collectionCount % 2 == 1 && indexPath.row == self.collectionCount - 1) {
            return CGSizeMake(collectWidth, border);
        } else {
            return CGSizeMake(border, border);
        }
    } else {
        CGFloat border = collectWidth / 3;
        return CGSizeMake(border, border);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark data

- (void)setCurState:(AudioCallState)curState {
    if (_curState != curState) {
        _curState = curState;
        [self autoSetUIByState];
    }
}

- (AudioCallState)curState {
    return _curState;
}

- (NSInteger)collectionCount {
    _collectionCount = (self.userList.count <= 4 ? self.userList.count : 9);
    if (self.curState == AudioCallState_OnInvitee) {
        _collectionCount = 1;
    }
    return _collectionCount;
}


- (CallUserModel *)getUserById:(NSString *)userID {
    for (CallUserModel *user in self.userList) {
        if ([user.userId isEqualToString:userID]) {
            return user;
        }
    }
    return nil;
}

@end

