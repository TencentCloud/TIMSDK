//
//  TUILiveAnchorToolView.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/11.
//

#import "TUILiveAnchorToolView.h"
#import "Masonry.h"
#import "TUILiveBottomToolBar.h"
#import "TUILiveTopToolBar.h"
#import "TRTCLiveRoomDef.h"
#import "TXLiveRoomCommonDef.h"
#import "TUILiveMsgListTableView.h"
#import "TUILiveMsgBarrageView.h"
#import "TUILiveOnKeyboardInputView.h"
#import "TUILiveLikeHeartCreator.h"
#import "TUILiveAnchorPKListView.h"
#import "TUILiveJoinAnchorListView.h"
#import "TLiveHeader.h"
#import "TUILiveUserProfile.h"
#import "TUILiveColor.h"

#define BOTTOM_BTN_ICON_WIDTH  35

@interface TUILiveAnchorToolView ()<TUILiveAnchorPKListViewDelegate, TUILiveJoinAnchorListViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic, strong)UIButton *showLinkMicAndExitPKBtn; // 非PK状态时显示连麦列表
@property(nonatomic, strong)UIView *tipsView; // 有连麦信息时的小红点
@property(nonatomic, strong)UIImageView *PKImage;

@property(nonatomic, strong)TUILiveMsgListTableView *msgTableView;
@property(nonatomic, strong)TUILiveMsgBarrageView *bulletViewOne;
@property(nonatomic, strong)TUILiveMsgBarrageView *bulletViewTwo;

@property(nonatomic, strong)TUILiveOnKeyboardInputView *inputView;

@property(nonatomic, strong)TUILiveBottomToolBar *bottomBar;
@property(nonatomic, strong)TUILiveTopToolBar *topToolBar;

@property(nonatomic, strong)TUILiveAnchorPKListView *roomListTableView;
@property(nonatomic, strong)NSArray<TRTCLiveRoomInfo *> *roomListDataSourceArr;

@property(nonatomic, strong)TUILiveJoinAnchorListView *joinAnchorListView;
@property(nonatomic, assign)NSInteger currentJoinAnchorListCount; // 当前申请上麦的观众数量
@property(nonatomic, strong)NSMutableArray<TRTCLiveUserInfo *> *joinAnchorDataSourceArr;

@property(nonatomic, strong)TUILiveLikeHeartCreator *heartCreator; // 点赞动画处理

@property(nonatomic, strong) NSMutableDictionary *audienceDic; // 观众数据管理
@property(nonatomic, strong) dispatch_queue_t audienceDicDataQueue; //数据处理队列

@property(nonatomic, strong) NSMutableArray *bottomToolBarButtons;
@property(nonatomic, strong) UIButton *bottomPKButton;

@end

@implementation TUILiveAnchorToolView {
    BOOL _isViewReady; // 视图是否准备就绪
    
    BOOL _isBeautyShow; // 美颜面板是否展示到位
    BOOL _isAudioSettingShow; // 音效面板是否展示
    
    BOOL _isHidePKMode; // 是否隐藏PK模式
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.audienceDic = [NSMutableDictionary dictionaryWithCapacity:10];
        self.audienceDicDataQueue = dispatch_queue_create("live_audience_tools_view_data", DISPATCH_QUEUE_SERIAL);
        self.bottomToolBarButtons = [NSMutableArray arrayWithCapacity:4];
        [self constructSubViews];
        [self bindInteraction];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.audienceDic = [NSMutableDictionary dictionaryWithCapacity:10];
        self.audienceDicDataQueue = dispatch_queue_create("live_audience_tools_view_data", DISPATCH_QUEUE_SERIAL);
        self.bottomToolBarButtons = [NSMutableArray arrayWithCapacity:4];
        [self constructSubViews];
        [self bindInteraction];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.audienceDic = [NSMutableDictionary dictionaryWithCapacity:10];
        self.audienceDicDataQueue = dispatch_queue_create("live_audience_tools_view_data", DISPATCH_QUEUE_SERIAL);
        self.bottomToolBarButtons = [NSMutableArray arrayWithCapacity:4];
        [self constructSubViews];
        [self bindInteraction];
    }
    return self;
}

- (BOOL)isPKRoomListShow {
    return !self.roomListTableView.isHidden;
}

