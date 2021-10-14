//
//  TUILiveRoomAudienceViewController.m
//  TUILiveKit
//
//  Created by coddyliu on 2020/9/2.
//  Copyright © 2020 null. All rights reserved.
/**
 提示主播不在线的逻辑:
 1、观众进入直播间，enterRoom
 2、enterRoom成功，则开启3秒的倒计时
 3、如果主播enter, 则有回调，将isOwnerEnter设置为YES，反之则为NO
 4、3秒延迟之后会调用checkAnchorOnline方法，此时如果isOwnerEnter为YES，则表明主播在线，反之主播不在线
 */

#import "TUILiveRoomAudienceViewController.h"
#import "TUILiveStatusInfoView.h"
#import "TUILiveTopToolBar.h"
#import "Masonry.h"
#import "TUILiveUtil.h"
#import "TUILiveAudienceToolsView.h"
#import "TRTCLiveRoom.h"
#import "TUILiveColor.h"
#import "TUILiveMsgModel.h"
#import "TUILiveGiftPanelView.h"
#import "TUILiveGiftAnimator.h"
#import "TUILiveHitTestView.h"
#import "SDWebImage.h"
#import "TUILiveHeader.h"
#import "TUILiveGiftInfoDataHandler.h"
#import "TUILiveGiftDataSource.h"
#import "TUILiveDefaultGiftAdapterImp.h"
#import "TUILiveUserProfile.h"
#import "TUILiveReportController.h"
#import "TUILiveRoomTipsView.h"
// 采用引用悬浮窗依赖的方式实现
#import "TUILiveFloatWindow.h"
#import "TUILiveAudienceVideoRenderView.h"
#import "TUILiveRoomAudienceViewController+FloatView.h"

#define VIDEO_VIEW_WIDTH            100
#define VIDEO_VIEW_HEIGHT           150
#define VIDEO_VIEW_MARGIN_BOTTOM    56
#define VIDEO_VIEW_MARGIN_RIGHT     8
#define VIDEO_VIEW_MARGIN_SPACE     5

#define FULL_SCREEN_PLAY_VIDEO_VIEW     10000

@interface TUILiveRoomAudienceViewController ()<TRTCLiveRoomDelegate, TUILiveGiftPanelDelegate> {
    //link mic
    BOOL                    _isBeingLinkMic;
    BOOL                    _isWaitingResponse;
    
    UITextView *            _waitingNotice;
    
    BOOL                    _isInVC;
    int                     _errorCode;
    NSString *              _errorMsg;
    BOOL                    _isErrorAlert; //是否已经弹出了错误提示框，用于保证在同时收到多个错误通知时，只弹一个错误提示框
    BOOL                    _isStop;
    
    uint64_t                _beginTime;
    uint64_t                _endTime;
    
    BOOL _shouldHideNavigationBar;
}

@property (nonatomic, strong) UILabel *noOwnerTip;
@property (nonatomic, strong) TUILiveAudienceToolsView *toolsView;
@property (nonatomic, strong) TUILiveHitTestView *topView;                      // 顶部视图

@property (nonatomic, strong) TUILiveGiftInfoDataHandler *giftDataProvider;   // 礼物数据提供者
@property (nonatomic, strong) TUILiveGiftPanelView *giftPannelView;            // 礼物面板
@property (nonatomic, strong) TUILiveGiftAnimator *giftAnimator;               // 礼物特效控制器

@property (nonatomic, strong) TRTCLiveRoomInfo *liveInfo;
@property (nonatomic, strong) TRTCLiveRoom *liveRoom;
@property (nonatomic, assign) NSInteger roomStatus;
@property (nonatomic, assign) BOOL isOwnerEnter;
@property (nonatomic, assign) BOOL hasSyncedRoomInfo;

/// 礼物动画面板，动画数据等数据源对象
@property (nonatomic, strong) id<TUILiveGiftDataSource> giftDataSource;
/// 举报业务控制器
@property (nonatomic, strong) TUILiveReportController *reportController;
/// 直播间提示视图: 主播不在线，roomid不存在等
@property (nonatomic, weak) TUILiveRoomTipsView *tipsView;
@property (nonatomic, strong) NSString *cdnDomain;
@property (nonatomic, assign) BOOL useCdn;
@property (nonatomic, strong) UIImageView *backgroudImageView;


- (void)onAnchorEnter:(NSString *)userID;
- (void)onAnchorExit:(NSString *)userID;
- (void)checkStatusViewModelNeedChange;
- (void)stopLocalPreview;
- (void)onKickoutJoinAnchor;
- (void)onLiveEnd;
- (BOOL)startRtmp;
- (void)stopRtmp;

