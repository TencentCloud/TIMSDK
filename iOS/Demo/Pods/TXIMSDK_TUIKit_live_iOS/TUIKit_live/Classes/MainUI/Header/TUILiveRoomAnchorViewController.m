//
//  TUILiveRoomAnchorViewController.m
//  TUILiveKit
//
//  Created by coddyliu on 2020/9/2.
//  Copyright © 2020 null. All rights reserved.
//

#import "TUILiveRoomAnchorViewController.h"
#import "TUILiveCreateAnchorRoomView.h"
#import "TUILiveAnchorToolView.h"
#import "Masonry.h"
#import "TRTCLiveRoom.h"
#import "TXLiveRoomCommonDef.h"
#import "TUILiveUtil.h"
#import "TXLiveRoomCommonDef.h"
#import "TUILiveStatusInfoView.h"
#import "TUILiveMsgModel.h"
#import "TUILivePushShowResultView.h"
#import "TUILiveMsgListCell.h"
#import "TUILiveGiftAnimator.h"
#import "TUILiveGiftInfoDataHandler.h"
#import "TUILiveUserProfile.h"

#import "TCBeautyPanel.h"
#import "AudioEffectSettingKit.h"
#import "TUILiveStatisticsTool.h"
#import "TUILiveGiftDataSource.h"
#import "TUILiveDefaultGiftAdapterImp.h"
#import "TUILiveCountDownView.h"
#import "TUILiveFloatWindow.h"


#define MAX_LINKMIC_MEMBER_SUPPORT  3

#define VIDEO_VIEW_WIDTH            100
#define VIDEO_VIEW_HEIGHT           150
#define VIDEO_VIEW_MARGIN_BOTTOM    56
#define VIDEO_VIEW_MARGIN_RIGHT     8
#define VIDEO_VIEW_MARGIN_SPACE     5

#define BOTTOM_BTN_ICON_WIDTH  35

@interface TUILiveRoomAnchorViewController ()<TUILiveCreateAnchorRoomViewDelegate, TUILiveAnchorToolViewDelegate,TRTCLiveRoomDelegate, AudioEffectViewDelegate>

@property (nonatomic, strong)TUILiveCreateAnchorRoomView *previewControlView; // 创建房间控制页面
@property (nonatomic, strong)TUILiveAnchorToolView *anchorLogicView; // 直播业务逻辑视图
@property (nonatomic, strong)UIView *videoParentView; // 视屏画面视图
@property (nonatomic, strong)TCBeautyPanel *vBeautyPanelView;
@property (nonatomic, strong)AudioEffectSettingView *audioEffectSettingView;

@property (nonatomic, strong) TUILiveGiftInfoDataHandler *giftDataProvider; // 礼物数据提供者
@property (nonatomic, strong) UIView *giftAnimationContainerView;            // 礼物动画承载视图
@property (nonatomic, strong) TUILiveGiftAnimator *giftAnimator;             // 礼物动画

/// 当前直播间信息
@property (nonatomic, strong)TRTCLiveRoomInfo *liveInfo;
@property (nonatomic, strong, nonnull)TUILiveStatisticsTool *statisticsTool; // 暂时只用来做直播信息的统计
/// 当前正在PK的房间信息
@property (nonatomic, strong)TRTCLiveRoomInfo *curPKRoom;
@property (nonatomic, assign)TRTCLiveRoomLiveStatus roomStatus;

//PK&LinkMic视图
@property(nonatomic, strong)NSMutableArray<TUILiveStatusInfoView *> *statusInfoViewArray;

// 连麦状态管理
@property (nonatomic, strong)NSMutableSet *setLinkMemeber;
@property (nonatomic, strong)NSMutableDictionary<NSString *,TRTCLiveUserInfo *> *curRequestUserDic; // 当前连麦用户列表
@property (nonatomic, strong)NSString *sessionId;
@property (nonatomic, strong)UIAlertController *pkAlert; // 记录PK的Alert对象
// model层
@property (nonatomic, strong)TRTCLiveRoom *liveRoom; // 外界传入，统一对象
@property (nonatomic, assign) int roomId;

/// 礼物动画面板，动画数据等数据源对象
@property (nonatomic, strong) id<TUILiveGiftDataSource> giftDataSource;
@property(nonatomic, assign) BOOL enablePK;

@property (nonatomic, weak) TUILiveCountDownView *countDownView;

@end

@implementation TUILiveRoomAnchorViewController{
    BOOL _isStop; // 是否已经调用停止推流方法
    BOOL _isPKEnter; // 是否进入PK状态的标志位
    BOOL _isPublishing; // 是否开始了直播
    BOOL _isNavigationHidden; // 进入前navigation是否为隐藏
}

- (instancetype)init
{
    self = [super init];
    if ([TUILiveFloatWindow sharedInstance].isShowing) {
        [[TUILiveFloatWindow sharedInstance] hide];
        [TUILiveFloatWindow sharedInstance].backController = nil;
    }
    if (self) {
        self->_isStop = NO;
        self->_isPKEnter = NO;
        self->_sessionId = [self getLinkMicSessionID];
        self.giftDataSource = [[TUILiveDefaultGiftAdapterImp alloc] init];
    }
    return self;
}

