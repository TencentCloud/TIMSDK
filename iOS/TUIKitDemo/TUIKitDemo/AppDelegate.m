//
//  AppDelegate.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "AppDelegate.h"
#import "TNavigationController.h"
#import "ConversationController.h"
#import "SettingController.h"
#import "ContactsController.h"
#import "TUILiveSceneViewController.h"
#import "TUITabBarController.h"
#import "LoginController.h"
#import "TUIKit.h"
#import <Bugly/Bugly.h>
#import "Aspects.h"
#import "TCUtil.h"
#import "UIColor+TUIDarkMode.h"
#import "TUIKitLive.h"
#import "GenerateTestUserSig.h"
#import "TXLiveBase.h"

@interface AppDelegate () <UIAlertViewDelegate,BuglyDelegate>
@property(nonatomic,strong) NSString *groupID;
@property(nonatomic,strong) NSString *userID;
@property(nonatomic,strong) V2TIMSignalingInfo *signalingInfo;
@end

static AppDelegate *app;

@implementation AppDelegate
{
    NSUInteger        _unReadCount;
}

+ (instancetype)sharedInstance {
    return app;
}

- (void)login:(NSString *)identifier userSig:(NSString *)sig succ:(TSucc)succ fail:(TFail)fail
{
    [[TUIKit sharedInstance] login:identifier userSig:sig succ:^{
        NSLog(@"-----> 登录成功");
        if (self.deviceToken) {
            V2TIMAPNSConfig *confg = [[V2TIMAPNSConfig alloc] init];
            /* 用户自己到苹果注册开发者证书，在开发者帐号中下载并生成证书(p12 文件)，将生成的 p12 文件传到腾讯证书管理控制台，控制台会自动生成一个证书 ID，将证书 ID 传入一下 busiId 参数中。*/
            //企业证书 ID
            confg.businessID = sdkBusiId;
            confg.token = self.deviceToken;
            [[V2TIMManager sharedInstance] setAPNS:confg succ:^{
                 NSLog(@"-----> 设置 APNS 成功");
            } fail:^(int code, NSString *msg) {
                 NSLog(@"-----> 设置 APNS 失败, code:%d msg:%@",code, msg);
            }];
        }
        self.window.rootViewController = [app getMainController];
        [self onReceiveNomalMsgAPNs];
        [self onReceiveGroupCallAPNs];
        [self setupTotalUnreadCount];
    } fail:^(int code, NSString *msg) {
        NSLog(@"-----> 登录失败");
        fail(code, msg);
    }];
    [TCUtil report:Action_Login actionSub:@"" code:@(0) msg:@"login"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    app = self;

    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserStatus:) name:TUIKitNotification_TIMUserStatusListener object:nil];
    
    [TXLiveBase setLicenceURL:@"http://license.vod2.myqcloud.com/license/v1/3e0ffdeec6f69f2ebb0033705d4b33e5/TXLiveSDK.licence" key:@"439c61a21e71e1af31024c2700f95b52"];
    
    BOOL test_environment = [[NSUserDefaults standardUserDefaults] integerForKey:@"test_environment"];
    [[V2TIMManager sharedInstance] callExperimentalAPI:@"setTestEnvironment" param:[NSNumber numberWithBool:test_environment] succ:nil fail:nil];
    
    [self setupBugly];
    [self registNotification];
    [self setupCustomSticker];

    [UIViewController aspect_hookSelector:@selector(setTitle:)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo, NSString *title) {
        UIViewController *vc = aspectInfo.instance;
        vc.navigationItem.titleView = ({
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            titleLabel.text = title;
            titleLabel;
        });
        vc.navigationItem.title = @"";
    } error:NULL];

    [[TUIKit sharedInstance] setupWithAppId:SDKAPPID];

    [[TUILocalStorage sharedInstance] login:^(NSString * _Nonnull identifier, NSUInteger appId, NSString * _Nonnull userSig) {
        if(appId == SDKAPPID && identifier.length != 0 && userSig.length != 0){
            [self login:identifier userSig:userSig succ:nil fail:^(int code, NSString *msg) {
                self.window.rootViewController = [self getLoginController];
            }];
        } else {
            self.window.rootViewController = [self getLoginController];
        }
    }];
    return YES;
}

