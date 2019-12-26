#import "AppDelegate.h"
#import "TNavigationController.h"
#import "ConversationController.h"
#import "SettingController.h"
#import "ContactsController.h"
#import "LoginController.h"
#import "TUITabBarController.h"
#import "TUIKit.h"
#import "THeader.h"
#import "ImSDK.h"
#import "GenerateTestUserSig.h"
#import <Bugly/Bugly.h>

@interface AppDelegate () <BuglyDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
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
        TIMLoginParam *param = [[TIMLoginParam alloc] init];
        param.identifier = identifier;
        param.userSig = userSig;
        [[TIMManager sharedInstance] login:param succ:^{
            if (ws.deviceToken) {
                TIMTokenParam *param = [[TIMTokenParam alloc] init];
                /* 用户自己到苹果注册开发者证书，在开发者帐号中下载并生成证书(p12 文件)，将生成的 p12 文件传到腾讯证书管理控制台，控制台会自动生成一个证书 ID，将证书 ID 传入一下 busiId 参数中。*/
                //企业证书 ID
                param.busiId = sdkBusiId;
                [param setToken:ws.deviceToken];
                [[TIMManager sharedInstance] setToken:param succ:^{
                    NSLog(@"-----> 上传 token 成功 ");
                    //推送声音的自定义化设置
                    TIMAPNSConfig *config = [[TIMAPNSConfig alloc] init];
                    config.openPush = 0;
                    config.c2cSound = @"00.caf";
                    config.groupSound = @"01.caf";
                    [[TIMManager sharedInstance] setAPNS:config succ:^{
                        NSLog(@"-----> 设置 APNS 成功");
                    } fail:^(int code, NSString *msg) {
                        NSLog(@"-----> 设置 APNS 失败");
                    }];
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
    _deviceToken = deviceToken;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    __block UIBackgroundTaskIdentifier bgTaskID;
    bgTaskID = [application beginBackgroundTaskWithExpirationHandler:^ {
        //不管有没有完成，结束 background_task 任务
        [application endBackgroundTask: bgTaskID];
        bgTaskID = UIBackgroundTaskInvalid;
    }];
    
    //获取未读计数
    int unReadCount = 0;
    NSArray *convs = [[TIMManager sharedInstance] getConversationList];
    for (TIMConversation *conv in convs) {
        if([conv getType] == TIM_SYSTEM){
            continue;
        }
        unReadCount += [conv getUnReadMessageNum];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = unReadCount;
    
    //doBackground
    TIMBackgroundParam  *param = [[TIMBackgroundParam alloc] init];
    [param setC2cUnread:unReadCount];
    [[TIMManager sharedInstance] doBackground:param succ:^() {
        NSLog(@"doBackgroud Succ");
    } fail:^(int code, NSString * err) {
        NSLog(@"Fail: %d->%@", code, err);
    }];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[TIMManager sharedInstance] doForeground:^() {
        NSLog(@"doForegroud Succ");
    } fail:^(int code, NSString * err) {
        NSLog(@"Fail: %d->%@", code, err);
    }];
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
            TIMLoginParam *param = [[TIMLoginParam alloc] init];
            param.identifier = identifier;
            param.userSig = userSig;
            [[TIMManager sharedInstance] login:param succ:^{
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


