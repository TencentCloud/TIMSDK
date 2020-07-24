#import "AppDelegate.h"
#import "TNavigationController.h"
#import "ConversationController.h"
#import "SettingController.h"
#import "ContactsController.h"
#import "LoginController.h"
#import "TUITabBarController.h"
#import "TUIKit.h"
#import "THeader.h"
#import "TCUtil.h"
#import "THelper.h"
#import "GenerateTestUserSig.h"
#import "ImSDK.h"
#import <Bugly/Bugly.h>

@interface AppDelegate () <BuglyDelegate>
@property(nonatomic,strong) NSString *groupID;
@property(nonatomic,strong) NSString *userID;
@property(nonatomic,strong) V2TIMSignalingInfo *signalingInfo;
@end

static AppDelegate *app;

@implementation AppDelegate

+ (instancetype)sharedInstance {
    return app;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    app = self;
    
    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserStatus:) name:TUIKitNotification_TIMUserStatusListener object:nil];
    
    [self setupBugly];
    [self registNotification];
    
    //_SDKAppID 填写自己控制台申请的sdkAppid
    if (SDKAPPID == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo 尚未配置 SDKAPPID，请前往 GenerateTestUserSig.h 配置" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        [[TUIKit sharedInstance] setupWithAppId:SDKAPPID];
    }
    
    NSNumber *appId = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_Appid];
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_User];
    //NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_Pwd];
    NSString *userSig = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_Sig];
    if([appId integerValue] == SDKAPPID && identifier.length != 0 && userSig.length != 0){
        __weak typeof(self) ws = self;
        [[TUIKit sharedInstance] login:identifier userSig:userSig succ:^{
            if (ws.deviceToken) {
                /* 用户自己到苹果注册开发者证书，在开发者帐号中下载并生成证书(p12 文件)，将生成的 p12 文件传到腾讯证书管理控制台，控制台会自动生成一个证书 ID，将证书 ID 传入一下 busiId 参数中。*/
                //企业证书 ID
                V2TIMAPNSConfig *confg = [[V2TIMAPNSConfig alloc] init];
                /* 用户自己到苹果注册开发者证书，在开发者帐号中下载并生成证书(p12 文件)，将生成的 p12 文件传到腾讯证书管理控制台，控制台会自动生成一个证书 ID，将证书 ID 传入一下 busiId 参数中。*/
                //企业证书 ID
                confg.businessID = sdkBusiId;
                confg.token = self.deviceToken;
                [[V2TIMManager sharedInstance] setAPNS:confg succ:^{
                     NSLog(@"-----> 设置 APNS 成功");
                } fail:^(int code, NSString *msg) {
                     NSLog(@"-----> 设置 APNS 失败");
                }];
                //普通消息推送
                [self onReceiveNomalMsgAPNs];
                //音视频消息推送
                [self onReceiveGroupCallAPNs];
            }
            ws.window.rootViewController = [self getMainController];
        } fail:^(int code, NSString *msg) {
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:Key_UserInfo_Appid];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_User];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_Pwd];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_Sig];
            ws.window.rootViewController = [self getLoginController];
        }];
    }
    else{
        _window.rootViewController = [self getLoginController];
    }
    return YES;
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
    config.version = [[TIMManager sharedInstance] GetVersion];
    
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
}

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 需要在 Xcode 把 Push Notifications打开
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
        UInt64 curTime = (UInt64)[[NSDate date] timeIntervalSince1970];
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
    if (self.groupID.length > 0 || self.userID.length > 0) {
        UITabBarController *tab = [app getMainController];
        if (tab.selectedIndex != 0) {
            [tab setSelectedIndex:0];
        }
        self.window.rootViewController = tab;
        UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
        ConversationController *vc = (ConversationController *)nav.viewControllers.firstObject;
        [vc pushToChatViewController:self.groupID userID:self.userID];
        self.groupID = nil;
        self.userID = nil;
    }
}

- (void)onReceiveGroupCallAPNs {
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
    // to do
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // to do
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
    msgItem.title = @"消息";
    msgItem.selectedImage = [UIImage imageNamed:TUIKitResource(@"message_pressed")];
    msgItem.normalImage = [UIImage imageNamed:TUIKitResource(@"message_normal")];
    msgItem.controller = [[TNavigationController alloc] initWithRootViewController:[[ConversationController alloc] init]];
    [items addObject:msgItem];
    
    TUITabBarItem *contactItem = [[TUITabBarItem alloc] init];
    contactItem.title = @"通讯录";
    contactItem.selectedImage = [UIImage imageNamed:TUIKitResource(@"contacts_pressed")];
    contactItem.normalImage = [UIImage imageNamed:TUIKitResource(@"contacts_normal")];
    contactItem.controller = [[TNavigationController alloc] initWithRootViewController:[[ContactsController alloc] init]];
    [items addObject:contactItem];
    
    TUITabBarItem *setItem = [[TUITabBarItem alloc] init];
    setItem.title = @"我";
    setItem.selectedImage = [UIImage imageNamed:TUIKitResource(@"setting_pressed")];
    setItem.normalImage = [UIImage imageNamed:TUIKitResource(@"setting_normal")];
    setItem.controller = [[TNavigationController alloc] initWithRootViewController:[[SettingController alloc] init]];
    [items addObject:setItem];
    tbc.tabBarItems = items;
    
    return tbc;
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


/**
 *强制下线后的响应函数委托
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        LoginController *login = [board instantiateViewControllerWithIdentifier:@"LoginController"];
        self.window.rootViewController = login;
    }else if(buttonIndex == 1){
        /****此处未提供reLogin接口，而是直接使用保存在本地的数据登录，仅适用于Demo体验版本****/
        NSNumber *appId = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_Appid];
        NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_User];
        NSString *userSig = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_Sig];
        if([appId integerValue] == SDKAPPID && identifier.length != 0 && userSig.length != 0){
            __weak typeof(self) ws = self;
            [[TUIKit sharedInstance] login:identifier userSig:userSig succ:^{
                if (ws.deviceToken) {
                    TIMTokenParam *param = [[TIMTokenParam alloc] init];
                    /* 用户自己到苹果注册开发者证书，在开发者帐号中下载并生成证书(p12 文件)，将生成的 p12 文件传到腾讯证书管理控制台，控制台会自动生成一个证书 ID，将证书 ID 传入一下 busiId 参数中。*/
                    //企业证书 ID
                    param.busiId = sdkBusiId;
                    [param setToken:ws.deviceToken];
                    [[TIMManager sharedInstance] setToken:param succ:^{
                        NSLog(@"-----> 上传 token 成功 ");
                    } fail:^(int code, NSString *msg) {
                        NSLog(@"-----> 上传 token 失败 ");
                    }];
                }
                ws.window.rootViewController = [self getMainController];
            } fail:^(int code, NSString *msg) {
                [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:Key_UserInfo_Appid];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_User];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_Pwd];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_Sig];
                ws.window.rootViewController = [self getLoginController];
            }];
        }
        else{
            _window.rootViewController = [self getLoginController];
        }
    }
}

@end