- (void)setupCustomSticker
{
    NSMutableArray *faceGroups = [NSMutableArray arrayWithArray:TUIKitConfig.defaultConfig.faceGroups];
    
    //4350 group
    NSMutableArray *faces4350 = [NSMutableArray array];
    for (int i = 0; i <= 17; i++) {
        TFaceCellData *data = [[TFaceCellData alloc] init];
        NSString *name = [NSString stringWithFormat:@"yz%02d", i];
        NSString *path = [NSString stringWithFormat:@"4350/%@", name];
        data.name = name;
        data.path = [[[NSBundle mainBundle] pathForResource:@"CustomFaceResource" ofType:@"bundle"] stringByAppendingPathComponent:path];
        [faces4350 addObject:data];
    }
    if(faces4350.count != 0){
        TFaceGroup *group4350 = [[TFaceGroup alloc] init];
        group4350.groupIndex = 1;
        group4350.groupPath = [[[NSBundle mainBundle] pathForResource:@"CustomFaceResource" ofType:@"bundle"] stringByAppendingPathComponent:@"4350/"]; //TUIKitFace(@"4350/");
        group4350.faces = faces4350;
        group4350.rowCount = 2;
        group4350.itemCountPerRow = 5;
        group4350.menuPath = [[[NSBundle mainBundle] pathForResource:@"CustomFaceResource" ofType:@"bundle"] stringByAppendingPathComponent:@"4350/menu"]; // TUIKitFace(@"4350/menu");
        [faceGroups addObject:group4350];
    }
    
    //4351 group
    NSMutableArray *faces4351 = [NSMutableArray array];
    for (int i = 0; i <= 15; i++) {
        TFaceCellData *data = [[TFaceCellData alloc] init];
        NSString *name = [NSString stringWithFormat:@"ys%02d", i];
        NSString *path = [NSString stringWithFormat:@"4351/%@", name];
        data.name = name;
        data.path = [[[NSBundle mainBundle] pathForResource:@"CustomFaceResource" ofType:@"bundle"] stringByAppendingPathComponent:path]; // TUIKitFace(path);
        [faces4351 addObject:data];
    }
    if(faces4351.count != 0){
        TFaceGroup *group4351 = [[TFaceGroup alloc] init];
        group4351.groupIndex = 2;
        group4351.groupPath = [[[NSBundle mainBundle] pathForResource:@"CustomFaceResource" ofType:@"bundle"] stringByAppendingPathComponent:@"4351/"]; // TUIKitFace(@"4351/");
        group4351.faces = faces4351;
        group4351.rowCount = 2;
        group4351.itemCountPerRow = 5;
        group4351.menuPath = [[[NSBundle mainBundle] pathForResource:@"CustomFaceResource" ofType:@"bundle"] stringByAppendingPathComponent:@"4351/menu"]; //TUIKitFace(@"4351/menu");
        [faceGroups addObject:group4351];
    }
    
    //4352 group
    NSMutableArray *faces4352 = [NSMutableArray array];
    for (int i = 0; i <= 16; i++) {
        TFaceCellData *data = [[TFaceCellData alloc] init];
        NSString *name = [NSString stringWithFormat:@"gcs%02d", i];
        NSString *path = [NSString stringWithFormat:@"4352/%@", name];
        data.name = name;
        data.path = [[[NSBundle mainBundle] pathForResource:@"CustomFaceResource" ofType:@"bundle"] stringByAppendingPathComponent:path]; // TUIKitFace(path);
        [faces4352 addObject:data];
    }
    if(faces4352.count != 0){
        TFaceGroup *group4352 = [[TFaceGroup alloc] init];
        group4352.groupIndex = 3;
        group4352.groupPath = [[[NSBundle mainBundle] pathForResource:@"CustomFaceResource" ofType:@"bundle"] stringByAppendingPathComponent:@"4352/"]; //TUIKitFace(@"4352/");
        group4352.faces = faces4352;
        group4352.rowCount = 2;
        group4352.itemCountPerRow = 5;
        group4352.menuPath = [[[NSBundle mainBundle] pathForResource:@"CustomFaceResource" ofType:@"bundle"] stringByAppendingPathComponent:@"4352/menu"]; // TUIKitFace(@"4352/menu");
        [faceGroups addObject:group4352];
    }
    
    TUIKitConfig.defaultConfig.faceGroups = faceGroups;
}

