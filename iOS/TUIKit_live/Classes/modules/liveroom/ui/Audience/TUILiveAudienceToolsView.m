//
//  TUILiveAudienceToolsView.m
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveAudienceToolsView.h"
#import "TUILiveOnKeyboardInputView.h"
#import "TUILiveMsgModel.h"
#import "TRTCLiveRoom.h"
#import "Masonry.h"
#import "TUILiveMsgListTableView.h"
#import "TUILiveBottomToolBar.h"
#import "TUILiveRoomAudienceViewController.h"
#import "TUILiveLikeHeartCreator.h"
#import "TUILiveMsgBarrageView.h"
#import "TUIKitLive.h"
#import <ImSDK/V2TIMManager+Friendship.h>
#import "TUILiveUtil.h"
#import "TUILiveUserProfile.h"
#import "TUILiveRoomAudienceViewController+FloatView.h"

typedef NS_ENUM(NSInteger, TUILiveBottomToolBarButtonType) {
    TUILiveBottomToolBarButtonLinkMic = 1000, /// 连麦按钮
    TUILiveBottomToolBarButtonLike,
    TUILiveBottomToolBarButtonClose,
    TUILiveBottomToolBarButtonGift,
    TUILiveBottomToolBarButtonSwitchCamera
};

@interface TUILiveAudienceToolsView () <UIGestureRecognizerDelegate> {
    /// 消息展示
    TUILiveMsgListTableView          *_msgTableView;
    TUILiveMsgBarrageView            *_bulletViewOne;
    TUILiveMsgBarrageView            *_bulletViewTwo;
}
@property(nonatomic, strong) TUILiveLikeHeartCreator *heartCreator;
@property(nonatomic, strong) NSMutableDictionary *audienceDic; /// 存储观众列表，快速索引
@property(nonatomic, strong) NSMutableArray *audienceList; /// 存储观众列表，保证顺序
@property(nonatomic, strong) dispatch_queue_t audienceDicDataQueue;
@property(nonatomic, strong) UIButton *bottomLinkMicBtn;
@property(nonatomic, strong) NSMutableArray *bottomToolBarRightButtons;
@property(nonatomic, strong) UIButton *buttomToolBarSwichCameraButton;
@property(nonatomic, strong) UIImageView *PKImage;
@property(nonatomic, strong) UIButton *reportButton;
@property(nonatomic, assign, getter=isKeyboardShow) BOOL keyboardShow;
@end

@implementation TUILiveAudienceToolsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.audienceDic = [NSMutableDictionary dictionaryWithCapacity:10];
        self.audienceList = [NSMutableArray arrayWithCapacity:10];
        self.audienceDicDataQueue = dispatch_queue_create("live_audience_tools_view_data", DISPATCH_QUEUE_SERIAL);
        self.bottomToolBarRightButtons = [NSMutableArray arrayWithCapacity:4];
        [self constructSubViews];
        [self bindInteraction];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutUI];
    });
}