@end

@implementation TUILiveRoomAudienceViewController

- (instancetype)init {
    if ([TUILiveFloatWindow sharedInstance].backController) {
        // 如果存在悬浮窗，首先从悬浮窗拿值
        [[TUILiveFloatWindow sharedInstance] hide];
        TUILiveRoomAudienceViewController *audienceViewController = (TUILiveRoomAudienceViewController *)[TUILiveFloatWindow sharedInstance].backController;
        return audienceViewController;
    } else {
        self = [super init];
        if (self) {
            _liveRoom = [TRTCLiveRoom sharedInstance];
            _liveRoom.delegate = self;
        }
        return self;
    }
}

/// 初始化观众页
/// @param roomId 房间Id，必填
/// @param useCdn 是否使用CDN YES：使用 NO：不使用 默认：NO
/// @param anchorId 该直播间的主播userId，建议设置，选填
/// @param cdnUrl cdn拉流URL，选填
- (instancetype)initWithRoomId:(int)roomId
                      anchorId:(NSString * _Nullable)anchorId
                        useCdn:(BOOL)useCdn
                        cdnUrl:(NSString * _Nullable)cdnUrl {
    if ([TUILiveFloatWindow sharedInstance].backController) {
        // 如果存在悬浮窗，首先从悬浮窗拿值
        [[TUILiveFloatWindow sharedInstance] hide];
        TUILiveRoomAudienceViewController *audienceViewController = (TUILiveRoomAudienceViewController *)[TUILiveFloatWindow sharedInstance].backController;
        self = audienceViewController;
        if (![audienceViewController.liveInfo.roomId isEqualToString:@(roomId).stringValue]) {
            //先退房需要重新进房
            [self stopLinkMic];
            [self stopLocalPreview];
            [self hideWaitingNotice];
            @weakify(self)
            [self stopRtmp:^(BOOL result) {
                @strongify(self)
                self->_useCdn = useCdn;
                self->_cdnDomain = cdnUrl;
                self->_liveRoom = [TRTCLiveRoom sharedInstance];
                self->_liveRoom.delegate = self;
                self->_liveInfo = [[TRTCLiveRoomInfo alloc] initWithRoomId:@(roomId).stringValue roomName:@"" coverUrl:@"" ownerId:anchorId ownerName:@"" streamUrl:cdnUrl memberCount:0 roomStatus:TRTCLiveRoomLiveStatusNone];
                self.modalPresentationStyle = UIModalPresentationOverFullScreen;
                self.toolsView.controller = self;
                self.hasSyncedRoomInfo = NO;
                [self enterLiveRoom];
            }];
        }
        return self;
    } else {
        self = [super init];
        if (self) {
            _useCdn = useCdn;
            _cdnDomain = cdnUrl;
            _liveRoom = [TRTCLiveRoom sharedInstance];
            _liveRoom.delegate = self;
            _liveInfo = [[TRTCLiveRoomInfo alloc] initWithRoomId:@(roomId).stringValue roomName:@"" coverUrl:@"" ownerId:anchorId ownerName:@"" streamUrl:cdnUrl memberCount:0 roomStatus:TRTCLiveRoomLiveStatusNone];
            self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        }
        return self;
    }
}

- (void)resetStatus {
    [self stopRtmp];
    _liveInfo = nil;
    _errorCode    = 0;
    _errorMsg     = @"";
    
    _isErrorAlert = NO;
    _isOwnerEnter = NO;
    _isStop = NO;
    
    //link mic
    _isBeingLinkMic = false;
    _isWaitingResponse = false;
    
    _roomStatus = TRTCLiveRoomLiveStatusNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self constructSubViews];
    [self bindInteraction];
    self.toolsView.controller = self;
    [self enterLiveRoom];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self->_shouldHideNavigationBar = self.navigationController.navigationBar.isHidden;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view insertSubview:self.renderView atIndex:1];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateAnchorInfo:self.liveInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:self->_shouldHideNavigationBar animated:NO];
    _isInVC = NO;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (!parent && ![TUILiveFloatWindow sharedInstance].isShowing) {
        [self prepareToShowFloatView];
    }
}

- (void)exitRoom {
    [self stopLinkMic];
    [self stopRtmp];
    [self stopLocalPreview];
    [self hideWaitingNotice];
}

- (void)dealloc {
    [self exitRoom];
    _isInVC = NO;
}