- (instancetype)initWithRoomId:(int)roomId {
    self = [super init];
    if ([TUILiveFloatWindow sharedInstance].isShowing) {
        [[TUILiveFloatWindow sharedInstance] hide];
        [TUILiveFloatWindow sharedInstance].backController = nil;
    }
    if (self) {
        self->_isStop = NO;
        self->_isPKEnter = NO;
        self->_sessionId = [self getLinkMicSessionID];
        self.giftDataSource = [[TUILiveDefaultGiftAdapterImp alloc] init];
        self.roomId = roomId;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

#pragma mark - public
- (void)enablePK:(BOOL)enable {
    _enablePK = enable;
    [self.anchorLogicView enablePK:enable];
}

#pragma mark - 懒加载
- (TRTCLiveRoom *)liveRoom {
    if (!_liveRoom) {
        _liveRoom = [TRTCLiveRoom sharedInstance];
    }
    return _liveRoom;
}

- (NSMutableArray<TUILiveStatusInfoView *> *)statusInfoViewArray {
    if (!_statusInfoViewArray) {
        _statusInfoViewArray = [NSMutableArray arrayWithCapacity:2];
    }
    return _statusInfoViewArray;
}

- (NSMutableSet *)setLinkMemeber {
    if (!_setLinkMemeber) {
        _setLinkMemeber = [NSMutableSet set];
    }
    return _setLinkMemeber;
}

- (NSMutableDictionary<NSString *,TRTCLiveUserInfo *> *)curRequestUserDic {
    if (!_curRequestUserDic) {
        _curRequestUserDic = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return _curRequestUserDic;
}

#pragma mark - public method


#pragma mark - 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundLayer];
    [self constructSubViews];
    [self changeCurrentStatus:YES]; // 进入主播页面，初始状态为预览页
    [self constructViewHierarchy];
    [self layoutUI];    // 添加通知
    [self addNotification];
    [self startPreview];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self->_isNavigationHidden = self.navigationController.navigationBar.isHidden;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:self->_isNavigationHidden animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopRtmp];
}

- (void)dealloc {
    [self stopRtmp];
    self.anchorLogicView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    NSLog(@"delloc anchorViewController");
    [self.audioEffectSettingView resetAudioSetting];
}

#pragma mark - 私有方法(viewdidLoad时调用)
- (void)addBackgroundLayer {
    //加载背景图
    NSArray *colors = [NSArray arrayWithObjects:
                       (__bridge id)[UIColor colorWithRed:19.0 / 255.0 green:41.0 / 255.0 blue:75.0 / 255.0 alpha:1].CGColor,
                       (__bridge id)[UIColor colorWithRed:5.0 / 255.0 green:12.0 / 255.0 blue:23.0 / 255.0 alpha:1].CGColor, nil];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)constructSubViews {
    self.statisticsTool = [[TUILiveStatisticsTool alloc] initWithIsHost:YES audienceCount:self.liveInfo.memberCount likeCount:0];
    
    self.videoParentView = [[UIView alloc] initWithFrame:self.view.frame];
    self.previewControlView = [[TUILiveCreateAnchorRoomView alloc] init];
    self.previewControlView.viewPresenter = self;
    
    self.anchorLogicView = [[TUILiveAnchorToolView alloc] initWithFrame:self.view.frame];
    self.anchorLogicView.delegate = self;
    [self.anchorLogicView enablePK:self.enablePK];
    self.audioEffectSettingView  = [[AudioEffectSettingView alloc] initWithType:AudioEffectSettingViewCustom];
    [self.audioEffectSettingView setAudioEffectManager:[self.liveRoom getAudioEffectManager]];
    self.audioEffectSettingView.delegate = self;
    [self.audioEffectSettingView hide];
    // 初始化连麦视图
    [self initStatusInfoView: 1];
    [self initStatusInfoView: 2];
    [self initStatusInfoView: 3];
    
    // 初始化连麦视图关闭（踢出出连麦的按钮）
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    int index = 1;
    CGFloat bottomMargin = VIDEO_VIEW_MARGIN_BOTTOM;
    if (@available(iOS 11.0, *)) {
        bottomMargin = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom + VIDEO_VIEW_MARGIN_BOTTOM;
    }
    for (TUILiveStatusInfoView* statusInfoView in _statusInfoViewArray) {
        statusInfoView.btnKickout = [[UIButton alloc] initWithFrame:CGRectMake(width - BOTTOM_BTN_ICON_WIDTH/2 - VIDEO_VIEW_MARGIN_RIGHT - 15,
                                                                               height - bottomMargin - VIDEO_VIEW_HEIGHT * index + 15 - 60,
                                                                               BOTTOM_BTN_ICON_WIDTH/2,
                                                                               BOTTOM_BTN_ICON_WIDTH/2)];
        [statusInfoView.btnKickout addTarget:self action:@selector(clickBtnKickout:) forControlEvents:UIControlEventTouchUpInside];
        [statusInfoView.btnKickout setImage:[UIImage imageNamed:@"live_anchor_kickout"] forState:UIControlStateNormal];
        statusInfoView.btnKickout.hidden = YES;
        index++;
    }
    CGFloat bottomOffset = 0;
    if (@available(iOS 11, *)) {
        bottomOffset = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    CGFloat beautyheight = [TCBeautyPanel getHeight] + bottomOffset;
    TCBeautyPanelTheme *theme = [[TCBeautyPanelTheme alloc] init];

    UIColor *cyanColor = [UIColor colorWithRed:11.f/255.f
                                         green:204.f/255.f
                                          blue:172.f/255.f
                                         alpha:1.0];
    theme.beautyPanelSelectionColor = cyanColor;
    theme.beautyPanelMenuSelectionBackgroundImage = [UIImage imageNamed:@"live_beauty_selection_bg"];
    theme.sliderThumbImage = [UIImage imageNamed:@"live_slider"];
    theme.sliderValueColor = theme.beautyPanelSelectionColor;
    theme.sliderMinColor = cyanColor;
    
    self.vBeautyPanelView = [[TCBeautyPanel  alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -beautyheight,
                                                                             self.view.frame.size.width, beautyheight)
                                               theme:theme
                                                  actionPerformer:[TCBeautyPanelActionProxy proxyWithSDKObject:self.liveRoom]];
    self.vBeautyPanelView.bottomOffset = bottomOffset;
    [self.vBeautyPanelView resetAndApplyValues];
    self.vBeautyPanelView.hidden = YES;
}

- (void)initStatusInfoView: (int)index {
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    TUILiveStatusInfoView* statusInfoView = [[TUILiveStatusInfoView alloc] init];
    CGFloat bottomMargin = VIDEO_VIEW_MARGIN_BOTTOM;
    if (@available(iOS 11.0, *)) {
        bottomMargin = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom + VIDEO_VIEW_MARGIN_BOTTOM;
    }
    statusInfoView.videoView = [[UIView alloc] initWithFrame:CGRectMake(width - VIDEO_VIEW_WIDTH - VIDEO_VIEW_MARGIN_RIGHT,
                                                                        height - bottomMargin - VIDEO_VIEW_HEIGHT * index - VIDEO_VIEW_MARGIN_SPACE * (index - 1) - 60,
                                                                        VIDEO_VIEW_WIDTH,
                                                                        VIDEO_VIEW_HEIGHT)];
    statusInfoView.linkFrame = CGRectMake(width - VIDEO_VIEW_WIDTH - VIDEO_VIEW_MARGIN_RIGHT,
                                          height - bottomMargin - VIDEO_VIEW_HEIGHT * index - VIDEO_VIEW_MARGIN_SPACE * (index - 1) - 60,
                                          VIDEO_VIEW_WIDTH,
                                          VIDEO_VIEW_HEIGHT);
    statusInfoView.pending = false;
    [self.statusInfoViewArray addObject:statusInfoView];
}

- (void)constructViewHierarchy {
    [self.view addSubview:self.videoParentView];
    [self.statusInfoViewArray enumerateObjectsUsingBlock:^(TUILiveStatusInfoView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.view addSubview:obj.videoView];
    }];
    [self.view addSubview:self.giftAnimationContainerView];
    [self.view addSubview:self.previewControlView];
    [self.view addSubview:self.anchorLogicView];
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithCapacity:2];
    [self.statusInfoViewArray enumerateObjectsUsingBlock:^(TUILiveStatusInfoView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempArr addObject:obj.btnKickout];
    }];
    self.anchorLogicView.insertControlViews = tempArr;
    [self.view addSubview:self.vBeautyPanelView];
    [self.view addSubview:self.audioEffectSettingView];
}