- (void)setupBugly {
    // Get the default config
    BuglyConfig * config = [[BuglyConfig alloc] init];

    // Open the debug mode to print the sdk log message.
    // Default value is NO, please DISABLE it in your RELEASE version.
#if DEBUG
    config.debugMode = YES;
#endif

    // Open the customized log record and report, BuglyLogLevelWarn will report Warn, Error log message.
    // Default value is BuglyLogLevelSilent that means DISABLE it.
    // You could change the value according to you need.
    //    config.reportLogLevel = BuglyLogLevelWarn;

    // Open the STUCK scene data in MAIN thread record and report.
    // Default value is NO
    //config.blockMonitorEnable = YES;

    // Set the STUCK THRESHOLD time, when STUCK time > THRESHOLD it will record an event and report data when the app launched next time.
    // Default value is 3.5 second.
    //config.blockMonitorTimeout = 1.5;

    // Set the app channel to deployment
    config.channel = @"Bugly";

    config.delegate = self;

    config.consolelogEnable = NO;
    config.viewControllerTrackingEnable = NO;
//    config.version = [TIMManager sharedInstance].GetVersion;

    // NOTE:Required
    // Start the Bugly sdk with APP_ID and your config
    [Bugly startWithAppId:BUGLY_APP_ID
#if DEBUG
        developmentDevice:YES
#endif
                   config:config];

    // Set the customizd tag thats config in your APP registerd on the  bugly.qq.com
    // [Bugly setTag:1799];

    [Bugly setUserIdentifier:[NSString stringWithFormat:@"User: %@", [UIDevice currentDevice].name]];

    [Bugly setUserValue:[NSProcessInfo processInfo].processName forKey:@"Process"];

}

- (void)setupTotalUnreadCount
{
    // 查询总的消息未读数
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance getTotalUnreadMessageCount:^(UInt64 totalCount) {
        NSNotification *notice = [NSNotification notificationWithName:TUIKitNotification_onTotalUnreadMessageCountChanged object:@(totalCount)];
        [weakSelf onTotalUnreadCountChanged:notice];
    } fail:^(int code, NSString *desc) {
        
    }];
}

