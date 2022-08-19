//
//  AppDelegate.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "AppDelegate.h"
#import "ConversationController.h"
#import "SettingController.h"
#import "ContactsController.h"
#import "TUIDefine.h"
#import "TUIKit.h"
#import "Aspects.h"
#import "TCUtil.h"
#import "TCLoginModel.h"

#if ENABLELIVE
#import "TRTCSignalFactory.h"
@import TXLiteAVSDK_TRTC;
#endif

#import "TUIBaseChatViewController.h"
#import "TUIBadgeView.h"
#import "AppDelegate+Redpoint.h"
#import "ThemeSelectController.h"
#import "TUIThemeManager.h"
#import "LanguageSelectController.h"
#import "TUILogin.h"
#import "TUIChatConfig.h"
#import "TUIWarningView.h"

@interface AppDelegate () <V2TIMConversationListener, TUILoginListener, ThemeSelectControllerDelegate, LanguageSelectControllerDelegate,V2TIMAPNSListener>

@end

@implementation AppDelegate


#pragma mark - 推送的配置及统一跳转

/**
 * APNs 证书 ID 配置
 * APNs certificate ID configuration
 */
TUIOfflinePushCertificateIDForAPNS(kAPNSBusiId)

/**
 * TPNS 自定义域名、key 配置
 * TPNS custom domain name, key configuration
 */
TUIOfflinePushConfigForTPNS(kTPNSAccessID, kTPNSAccessKey, kTPNSDomain)

/**
 * 统一点击跳转
 * Click the notification bar to jump
 */
- (void)navigateToTUIChatViewController:(NSString *)userID groupID:(NSString *)groupID
{
    UITabBarController *tab = [self getMainController];
    if (![tab isKindOfClass: UITabBarController.class]) {
        // 正在登录中
        return;
    }
    if (tab.selectedIndex != 0) {
        [tab setSelectedIndex:0];
    }
    self.window.rootViewController = tab;
    UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
    if (![nav isKindOfClass:UINavigationController.class]) {
        return;
    }

    UIViewController *vc = nav.viewControllers.firstObject;
    if (![vc isKindOfClass:NSClassFromString(@"ConversationController")]) {
        return;
    }
    if ([vc respondsToSelector:NSSelectorFromString(@"pushToChatViewController:userID:")]) {
        [vc performSelector:NSSelectorFromString(@"pushToChatViewController:userID:") withObject:groupID withObject:userID];
    }
}

#pragma mark - Life cycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    app = self;

    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    TUIRegisterThemeResourcePath([NSBundle.mainBundle pathForResource:@"TUIDemoTheme.bundle" ofType:nil], TUIThemeModuleDemo);
    [ThemeSelectController applyLastTheme];
        
    [self setupListener];
    [self setupGlobalUI];
    [self setupConfig];
    [self tryAutoLogin];
    
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}
#pragma mark - Public
+ (instancetype)sharedInstance {
    return app;
}

- (UIViewController *)getLoginController {
   UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
   LoginController *login = [board instantiateViewControllerWithIdentifier:@"LoginController"];
   UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
   return nav;
}

- (void)loginSDK:(NSString *)userID userSig:(NSString *)sig succ:(TSucc)succ fail:(TFail)fail {
    [TUILogin login:SDKAPPID userID:userID userSig:sig succ:^{
        [self redpoint_setupTotalUnreadCount];
        self.window.rootViewController = [self getMainController];
        [TUITool makeToast:NSLocalizedString(@"AppLoginSucc", nil) duration:1];
        if (succ) {
            succ();
        }
    } fail:^(int code, NSString *msg) {
        self.window.rootViewController = [self getLoginController];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
        if (fail) {
            fail(code, msg);
        }
    }];
}