- (void)layoutUI {
    CGFloat bottomOffset = 0;
    if (@available(iOS 11, *)) {
        bottomOffset = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    [self.videoParentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    [self.previewControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    [self.anchorLogicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    [self.giftAnimationContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    [self.audioEffectSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.height.mas_equalTo(526 + bottomOffset);
        make.bottom.equalTo(self.view.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

- (void)startPreview {
    [self.liveRoom startCameraPreviewWithFrontCamera:YES view:self.videoParentView callback:^(int code, NSString * _Nullable message) {
        if (code == 0) {
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        }
    }];
    self.liveRoom.delegate = self;
}

#pragma mark - AudioEffectViewDelegate
- (void)onEffectViewHidden:(BOOL)isHidden {
    [self.anchorLogicView switchAudioSettingStatus:!isHidden];
}

#pragma mark - 私有方法 - 房间
-(void)closeVC {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UInt32)generateRoomID {
    if (self.roomId <= 0) {
        NSString* userID = [NSString stringWithFormat:@"%@_liveRoom", [TUILiveUserProfile getLoginUserInfo].userID];
        self.roomId = ([userID hash] & 0x7FFFFFFF);
    }
    return self.roomId;
}

// 切换当前页面状态
- (void)changeCurrentStatus:(BOOL)isPreview {
    self.previewControlView.hidden = !isPreview;
    self.anchorLogicView.hidden = isPreview;
}

/// 创建房间成功的后续逻辑
/// @param roomParam 创建房间的参数
- (void)onRoomCreateSuccessWithRoomID:(UInt32)roomID params:(TUILiveRoomPublishParams *)roomParam {
    V2TIMUserFullInfo *userInfo = [TUILiveUserProfile getLoginUserInfo];
    NSString *roomIDStr = [NSString stringWithFormat:@"%u", (unsigned int)roomID];
    TRTCLiveRoomInfo *roomInfo = [[TRTCLiveRoomInfo alloc] initWithRoomId:roomIDStr
                                                                 roomName:roomParam.roomName
                                                                 coverUrl:userInfo.faceURL
                                                                  ownerId:userInfo.userID
                                                                ownerName:userInfo.nickName
                                                                streamUrl:userInfo.faceURL ?: @""
                                                              memberCount:0
                                                               roomStatus:TRTCLiveRoomLiveStatusSingle];
    self.liveInfo = roomInfo;
    
    // 切换为直播状态
    [self changeCurrentStatus:NO];
    // 设置音效
    [self.liveRoom setAudioQuality:roomParam.audioQuality];
    // 创建推流stream ID 默认：urlencode(sdkAppId_roomId_userId_streamType)
    //[[TUIKitLive shareInstance] valueForKey:@"sdkAppId"];
    // NSString *streamID = [NSString stringWithFormat:@"%@_stream", userInfo.userID];
    [self.liveRoom startPublishWithStreamID:@"" callback:^(int code, NSString * _Nullable message) {
        if (code != 0) {
            // TODO: 跑错误事件
            NSLog(@"%@", message);
            [TUITool makeToast:message];
        }
    }];
    
}

/// 停止直播
- (void)stopRtmp {
    if (!self->_isStop) {
        self->_isStop = YES;
    } else {
        return;
    }
    for (TUILiveStatusInfoView* statusInfoView in _statusInfoViewArray) {
        if (statusInfoView.userID.length > 0 && [self.setLinkMemeber containsObject:statusInfoView.userID]) {
            [self.liveRoom kickoutJoinAnchor:statusInfoView.userID callback:^(int code, NSString * error) {
                
            }];
        }
        [statusInfoView stopPlay];
    }
    if (self.curPKRoom) {
        [self quitPK];
    }
    self.liveRoom.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.liveRoom stopCameraPreview];
    [self.liveRoom stopPublish:nil];
    [self.liveRoom destroyRoom:^(int code, NSString * _Nullable message) {
        if (code == 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomDestroy:)]) {
                [self.delegate onRoomDestroy:self.liveInfo];
            }
        } else {
            NSLog(@"TUIKitLive# 解散房间失败:%d, %@", code, message);
        }
    }];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)getAndShowCurrentRoomExceptMine {
    if (self.delegate && [self.delegate respondsToSelector:@selector(getPKRoomIDList:)]) {
        @weakify(self);
        [self.delegate getPKRoomIDList:^(NSArray<NSString *> * _Nonnull pkRoomIDList) {
            dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
            dispatch_async(globalQueue, ^{
                @strongify(self);
                NSMutableArray<NSNumber *> *roomIDNumberValues = [[NSMutableArray alloc] init];
                [pkRoomIDList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj intValue]) {
                        [roomIDNumberValues addObject:@([obj intValue])];
                    }
                }];
                @weakify(self);
                [self.liveRoom getRoomInfosWithRoomIDs:roomIDNumberValues callback:^(int code, NSString * _Nullable message, NSArray<TRTCLiveRoomInfo *> * _Nonnull roomList) {
                    //首先剔除自己的房间，而后将数组传递给AnchorLogicView，显示房间列表。
                    @strongify(self);
                    NSMutableArray<TRTCLiveRoomInfo *> *mutableArr = [roomList mutableCopy];
                    [mutableArr enumerateObjectsUsingBlock:^(TRTCLiveRoomInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.roomId isEqualToString:self.liveInfo.roomId]) {
                            *stop = YES;
                            [mutableArr removeObject:obj];
                        }
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.anchorLogicView showRoomList:mutableArr];
                    });
                }];
            });
        }];
    }
}