- (void)registNotification
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onTotalUnreadCountChanged:) name:TUIKitNotification_onTotalUnreadMessageCountChanged object:nil];
}

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    _deviceToken = deviceToken;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    // 收到推送普通信息推送（普通消息推送设置代码请参考 TUIMessageController -> sendMessage）
    //普通消息推送格式（C2C）：
    //@"ext" :
    //@"{\"entity\":{\"action\":1,\"chatType\":1,\"content\":\"Hhh\",\"sendTime\":0,\"sender\":\"2019\",\"version\":1}}"
    //普通消息推送格式（Group）：
    //@"ext"
    //@"{\"entity\":{\"action\":1,\"chatType\":2,\"content\":\"Hhh\",\"sendTime\":0,\"sender\":\"@TGS#1PWYXLTGA\",\"version\":1}}"
    
    // 收到推送音视频推送（音视频推送设置代码请参考 TUICall+Signal -> sendAPNsForCall）
    //音视频通话推送格式（C2C）：
    //@"ext" :
    //@"{\"entity\":{\"action\":2,\"chatType\":1,\"content\":\"{\\\"action\\\":1,\\\"call_id\\\":\\\"144115224193193423-1595225880-515228569\\\",\\\"call_type\\\":1,\\\"code\\\":0,\\\"duration\\\":0,\\\"invited_list\\\":[\\\"10457\\\"],\\\"room_id\\\":1688911421,\\\"timeout\\\":30,\\\"timestamp\\\":0,\\\"version\\\":4}\",\"sendTime\":1595225881,\"sender\":\"2019\",\"version\":1}}"
    //音视频通话推送格式（Group）：
    //@"ext"
    //@"{\"entity\":{\"action\":2,\"chatType\":2,\"content\":\"{\\\"action\\\":1,\\\"call_id\\\":\\\"144115212826565047-1595506130-2098177837\\\",\\\"call_type\\\":2,\\\"code\\\":0,\\\"duration\\\":0,\\\"group_id\\\":\\\"@TGS#1BUBQNTGS\\\",\\\"invited_list\\\":[\\\"10457\\\"],\\\"room_id\\\":1658793276,\\\"timeout\\\":30,\\\"timestamp\\\":0,\\\"version\\\":4}\",\"sendTime\":1595506130,\"sender\":\"vinson1\",\"version\":1}}"
    NSLog(@"didReceiveRemoteNotification, %@", userInfo);
    NSDictionary *extParam = [TCUtil jsonSring2Dictionary:userInfo[@"ext"]];
    NSDictionary *entity = extParam[@"entity"];
    if (!entity) {
        return;
    }
    // 业务，action : 1 普通文本推送；2 音视频通话推送
    NSString *action = entity[@"action"];
    if (!action) {
        return;
    }
    // 聊天类型，chatType : 1 单聊；2 群聊
    NSString *chatType = entity[@"chatType"];
    if (!chatType) {
        return;
    }
    // action : 1 普通消息推送
    if ([action intValue] == APNs_Business_NormalMsg) {
        if ([chatType intValue] == 1) {   //C2C
            self.userID = entity[@"sender"];
        } else if ([chatType intValue] == 2) { //Group
            self.groupID = entity[@"sender"];
        }
        if ([[V2TIMManager sharedInstance] getLoginStatus] == V2TIM_STATUS_LOGINED) {
            [self onReceiveNomalMsgAPNs];
        }
    }
    // action : 2 音视频通话推送
    else if ([action intValue] == APNs_Business_Call) {
        // 单聊中的音视频邀请推送不需处理，APP 启动后，TUIkit 会自动处理
        if ([chatType intValue] == 1) {   //C2C
            return;
        }
        // 内容
        NSDictionary *content = [TCUtil jsonSring2Dictionary:entity[@"content"]];
        if (!content) {
            return;
        }
        UInt64 sendTime = [entity[@"sendTime"] integerValue];
        uint32_t timeout = [content[@"timeout"] intValue];
        UInt64 curTime = [[V2TIMManager sharedInstance] getServerTime];
        if (curTime - sendTime > timeout) {
            [THelper makeToast:@"通话接收超时"];
            return;
        }
        self.signalingInfo = [[V2TIMSignalingInfo alloc] init];
        self.signalingInfo.actionType = (SignalingActionType)[content[@"action"] intValue];
        self.signalingInfo.inviteID = content[@"call_id"];
        self.signalingInfo.inviter = entity[@"sender"];
        self.signalingInfo.inviteeList = content[@"invited_list"];
        self.signalingInfo.groupID = content[@"group_id"];
        self.signalingInfo.timeout = timeout;
        self.signalingInfo.data = [TCUtil dictionary2JsonStr:@{SIGNALING_EXTRA_KEY_ROOM_ID : content[@"room_id"], SIGNALING_EXTRA_KEY_VERSION : content[@"version"], SIGNALING_EXTRA_KEY_CALL_TYPE : content[@"call_type"]}];
        if ([[V2TIMManager sharedInstance] getLoginStatus] == V2TIM_STATUS_LOGINED) {
            [self onReceiveGroupCallAPNs];
        }
    }
}

- (void)onReceiveNomalMsgAPNs {
    NSLog(@"---> receive normal msg apns, groupId:%@, userId:%@", self.groupID, self.userID);
    // 异步处理，防止出现时序问题, 特别是当前正在登录操作中
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.groupID.length > 0 || weakSelf.userID.length > 0) {
            UITabBarController *tab = [app getMainController];
            if (![tab isKindOfClass: UITabBarController.class]) {
                // 正在登录中
                return;
            }
            if (tab.selectedIndex != 0) {
                [tab setSelectedIndex:0];
            }
            weakSelf.window.rootViewController = tab;
            UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
            if (![nav isKindOfClass:UINavigationController.class]) {
                return;
            }
            ConversationController *vc = (ConversationController *)nav.viewControllers.firstObject;
            if (![vc isKindOfClass:ConversationController.class]) {
                return;
            }
            [vc pushToChatViewController:weakSelf.groupID userID:weakSelf.userID];
            weakSelf.groupID = nil;
            weakSelf.userID = nil;
        }
    });
}