- (void)enterLiveRoom {
    self.toolsView.liveRoom = self.liveRoom;
    if (!self.liveInfo) {
        if (!self.liveInfo.roomId) {
            NSLog(@"初始化观众端失败：缺少直播间信息roomId。请通过设置TRTCLiveRoomInfo的roomId属性!!!");
        } else {
            NSLog(@"初始化观众端失败：缺少直播间信息TRTCLiveRoomInfo。请通过TUILiveRoomAudienceViewController initWithRoomInfo:初始化并传入直播间信息对象!!!!");
        }
    }
    self.noOwnerTip.hidden = YES;
    _beginTime = [[NSDate date] timeIntervalSince1970];
    self.giftDataSource = [[TUILiveDefaultGiftAdapterImp alloc] init];
    
    [self startRtmp];
    _isInVC = YES;
    if (_errorCode != 0) {
        [self onError:_errorCode errMsg:_errorMsg extraInfo:nil];
        _errorCode = 0;
        _errorMsg  = @"";
    }
#ifdef DEBUG
    if (self.useCdn) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TUILiveUtil toastTip:@"正在使用cdn播放" parentView:self.view];
        });
    }
#endif
}

#pragma mark - liveroom start stop
- (BOOL)startPlay {
    [self initRoomLogic];
    return YES;
}

- (BOOL)startRtmp {
    if (self.useCdn && [self.cdnDomain length] == 0) {
        NSLog(@"TUIKitLive# 播放失败，缺少cdnURL，TUILiveRoomAudienceViewController 初始化 cdnURL 参数不能为空");
        return NO;
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    return [self startPlay];
}

- (void)stopRtmp {
    [self stopRtmp:nil];
}

- (void)stopRtmp:(void(^)(BOOL))complete {
    if (!_isStop) {
        _isStop = YES;
    } else {
        return;
    }
    [self.liveRoom showVideoDebugLog:NO];
    if (self.liveRoom) {
        [self.liveRoom exitRoom:^(int code, NSString * error) {
            NSLog(@"exitRoom: errCode[%ld] errMsg[%@]", (long)code, error);
            if (complete) {
                complete(code == 0);
            }
        }];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)initRoomLogic {
    _isStop = NO;
    __weak __typeof(self) wself = self;
    [_liveRoom enterRoomWithRoomID:[_liveInfo.roomId intValue]
                          useCDNFirst:self.useCdn
                         cdnDomain:self.cdnDomain
                          callback:^(int code, NSString * error) {
        __strong __typeof(wself) self = wself;
        if (self == nil) {
            return ;
        }
        if (code == 0 || code == 8513) {
            __block BOOL isGetList = NO;
            //获取成员列表
            [self.liveRoom getAudienceList:^(int code, NSString * error, NSArray<TRTCLiveUserInfo *> * users) {
                isGetList = (code == 0);
                [self.toolsView updateAudienceList:users];
            }];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (isGetList) {
                    return;
                }
                //获取成员列表
                [self.liveRoom getAudienceList:^(int code, NSString * error, NSArray<TRTCLiveUserInfo *> * users) {
                    [self.toolsView updateAudienceList:users];
                }];
                // 如果因getgroup info限频导致错误回调，延迟一秒后再次获取更新房间信息
                if (code == 8513) {
                    [wself updateAnchorInfo:wself.liveInfo];
                }
            });
            
            // 延时3秒后，判断主播是否在线
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wself checkAnchorOnline];
            });
            
        } else {
            __strong __typeof(wself) self = wself;
            if (self == nil) {
                return ;
            }
            [TUILiveUtil toastTip:error.length > 0 ? error : @"进入房间失败" parentView:self.toolsView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //退房
                [self closeVCWithRefresh:YES];
            });
            
        }
    }];
}

// 检查主播是否在线
- (void)checkAnchorOnline
{
    if (self.isOwnerEnter) {
        // 主播在线，忽略
        return;
    }
    
    // 提示主播不在线
    if (self.tipsView) {
        [self.tipsView removeFromSuperview];
    }
    TUILiveRoomTipsView *tipsView = [[TUILiveRoomTipsView alloc] init];
    __weak typeof(self) weakSelf = self;
    [tipsView updateTips:@"主播暂时不在线..." background:self.liveInfo.coverUrl action:^{
        [weakSelf.tipsView removeFromSuperview];
        [weakSelf closeVCWithRefresh:YES];
    }];
    [self.view addSubview:tipsView];
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    self.tipsView = tipsView;
}