- (void)onAnchorEnter:(NSString *)userID {
    if ([userID isEqualToString:self.liveInfo.ownerId]) {
        return;
    }
    if (userID == nil || userID.length == 0) {
        return;
    }
    BOOL isPKMode = (self.curPKRoom != nil && [userID isEqualToString:self.curPKRoom.ownerId]);
    if (isPKMode) {
        self->_isPKEnter = YES;
        [self.anchorLogicView changePKState:YES];
    }
    for (TUILiveStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if ([userID isEqualToString:statusInfoView.userID]) {
            if ([statusInfoView pending]) {
                statusInfoView.pending = NO;
                __weak __typeof(self) weakSelf = self;
                [self.liveRoom startPlayWithUserID:userID view:statusInfoView.videoView callback:^(int code, NSString * error) {
                    [statusInfoView stopLoading];
                    if (code == 0) {
                         [statusInfoView.btnKickout setHidden:isPKMode];
                    } else {
                        if (!isPKMode) {
                            [weakSelf.liveRoom kickoutJoinAnchor:userID callback:nil];
                            [weakSelf onAnchorExit:userID];
                        }
                    }
                }];
            }
            break;
        }
    }
}

- (void)onAnchorExit:(NSString *)userID {
    if ([userID isEqualToString:self.liveInfo.ownerId]) {
        return;
    }
    TUILiveStatusInfoView * statusInfoView = [self getStatusInfoViewFrom:userID];
    if (statusInfoView) {
        [statusInfoView stopLoading];
        [statusInfoView stopPlay];
        [self.liveRoom stopPlayWithUserID:statusInfoView.userID callback:nil];
        [statusInfoView emptyPlayInfo];
        [self.setLinkMemeber removeObject:userID];
    }
    if (self.curPKRoom != nil && [userID isEqualToString:self.curPKRoom.ownerId]) {
        [self linkFrameRestore];
    }
}

- (TUILiveIMUserAble *)createUserAbleWith:(TRTCLiveUserInfo *)user cmdType:(NSInteger)cmdType {
    TUILiveIMUserAble *info = [[TUILiveIMUserAble alloc] init];
    info.imUserId = user.userId;
    info.imUserName = user.userName;
    info.imUserIconUrl = user.avatarURL;
    info.cmdType = cmdType;
    return info;
}
#pragma mark - 私有方法 - PK

//响应其他主播PK
- (void)onRequestRoomPK:(TRTCLiveUserInfo *)user {
    
    // 如果正在连麦，或者正在建立连麦，则过滤掉
    if (self.anchorLogicView.isLinkMic) {
        NSLog(@"当前正在连麦，无法接受PK请求");
        return;
    }
    
    self.curPKRoom = [[TRTCLiveRoomInfo alloc] init];
    self.curPKRoom.ownerId = user.userId;
    self.curPKRoom.ownerName = user.userName;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@发起了PK请求", user.userName?:user.userId] message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    __weak __typeof(self) weakSelf = self;
    UIAlertAction *reject = [UIAlertAction actionWithTitle:@"拒绝" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf linkFrameRestore];
        [weakSelf.liveRoom responseRoomPKWithUserID:user.userId agree:NO reason:@"主播拒绝"];
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"接受" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.liveRoom responseRoomPKWithUserID:user.userId agree:YES reason:@""];
        [weakSelf.anchorLogicView changePKState:YES];
    }];
    [alert addAction:reject];
    [alert addAction:ok];
    self.pkAlert = alert;
    [self presentViewController:alert animated:YES completion:nil];
}