- (void)constructSubViews {
    self.PKImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_PK"]];
    [self addSubview:self.PKImage];
    self.PKImage.hidden = YES;
    /// 输入框
    self.inputView = [[TUILiveOnKeyboardInputView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 45)];
    [self addSubview:self.inputView];

    //底部栏
    TUILiveBottomToolBar *bottomToolBar = [[TUILiveBottomToolBar alloc] initWithFrame:CGRectMake(0, 400, 375, 50)];
    [self addSubview:bottomToolBar];
    self.bottomToolBar = bottomToolBar;
    UIButton *linkMicButton = [TUILiveBottomToolBar createButtonWithImage:[UIImage imageNamed:@"live_audience_bottom_bar_linkmic_on"]
                                            selectedImage:[UIImage imageNamed:@"live_audience_bottom_bar_linkmic_off"]];
    linkMicButton.tag = TUILiveBottomToolBarButtonLinkMic;
    UIButton *likeButton = [TUILiveBottomToolBar createButtonWithImage:[UIImage imageNamed:@"live_audience_room_bottom_bar_like"]
                                         selectedImage:nil];
    likeButton.tag = TUILiveBottomToolBarButtonLike;
    UIButton *closeButton = [TUILiveBottomToolBar createButtonWithImage:[UIImage imageNamed:@"live_audience_bottom_bar_close"]
                                          selectedImage:nil];
    closeButton.tag = TUILiveBottomToolBarButtonClose;
    UIButton *giftButton = [TUILiveBottomToolBar createButtonWithImage:[UIImage imageNamed:@"live_gift_btn_icon"]
                                          selectedImage:nil];
    giftButton.tag = TUILiveBottomToolBarButtonGift;
    UIButton *swichCameraButton = [TUILiveBottomToolBar createButtonWithImage:[UIImage imageNamed:@"live_switch_camera_normal"]
                                                        selectedImage:nil];
    swichCameraButton.tag = TUILiveBottomToolBarButtonSwitchCamera;
    self.buttomToolBarSwichCameraButton = swichCameraButton;
    [self.bottomToolBarRightButtons addObjectsFromArray:@[linkMicButton, likeButton, giftButton, closeButton]];
    [bottomToolBar setRightButtons:self.bottomToolBarRightButtons];
    
    //聊天列表
    _msgTableView = [[TUILiveMsgListTableView alloc] initWithFrame:CGRectMake(15, self.frame.size.height - 50, MSG_TABLEVIEW_WIDTH, MSG_TABLEVIEW_HEIGHT) style:UITableViewStylePlain];
    [self addSubview:_msgTableView];
    
    _bulletViewOne = [[TUILiveMsgBarrageView alloc] initWithFrame:CGRectMake(0, _msgTableView.frame.origin.y + MSG_UI_SPACE + MSG_BULLETVIEW_HEIGHT*2, SCREEN_WIDTH, MSG_BULLETVIEW_HEIGHT)];
    [self addSubview:_bulletViewOne];

    _bulletViewTwo = [[TUILiveMsgBarrageView alloc] initWithFrame:CGRectMake(0, _bulletViewOne.frame.origin.y + MSG_BULLETVIEW_HEIGHT, SCREEN_WIDTH, MSG_BULLETVIEW_HEIGHT)];
    [self addSubview:_bulletViewTwo];
    
    /// 顶部栏
    TUILiveTopToolBar *topToolBar = [[TUILiveTopToolBar alloc] initWithFrame:CGRectMake(0, 83, 375, 75)];
    [self addSubview:topToolBar];
    self.topToolBar = topToolBar;
    topToolBar.backgroundColor = [UIColor clearColor];
    
    // 举报
    [self addSubview:self.reportButton];
}

- (void)bindInteraction {
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onKeyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onKeyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.inputView setTextReturnBlock:^BOOL(TUILiveOnKeyboardInputView * _Nonnull view, NSString * _Nonnull text) {
        NSLog(@"%@", text);
        return [weakSelf sendMsg:text];
    }];
    [self.inputView setOnBullteClick:^(TUILiveOnKeyboardInputView * _Nonnull view, UIButton * _Nonnull sender) {
        NSLog(@"%d", sender.selected);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    [self.bottomToolBar setOnClick:^(TUILiveBottomToolBar * _Nonnull toolBar, UIButton *sender) {
        NSLog(@"%@：%ld", toolBar, (long)index);
        __strong typeof(self) strongSelf = weakSelf;
        if ([sender isEqual:toolBar.inputButton]) {
            /// 输入文字
            [weakSelf.inputView.msgInputFeild becomeFirstResponder];
        } else if (sender.tag == TUILiveBottomToolBarButtonClose) {
            if (!weakSelf.controller) {
                return;
            }
            [weakSelf.controller prepareToShowFloatView];
            /// 关闭
            if (weakSelf.controller.navigationController) {
                [weakSelf.controller.navigationController popViewControllerAnimated:YES];
            } else {
                [weakSelf.controller dismissViewControllerAnimated:YES completion:nil];
            }
        } else if (sender.tag == TUILiveBottomToolBarButtonLike) {
            /// 点赞
            [weakSelf clickLike:sender];
        } else if (sender.tag == TUILiveBottomToolBarButtonLinkMic) {
            strongSelf.bottomLinkMicBtn = sender;
            /// 连麦
            if (strongSelf.onLinkMic) {
                strongSelf.onLinkMic(strongSelf, nil);
            }
        } else if (sender.tag == TUILiveBottomToolBarButtonGift) {
            /// 礼物
            if (strongSelf.onGiftClick) {
                strongSelf.onGiftClick(strongSelf, nil);
            }
        } else if (sender.tag == TUILiveBottomToolBarButtonSwitchCamera) {
            /// 切换摄像头
            [strongSelf.liveRoom switchCamera];
        }
    }];
    
    [self.topToolBar setOnClickFollow:^(TUILiveTopToolBar *toolBar, TUILiveAnchorInfo *info) {
        /// 关注
        NSLog(@"%@；%@", toolBar, info);
        __strong typeof(self) strongSelf = weakSelf;
        if (!info.userId) {
            if (strongSelf) {
                [TUILiveUtil toastTip:@"主播信息不存在" parentView:strongSelf];
            }
            return;
        }
        toolBar.hasFollowed = YES;
        V2TIMFriendAddApplication *addApplication = [[V2TIMFriendAddApplication alloc] init];
        addApplication.userID = info.userId;
        addApplication.addWording = @"";
        addApplication.addSource = @"liveRoom";
        addApplication.addType = V2TIM_FRIEND_TYPE_SINGLE;
        [[V2TIMManager sharedInstance] addFriend:addApplication succ:^(V2TIMFriendOperationResult *result) {
        } fail:^(int code, NSString *desc) {
            NSLog(@"加关注：%d, %@", code, desc);
            toolBar.hasFollowed = NO;
        }];
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
}

- (CGFloat)safeTopOffset {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
    } else {
        return 0.0;
    }
}

- (CGFloat)pkImageBottomOffset {
    CGFloat relateBottomOffset = ((30+480)/960.0)*(self.bounds.size.height - [self safeTopOffset] - 35);
    return relateBottomOffset - [self safeTopOffset] - 35;
}

- (void)setIsCdnPK:(BOOL)isCdnPK {
    _isCdnPK = isCdnPK;
    if (self.PKImage.superview) {
        [self.PKImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-[self pkImageBottomOffset]);
            make.centerX.equalTo(self.mas_centerX);
        }];
    }
}