- (void)setIsLinkMic:(BOOL)isLinkMic
{
    _isLinkMic = isLinkMic;
    
    // 如果正在连麦，禁用PK按钮
    self.bottomPKButton.enabled = !isLinkMic;
}

- (TUILiveLikeHeartCreator *)heartCreator {
    if (!_heartCreator) {
        _heartCreator = [[TUILiveLikeHeartCreator alloc] init];
    }
    return _heartCreator;
}

- (NSMutableArray<TRTCLiveUserInfo *> *)joinAnchorDataSourceArr {
    if (!_joinAnchorDataSourceArr) {
        _joinAnchorDataSourceArr = [NSMutableArray arrayWithCapacity:2];
    }
    return _joinAnchorDataSourceArr;
}

#pragma mark - public method
- (void)showRoomList:(NSArray<TRTCLiveRoomInfo *> *)list {
    [self.roomListTableView showWithRoomInfos:list];
}

- (void)hideRoomList {
    [self.roomListTableView hide];
}

- (void)switchBeautyStatus:(BOOL)isBeauty {
    self->_isBeautyShow = isBeauty;
    if (isBeauty) {
        // 隐藏其他面板
        self.bottomBar.hidden = YES;
    } else {
        self.bottomBar.hidden = NO;
    }
}

- (void)switchAudioSettingStatus:(BOOL)isAudioPanelShow {
    self->_isAudioSettingShow = isAudioPanelShow;
    if (isAudioPanelShow) {
        self.bottomBar.hidden = YES;
    } else {
        self.bottomBar.hidden = NO;
    }
}

- (void)enablePK:(BOOL)enable {
    self -> _isHidePKMode = !enable;
    if (enable) {
        if (![self.bottomBar.rightButtons containsObject:self.bottomPKButton]) {
            [self.bottomToolBarButtons insertObject:self.bottomPKButton atIndex:0];
            [self.bottomBar setRightButtons:self.bottomToolBarButtons];
        }
    } else {
        [self.bottomToolBarButtons removeObject:self.bottomPKButton];
        [self.bottomBar setRightButtons:self.bottomToolBarButtons];
    }
}

- (void)updateJoinAnchorList:(NSArray<TRTCLiveUserInfo *> *)list needShow:(BOOL)needShow{
    if (list.count > 0) {
        self.tipsView.backgroundColor = UIColor.redColor;
    } else {
        self.tipsView.backgroundColor = UIColor.clearColor;
    }
    self.currentJoinAnchorListCount = list.count;
    if (needShow) {
        [self.joinAnchorListView showWithUserInfos:list];
    } else {
        [self.joinAnchorListView refreshUserInfos:list];
    }
    
}

#pragma mark - 视图生命周期
- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (_isViewReady) {
        return;
    }
    [self constructViewHierarchy];
    [self layoutUI];
    self->_isViewReady = YES;
}