- (UITabBarController *)getMainController {
    TUITabBarController *tbc = [[TUITabBarController alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    TUITabBarItem *msgItem = [[TUITabBarItem alloc] init];
    msgItem.title = NSLocalizedString(@"TabBarItemMessageText", nil);
    msgItem.selectedImage = TUIDemoDynamicImage(@"tab_msg_selected_img", [UIImage imageNamed:@"session_selected"]);
    msgItem.normalImage = TUIDemoDynamicImage(@"tab_msg_normal_img", [UIImage imageNamed:@"session_normal"]);
    msgItem.controller = [[TUINavigationController alloc] initWithRootViewController:[[ConversationController alloc] init]];
    msgItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    msgItem.badgeView = [[TUIBadgeView alloc] init];
    @weakify(self)
    msgItem.badgeView.clearCallback = ^{
        @strongify(self)
        [self redpoint_clearUnreadMessage];
    };
    [items addObject:msgItem];

    TUITabBarItem *contactItem = [[TUITabBarItem alloc] init];
    contactItem.title = NSLocalizedString(@"TabBarItemContactText", nil);
    contactItem.selectedImage = TUIDemoDynamicImage(@"tab_contact_selected_img", [UIImage imageNamed:@"contact_selected"]);
    contactItem.normalImage = TUIDemoDynamicImage(@"tab_contact_normal_img", [UIImage imageNamed:@"contact_normal"]);
    contactItem.controller = [[TUINavigationController alloc] initWithRootViewController:[[ContactsController alloc] init]];
    contactItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    contactItem.badgeView = [[TUIBadgeView alloc] init];
    [items addObject:contactItem];
    
    TUITabBarItem *setItem = [[TUITabBarItem alloc] init];
    setItem.title = NSLocalizedString(@"TabBarItemMeText", nil);
    setItem.selectedImage = TUIDemoDynamicImage(@"tab_me_selected_img", [UIImage imageNamed:@"myself_selected"]);
    setItem.normalImage = TUIDemoDynamicImage(@"tab_me_normal_img", [UIImage imageNamed:@"myself_normal"]);
    setItem.controller = [[TUINavigationController alloc] initWithRootViewController:[[SettingController alloc] init]];
    setItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [items addObject:setItem];
    tbc.tabBarItems = items;

    return tbc;
}



#pragma mark - Private
- (void)setupListener {
    [TUILogin addLoginListener:self];
    [[V2TIMManager sharedInstance] addConversationListener:self];
    [[V2TIMManager sharedInstance] setAPNSListener:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMarkUnreadCount:) name:TUIKitNotification_onConversationMarkUnreadCountChanged object:nil];
}

void uncaughtExceptionHandler(NSException*exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@",[exception callStackSymbols]);
    // Internal error reporting
}

- (void)tryAutoLogin {
    self.window.rootViewController = [self getLoginController];
    [[TCLoginModel sharedInstance] getAccessAddressWithSucceedBlock:^(NSDictionary *data) {
        [self autoLoginIfNeeded];
    } failBlock:^(NSInteger errorCode, NSString *errorMsg) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[TCLoginModel sharedInstance] getAccessAddressWithSucceedBlock:^(NSDictionary *data) {
                [self autoLoginIfNeeded];
            } failBlock:^(NSInteger errorCode, NSString *errorMsg) {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
            }];
        });
    }];
}

- (void)autoLoginIfNeeded {
    @weakify(self)
    [[TCLoginModel sharedInstance] autoLoginWithSucceedBlock:^(NSDictionary *data) {
        @strongify(self)
        NSString *userSig = data[@"sdkUserSig"];
        NSString *userID = data[@"userId"];
        if (userID.length != 0 && userSig.length != 0) {
            [self loginSDK:userID userSig:userSig succ:nil fail:nil];
        } else {
            self.window.rootViewController = [self getLoginController];
            [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
        }
    } failBlock:^(NSInteger errorCode, NSString *errorMsg) {
        @strongify(self)
        self.window.rootViewController = [self getLoginController];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
    }];
}

- (void)setupConfig {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kEnableMsgReadStatus]) {
        TUIChatConfig.defaultConfig.msgNeedReadReceipt = [[NSUserDefaults standardUserDefaults] boolForKey:kEnableMsgReadStatus];
    } else {
        TUIChatConfig.defaultConfig.msgNeedReadReceipt = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kEnableMsgReadStatus];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    TUIConfig.defaultConfig.displayOnlineStatusIcon = [[NSUserDefaults standardUserDefaults] boolForKey:kEnableOnlineStatus];
}