- (void)layoutUI {
    CGFloat topOffset = 0;
    if (@available(iOS 11, *)) {
        topOffset = UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;
    }
    [self.PKImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.isCdnPK) {
            make.bottom.equalTo(self).offset(-[self pkImageBottomOffset]);
        } else {
            make.bottom.equalTo(self.mas_centerY).offset(80 + topOffset);
        }
        make.centerX.equalTo(self.mas_centerX);
    }];
    [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-5);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self).offset(10.0);
        }
        make.height.equalTo(@50);
    }];

    [_msgTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.bottom.equalTo(self.bottomToolBar.mas_top).offset(-10);
        make.width.equalTo(@(MSG_TABLEVIEW_WIDTH));
        make.height.equalTo(@(MSG_TABLEVIEW_HEIGHT));
    }];

    [_bulletViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_msgTableView.mas_top).offset(-10-MSG_BULLETVIEW_HEIGHT*3);
        make.width.equalTo(self);
        make.height.equalTo(@(MSG_BULLETVIEW_HEIGHT));
    }];
    
    [_bulletViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_msgTableView.mas_top).offset(-10-MSG_BULLETVIEW_HEIGHT*2);
        make.width.equalTo(self);
        make.height.equalTo(@(MSG_BULLETVIEW_HEIGHT));
    }];
    
    [self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(5);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(@20).offset(5);
        }
        make.left.right.equalTo(self);
        make.height.equalTo(@65);
    }];
    
    [self.reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(15);
        make.top.mas_equalTo(self.topToolBar.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(40, 28));
    }];
}

#pragma mark - UIGestureRecognizerDelegate 用来处理键盘问题
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self.keyboardShow || YES;
}

- (void)onKeyboardDidShow
{
    self.keyboardShow = YES;
}

- (void)onKeyboardDidHide
{
    self.keyboardShow = NO;
}

- (void)onTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    NSArray *ignoreTapViews = @[
        self.topToolBar,
        _msgTableView,
        self.inputView,
    ];
    for (UIView *view in ignoreTapViews) {
        if (CGRectContainsPoint(view.frame, point)) {
            return;;
        }
    }
    [self.inputView.msgInputFeild resignFirstResponder];
}

- (void)changePKState:(BOOL)isPK {
    // 修改当前视图为PK控制状态
    self.PKImage.hidden = !isPK;
}

- (void)setSwitchCameraButtonHidden:(BOOL)hidden {
    if (hidden) {
        [self.bottomToolBarRightButtons removeObject:self.buttomToolBarSwichCameraButton];
    } else {
        [self.bottomToolBarRightButtons insertObject:self.buttomToolBarSwichCameraButton atIndex:1];
    }
    [self.bottomToolBar setRightButtons:self.bottomToolBarRightButtons];
}

- (TUILiveMsgModel *)createMsgModelWith:(TUILiveIMUserAble *)info msgText:(NSString *)msgText {
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
    audienceInfo.weightTagName = @"经验";
    return audienceInfo;
}

- (TUILiveAnchorInfo *)createAudienceInfoWithLive:(TRTCLiveUserInfo *)info {
    TUILiveAnchorInfo *audienceInfo = [[TUILiveAnchorInfo alloc] init];
    audienceInfo.userId = info.userId;
    audienceInfo.nickName = info.userName;
    audienceInfo.avatarUrl = info.avatarURL;
    audienceInfo.weightValue = rand()%300000;
    audienceInfo.weightTagName = @"经验";
    return audienceInfo;
}