// 初始化子视图属性
- (void)constructSubViews {
    self.showLinkMicAndExitPKBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.showLinkMicAndExitPKBtn setTitle:@"连麦列表" forState:UIControlStateNormal];
    [self.showLinkMicAndExitPKBtn setTitle:@"连麦列表" forState:UIControlStateSelected];
    self.showLinkMicAndExitPKBtn.layer.cornerRadius = 15.0;
    self.showLinkMicAndExitPKBtn.backgroundColor = [UIColor colorWithRed:56 / 255.0 green:180 / 255.0 blue:218 / 255.0 alpha:1.0];
    [self.showLinkMicAndExitPKBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.showLinkMicAndExitPKBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.showLinkMicAndExitPKBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.showLinkMicAndExitPKBtn.selected = YES;
    
    self.tipsView = [[UIView alloc] init];
    self.tipsView.layer.cornerRadius = 5; // 直径为6
    
    self.PKImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_PK"]];
    
    self.bottomBar = [[TUILiveBottomToolBar alloc] init];
    NSMutableArray *buttons = self.bottomToolBarButtons;
    self.bottomPKButton = [TUILiveBottomToolBar createButtonWithImage:[UIImage imageNamed:@"live_pk_start"] selectedImage:nil];
    [buttons addObject:self.bottomPKButton];
    [buttons addObject:[TUILiveBottomToolBar createButtonWithImage:[UIImage imageNamed:@"live_music_icon"] selectedImage:nil]];
    [buttons addObject:[TUILiveBottomToolBar createButtonWithImage:[UIImage imageNamed:@"live_anchor_beauty"] selectedImage:nil]];
    [buttons addObject:[TUILiveBottomToolBar createButtonWithImage:[UIImage imageNamed:@"live_anchor_camera"] selectedImage:nil]];
    [buttons addObject:[TUILiveBottomToolBar createButtonWithImage:[UIImage imageNamed:@"live_anchor_close"] selectedImage:nil]];
    [self.bottomBar setRightButtons:buttons];
    
    self.topToolBar = [[TUILiveTopToolBar alloc] initWithFrame:CGRectMake(0, 83, 375, 75)];
    self.topToolBar.backgroundColor = [UIColor clearColor];
    self.topToolBar.hasFollowed = YES;
    TUILiveAnchorInfo *anchorInfo = [[TUILiveAnchorInfo alloc] init];
    V2TIMUserFullInfo *profile = [TUILiveUserProfile getLoginUserInfo];
    anchorInfo.userId = profile.userID;
    anchorInfo.nickName = profile.nickName;
    anchorInfo.avatarUrl = profile.faceURL;
    anchorInfo.weightValue = rand()%300000;
    anchorInfo.weightTagName = @"经验";
    self.topToolBar.anchorInfo = anchorInfo;

    self.msgTableView = [[TUILiveMsgListTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.bulletViewOne = [[TUILiveMsgBarrageView alloc] initWithFrame:CGRectMake(0, _msgTableView.frame.origin.y + MSG_UI_SPACE + MSG_BULLETVIEW_HEIGHT*2, SCREEN_WIDTH, MSG_BULLETVIEW_HEIGHT)];
    self.bulletViewTwo = [[TUILiveMsgBarrageView alloc] initWithFrame:CGRectMake(0, _bulletViewOne.frame.origin.y + MSG_BULLETVIEW_HEIGHT, SCREEN_WIDTH, MSG_BULLETVIEW_HEIGHT)];
    self.bulletViewOne.defaultAvatarImage = self.bulletViewTwo.defaultAvatarImage = [UIImage imageNamed:@"live_anchor_default_avatar"];
    
    self.inputView = [[TUILiveOnKeyboardInputView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 45)];

    self.roomListTableView = [[TUILiveAnchorPKListView alloc] init];
    self.roomListTableView.delegate = self;
    self.roomListTableView.backgroundColor = [UIColor colorWithRed:19.0 / 255.0 green:35.0 / 255.0 blue:63.0 / 255.0 alpha:1.0];
    [self.roomListTableView hide];
    
    self.joinAnchorListView = [[TUILiveJoinAnchorListView alloc] init];
    self.joinAnchorListView.delegate = self;
    self.joinAnchorListView.backgroundColor = [UIColor colorWithRed:19.0 / 255.0 green:35.0 / 255.0 blue:63.0 / 255.0 alpha:1.0];
    [self.joinAnchorListView hide];
}

- (void)constructViewHierarchy {
    [self addSubview:self.topToolBar];
    [self addSubview:self.showLinkMicAndExitPKBtn];
    [self.showLinkMicAndExitPKBtn addSubview:self.tipsView];
    [self addSubview:self.PKImage];
    [self addSubview:self.bottomBar];
    [self addSubview:self.msgTableView];
    [self addSubview:self.bulletViewOne];
    [self addSubview:self.bulletViewTwo];
    if (self.insertControlViews && self.insertControlViews.count > 0) {
        [self.insertControlViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addSubview:obj];
        }];
    }
    [self addSubview:self.roomListTableView];
    [self addSubview:self.joinAnchorListView];
    [self addSubview:self.inputView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];
}