#pragma mark - 直播结束 结束弹窗
- (void)closeVC {
    [self stopLocalPreview];
    [self stopLinkMic];
    [self closeVCWithRefresh:NO];
    [self hideWaitingNotice];
}

- (void)onRecvGroupDeleteMsg {
    if ([TUILiveFloatWindow sharedInstance].isShowing) {
        [[TUILiveFloatWindow sharedInstance] hide];
        [TUILiveFloatWindow sharedInstance].backgroundColor = nil;
        return;
    }
    [self closeVC];
    if (!_isErrorAlert) {
        _isErrorAlert = YES;
        __weak __typeof(self) weakSelf = self;
        [self showAlertWithTitle:@"直播已结束" sureAction:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)showAlertWithTitle:(NSString *)title sureAction:(void(^)(void))callback {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (callback) {
            callback();
        }
    }];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark- MiscFunc


- (void)onLiveEnd {
    [self onRecvGroupDeleteMsg];
}

#pragma mark - liveroom listener
- (void)onDebugLog:(NSString *)msg {
    NSLog(@"onDebugMsg:%@", msg);
}

- (void)onRoomDestroy:(NSString *)roomID {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onRoomDestroy, roomID:%@", roomID);
        __weak __typeof(self) weakSelf = self;
        [self showAlertWithTitle:@"大主播关闭直播间" sureAction:^{
            [weakSelf closeVCWithRefresh:YES];
        }];
    });
}

- (void)onError:(int)errCode errMsg:(NSString *)errMsg extraInfo:(NSDictionary *)extraInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onError:%d, %@", errCode, errMsg);
        if(errCode != 0){
            if (self->_isInVC) {
                __weak __typeof(self) weakSelf = self;
                [self showAlertWithTitle:@"大主播关闭直播间" sureAction:^{
                    [weakSelf closeVCWithRefresh:YES];
                }];
            }else{
                self->_errorCode = errCode;
                self->_errorMsg = errMsg;
            }
        }
    });
}

- (void)onKickoutJoinAnchor {
    [TUILiveUtil toastTip:@"不好意思，您被主播踢开" parentView:self.view];
    [self stopLocalPreview];
}

-(void)setIsOwnerEnter:(BOOL)isOwnerEnter {
    _isOwnerEnter = isOwnerEnter;
    [self.renderView.videoRenderView setHidden:!isOwnerEnter];
    [_noOwnerTip setHidden:_isOwnerEnter];
    [[TUILiveFloatWindow sharedInstance] switchNoAnchorStatus:!isOwnerEnter];
}


