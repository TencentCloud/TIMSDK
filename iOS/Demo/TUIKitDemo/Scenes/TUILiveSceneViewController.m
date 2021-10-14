//
//  TUILiveSceneViewController.m
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/7.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveSceneViewController.h"
#import "TUINaviBarIndicatorView.h"
#import "TUILiveRoomListViewController.h"
#import "TUIDarkModel.h"
#import "TUIKit.h"
#import "TUILiveRoomManager.h"
#import "TCLoginModel.h"
#import "TUILiveDefaultGiftAdapterImp.h"
#import "TUILiveUserProfile.h"
#import "TUIKitLive.h"
#import "TUILiveRoomAnchorViewController.h"
#import "TUITool.h"
#import <TRTCLiveRoom.h>
#import "TUIDefine.h"

#import <Masonry.h>
#import "GenerateTestUserSig.h"

#import "ReactiveObjC/ReactiveObjC.h"

#import "TUILiveHeartBeatManager.h"

#define IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

@interface TUILiveSceneViewController ()<UIScrollViewDelegate, TUILiveRoomAnchorDelegate, V2TIMSDKListener>

@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;

@property(strong, nonatomic) TUILiveRoomListViewController* liveRoomListController;

@property(strong, nonatomic) UIScrollView *contentScrollView;
@property(strong, nonatomic) UIButton* createRoomButton;

@end

@implementation TUILiveSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigation];
    // Do any additional setup after loading the view.
    [self constructSubViews]; // 初始化子视图
    [self constructViewHierarchy]; // 初始化视图约束
    [self layoutUI]; // 初始化视图布局
}
/**
 *初始化导航栏
 */
- (void)setupNavigation
{
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:NSLocalizedString(@"TabBarItemLiveText", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    [[V2TIMManager sharedInstance] addIMSDKListener:self];
}

/**
 *初始化导航栏Title，不同连接状态下Title显示内容不同
 */
- (void)onNetworkChanged:(TUINetStatus)status
{
    [TUITool dispatchMainAsync:^{
        switch (status) {
            case TNet_Status_Succ:
                [self.titleView setTitle:NSLocalizedString(@"TabBarItemLiveText", nil)];
                [self.titleView stopAnimating];
                break;
            case TNet_Status_Connecting:
                [self.titleView setTitle:NSLocalizedString(@"TabBarItemLiveConnectingText", nil)];
                [self.titleView startAnimating];
                break;
            case TNet_Status_Disconnect:
                [self.titleView setTitle:NSLocalizedString(@"TabBarItemLiveDisconnectText", nil)];
                [self.titleView stopAnimating];
                break;
            case TNet_Status_ConnFailed:
                [self.titleView setTitle:NSLocalizedString(@"TabBarItemLiveDisconnectText", nil)];
                [self.titleView stopAnimating];
                break;
                
            default:
                break;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TUILiveUserProfile refreshLoginUserInfo:nil];
}

- (void)constructSubViews {
    // 初始化子视图
    self.liveRoomListController = [[TUILiveRoomListViewController alloc] init];
    @weakify(self);
    [self.liveRoomListController setCreateRoomAction:^{
        @strongify(self);
        [self createRoomActon:self.createRoomButton];
    }];
    [self addChildViewController:self.liveRoomListController];
    
    self.contentScrollView = [[UIScrollView alloc] init];
    self.contentScrollView.delegate = self;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    
    self.createRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.createRoomButton.layer.cornerRadius = 20.0;
    [self.createRoomButton setImage:[UIImage imageNamed:@"live_create_room"] forState:UIControlStateNormal];
    [self.createRoomButton addTarget:self action:@selector(createRoomActon:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 视图整合
- (void)constructViewHierarchy {
    
    [self.view addSubview:self.contentScrollView];
    [self.contentScrollView addSubview:self.liveRoomListController.view];
    [self.view addSubview:self.createRoomButton];
}

- (void)layoutUI {
    [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top);
        }
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    // 左右滑动，注意子视图上下的约束
    [self.liveRoomListController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top);
        }
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.contentScrollView.mas_left);
        make.width.equalTo(self.view.mas_width);
        make.right.equalTo(self.contentScrollView.mas_right);
    }];
    [self.createRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-20);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        }
        make.right.equalTo(self.view).offset(-20);
        make.height.and.width.mas_equalTo(70.0);
    }];
}

- (void)createRoomActon:(UIButton *)sender {
    TUILiveRoomAnchorViewController *anchorVC = [[TUILiveRoomAnchorViewController alloc] init];
    anchorVC.delegate = self;
    [anchorVC enablePK:YES];
    [anchorVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:anchorVC animated:YES];
}

#pragma mark - V2TIMSDKListener
- (void)onConnecting {
    [self onNetworkChanged:TNet_Status_Connecting];
}

- (void)onConnectSuccess {
    [self onNetworkChanged:TNet_Status_Succ];
}

- (void)onConnectFailed:(int)code err:(NSString*)err {
    [self onNetworkChanged:TNet_Status_ConnFailed];
}

#pragma mark - TUILiveRoomAnchorDelegate
- (void)onRoomCreate:(TRTCLiveRoomInfo *)roomInfo {
    [[TUILiveRoomManager sharedManager] createRoom:SDKAPPID type:@"liveRoom" roomID:[NSString stringWithFormat:@"%@", roomInfo.roomId] success:^{
        NSLog(@"----> 业务层创建房间成功");
        [TUILiveHeartBeatManager.shareManager startWithType:@"liveRoom" roomId:roomInfo.roomId];
    } failed:^(int code, NSString * _Nonnull errorMsg) {
        NSLog(@"----> 业务层创建房间失败，%d, %@", code, errorMsg);
    }];
}

- (void)onRoomDestroy:(TRTCLiveRoomInfo *)roomInfo {
    [[TUILiveRoomManager sharedManager] destroyRoom:SDKAPPID type:@"liveRoom" roomID:[NSString stringWithFormat:@"%@", roomInfo.roomId] success:^{
        NSLog(@"----> 业务层销毁房间成功");
        [TUILiveHeartBeatManager.shareManager stop];
    } failed:^(int code, NSString * _Nonnull errorMsg) {
        NSLog(@"----> 业务层销毁房间失败，%d, %@", code, errorMsg);
    }];
}

- (void)onRoomError:(TRTCLiveRoomInfo *)roomInfo errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage
{
    NSLog(@"---> 业务层收到错误信息");
}

- (void)getPKRoomIDList:(TUILiveOnRoomListCallback)callback {
   // 业务层向下层传递PK房间数据
    [self.liveRoomListController getRoomIDList:^(NSArray<NSString *> * _Nonnull roomIDList) {
        if (callback) {
            callback(roomIDList);
        }
    }];
}

@end