- (void)layoutUI {
    [self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(5);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.mas_top).offset(5);
        }
        make.left.right.equalTo(self);
        make.height.equalTo(@65);
    }];
    [self.showLinkMicAndExitPKBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomBar.mas_top).offset(-10);
        make.trailing.mas_equalTo(-20);
        make.height.mas_equalTo(BOTTOM_BTN_ICON_WIDTH);
        make.width.mas_greaterThanOrEqualTo(@(90));
    }];
    [self.tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showLinkMicAndExitPKBtn.mas_top).offset(5);
        make.right.equalTo(self.showLinkMicAndExitPKBtn.mas_right).offset(5);
        make.width.height.mas_equalTo(10);
    }];
    CGFloat topOffset = 0;
    if (@available(iOS 11, *)) {
        topOffset = UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;
    }
    [self.PKImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_centerY).offset(80 + topOffset);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(0);
        make.right.equalTo(self).offset(0);
        make.height.mas_equalTo(50);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-10);
        } else {
            make.bottom.equalTo(self.mas_bottom);
        }
    }];
    [self.msgTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.bottom.equalTo(self.bottomBar.mas_top).offset(-10);
        make.width.equalTo(@(MSG_TABLEVIEW_WIDTH));
        make.height.equalTo(@(MSG_TABLEVIEW_HEIGHT));
    }];
    [self.bulletViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_msgTableView.mas_top).offset(-10-MSG_BULLETVIEW_HEIGHT*3);
        make.width.equalTo(self);
        make.height.equalTo(@(MSG_BULLETVIEW_HEIGHT));
    }];
    [self.bulletViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_msgTableView.mas_top).offset(-10-MSG_BULLETVIEW_HEIGHT*2);
        make.width.equalTo(self);
        make.height.equalTo(@(MSG_BULLETVIEW_HEIGHT));
    }];
    [self.roomListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(300);
    }];
    [self.joinAnchorListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(300);
    }];
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.left.equalTo(self.mas_left);
        make.height.mas_equalTo(45);
    }];
    [self.inputView layoutIfNeeded];
}

- (void)bindInteraction {
    [self.showLinkMicAndExitPKBtn addTarget:self action:@selector(exitPKAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topToolBar setOnClickFollow:^(TUILiveTopToolBar *toolBar, id  _Nonnull info) {
        NSLog(@"%@；%@", toolBar, info);
        toolBar.hasFollowed = YES;
    }];
    [self.topToolBar setOnClickAnchorAvator:^(id  _Nonnull toolBar, id  _Nonnull info) {
        NSLog(@"%@；%@", toolBar, info);
    }];
    [self.topToolBar setOnClickAudience:^(id  _Nonnull toolBar, id  _Nonnull info) {
        NSLog(@"%@；%@", toolBar, info);
    }];
    [self.topToolBar setOnClickOnlineNum:^(id  _Nonnull toolBar, id  _Nonnull info) {
        NSLog(@"%@；%@", toolBar, info);
    }];
    @weakify(self);
    [self.bottomBar setOnClick:^(TUILiveBottomToolBar * _Nonnull toolBar, UIButton *sender) {
        @strongify(self);
        [self bottomToolBar:toolBar onClick:sender];
    }];
    [self.inputView setTextReturnBlock:^BOOL(TUILiveOnKeyboardInputView * _Nonnull view, NSString * _Nonnull text) {
        @strongify(self);
        return [self sendMsg:text];
    }];
}

- (void)taggleCloseVC {
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeAction)]) {
        [self.delegate closeAction];
    }
}

- (void)exitPKAction:(UIButton *)sender {
    BOOL selected = sender.isSelected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(anchorToolView:clickAction:)]) {
        [self.delegate anchorToolView:self clickAction:selected ? TUILiveAnchorToolViewActionShowJoinAnchorList : TUILiveAnchorToolViewActionStopPK];
    }
}

#pragma mark - UILiveAnchorBottomToolBarDelegate
- (void)bottomToolBar:(TUILiveBottomToolBar *)toolBar onClick:(UIButton *)sender {
    if ([sender isEqual:toolBar.inputButton]) {
        // 发送消息事件, 弹出键盘，展示消息输入框
        [self.inputView.msgInputFeild becomeFirstResponder];
        return;
    }
    // 底部栏的点击事件
    if (self.delegate && [self.delegate respondsToSelector:@selector(anchorToolView:clickAction:)]) {
        NSInteger index = [self.bottomToolBarButtons indexOfObject:sender];
        if (self->_isHidePKMode) {
            index += 1;
        }
        [self.delegate anchorToolView:self clickAction:index];
    }
}

#pragma mark - TUILiveAnchorPKListViewDelegate
- (void)pkListViewDidHidden:(TUILiveAnchorPKListView *)view {
    // 修改PK按钮的状态
}

- (void)pkListView:(TUILiveAnchorPKListView *)view didSelectRoom:(TRTCLiveRoomInfo *)roomInfo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(startPKWithRoom:)]) {
        [self.delegate startPKWithRoom:roomInfo];
    }
}