#pragma mark -- Setup UI
- (void)setupGlobalUI {
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
    
    [self setupChatSecurityWarningView];
}

- (void)setupChatSecurityWarningView {
    NSString *tips = NSLocalizedString(@"ChatSecurityWarning", nil);
    NSString *buttonTitle = NSLocalizedString(@"ChatSecurityWarningReport", nil);
    TUIWarningView *tipsView = [[TUIWarningView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 0)
                                                                tips:tips
                                                         buttonTitle:buttonTitle
                                                        buttonAction:^{
        NSURL *url = [NSURL URLWithString:@"https://cloud.tencent.com/apply/p/xc3oaubi98g"];
        [TUITool openLinkWithURL:url];
    }];
    [TUIBaseChatViewController setCustomTopView:tipsView];
}

#pragma mark - V2TIMConversationListener
- (void)onTotalUnreadMessageCountChanged:(UInt64) totalUnreadCount {
    NSLog(@"%s, totalUnreadCount:%llu", __func__, totalUnreadCount);
}

#pragma mark - TUILoginListener
- (void)onConnecting {
    
}

- (void)onConnectSuccess {
    
}

- (void)onConnectFailed:(int)code err:(NSString *)err {
    
}

- (void)onUserSigExpired {
    [self onUserStatus:TUser_Status_SigExpired];
}

- (void)onKickedOffline {
    [self onUserStatus:TUser_Status_ForceOffline];
}

- (TUIContactViewDataProvider *)contactDataProvider
{
    if (_contactDataProvider == nil) {
        _contactDataProvider = [[TUIContactViewDataProvider alloc] init];
    }
    return _contactDataProvider;
}

- (void)onUserStatus:(TUIUserStatus)status {
    switch (status) {
        case TUser_Status_ForceOffline:
        {
            [self showKickOffAlert];
        }
            break;
        case TUser_Status_ReConnFailed:
        {
            NSLog(@"%s, status:%zd", __func__, status);
        }
            break;
        case TUser_Status_SigExpired:
        {
            NSLog(@"%s, status:%zd", __func__, status);
        }
            break;
        default:
            break;
    }
}

- (void)showKickOffAlert {
    [self showAlertWithTitle:NSLocalizedString(@"AppOfflineTitle", nil) message:NSLocalizedString(@"AppOfflineDesc", nil) cancelAction:^(UIAlertAction *action, NSString *content) {
        [TUILogin logout:^{
            NSLog(@"logout sdk succeed");
        } fail:^(int code, NSString *msg) {
            NSLog(@"logout sdk failed, code: %ld, msg: %@", (long)code, msg);
        }];
        self.window.rootViewController = [self getLoginController];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
    } confirmAction:^(UIAlertAction *action, NSString *content) {
        NSString *userID = [TCLoginModel sharedInstance].userID;
        NSString *userSig = [TCLoginModel sharedInstance].userSig;
        [self loginSDK:userID userSig:userSig succ:^{
            NSLog(@"relogin sdk succeed");
            self.window.rootViewController = [self getMainController];
        } fail:^(int code, NSString *msg) {
            NSLog(@"relogin sdk failed, code: %ld, msg: %@", (long)code, msg);
            self.window.rootViewController = [self getLoginController];
            [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
        }];
    }];
}

#pragma mark - LanguageSelectControllerDelegate
- (void)onSelectLanguage:(LanguageSelectCellModel *)cellModel {
    /**
     * 动态刷新语言的方法: 销毁当前界面，并重新创建后跳转来实现动态刷新语言
     * The method of dynamically refreshing the language: Destroy the current interface, and recreate it and then jump to realize dynamic refreshing of the language
     */
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"need_recover_login_page_info"];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    /**
     * 1. 重新创建登录控制器以及根导航控制器
     * 1. Recreate the login controller as well as the root navigation controller
     */
    UIViewController *loginVc = [self getLoginController];
    UINavigationController *navVc = nil;
    if ([loginVc isKindOfClass:UINavigationController.class]) {
        navVc = (UINavigationController *)loginVc;
    } else {
        navVc = loginVc.navigationController;
    }
    if (navVc == nil) {
        return;
    }
    
    /**
     * 2. 创建语言选择页面，并 push
     * 2. Create a language selection page and push
     */
    LanguageSelectController *languageVc = [[LanguageSelectController alloc] init];
    languageVc.delegate = self;
    [navVc pushViewController:languageVc animated:NO];
    
    /**
     * 3. 切换根控制器
     * 3. Switch root controller
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication.sharedApplication.keyWindow.rootViewController = navVc;
    });
    
    /**
     * 4. 重新配置安全警告视图
     * 4. Recofig the security warning view in ChatVC
     */
    [self setupChatSecurityWarningView];
}