#pragma mark - 管理观众列表
- (void)updateAudienceList:(NSArray *)audienceList {
    dispatch_async(self.audienceDicDataQueue, ^{
        for (TRTCLiveUserInfo *info in audienceList) {
            if (info.userId && ![self.topToolBar.anchorInfo.userId isEqualToString:info.userId] &&
                ![self.audienceDic objectForKey:info.userId]) {
                TUILiveAnchorInfo *audienceInfo = [self createAudienceInfoWithLive:info];
                [self.audienceDic setObject:audienceInfo forKey:audienceInfo.userId];
                [self.audienceList addObject:audienceInfo];
            }
        }
        self.topToolBar.audienceList = self.audienceList.copy;
    });
}

- (void)onUserEnterLiveRoom:(TUILiveIMUserAble *)info {
    TUILiveAnchorInfo *audienceInfo = [self createAudienceInfoWithIM:info];
    dispatch_async(self.audienceDicDataQueue, ^{
        if (audienceInfo.userId && ![self.topToolBar.anchorInfo.userId isEqualToString:audienceInfo.userId] &&
            ![self.audienceDic objectForKey:audienceInfo.userId]) {
            [self.audienceDic setObject:audienceInfo forKey:audienceInfo.userId];
            [self.audienceList addObject:audienceInfo];
            self.topToolBar.audienceList = self.audienceList.copy;
        }
    });
}

- (void)onUserExitLiveRoom:(TUILiveIMUserAble *)info {
    dispatch_async(self.audienceDicDataQueue, ^{
        TUILiveAnchorInfo *audienceInfo = [self.audienceDic objectForKey:info.imUserId];
        if (audienceInfo.userId && ![self.topToolBar.anchorInfo.userId isEqualToString:audienceInfo.userId] &&
            [self.audienceDic objectForKey:audienceInfo.userId]) {
            [self.audienceDic removeObjectForKey:info.imUserId];
            [self.audienceList removeObject:audienceInfo];
            self.topToolBar.audienceList = self.audienceList.copy;
        }
    });
}

#pragma mark - 消息显示和发送
- (void)handleIMMessage:(TUILiveIMUserAble*)info msgText:(NSString*)msgText {
    NSLog(@"%@,%@", info, msgText);
    TUILiveMsgModel *msgModel = [self createMsgModelWith:info msgText:msgText];
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
            [self clickLike:nil];
//            [_topView onUserSendLikeMessage];
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
        [_liveRoom sendRoomCustomMsgWithCommand:[@(TUILiveMsgModelType_DanmaMsg) stringValue] message:textMsg callback:^(int code, NSString * error) {
        }];
    }else{
        msgModel.msgType = TUILiveMsgModelType_NormalMsg;
        [_liveRoom sendRoomTextMsg:textMsg callback:^(int code, NSString * error) {
        }];
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
    if (self.onReceiveGiftMsg) {
        self.onReceiveGiftMsg(self, msgModel);
    }
}

- (CGFloat)getLocation:(TUILiveMsgBarrageView *)bulletView {
    UIView *view = bulletView.lastAnimateView;
    CGRect rect = [view.layer.presentationLayer frame];
    return rect.origin.x + rect.size.width;
}

#pragma mark - logic
- (void)clickLike:(UIButton *)button {
    if (button) {
        /// 主动点击，需要发送
        [_liveRoom sendRoomCustomMsgWithCommand:[@(TUILiveMsgModelType_Praise) stringValue] message:@"" callback:^(int code, NSString * error) {
            NSLog(@"sendRoomCustomMsgWithCommand：%d, %@", code, error);
        }];
    } else {
        /// 收到点赞，仅展示
        button = [self.bottomToolBar.rightButtons objectAtIndex:self.bottomToolBar.rightButtons.count-2];
    }
    if (!self.heartCreator) {
        self.heartCreator = [[TUILiveLikeHeartCreator alloc] init];
    }
    
    CGRect buttonRect = [self.bottomToolBar convertRect:button.frame toView:self.superview];
    CGSize size = [button imageForState:UIControlStateNormal].size;
    int x = CGRectGetMidX(buttonRect)-size.width/2.0;
    CGRect rect = CGRectMake(x, CGRectGetMidY(buttonRect)-size.height/2.0, size.width, size.height);
    [self.heartCreator createHeartOn:self.superview startRect:rect];
//    [_topView onUserSendLikeMessage];
}

#pragma mark - logic: 举报
- (UIButton *)reportButton
{
    if (_reportButton == nil) {
        _reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reportButton.backgroundColor = [UIColor blackColor];
        [_reportButton setTitle:@"举报" forState:UIControlStateNormal];
        [_reportButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _reportButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _reportButton.layer.cornerRadius = 14.f;
        [_reportButton addTarget:self action:@selector(userReport:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reportButton;
}

- (void)userReport:(UIButton *)button
{
    if (self.onUserReport) {
        self.onUserReport(self, nil);
    }
}

@end