// 主要做PK响应超时处理
- (void)PKAlertCheck: (UIAlertController*)alert {
    if (alert.presentingViewController == self || self.presentedViewController == alert) {
        NSString *tipName = _curPKRoom.ownerName;
        if (!tipName || [tipName isEqualToString:@""]) {
            tipName = _curPKRoom.ownerId; // 房主没有设置昵称，则用ID代替提示
        }
        [TUILiveUtil toastTip: [NSString stringWithFormat: @"处理%@PK超时", tipName] parentView:self.view];
        [alert dismissViewControllerAnimated:YES completion:nil];
        [self linkFrameRestore];
    }
}

- (void)startPKWithRoom:(TRTCLiveRoomInfo *)roomInfo {
    if (self.roomStatus == TRTCLiveRoomLiveStatusLinkMic) {
        return;
    }
    @weakify(self);
    [self.liveRoom requestRoomPKWithRoomID:[roomInfo.roomId intValue] userID:roomInfo.ownerId timeout:15 responseCallback:^(BOOL agreed, NSString * _Nullable reason) {
        @strongify(self);
        NSString *tipName = roomInfo.ownerName;
        if (!tipName || [tipName isEqualToString:@""]) {
            tipName = roomInfo.ownerId; // 房主没有设置昵称，则用ID代替提示
        }
        if (agreed) {
            // 同意PK
            [TUILiveUtil toastTip:[NSString stringWithFormat:@"%@已接受您的PK请求", tipName] parentView:self.view];
        } else {
            // 拒绝PK
            if (reason.length > 0) {
                [TUILiveUtil toastTip:reason parentView:self.view];
            } else {
                [TUILiveUtil toastTip:[NSString stringWithFormat:@"%@已拒绝了您的PK请求", tipName] parentView:self.view];
            }
            if (self.roomStatus != TRTCLiveRoomLiveStatusRoomPK) {
                self.curPKRoom = nil;
            }
        }
    }];
    if (self.roomStatus != TRTCLiveRoomLiveStatusRoomPK) {
        self.curPKRoom = roomInfo;
    }
}

- (void)quitPK {
    [self.liveRoom quitRoomPK:nil];
    [UIView animateWithDuration:0.1 animations:^{
        [self onAnchorExit:self.curPKRoom.ownerId];
    }];
}

- (void)setCurPKRoom:(TRTCLiveRoomInfo *)curPKRoom {
    _curPKRoom = curPKRoom;
    if (_curPKRoom == nil) {
        _isPKEnter = NO;
        [_anchorLogicView changePKState:NO];
    }
}