#pragma mark -  TRTCLiveRoomDelegate 主播进退房
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onAnchorEnter:(NSString *)userID {
    if ((_liveInfo.ownerId && [userID isEqualToString:_liveInfo.ownerId])) {
        self.isOwnerEnter = YES;
        [self.liveRoom startPlayWithUserID:userID view:self.renderView.videoRenderView callback:^(int code, NSString * _Nullable message) {
            NSLog(@"onAnchorEnter：%d,%@", code, message);
        }];
    } else {
        [self onAnchorEnter:userID];
    }
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onAnchorExit:(NSString *)userID {
    [self onAnchorExit:userID];
}

#pragma mark - TRTCLiveRoomDelegate 消息
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onRecvRoomTextMsg:(NSString *)message fromUser:(TRTCLiveUserInfo *)user {
    TUILiveIMUserAble *info = [self createUserAbleWith:user cmdType:TUILiveMsgModelType_NormalMsg];
    [self.toolsView handleIMMessage:info msgText:message];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onRecvRoomCustomMsgWithCommand:(NSString *)command message:(NSString *)message fromUser:(TRTCLiveUserInfo *)user {
    TUILiveIMUserAble *info = [self createUserAbleWith:user cmdType:command.intValue];
    [self.toolsView handleIMMessage:info msgText:message];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onAudienceEnter:(TRTCLiveUserInfo *)user {
    TUILiveIMUserAble *info = [self createUserAbleWith:user cmdType:2];
    [self.toolsView handleIMMessage:info msgText:@"加入直播"];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onAudienceExit:(TRTCLiveUserInfo *)user {
    TUILiveIMUserAble *info = [self createUserAbleWith:user cmdType:3];
    [self.toolsView handleIMMessage:info msgText:@"退出直播"];
}

- (TUILiveIMUserAble *)createUserAbleWith:(TRTCLiveUserInfo *)user cmdType:(NSInteger)cmdType {
    TUILiveIMUserAble *info = [[TUILiveIMUserAble alloc] init];
    info.imUserId = user.userId;
    info.imUserName = user.userName;
    info.imUserIconUrl = user.avatarURL;
    info.cmdType = cmdType;
    return info;
}

- (void)updateVideoParentViewFrame {
    self.backgroudImageView.hidden = NO;
    BOOL useCDN = (self.useCdn && [self.cdnDomain length] > 0);
    if (self.roomStatus == TRTCLiveRoomLiveStatusSingle || self.roomStatus == TRTCLiveRoomLiveStatusLinkMic) {
        [self.renderView switchPKStatus:NO useCDN:useCDN];
    } else if (self.roomStatus == TRTCLiveRoomLiveStatusRoomPK) {
        if (useCDN) {
            self.backgroudImageView.hidden = YES;
        }
        [self.renderView switchPKStatus:YES useCDN:useCDN];
    }
    [self checkStatusViewModelNeedChange]; // 校验PK状态
}

#pragma mark - TRTCLiveRoomDelegate 房间信息变化
- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onRoomDestroy:(NSString *)roomID {
    [self onLiveEnd];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onRoomInfoChange:(TRTCLiveRoomInfo *)info {
    self.roomStatus = info.roomStatus;
    [self updateVideoParentViewFrame];
}

- (void)trtcLiveRoomOnKickoutJoinAnchor:(TRTCLiveRoom *)liveRoom {
    [self onKickoutJoinAnchor];
}

- (void)trtcLiveRoom:(TRTCLiveRoom *)trtcLiveRoom onError:(NSInteger)code message:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(onRoomError:errorCode:errorMessage:)]) {
        [self.delegate onRoomError:self.liveInfo errorCode:code errorMessage:message];
    }
}

#pragma mark - UI
- (void)constructSubViews {
    //加载背景图 - 与安卓保持一致(渐变色)
    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.frame;
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:19/255.0 green:41/255.0 blue:75/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:5/255.0 green:12/255.0 blue:23/255.0 alpha:1].CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.locations = @[@0,@1];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    backgroundImageView.backgroundColor = UIColorFromRGB(242424);
    [backgroundImageView.layer addSublayer:gradientLayer];
    [self.view addSubview:backgroundImageView];
    self.backgroudImageView = backgroundImageView;
    self.view.backgroundColor = [UIColor blackColor];
    
    //视频画面父view
    _renderView = [[TUILiveAudienceVideoRenderView alloc] initWithFrame:self.view.frame];
    _renderView.fatherView = self.view;
    

    //初始化组件View
    self.toolsView = [[TUILiveAudienceToolsView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.toolsView];
    [self.toolsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.toolsView.backgroundColor = [UIColor clearColor];
    
    // top视图层
    TUILiveHitTestView *topView = [[TUILiveHitTestView alloc] init];
    self.topView = topView;
    [self.view addSubview:self.topView];
    self.topView.frame = self.view.bounds;

    //提示
    _noOwnerTip = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 2 - 40, self.view.bounds.size.width, 30)];
    _noOwnerTip.backgroundColor = [UIColor clearColor];
    [_noOwnerTip setTextColor:[UIColor whiteColor]];
    [_noOwnerTip setTextAlignment:NSTextAlignmentCenter];
    [_noOwnerTip setText:@"主播暂时不在线..."];
    [self.view addSubview:_noOwnerTip];
}

- (void)bindInteraction {
    __weak typeof(self) weakSelf = self;
    [self.toolsView setOnLinkMic:^(TUILiveAudienceToolsView * _Nonnull view, id  _Nonnull info) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf || strongSelf->_isWaitingResponse) {
            return;
        }
        if (strongSelf->_isBeingLinkMic) {
            [strongSelf stopLocalPreview];
            [strongSelf hideWaitingNotice];
        } else {
            [strongSelf startLinkMic];
        }
    }];
    self.toolsView.onGiftClick = ^(TUILiveAudienceToolsView * _Nonnull view, id  _Nullable info) {
        // 打开送礼面板
        [weakSelf showGiftPannel];
    };
    self.toolsView.onReceiveGiftMsg = ^(TUILiveAudienceToolsView * _Nonnull view, id  _Nullable info) {
        // 打开礼物动画组件
        [weakSelf showGiftAnimation:info];
    };
    self.toolsView.onUserReport = ^(TUILiveAudienceToolsView * _Nonnull view, id  _Nullable info) {
        // 举报
        [weakSelf.reportController reportUser:weakSelf.liveInfo.ownerId];
    };
}