#pragma mark - TUILiveJoinAnchorListViewDelegate
- (void)joinAnchorListView:(TUILiveJoinAnchorListView *)listView didRespondJoinAnchor:(TRTCLiveUserInfo *)user agree:(BOOL)agree {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRespondJoinAnchor:agree:)]) {
        [self.delegate onRespondJoinAnchor:user agree:agree];
    }
}

- (void)joinAnchorListViewDidHidden {
    
}

#pragma mark - public method
- (void)changePKState:(BOOL)isPK {
    // 修改当前视图为PK控制状态
    self.showLinkMicAndExitPKBtn.selected = !isPK;
    [self.showLinkMicAndExitPKBtn setTitle:isPK ? @"结束PK" : @"连麦列表" forState:UIControlStateNormal];
    self.tipsView.hidden = isPK;
    self.PKImage.hidden = !isPK;
    
    // 设置PK按钮的状态
    if (isPK) {
        self.bottomPKButton.enabled = NO;
    }else {
        if (self.isLinkMic) {
            self.bottomPKButton.enabled = NO;
            return;
        }
        self.bottomPKButton.enabled = YES;
    }
}

- (void)stopLive {
    [self.bulletViewOne stopAnimation];
    [self.bulletViewTwo stopAnimation];
}

#pragma mark - pangesture
- (void)onTap:(UITapGestureRecognizer *)tap {
    if (self.isPKRoomListShow) {
        [self hideRoomList];
        return;
    }
    [self.inputView.msgInputFeild resignFirstResponder];
    if (self->_isBeautyShow) {
        [self switchBeautyStatus:NO];
    }
    if (self->_isAudioSettingShow) {
        [self switchAudioSettingStatus:NO];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(anchorToolViewOnTapCancelAction:)]) {
        [self.delegate anchorToolViewOnTapCancelAction:self];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self->_isBeautyShow) {
        return YES;
    }
    CGPoint point = [touch locationInView:self];
    NSArray *ignoreTapViews = @[
        self.topToolBar,
        self.msgTableView,
        self.inputView,
        self.roomListTableView,
        self.bottomBar
    ];
    for (UIView *view in ignoreTapViews) {
        if (CGRectContainsPoint(view.frame, point)) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - 消息显示和发送
- (void)handleIMMessage:(TUILiveIMUserAble*)info msgText:(NSString*)msgText {
    NSLog(@"%@,%@", info, msgText);
    TUILiveMsgModel *msgModel = [self createMsgModelWithInfo:info msgText:msgText];
    switch (info.cmdType) {
        case TUILiveMsgModelType_NormalMsg: {
            [self bulletMsg:msgModel];
            break;
        }
        case TUILiveMsgModelType_MemberEnterRoom: {
            //收到新增观众消息，判断只有没在观众列表中，数量才需要增加1
//            if (![self isAlreadyInAudienceList:msgModel])
//            {
//                [_topView onUserEnterLiveRoom];
//            }
            [self onUserEnterLiveRoom:info];
            [self bulletMsg:msgModel];
            break;
        }
        case TUILiveMsgModelType_MemberQuitRoom: {
            [self bulletMsg:msgModel];
//            [_topView onUserExitLiveRoom];
            [self onUserExitLiveRoom:info];
            break;
        }
        case TUILiveMsgModelType_Praise: {
            msgModel.userMsg  =  @"点了个赞";
            [self bulletMsg:msgModel];
            [self showLikeHeart];
            break;
        }
        case TUILiveMsgModelType_DanmaMsg: {
            [self bulletMsg:msgModel];
            break;
        }
        case TUILiveMsgModelType_Gift: {
            [self giftMsg:msgModel];
            break;
        }
        default:
            break;
    }
}

- (BOOL)sendMsg:(NSString *)textMsg {
    if (textMsg.length <= 0) {
//        [HUDHelper alert:@"消息不能为空"];
        return YES;
    }
    TUILiveMsgModel *msgModel = [[TUILiveMsgModel alloc] init];
    msgModel.userName = @"我";
    msgModel.userMsg  =  textMsg;
    msgModel.userHeadImageUrl = [TUILiveUserProfile getLoginUserInfo].faceURL;
    msgModel.userId = [TUILiveUserProfile getLoginUserInfo].userID;
    /// TODO 设置头像 发送消息
//    msgModel.userHeadImageUrl = [[ProfileManager shared] curUserModel].avatar;
    if (self.inputView.bulletBtn.selected) {
        msgModel.msgType  = TUILiveMsgModelType_DanmaMsg;
    }else{
        msgModel.msgType = TUILiveMsgModelType_NormalMsg;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendTextMsg:isDamma:)]) {
        [self.delegate sendTextMsg:textMsg isDamma:self.inputView.bulletBtn.selected];
    }
    [self bulletMsg:msgModel];
    return YES;
}