- (void)switchPKModel {
    CGFloat topOffset = 0;
    if (@available(iOS 11, *)) {
        topOffset = UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;
    }
    TUILiveStatusInfoView *info = [self getStatusInfoViewFrom:self.curPKRoom.ownerId];
    if (info == nil) {
        for (TUILiveStatusInfoView *statusInfoView in self.statusInfoViewArray) {
            if (statusInfoView.userID == nil || [statusInfoView.userID length] == 0) {
                [statusInfoView.videoView setFrame:CGRectMake(self.view.frame.size.width / 2, 80 + topOffset, self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
                statusInfoView.pending = YES;
                statusInfoView.userID = self.curPKRoom.ownerId;
                [statusInfoView startLoading];
                break;
            }
        }
    } else {
        [info.videoView setFrame:CGRectMake(self.view.frame.size.width / 2, 80 + topOffset, self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
    }
}

- (void)linkFrameRestore {
    for (TUILiveStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if ([statusInfoView.userID length] > 0) {
            [statusInfoView.videoView setFrame:statusInfoView.linkFrame];
        }
    }
    [self.liveRoom stopPlayWithUserID:_curPKRoom.ownerId callback:^(int code, NSString * error) {
        
    }];
    self.curPKRoom = nil;
}

- (TUILiveStatusInfoView *)getStatusInfoViewFrom:(NSString*)userID {
    if (userID) {
        for (TUILiveStatusInfoView* statusInfoView in _statusInfoViewArray) {
            if ([userID isEqualToString:statusInfoView.userID]) {
                return statusInfoView;
            }
        }
    }
    return nil;
}

- (BOOL)isNoAnchorINStatusInfoView {
    for (TUILiveStatusInfoView* statusInfoView in _statusInfoViewArray) {
        if ([statusInfoView.userID length] > 0) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 私有方法 - 连麦
- (void)onRequestJoinAnchor:(TRTCLiveUserInfo *)user reason:(NSString *)reason{
    if ([self.setLinkMemeber count] >= MAX_LINKMIC_MEMBER_SUPPORT) {
        [TUILiveUtil toastTip:@"连麦请求拒绝，主播端连麦人数超过最大限制" parentView:self.view];
        [self.liveRoom responseJoinAnchor:user.userId agree:NO reason:@"主播端连麦人数超过最大限制"];
    }
    else if (self.curPKRoom != nil) {
        [TUILiveUtil toastTip:@"主播正在进行PK，暂时无法连麦" parentView:self.view];
        [self.liveRoom responseJoinAnchor:user.userId agree:NO reason:@"请稍后，主播正在进行PK"];
    }
    else {
        TUILiveStatusInfoView * statusInfoView = [self getStatusInfoViewFrom:user.userId];
        if (statusInfoView){
            [self.liveRoom kickoutJoinAnchor:user.userId callback:^(int code, NSString * error) {
                
            }];
            [self.setLinkMemeber removeObject:statusInfoView.userID];
            [statusInfoView stopLoading];
            [statusInfoView stopPlay];
            [statusInfoView emptyPlayInfo];
        }
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [TUITool makeToast:[NSString stringWithFormat:@"收到1个观众的邀请"] duration:2 position:CGPointMake(self.view.center.x, self.view.frame.size.height - 80)];
            [self.curRequestUserDic setObject:user forKey:user.userId];
            [self.anchorLogicView updateJoinAnchorList:self.curRequestUserDic.allValues needShow:NO];
        });
    }
}

- (void)onLinkMicTimeOut:(NSString*)userID {
    if (userID) {
        TUILiveStatusInfoView* statusInfoView = [self getStatusInfoViewFrom:userID];
        if (statusInfoView && statusInfoView.pending == YES){
            [self.liveRoom kickoutJoinAnchor:statusInfoView.userID callback:^(int code, NSString * error) {
                
            }];
            [self.setLinkMemeber removeObject:userID];
            [statusInfoView stopPlay];
            [statusInfoView emptyPlayInfo];
            [TUILiveUtil toastTip: [NSString stringWithFormat: @"%@进房超时", userID] parentView:self.view];
        }
    }
}

- (void)handleTimeOutRequest:(UIAlertController *)alertController {
    if (alertController && self.presentingViewController == alertController) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        [TUILiveUtil toastTip: @"处理连麦请求超时" parentView:self.view];
    }
    self.anchorLogicView.isLinkMic = NO;    // 标记连麦结束
}

// FIXME: - 暂时没有用到
- (NSString*)getLinkMicSessionID {
    //说明：
    //1.sessionID是混流依据，sessionID相同的流，后台混流Server会混为一路视频流；因此，sessionID必须全局唯一
    
    //2.直播码频道ID理论上是全局唯一的，使用直播码作为sessionID是最为合适的
    //NSString* strSessionID = [TCLinkMicModel getStreamIDByStreamUrl:self.rtmpUrl];
    
    //3.直播码是字符串，混流Server目前只支持64位数字表示的sessionID，暂时按照下面这种方式生成sessionID
    //  待混流Server改造完成后，再使用直播码作为sessionID
    
    UInt64 timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    
    UInt64 sessionID = ((UInt64)3891 << 48 | timeStamp); // 3891是bizid, timeStamp是当前毫秒值
    
    return [NSString stringWithFormat:@"%llu", sessionID];
}


- (void)clickBtnKickout:(UIButton *)btn {
    for (TUILiveStatusInfoView* statusInfoView in _statusInfoViewArray) {
        if (statusInfoView.btnKickout == btn) {
            [self.liveRoom stopPlayWithUserID:statusInfoView.userID callback:^(int code, NSString * error) {
                
            }];
            [self.liveRoom kickoutJoinAnchor:statusInfoView.userID callback:^(int code, NSString * error) {
                
            }];
            [self.setLinkMemeber removeObject:statusInfoView.userID];
            [statusInfoView stopLoading];
            [statusInfoView stopPlay];
            [statusInfoView emptyPlayInfo];
            self.anchorLogicView.isLinkMic = NO;
            break;
        }
    }
}


#pragma mark - TUILiveCreateAnchorRoomViewDelegate
- (void)startPublish:(TUILiveRoomPublishParams *)roomParams{
    // 创建房间开始直播
    NSString *avatar = [TUILiveUserProfile getLoginUserInfo].faceURL;
    TRTCCreateRoomParam *trtcParam = [[TRTCCreateRoomParam alloc] initWithRoomName:roomParams.roomName coverUrl:avatar];
    UInt32 roomID = [self generateRoomID];
    @weakify(self);
    [self.liveRoom createRoomWithRoomID:roomID roomParam:trtcParam callback:^(int code, NSString * _Nullable message) {
        @strongify(self);
        if (code == 0) {
            [self showCountDown:^{
                [self onRoomCreateSuccessWithRoomID:roomID params:roomParams];
                if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomCreate:)]) {
                    [self.delegate onRoomCreate:self.liveInfo];
                }
                [self.statisticsTool startLive];
                self->_isPublishing = YES;
            }];
            
        } else {
            [TUITool makeToast:@"创建房间失败，请检查房间名是否合法，网络是否正常。" duration:2.0 idposition:TUICSToastPositionCenter];
        }
    }];
}

- (void)switchCamera {
    [self.liveRoom switchCamera];
}

- (void)showBeautyPanel:(BOOL)isShow {
    self.vBeautyPanelView.hidden = !isShow;
}