- (UIImage *)gsImageWithImage:(UIImage *)image {
    UIImage *backImage = image ?: [UIImage imageNamed:@"live_room_list_item_bg"];
    if (backImage) {
        CGFloat backImageNewHeight = self.view.frame.size.height;
        CGFloat backImageNewWidth = backImageNewHeight * backImage.size.width / backImage.size.height;
        UIImage *gsImage = [TUILiveUtil gsImage:backImage withGsNumber:5];
        UIImage *scaleImage = [TUILiveUtil scaleImage:gsImage scaleToSize:CGSizeMake(backImageNewWidth, backImageNewHeight)];
        backImage = [TUILiveUtil clipImage:scaleImage inRect:CGRectMake((backImageNewWidth - self.view.frame.size.width)/2, (backImageNewHeight - self.view.frame.size.height)/2, self.view.frame.size.width, self.view.frame.size.height)];
    }
    return backImage;
}


- (void)syncRoomInfo:(TRTCLiveRoomInfo *)curRoomInfo {
    NSString *roomId = curRoomInfo.roomId;
    if (!self.hasSyncedRoomInfo && roomId.length > 0) {
        [[TRTCLiveRoom sharedInstance] getRoomInfosWithRoomIDs:@[[NSNumber numberWithInt:[roomId intValue]]] callback:^(int code, NSString * _Nullable message, NSArray<TRTCLiveRoomInfo *> * _Nonnull roomList) {
            if ([roomList.firstObject isKindOfClass:[TRTCLiveRoomInfo class]]) {
                TRTCLiveRoomInfo *info = roomList.firstObject;
                info.streamUrl = self.cdnDomain;
                info.ownerId = self.liveInfo.ownerId;
                self.liveInfo = info;
            }
            self.hasSyncedRoomInfo = YES;
            self.roomStatus = self.liveInfo.roomStatus;
            [self updateAnchorInfo:self.liveInfo];
        }];
    }
}

- (void)updateAnchorInfo:(TRTCLiveRoomInfo *)curRoomInfo {
    if (!self.toolsView || !curRoomInfo) {
        return;
    }
    if (!self.hasSyncedRoomInfo) {
        [self syncRoomInfo:curRoomInfo];
        return;
    }
    TUILiveAnchorInfo *anchorInfo = [[TUILiveAnchorInfo alloc] init];
    anchorInfo.userId = curRoomInfo.ownerId;
    anchorInfo.nickName = curRoomInfo.ownerName;
    anchorInfo.avatarUrl = curRoomInfo.coverUrl;
    anchorInfo.weightValue = rand()%300000;
    anchorInfo.weightTagName = @"经验";
    self.toolsView.topToolBar.anchorInfo = anchorInfo;
    [self.toolsView setIsCdnPK:(self.useCdn && [self.cdnDomain length] > 0)];
    [self.toolsView changePKState:(self.liveInfo.roomStatus == TRTCLiveRoomLiveStatusRoomPK)];
    [self updateVideoParentViewFrame];
    if (anchorInfo.userId) {
        [[V2TIMManager sharedInstance] checkFriend:@[anchorInfo.userId] checkType:V2TIM_FRIEND_TYPE_SINGLE succ:^(NSArray<V2TIMFriendCheckResult *> *resultList) {
            if (resultList.count && resultList.firstObject.relationType != V2TIM_FRIEND_RELATION_TYPE_NONE) {
                self.toolsView.topToolBar.hasFollowed = YES;
            }
        } fail:^(int code, NSString *desc) {
            NSLog(@"检查好友：%d，%@", code, desc);
        }];
    }
}

- (void)showWaitingNotice:(NSString*)notice {
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - (IPHONE_X ? 114 : 80);
    frameRC.size.height -= 110;
    if (_waitingNotice == nil) {
        _waitingNotice = [[UITextView alloc] init];
        _waitingNotice.editable = NO;
        _waitingNotice.selectable = NO;
        
        frameRC.size.height = [TUILiveUtil heightForString:_waitingNotice andWidth:frameRC.size.width];
        _waitingNotice.frame = frameRC;
        _waitingNotice.textColor = [UIColor blackColor];
        _waitingNotice.backgroundColor = [UIColor whiteColor];
        _waitingNotice.alpha = 0.5;
        
        [self.view addSubview:_waitingNotice];
    }
    
    _waitingNotice.text = notice;
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^(){
        @strongify(self)
        [self freshWaitingNotice:notice withIndex: [NSNumber numberWithLong:0]];
    });
}