- (void)bulletMsg:(TUILiveMsgModel *)msgModel {
    [_msgTableView bulletNewMsg:msgModel];
    if (msgModel.msgType == TUILiveMsgModelType_DanmaMsg) {
        if ([self getLocation:_bulletViewOne] >= [self getLocation:_bulletViewTwo]) {
            [_bulletViewTwo bulletNewMsg:msgModel];
        }else{
            [_bulletViewOne bulletNewMsg:msgModel];
        }
    }
//    if (msgModel.msgType == TUILiveMsgModelType_MemberEnterRoom || msgModel.msgType == TUILiveMsgModelType_MemberQuitRoom) {
//        [_audienceTableView refreshAudienceList:msgModel];
//    }
}

- (void)giftMsg:(TUILiveMsgModel *)msgModel
{
    NSLog(@"收到了礼物消息： %@", msgModel);
    if ([self.delegate respondsToSelector:@selector(onReceiveGiftMsg:)]) {
        [self.delegate onReceiveGiftMsg:msgModel];
    }
}

- (CGFloat)getLocation:(TUILiveMsgBarrageView *)bulletView {
    UIView *view = bulletView.lastAnimateView;
    CGRect rect = [view.layer.presentationLayer frame];
    return rect.origin.x + rect.size.width;
}

#pragma mark - 管理观众列表
- (void)onUserEnterLiveRoom:(TUILiveIMUserAble *)info {
    TUILiveAnchorInfo *audienceInfo = [self createAudienceInfoWithIM:info];
    dispatch_async(self.audienceDicDataQueue, ^{
        [self.audienceDic setObject:audienceInfo forKey:audienceInfo.userId];
        self.topToolBar.audienceList = self.audienceDic.allValues;
    });
}

- (void)onUserExitLiveRoom:(TUILiveIMUserAble *)info {
    dispatch_async(self.audienceDicDataQueue, ^{
        [self.audienceDic removeObjectForKey:info.imUserId];
        self.topToolBar.audienceList = self.audienceDic.allValues;
    });
}

- (TUILiveMsgModel *)createMsgModelWithInfo:(TUILiveIMUserAble *)info msgText:(NSString *)msgText {
    TUILiveMsgModel *msgModel = [[TUILiveMsgModel alloc] init];
    msgModel.userId = info.imUserId;
    msgModel.userName = info.imUserName;
    msgModel.userMsg = msgText;
    msgModel.userHeadImageUrl = info.imUserIconUrl;
    msgModel.msgType = info.cmdType;
    return msgModel;
}

- (TUILiveAnchorInfo *)createAudienceInfoWithIM:(TUILiveIMUserAble *)info {
    TUILiveAnchorInfo *audienceInfo = [[TUILiveAnchorInfo alloc] init];
    audienceInfo.userId = info.imUserId;
    audienceInfo.nickName = info.imUserName;
    audienceInfo.avatarUrl = info.imUserIconUrl;
    audienceInfo.weightValue = rand()%300000;
    audienceInfo.weightTagName = @"经验值";
    return audienceInfo;
}

#pragma mark - 点赞动画
- (void)showLikeHeart {
    UIButton *button = [self.bottomBar.rightButtons objectAtIndex:self.bottomBar.rightButtons.count - 2];
    CGRect buttonRect = [self.bottomBar convertRect:button.frame toView:self.superview];
    CGSize size = [button imageForState:UIControlStateNormal].size;
    int x = CGRectGetMidX(buttonRect)-size.width/2.0;
    CGRect rect = CGRectMake(x, CGRectGetMidY(buttonRect)-size.height/2.0, size.width, size.height);
    [self.heartCreator createHeartOn:self.superview startRect:rect];
}

@end