#pragma mark - ThemeSelectControllerDelegate
- (void)onSelectTheme:(ThemeSelectCollectionViewCellModel *)cellModel {
    /**
     * 动态刷新主题的方法: 销毁当前界面，并重新创建后跳转来实现动态刷新主题
     * The method of dynamically refreshing the theme: Destroy the current interface, and recreate it and then jump to realize the dynamic refresh theme
     */
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"need_recover_login_page_info"];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    /**
     * 1. 重新创建登录控制器以及根导航控制器
     * 1. Recreate the login controller and root navigation controller
     */
    UIViewController *loginVc = [self getLoginController];
    UINavigationController *navVc = nil;
    if ([loginVc isKindOfClass:UINavigationController.class]) {
        navVc = (UINavigationController *)loginVc;
    } else {
        navVc = loginVc.navigationController;
    }
    if (navVc == nil) {
        return;
    }
    
    /**
     * 2. 创建主题选择控制器并 push
     * 2. Create a theme selection controller and push
     */
    ThemeSelectController *themeVc = [[ThemeSelectController alloc] init];
    themeVc.disable = YES;
    themeVc.delegate = self;
    [themeVc.view makeToastActivity:TUICSToastPositionCenter];
    [navVc pushViewController:themeVc animated:NO];
    
    /**
     * 3. 切换根控制器
     * 3. Switch root controller
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication.sharedApplication.keyWindow.rootViewController = navVc;
        if (@available(iOS 13.0, *)) {
            if ([cellModel.themeID isEqual:@"system"]) {
                // Follow system settings
                UIApplication.sharedApplication.keyWindow.overrideUserInterfaceStyle = 0;
            } else if ([cellModel.themeID isEqual:@"dark"]) {
                // Forced switch to drak mode
                UIApplication.sharedApplication.keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
            } else {
                /**
                 * 忽略系统的设置，强制修改成白天模式，并应用当前的主题
                 * Ignoring system settings, forced switch to light mode, and apply the current theme
                 */
                UIApplication.sharedApplication.keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        }
        [themeVc.view hideToastActivity];
        themeVc.disable = NO;
    });
}

#pragma mark - NSNotification

- (void)updateMarkUnreadCount:(NSNotification *)note {}

#pragma mark - Other
typedef void (^cancelHandler)(UIAlertAction *action, NSString *content);
typedef void (^confirmHandler)(UIAlertAction *action, NSString *content);
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelAction:(cancelHandler)cancelHandler confirmAction:(confirmHandler)confirmHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"AppCancelRelogin", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelHandler) {
            cancelHandler(action, nil);
        }
    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"AppConfirmRelogin", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (confirmHandler) {
            confirmHandler(action, nil);
        }
    }];
    
    [alertController addAction:cancel];
    [alertController addAction:confirm];
    
    [self.window.rootViewController presentViewController:alertController animated:NO completion:nil];
}

@end