- (void)freshWaitingNotice:(NSString *)notice withIndex:(NSNumber *)numIndex {
    if (_waitingNotice) {
        long index = [numIndex longValue];
        ++index;
        index = index % 4;
        
        NSString * text = notice;
        for (long i = 0; i < index; ++i) {
            text = [NSString stringWithFormat:@"%@.....", text];
        }
        [_waitingNotice setText:text];
        
        numIndex = [NSNumber numberWithLong:index];
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^(){
            @strongify(self)
            [self freshWaitingNotice:notice withIndex: numIndex];
        });
    }
}

- (void)stopLocalPreview {
    if (_isBeingLinkMic == YES) {
        //关闭本地摄像头，停止推流
        TUILiveStatusInfoView *targetView = [self.renderView getStatusInfoViewByUserID:[TUILiveUserProfile getLoginUserInfo].userID ?: @""];
        if (targetView) {
            [self.liveRoom stopCameraPreview];
            [targetView stopLoading];
            [targetView stopPlay];
            [targetView emptyPlayInfo];
        }
        [self.liveRoom stopPublish:^(int code, NSString * error) {
            NSLog(@"TUIKitLive# 停止连麦推流: %d, %@", code, error);
        }];
        //UI重置
        self.toolsView.bottomLinkMicBtn.selected = NO;
        [self.toolsView setSwitchCameraButtonHidden:YES];
        _isBeingLinkMic = NO;
        _isWaitingResponse = NO;
    }
}