//  TUILiveAnchorToolViewDelegate 也有此方法
-(void)closeAction {
    if (!self->_isPublishing) {
        [self closeVC];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"当前正在直播，确定退出直播？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *suerAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.anchorLogicView stopLive];
        [self stopRtmp];
        [self.statisticsTool pauseLive];
        [self.vBeautyPanelView resetAndApplyValues];
        self->_isPublishing = NO;
        @weakify(self);
        TUILivePushShowResultView *resultView = [[TUILivePushShowResultView alloc] initWithFrame:CGRectMake(
                                                                                                  UIScreen.mainScreen.bounds.size.width / 4.0,
                                                                                                  UIScreen.mainScreen.bounds.size.height / 3.0,
                                                                                                  UIScreen.mainScreen.bounds.size.width / 2.0,
                                                                                                  222) resultData:self.statisticsTool backHomepage:^{
            @strongify(self);
            [self closeVC];
        }];
        UIView *clearView = [[UIView alloc] initWithFrame:self.view.frame];
        clearView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self.view addSubview:clearView];
        [self.view addSubview:resultView];
        [resultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(66);
            make.trailing.mas_equalTo(-66);
            make.centerY.mas_equalTo(self.view);
            make.height.mas_equalTo(268);
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:suerAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -  TUILiveAnchorToolViewDelegate
- (void)anchorToolView:(TUILiveAnchorToolView *)view clickAction:(TUILiveAnchorToolViewAction)action {
    // index 0 美颜 1 PK 2 切换摄像头 3 关闭
    switch (action) {
        case TUILiveAnchorToolViewActionShowBeauty:
            // 美颜
            [self.anchorLogicView switchBeautyStatus:YES];
            self.vBeautyPanelView.hidden = NO;
            break;
        case TUILiveAnchorToolViewActionShowAudioPanel:
            [self.anchorLogicView switchAudioSettingStatus:YES];
            [self.audioEffectSettingView show];
            break;
        case TUILiveAnchorToolViewActionShowPKList:
            // PK
            if (self.anchorLogicView.isPKRoomListShow) {
                [self.anchorLogicView hideRoomList];
            } else {
                [self getAndShowCurrentRoomExceptMine];
            }
            break;
        case TUILiveAnchorToolViewActionSwitchCamera:
            // 切换摄像头
            [self switchCamera];
            break;
        case TUILiveAnchorToolViewActionCloseAction:
            [self closeAction];
            break;
        case TUILiveAnchorToolViewActionStopPK:
            [self quitPK];
            break;
        case TUILiveAnchorToolViewActionShowJoinAnchorList:
            [self.anchorLogicView updateJoinAnchorList:self.curRequestUserDic.allValues needShow:YES];
            break;
        default:
            break;
    }
}

- (void)anchorToolViewOnTapCancelAction:(TUILiveAnchorToolView *)view {
    if (!self.vBeautyPanelView.isHidden) {
        self.vBeautyPanelView.hidden = YES;
    }
    if (!self.audioEffectSettingView.isHidden) {
        [self.audioEffectSettingView hide];
    }
}

- (void)sendTextMsg:(NSString *)msg isDamma:(BOOL)isDama {
    if (isDama) {
        [self.liveRoom sendRoomCustomMsgWithCommand:[@(TUILiveMsgModelType_DanmaMsg) stringValue] message:msg callback:nil];
    } else {
        [self.liveRoom sendRoomTextMsg:msg callback:nil];
    }
}

- (void)onReceiveGiftMsg:(TUILiveMsgModel *)gift
{
    // 接收到礼物消息 - 打开礼物动画组件
    [self showGiftAnimation:gift];
}

#pragma mark - 响应连麦
- (void)onRespondJoinAnchor:(TRTCLiveUserInfo *)user agree:(BOOL)agree {
    if (agree) {
        
        // 如果正在PK，提示
        if (self.curPKRoom) {
            [TUILiveUtil toastTip:@"当前正在PK，无法接受连麦请求" parentView:self.view];
            return;
        }
        
        if ([self.setLinkMemeber count] >= MAX_LINKMIC_MEMBER_SUPPORT) {
            [TUILiveUtil toastTip:@"当前连麦人数超过最大限制" parentView:self.view];
            return;
        }
        [self.liveRoom responseJoinAnchor:user.userId agree:YES reason:@""];
        for (TUILiveStatusInfoView *statusInfoView in self.statusInfoViewArray) {
            if (statusInfoView.userID == nil || statusInfoView.userID.length == 0) {
                statusInfoView.pending = YES;
                statusInfoView.userID = user.userId;
                [statusInfoView startLoading];
                break;
            }
        }
        [self.setLinkMemeber addObject:user.userId];
        // 设置超时逻辑
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onLinkMicTimeOut:) object:user.userId];
        [self performSelector:@selector(onLinkMicTimeOut:) withObject:user.userId afterDelay:5];
        self.anchorLogicView.isLinkMic = YES;
    } else {
        [self.liveRoom responseJoinAnchor:user.userId agree:NO reason:@"主播拒绝了你的连麦请求"];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.curRequestUserDic removeObjectForKey:user.userId];
        [self.anchorLogicView updateJoinAnchorList:self.curRequestUserDic.allValues needShow:NO];
    });
}

#pragma mark - TRTCLiveRoomDelegate
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onError:(NSInteger)code message:(NSString  *)message
{
    if ([self.delegate respondsToSelector:@selector(onRoomError:errorCode:errorMessage:)]) {
        [self.delegate onRoomError:self.liveInfo errorCode:code errorMessage:message];
    }
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onRoomDestroy:(NSString *)roomID {
    // 主播端通常由主播销毁房间，所以不需要监听回调
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onRoomInfoChange:(TRTCLiveRoomInfo *)info {
    self.roomStatus = info.roomStatus;
    if (info.roomStatus == TRTCLiveRoomLiveStatusSingle || info.roomStatus == TRTCLiveRoomLiveStatusLinkMic) {
        self.curPKRoom = nil;
        [UIView animateWithDuration:0.1 animations:^{
            [self.videoParentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.left.equalTo(self.view);
                make.bottom.right.equalTo(self.view);
            }];
            [self.videoParentView layoutIfNeeded];
            [self linkFrameRestore];
        }];
        
        if (info.roomStatus == TRTCLiveRoomLiveStatusSingle) {
            self.anchorLogicView.isLinkMic = NO;
        }
    } else if (info.roomStatus == TRTCLiveRoomLiveStatusRoomPK) {
        CGFloat topOffset = 0;
        if (@available(iOS 11, *)) {
            topOffset = UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;
        }
        [UIView animateWithDuration:0.1 animations:^{
            [self.videoParentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view);
                make.top.equalTo(self.view.mas_top).offset(80 + topOffset);
                make.height.width.equalTo(self.view).multipliedBy(0.5);
            }];
            [self.videoParentView layoutIfNeeded];
            [self switchPKModel];
        }];
    }
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onAnchorEnter:(NSString *)userID {
    [self onAnchorEnter:userID];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onAnchorExit:(NSString *)userID {
    [self onAnchorExit:userID];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onAudienceEnter:(TRTCLiveUserInfo *)user {
    [self.statisticsTool onUserEnterLiveRoom]; //TODO: - 得检查是否已经在观众列表了
    TUILiveIMUserAble *info = [self createUserAbleWith:user cmdType:2];
    [self.anchorLogicView handleIMMessage:info msgText:@"加入直播"];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onAudienceExit:(TRTCLiveUserInfo *)user {
    [self.statisticsTool onUserExitLiveRoom];
    TUILiveIMUserAble *info = [self createUserAbleWith:user cmdType:3];
    [self.anchorLogicView handleIMMessage:info msgText:@"退出直播"];
    // 如果此时该观众处于申请上麦的状态，则从上麦列表清除
    if ([self.curRequestUserDic.allKeys containsObject:user.userId]) {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.curRequestUserDic removeObjectForKey:user.userId];
            [self.anchorLogicView updateJoinAnchorList:self.curRequestUserDic.allValues needShow:NO];
        });
    }
}