- (void)onReceiveGroupCallAPNs {
    NSLog(@"---> receive group call apns, signalingInfo:%@", self.signalingInfo);
    if (self.signalingInfo) {
        [[TUIKit sharedInstance] onReceiveGroupCallAPNs:self.signalingInfo];
        self.signalingInfo = nil;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIApplication.sharedApplication.applicationIconBadgeNumber = _unReadCount;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    UIApplication.sharedApplication.applicationIconBadgeNumber = _unReadCount;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


void uncaughtExceptionHandler(NSException*exception){
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@",[exception callStackSymbols]);
    // Internal error reporting
}

- (UIViewController *)getLoginController{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LoginController *login = [board instantiateViewControllerWithIdentifier:@"LoginController"];
    return login;
}

- (UITabBarController *)getMainController{
    TUITabBarController *tbc = [[TUITabBarController alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    TUITabBarItem *msgItem = [[TUITabBarItem alloc] init];
    msgItem.title = NSLocalizedString(@"TabBarItemMessageText", nil); //@"消息";
    msgItem.selectedImage = [UIImage imageNamed:@"session_selected"];
    msgItem.normalImage = [UIImage imageNamed:@"session_normal"];
    msgItem.controller = [[TNavigationController alloc] initWithRootViewController:[[ConversationController alloc] init]];
    msgItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [items addObject:msgItem];

    TUITabBarItem *contactItem = [[TUITabBarItem alloc] init];
    contactItem.title = NSLocalizedString(@"TabBarItemContactText", nil);
    contactItem.selectedImage = [UIImage imageNamed:@"contact_selected"];
    contactItem.normalImage = [UIImage imageNamed:@"contact_normal"];
    contactItem.controller = [[TNavigationController alloc] initWithRootViewController:[[ContactsController alloc] init]];
    contactItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [items addObject:contactItem];
    // 直播Tab添加
    TUITabBarItem *sceneItem = [[TUITabBarItem alloc] init];
    sceneItem.title = NSLocalizedString(@"TabBarItemLiveText", nil);
    sceneItem.selectedImage = [UIImage imageNamed:@"live_broadcast_camera_on"];
    sceneItem.normalImage = [UIImage imageNamed:@"live_broadcast_camera_off"];
    sceneItem.controller = [[TNavigationController alloc] initWithRootViewController:[[TUILiveSceneViewController alloc] init]];
    sceneItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [items addObject:sceneItem];
    
    TUITabBarItem *setItem = [[TUITabBarItem alloc] init];
    setItem.title = NSLocalizedString(@"TabBarItemMeText", nil);
    setItem.selectedImage = [UIImage imageNamed:@"myself_selected"];
    setItem.normalImage = [UIImage imageNamed:@"myself_normal"];
    setItem.controller = [[TNavigationController alloc] initWithRootViewController:[[SettingController alloc] init]];
    setItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [items addObject:setItem];
    tbc.tabBarItems = items;

    return tbc;
}

- (void)onTotalUnreadCountChanged:(NSNotification *)notice
{
    id object = notice.object;
    if (![object isKindOfClass:NSNumber.class]) {
        return;
    }
    NSUInteger total = [object integerValue];
    TUITabBarController *tab = (TUITabBarController *)UIApplication.sharedApplication.keyWindow.rootViewController;
    if (![tab isKindOfClass:TUITabBarController.class]) {
        return;
    }
    TUITabBarItem *item = tab.tabBarItems.firstObject;
    item.controller.tabBarItem.badgeValue = total ? [NSString stringWithFormat:@"%@", total > 99 ? @"99+" : @(total)] : nil;
    _unReadCount = total;
}

- (void)onUserStatus:(NSNotification *)notification
{
    TUIUserStatus status = [notification.object integerValue];
    switch (status) {
        case TUser_Status_ForceOffline:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"下线通知" message:@"您的帐号于另一台手机上登录。" delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"重新登录", nil];
            [alertView show];
        }
            break;
        case TUser_Status_ReConnFailed:
        {
            NSLog(@"连网失败");
        }
            break;
        case TUser_Status_SigExpired:
        {
            NSLog(@"userSig过期");
        }
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // 退出
        [[V2TIMManager sharedInstance] logout:^{
            NSLog(@"登出成功！");
        } fail:^(int code, NSString *msg) {
            NSLog(@"退出登录");
        }];
        self.window.rootViewController = [self getLoginController];
    }
    else
    {
        // 重新登录
        [[TUILocalStorage sharedInstance] login:^(NSString * _Nonnull identifier, NSUInteger appId, NSString * _Nonnull userSig) {
            [self login:identifier userSig:userSig succ:^{
                NSLog(@"登录成功！");
                self.window.rootViewController = [self getMainController];
            } fail:^(int code, NSString *msg) {
                NSLog(@"登录失败！");
                self.window.rootViewController = [self getLoginController];
            }];
        }];
    }
}

@end