- (void)closeVCWithRefresh:(BOOL)refresh {
    [self stopRtmp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.presentingViewController){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - logic
#pragma mark - 连麦
- (void)startLinkMic {
    if (_isBeingLinkMic || _isWaitingResponse) {
        return;
    }
    _isWaitingResponse = YES;

    self.toolsView.bottomLinkMicBtn.selected = YES;
    [self showWaitingNotice:@"等待主播接受"];
    
    @weakify(self)
    [self.liveRoom requestJoinAnchor:@"" timeout:60 responseCallback:^(BOOL agreed, NSString * reason) {
        @strongify(self)
        if (self == nil) {
            return ;
        }
        if (self->_isWaitingResponse == NO) {
            return;
        }
        self->_isWaitingResponse = NO;
        [self hideWaitingNotice];
        if (agreed) {
            self->_isBeingLinkMic = YES;
            self.toolsView.bottomLinkMicBtn.selected = YES;
            [TUILiveUtil toastTip:@"主播接受了您的连麦请求，开始连麦" parentView:self.view];
            //推流允许前后切换摄像头
            [self.toolsView setSwitchCameraButtonHidden:NO];
            TUILiveStatusInfoView *statusInfoView = [self.renderView getFreeStatusInfoView];
            if (statusInfoView) {
                statusInfoView.userID = [TUILiveUserProfile getLoginUserInfo].userID;
                [self.liveRoom startCameraPreviewWithFrontCamera:YES view:statusInfoView.videoView callback:^(int code, NSString * error) {
                    NSLog(@"startCameraPreviewWithFrontCamera：%d, %@", code, error);
                }];
                [self.liveRoom startPublishWithStreamID:@"" callback:^(int code, NSString * error) {
                    NSLog(@"startPublishWithStreamID：%d, %@", code, error);
                }];
            }
        } else {
            self->_isBeingLinkMic = NO;
            self.toolsView.bottomLinkMicBtn.selected = NO;
            if ([reason length] > 0) {
                [TUILiveUtil toastTip:reason parentView:self.view];
            } else {
                [TUILiveUtil toastTip:@"主播拒绝了您的连麦请求" parentView:self.view];
            }
        }
    }];
}

- (void)stopLinkMic {
    [self.renderView stopAndResetAllStatusView:^(NSString * _Nonnull userID) {
        [self.liveRoom stopPlayWithUserID:userID callback:^(int code, NSString * error) {
            NSLog(@"stopPlayWithUserID %d, %@", code, error);
        }];
    }];
}

- (void)hideWaitingNotice {
    if (_waitingNotice) {
        [_waitingNotice removeFromSuperview];
        _waitingNotice = nil;
    }
}

#pragma mark - LinkMic
- (void)onAnchorEnter:(NSString *)userID {
    if ([userID isEqualToString:[TUILiveUserProfile getLoginUserInfo].userID ?: @""]) {
        return;
    }
    if (userID == nil || userID.length == 0) {
        return;
    }
    TUILiveStatusInfoView *view = [self.renderView getStatusInfoViewByUserID:userID];
    if (view) {
        // 已存在
        return;
    }
    TUILiveStatusInfoView *targetView = [self.renderView getFreeStatusInfoView];
    if (targetView) {
        targetView.userID = userID;
        [targetView startLoading];
        @weakify(self)
        [self.liveRoom startPlayWithUserID:userID view:targetView.videoView callback:^(int code, NSString * _Nullable message) {
            @strongify(self)
            if (code == 0) {
                [targetView stopLoading];
            } else {
                [self onAnchorExit:userID];
            }
        }];
    }
    // 校验状态
    [self checkStatusViewModelNeedChange];
}

- (void)onAnchorExit:(NSString *)userID {
    if ([userID isEqualToString:_liveInfo.ownerId]) {
        [self.liveRoom stopPlayWithUserID:userID callback:^(int code, NSString * error) {
            
        }];
        self.isOwnerEnter = NO;
        return;
    }
    TUILiveStatusInfoView *statusInfoView = [self.renderView getStatusInfoViewByUserID:userID];
    if (statusInfoView && ![statusInfoView.userID isEqualToString:[TUILiveUserProfile getLoginUserInfo].userID ?: @""]) {
        [statusInfoView stopLoading];
        [statusInfoView stopPlay];
        [self.liveRoom stopPlayWithUserID:userID callback:nil];
        [statusInfoView emptyPlayInfo];
    }
    if ([self.renderView isNoAnchorInStatusInfoView]) {
        [self.renderView linkFrameRestore];
    }
}

#pragma mark - PK
/// 校验小窗状态，非PK模式下，恢复到默认位置
- (void)checkStatusViewModelNeedChange {
    BOOL isPK = self.roomStatus == TRTCLiveRoomLiveStatusRoomPK;
    [self.toolsView changePKState:isPK];
    if (isPK) {
        [self.renderView switchStatusViewPKModel];
    } else {
        [self.renderView switchStatusViewJoinAnchorModel];
    }
    if ([TUILiveFloatWindow sharedInstance].isShowing) {
        // 如果正在显示，则调整视windwo的视图约束
        [[TUILiveFloatWindow sharedInstance] switchPKStatus:isPK];
    }
}

#pragma mark - 礼物: 礼物面板
- (void)setGiftDataSource:(id<TUILiveGiftDataSource>)giftDataSource
{
    _giftDataSource = giftDataSource;
    self.giftDataProvider.giftDataSource = giftDataSource;
}

- (void)showGiftPannel
{
    [self.giftPannelView showInView:self.toolsView];
}

- (void)dismissGiftPannel
{
    [self.giftPannelView hide];
}

- (TUILiveGiftPanelView *)giftPannelView
{
    if (_giftPannelView == nil) {
        _giftPannelView = [[TUILiveGiftPanelView alloc] initWithProvider:self.giftDataProvider];
        [_giftPannelView setGiftPannelDelegate:self];
    }
    return _giftPannelView;
}

- (TUILiveGiftInfoDataHandler *)giftDataProvider
{
    if (_giftDataProvider == nil) {
        _giftDataProvider = [[TUILiveGiftInfoDataHandler alloc] init];
    }
    return _giftDataProvider;
}

#pragma mark - 礼物: TUILiveGiftPannelDelegate
- (void)onGiftItemClick:(TUILiveGiftInfo *)giftInfo
{
    NSLog(@"赠送礼物: %@", giftInfo);
    // 动画
    giftInfo.sendUser = @"我";
    giftInfo.sendUserHeadIcon = [TUILiveUserProfile getLoginUserInfo].faceURL;
    [self.giftAnimator show:giftInfo];
    
    // 发送礼物消息
    [_liveRoom sendRoomCustomMsgWithCommand:[@(TUILiveMsgModelType_Gift) stringValue] message:giftInfo.giftId callback:^(int code, NSString * _Nullable message) {
        
    }];
}

- (void)onChargeClick
{
    NSLog(@"点击充值: ");
}

#pragma mark - 礼物: 动画相关
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
    giftInfo.sendUser = msgModel.userName;
    giftInfo.sendUserHeadIcon = msgModel.userHeadImageUrl;
    
    // 动画
    [self.giftAnimator show:giftInfo];
}

- (TUILiveGiftAnimator *)giftAnimator
{
    if (_giftAnimator == nil) {
        _giftAnimator = [[TUILiveGiftAnimator alloc] initWithAnimationContainerView:self.topView];
    }
    return _giftAnimator;
}

#pragma mark - 举报
- (TUILiveReportController *)reportController
{
    if (_reportController == nil) {
        _reportController = [[TUILiveReportController alloc] init];
    }
    return _reportController;
}

@end