// 连麦
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onRequestJoinAnchor:(TRTCLiveUserInfo *)user reason:(NSString *)reason {
    [self onRequestJoinAnchor:user reason:reason];
}

- (void)trtcLiveRoomOnKickoutJoinAnchor:(TRTCLiveRoom *)liveRoom {
    // 主播端不会出现被踢下麦的情况
}

// PK
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onRequestRoomPK:(TRTCLiveUserInfo *)user {
    [self onRequestRoomPK:user];
}

- (void)trtcLiveRoomOnQuitRoomPK:(TRTCLiveRoom *)liveRoom {
    [TUILiveUtil toastTip:@"对方主播已结束PK" parentView:self.view];
    [self linkFrameRestore];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onRecvRoomTextMsg:(NSString *)message fromUser:(TRTCLiveUserInfo *)user {
    TUILiveIMUserAble *info = [self createUserAbleWith:user cmdType:TUILiveMsgModelType_NormalMsg];
    [self.anchorLogicView handleIMMessage:info msgText:message];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onRecvRoomCustomMsgWithCommand:(NSString *)command message:(NSString *)message fromUser:(TRTCLiveUserInfo *)user {
    TUILiveIMUserAble *info = [self createUserAbleWith:user cmdType:command.intValue];
    if (info.cmdType == TUILiveMsgModelType_Praise) {
        [self.statisticsTool onUserSendLikeMessage]; // 统计点赞
    }
    [self.anchorLogicView handleIMMessage:info msgText:message];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom anchorRequestRoomPKTimeout:(NSString *)userID {
    [self PKAlertCheck:self.pkAlert];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom audienceRequestJoinAnchorTimeout:(NSString *)userID {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.curRequestUserDic removeObjectForKey:userID];
        [self.anchorLogicView updateJoinAnchorList:self.curRequestUserDic.allValues needShow:NO];
        self.anchorLogicView.isLinkMic = NO;
    });
}

#pragma mark - notificaton
- (void)onAppWillEnterForeground:(UIApplication*)app {
//    [[self.liveRoom getAudioEffectManager] stopPlayMusic:];
}

- (void)onAppDidEnterBackGround:(UIApplication*)app {
    // 暂停背景音乐
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    }];
}


- (void)onAppWillResignActive:(NSNotification*)notification {
//    _appIsInterrupt = YES;
}

- (void)onAppDidBecomeActive:(NSNotification*)notification {
//    if (_appIsInterrupt) {
//        _appIsInterrupt = NO;
//    }
}

#pragma mark - 礼物相关
- (void)setGiftDataSource:(id<TUILiveGiftDataSource>)giftDataSource
{
    _giftDataSource = giftDataSource;
    self.giftDataProvider.giftDataSource = giftDataSource;
}

- (TUILiveGiftInfoDataHandler *)giftDataProvider
{
    if (_giftDataProvider == nil) {
        _giftDataProvider = [[TUILiveGiftInfoDataHandler alloc] init];
    }
    return _giftDataProvider;
}

- (UIView *)giftAnimationContainerView
{
    if (_giftAnimationContainerView == nil) {
        _giftAnimationContainerView = [[UIView alloc] init];
    }
    return _giftAnimationContainerView;
}

- (void)showGiftAnimation:(TUILiveMsgModel *)msgModel
{
    if (msgModel.msgType != TUILiveMsgModelType_Gift) {
        return;
    }
    
    // todo: 如果消息是自己发出的，过滤掉? 与mason沟通，不做过滤
    
    
    // 取出礼物id
    NSString *giftId = msgModel.userMsg;
    if (giftId == nil || giftId.length == 0) {
        return;
    }
    
    // 根据id获取giftInfo
    TUILiveGiftInfo *giftInfo = nil;
    if ([self.giftDataProvider respondsToSelector:@selector(getGiftInfo:)]) {
        giftInfo = [self.giftDataProvider getGiftInfo:giftId];
    }

    if (giftInfo == nil) {
        return;
    }
    giftInfo.sendUser = msgModel.userName.length == 0 ? msgModel.userId : msgModel.userName;
    giftInfo.sendUserHeadIcon = msgModel.userHeadImageUrl;
    
    // 动画
    [self.giftAnimator show:giftInfo];
}


 - (TUILiveGiftAnimator *)giftAnimator
 {
     if (_giftAnimator == nil) {
         _giftAnimator = [[TUILiveGiftAnimator alloc] initWithAnimationContainerView:self.giftAnimationContainerView];
     }
     return _giftAnimator;
 }

/// 开启倒计时
- (void)showCountDown:(dispatch_block_t)onEnd
{
    // 隐藏预览界面
    self.previewControlView.hidden = YES;
    
    // 显示倒计时界面
    if (self.countDownView) {
        [self.countDownView removeFromSuperview];
        self.countDownView = nil;
    }
    
    TUILiveCountDownView *coutDownView = [[TUILiveCountDownView alloc] init];
    [UIApplication.sharedApplication.keyWindow addSubview:coutDownView];
    self.countDownView = coutDownView;
    coutDownView.frame = UIApplication.sharedApplication.keyWindow.bounds;
    
    __weak typeof(self) weakSelf = self;
    [coutDownView beginCount:3 onEnd:^{
        [weakSelf.countDownView removeFromSuperview];
        if (onEnd) {
            onEnd();
        }
    }];
}

@end
