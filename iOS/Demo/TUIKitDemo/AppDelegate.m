//
//  AppDelegate.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "AppDelegate.h"
#import "ConversationController.h"
#import "SettingController.h"
#import "ContactsController.h"
#import "TUIDefine.h"
#import "TUIKit.h"
#import "Aspects.h"
#import "TUIUtil.h"
#import "TCLoginModel.h"

#if ENABLELIVE
#import "TRTCSignalFactory.h"
@import TXLiteAVSDK_TRTC;
#endif

#import "TUIBaseChatViewController.h"
#import "TUIBadgeView.h"
#import "AppDelegate+Redpoint.h"
#import "TUIThemeSelectController.h"
#import "TUIThemeManager.h"
#import "TUILanguageSelectController.h"
#import "TUILogin.h"
#import "TUIChatConfig.h"
#import "TUIWarningView.h"
#import "TUICallingHistoryViewController.h"
#import "TIMDefine.h"
#import "UIView+TUILayout.h"
#import "OfflinePushExtInfo.h"

//Minimalist
#import "ConversationController_Minimalist.h"
#import "ContactsController_Minimalist.h"
#import "SettingController_Minimalist.h"
//Minimalist

#if __has_include(<TIMPush/TIMPushManager.h>)
    #import <TIMPush/TIMPushManager.h>
#elif __has_include(<TPush/TIMPushManager.h>)
    #import <TPush/TIMPushManager.h>
#endif
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <V2TIMConversationListener, TUILoginListener, TUIThemeSelectControllerDelegate, TUILanguageSelectControllerDelegate,V2TIMAPNSListener, TIMPushDelegate, V2TIMSDKListener>

@property (nonatomic, strong) TUIContactViewDataProvider *contactDataProvider;
@property (nonatomic, strong) TUILoginConfig *loginConfig;
@property (nonatomic, weak) TUITabBarItem *callsRecordItem;

@property (nonatomic, strong) UITabBarController *preloadMainVC;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userSig;
@end

@implementation AppDelegate

#pragma mark - Life cycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    app = self;
    self.lastLoginResultCode = 0;

    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    TUIRegisterThemeResourcePath(TUIDemoThemePath, TUIThemeModuleDemo);
    [TUIThemeSelectController applyLastTheme];
    [self setupListener];
    [self setupGlobalUI];
    [self setupConfig];
    [self tryPreloadMainVC];
    [self tryAutoLogin];
    
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

- (UIInterfaceOrientationMask )application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}
- (void)startFullScreen {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
    if (@available(iOS 16.0, *)) {
        UIWindowScene *windowScene =
            (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
        for (UIWindow *windows in windowScene.windows) {
            if ([windows.rootViewController respondsToSelector:NSSelectorFromString(@"setNeedsUpdateOfSupportedInterfaceOrientations")]) {
                [windows.rootViewController performSelector:NSSelectorFromString(@"setNeedsUpdateOfSupportedInterfaceOrientations")];
            }
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)endFullScreen {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
 
    
    if (@available(iOS 16.0, *)) {
        @try {
            NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
            UIWindowScene *ws = (UIWindowScene *)array[0];
            Class GeometryPreferences = NSClassFromString(@"UIWindowSceneGeometryPreferencesIOS");
            id geometryPreferences = [[GeometryPreferences alloc]init];
            [geometryPreferences setValue:@(UIInterfaceOrientationMaskPortrait) forKey:@"interfaceOrientations"];
            SEL sel_method = NSSelectorFromString(@"requestGeometryUpdateWithPreferences:errorHandler:");
            void (^ErrorBlock)(NSError *err) = ^(NSError *err){};
            if ([ws respondsToSelector:sel_method]) {
                (((void (*)(id, SEL,id,id))[ws methodForSelector:sel_method])(ws, sel_method,geometryPreferences,ErrorBlock));
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    else {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            @try {
                SEL selector = NSSelectorFromString(@"setOrientation:");
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
                [invocation setSelector:selector];
                [invocation setTarget:[UIDevice currentDevice]];
                int val = UIInterfaceOrientationPortrait;
                [invocation setArgument:&val atIndex:2];
                [invocation invoke];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    }
}

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

- (void)applyPrivateBasicInfo {
    // Subclass override
}

- (void)tryPreloadMainVC {
    [[TCLoginModel sharedInstance] loadIsDirectlyLogin];
    [[TCLoginModel sharedInstance] loadLastLoginInfo];
    self.userID = [TCLoginModel sharedInstance].userID;
    self.userSig = [TCLoginModel sharedInstance].userSig;
    if (!self.userID || !self.userSig) {
        self.window.rootViewController = [self getLoginController];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
        return;
    }
    [self applyPrivateBasicInfo];

    self.preloadMainVC = [self getMainController];
    
    TUILoginConfig *config = [[TUILoginConfig alloc] init];
    config.initLocalStorageOnly = YES;
    @weakify(self)
    [TUILogin login:SDKAPPID userID:self.userID userSig:self.userSig config:config succ:^{
      @strongify(self)
      self.window.rootViewController = self.preloadMainVC;
      [self redpoint_setupTotalUnreadCount];
    } fail:^(int code, NSString * _Nullable msg) {
      NSLog(@"%@", [NSString stringWithFormat:@"preloadMainController failed, code:%d desc:%@", code, msg]);
    }];
}

- (void)loginSDK:(NSString *)userID userSig:(NSString *)sig succ:(TSucc)succ fail:(TFail)fail {
    self.userID = userID;
    self.userSig = sig;
    [TUILogin login:SDKAPPID userID:self.userID userSig:self.userSig config:self.loginConfig succ:^{
        if (self.preloadMainVC && [self.window.rootViewController isEqual:self.preloadMainVC]) {
            // main vc has load
        } else {
            self.window.rootViewController = [self getMainController];
        }
        [self redpoint_setupTotalUnreadCount];
        [TUITool makeToast:NSLocalizedString(@"AppLoginSucc", nil) duration:1];
        if (succ) {
            succ();
        }
    } fail:^(int code, NSString *msg) {
        self.lastLoginResultCode = code;
        self.window.rootViewController = [self getLoginController];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
        if (fail) {
            fail(code, msg);
        }
    }];
}

#pragma mark - Private
- (void)setupListener {
    [TUILogin addLoginListener:self];
    [[V2TIMManager sharedInstance] addIMSDKListener:self];
    [[V2TIMManager sharedInstance] addConversationListener:self];
    [[V2TIMManager sharedInstance] setAPNSListener:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMarkUnreadCount:) name:TUIKitNotification_onConversationMarkUnreadCountChanged object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onLogoutSucc) name:TUILogoutSuccessNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onDisplayCallsRecordForMinimalist:) name:kEnableCallsRecord_mini object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onDisplayCallsRecordForClassic:) name:kEnableCallsRecord object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(startFullScreen) name:kEnableAllRotationOrientationNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(endFullScreen) name:kDisableAllRotationOrientationNotification object:nil];
}

void uncaughtExceptionHandler(NSException*exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@",[exception callStackSymbols]);
    // Internal error reporting
}

- (void)tryAutoLogin {
    [self loginSDK:[TCLoginModel sharedInstance].userID userSig:[TCLoginModel sharedInstance].userSig succ:nil fail:nil];
}

- (void)onLogoutSucc {
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
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
    NSString *gotButtonTitle = NSLocalizedString(@"ChatSecurityWarningGot", nil);

    __block TUIWarningView *tipsView = [[TUIWarningView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 0)
                                                                tips:tips
                                                         buttonTitle:buttonTitle
                                                        buttonAction:^{
        NSURL *url = [NSURL URLWithString:@"https://cloud.tencent.com/act/event/report-platform"];
        [TUITool openLinkWithURL:url];
    }
                                                      gotButtonTitle:gotButtonTitle gotButtonAction:^{
        tipsView.frame = CGRectZero;;
        [tipsView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:TUICore_TUIChatExtension_ChatViewTopArea_ChangedNotification object:nil];
    
    }];
    [TUIBaseChatViewController setCustomTopView:tipsView];
}

- (TUILoginConfig *)loginConfig {
    if (!_loginConfig) {
        _loginConfig = [[TUILoginConfig alloc] init];
#if DEBUG
        _loginConfig.logLevel = TUI_LOG_DEBUG;
#else
        _loginConfig.logLevel = TUI_LOG_INFO;
#endif
        @weakify(self);
        _loginConfig.onLog = ^(NSInteger logLevel, NSString *logContent) {
            @strongify(self);
            [self onLog:logLevel logContent:logContent];
        };
    }
    return _loginConfig;
}

#pragma mark - V2TIMConversationListener
- (void)onTotalUnreadMessageCountChanged:(UInt64) totalUnreadCount {
    NSLog(@"%s, totalUnreadCount:%llu", __func__, totalUnreadCount);
}

#pragma mark V2TIMSDKListener
- (void)onConnectSuccess {
    BOOL lastLoginIsNetworkError = (self.lastLoginResultCode >= 9501 && self.lastLoginResultCode <= 9525);
    if (V2TIM_STATUS_LOGOUT == [[V2TIMManager sharedInstance] getLoginStatus]
        && self.userID.length > 0 &&  self.userSig.length > 0  && lastLoginIsNetworkError) {
        // The last time login failed due to network reasons, try to login again.
        self.lastLoginResultCode = 0;
        [TUILogin login:SDKAPPID userID:self.userID userSig:self.userSig config:self.loginConfig succ:^{
            [self redpoint_setupTotalUnreadCount];
            [TUITool makeToast:NSLocalizedString(@"AppLoginSucc", nil) duration:1];
        } fail:^(int code, NSString * _Nullable msg) {
            BOOL currentLoginIsNetworkError = (code >= 9501 && code <= 9525);
            if (!currentLoginIsNetworkError) {
                self.window.rootViewController = [self getLoginController];
                [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
            }
            self.lastLoginResultCode = code;
        }];
    }
}

#pragma mark - TUILoginListener
- (void)onUserSigExpired {
    [self onUserStatus:TUser_Status_SigExpired];
}

- (void)onKickedOffline {
    [self onUserStatus:TUser_Status_ForceOffline];
}

- (void)onLog:(NSInteger)logLevel logContent:(NSString *)logContent {
    
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
            [self userSigExpiredAction];
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
        [self loginSDK:userID userSig:userSig succ:nil fail:nil];
    }];
}

- (void)userSigExpiredAction {
    [TUILogin logout:^{
        NSLog(@"logout sdk succeed");
    } fail:^(int code, NSString *msg) {
        NSLog(@"logout sdk failed, code: %ld, msg: %@", (long)code, msg);
    }];
    self.window.rootViewController = [self getLoginController];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
}


#pragma mark - TUILanguageSelectControllerDelegate
- (void)onSelectLanguage:(TUILanguageSelectCellModel *)cellModel {
    /**
     * The method of dynamically refreshing the language: Destroy the current interface, and recreate it and then jump to realize dynamic refreshing of the language
     */
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"need_recover_login_page_info"];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    /**
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
     * 2. Create a language selection page and push
     */
    TUILanguageSelectController *languageVc = [[TUILanguageSelectController alloc] init];
    languageVc.delegate = self;
    [navVc pushViewController:languageVc animated:NO];
    
    /**
     * 3. Switch root controller
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication.sharedApplication.keyWindow.rootViewController = navVc;
    });
    
    /**
     * 4. Recofig the security warning view in ChatVC
     */
    [self setupChatSecurityWarningView];
}

#pragma mark - ThemeSelectControllerDelegate
- (void)onSelectTheme:(TUIThemeSelectCollectionViewCellModel *)cellModel {
    /**
     * : ，
     * The method of dynamically refreshing the theme: Destroy the current interface, and recreate it and then jump to realize the dynamic refresh theme
     */
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"need_recover_login_page_info"];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    /**
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
     * 2. Create a theme selection controller and push
     */
    TUIThemeSelectController *themeVc = [[TUIThemeSelectController alloc] init];
    themeVc.disable = YES;
    themeVc.delegate = self;
    [themeVc.view makeToastActivity:TUICSToastPositionCenter];
    [navVc pushViewController:themeVc animated:NO];
    
    /**
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
- (void)updateMarkUnreadCount:(NSNotification *)notice {
    
}

- (void)onDisplayCallsRecordForClassic:(NSNotification *)notice {
    [self onDisplayCallsRecord:notice isMinimalist:NO];
}

- (void)onDisplayCallsRecordForMinimalist:(NSNotification *)notice {
    [self onDisplayCallsRecord:notice isMinimalist:YES];
}

- (void)onDisplayCallsRecord:(NSNotification *)notice isMinimalist:(BOOL)isMinimalist {
    TUITabBarController *tabVC = (TUITabBarController *)self.window.rootViewController;
    NSNumber *value = notice.object;
    if (![value isKindOfClass:NSNumber.class] ||
        ![tabVC isKindOfClass:TUITabBarController.class]) {
        return;
    }
    NSMutableArray *items = tabVC.tabBarItems;
    BOOL isOn = value.boolValue;
    if (isOn) {
        if (self.callsRecordItem) {
            [items removeObject:self.callsRecordItem];
        }
        TUITabBarItem *item = [self getCallsRecordTabBarItem:isMinimalist];
        if (item) {
            [items insertObject:item atIndex:1];
            self.callsRecordItem = item;
        }
        tabVC.tabBarItems = items;
    } else {
        if (self.callsRecordItem) {
            [items removeObject:self.callsRecordItem];
        }
        tabVC.tabBarItems = items;
    }
    
    [tabVC layoutBadgeViewIfNeeded];
}


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
    
    [alertController tuitheme_addAction:cancel];
    [alertController tuitheme_addAction:confirm];
    
    [self.window.rootViewController presentViewController:alertController animated:NO completion:nil];
}

#pragma mark - Classic  & Minimalist
- (void)setupConfig {
   
    if ([TUIStyleSelectViewController isClassicEntrance]) {
        [self setupConfig_Classic];
    }
    else {
        [self setupConfig_Minimalist];
    }
}

- (UITabBarController *)getMainController {
    if ([TUIStyleSelectViewController isClassicEntrance]) {
        return [self getMainController_Classic];
    }
    else {
        return [self getMainController_Minimalist];
    }
    
}

- (UITabBarController *)getMainController_Classic {
    UIImage *backimg = TIMCommonDynamicImage(@"nav_back_img", [UIImage imageNamed:TIMCommonImagePath(@"nav_back")]);
    backimg = [backimg rtl_imageFlippedForRightToLeftLayoutDirection];
    
    TUITabBarController *tbc = [[TUITabBarController alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    TUITabBarItem *msgItem = [[TUITabBarItem alloc] init];
    msgItem.title = NSLocalizedString(@"TabBarItemMessageText", nil);
    msgItem.identity = @"msgItem";
    msgItem.selectedImage = TUIDemoDynamicImage(@"tab_msg_selected_img", [UIImage imageNamed:@"session_selected"]);
    msgItem.normalImage = TUIDemoDynamicImage(@"tab_msg_normal_img", [UIImage imageNamed:@"session_normal"]);
    TUINavigationController *msgNav = [[TUINavigationController alloc] initWithRootViewController:[[ConversationController alloc] init]];
    msgNav.navigationItemBackArrowImage = backimg;
    msgItem.controller = msgNav;
    msgItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    msgItem.badgeView = [[TUIBadgeView alloc] init];
    @weakify(self)
    msgItem.badgeView.clearCallback = ^{
        @strongify(self)
        [self redpoint_clearUnreadMessage];
    };
    [items addObject:msgItem];
    
    TUITabBarItem *callsItem = [self getCallsRecordTabBarItem:NO];
    if (callsItem) {
        [items addObject:callsItem];
        self.callsRecordItem = callsItem;
    }
    
    TUITabBarItem *contactItem = [[TUITabBarItem alloc] init];
    contactItem.title = NSLocalizedString(@"TabBarItemContactText", nil);
    contactItem.identity = @"contactItem";
    contactItem.selectedImage = TUIDemoDynamicImage(@"tab_contact_selected_img", [UIImage imageNamed:@"contact_selected"]);
    contactItem.normalImage = TUIDemoDynamicImage(@"tab_contact_normal_img", [UIImage imageNamed:@"contact_normal"]);
    TUINavigationController *contactNav = [[TUINavigationController alloc] initWithRootViewController:[[ContactsController alloc] init]];
    contactNav.navigationItemBackArrowImage = backimg;
    contactItem.controller = contactNav;
    contactItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    contactItem.badgeView = [[TUIBadgeView alloc] init];
    [items addObject:contactItem];
    
    TUITabBarItem *setItem = [[TUITabBarItem alloc] init];
    setItem.title = NSLocalizedString(@"TabBarItemMeText", nil);
    setItem.identity = @"setItem";
    setItem.selectedImage = TUIDemoDynamicImage(@"tab_me_selected_img", [UIImage imageNamed:@"myself_selected"]);
    setItem.normalImage = TUIDemoDynamicImage(@"tab_me_normal_img", [UIImage imageNamed:@"myself_normal"]);
    SettingController *setVC = [[SettingController alloc] init];
    setVC.lastLoginUser = self.userID;
    setVC.confirmLogout = ^{
        [TUILogin logout:^{
            [[TCLoginModel sharedInstance] clearLoginedInfo];
            UIViewController *loginVc = [self getLoginController];
            self.window.rootViewController = loginVc;
            [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
        } fail:^(int code, NSString *msg) {
            NSLog(@"logout fail");
        }];
    };
    TUINavigationController *setNav = [[TUINavigationController alloc] initWithRootViewController:setVC];
    setNav.navigationItemBackArrowImage = backimg;
    setItem.controller = setNav;
    setItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [items addObject:setItem];
    tbc.tabBarItems = items;

    return tbc;
}

- (void)setupConfig_Classic {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kEnableMsgReadStatus]) {
        TUIChatConfig.defaultConfig.msgNeedReadReceipt = [[NSUserDefaults standardUserDefaults] boolForKey:kEnableMsgReadStatus];
    } else {
        TUIChatConfig.defaultConfig.msgNeedReadReceipt = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kEnableMsgReadStatus];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    TUIConfig.defaultConfig.displayOnlineStatusIcon = [[NSUserDefaults standardUserDefaults] boolForKey:kEnableOnlineStatus];
    TUIChatConfig.defaultConfig.enableMultiDeviceForCall = NO;
    
    if ([NSUserDefaults.standardUserDefaults objectForKey:kEnableCallsRecord] == nil) {
        [NSUserDefaults.standardUserDefaults setObject:@(NO) forKey:kEnableCallsRecord];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setupConfig_Minimalist {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kEnableMsgReadStatus_mini]) {
        TUIChatConfig.defaultConfig.msgNeedReadReceipt = [[NSUserDefaults standardUserDefaults] boolForKey:kEnableMsgReadStatus_mini];
    } else {
        TUIChatConfig.defaultConfig.msgNeedReadReceipt = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kEnableMsgReadStatus_mini];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    TUIConfig.defaultConfig.displayOnlineStatusIcon = [[NSUserDefaults standardUserDefaults] boolForKey:kEnableOnlineStatus_mini];
    TUIChatConfig.defaultConfig.enableMultiDeviceForCall = NO;
    TUIConfig.defaultConfig.avatarType = TAvatarTypeRounded;
    
    if ([NSUserDefaults.standardUserDefaults objectForKey:kEnableCallsRecord_mini] == nil) {
        [NSUserDefaults.standardUserDefaults setObject:@(YES) forKey:kEnableCallsRecord_mini];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)onSelectStyle:(TUIStyleSelectCellModel *)cellModel {
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"need_recover_login_page_info"];
    [NSUserDefaults.standardUserDefaults synchronize];
    [self reloadCombineData];
    
    /**
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
    
    TUIStyleSelectViewController *styleSelectVC = [[TUIStyleSelectViewController alloc] init];
    styleSelectVC.delegate = self;
    [navVc pushViewController:styleSelectVC animated:NO];

    /**
     * 3. Switch root controller
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication.sharedApplication.keyWindow.rootViewController = navVc;
        if (![TUIStyleSelectViewController isClassicEntrance]) {
            [TUIThemeSelectController applyTheme:@"light"];
            [NSUserDefaults.standardUserDefaults setObject:@"light" forKey:@"current_theme_id"];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
        /**
         * 4. Recofig the security warning view in ChatVC
         */
        [self setupChatSecurityWarningView];
    });
}
- (void)reloadCombineData {
    [self setupConfig];
}

- (UITabBarController *)getMainController_Minimalist {
    
    UIImage *backimg = [[UIImage imageNamed:@"icon_back_blue"] rtl_imageFlippedForRightToLeftLayoutDirection];
    
    TUITabBarController *tbc = [[TUITabBarController alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    TUITabBarItem *msgItem = [[TUITabBarItem alloc] init];

    msgItem.title = NSLocalizedString(@"TabBarItemMessageText_mini", nil);
    msgItem.identity = @"msgItem";
    msgItem.selectedImage = TUIDynamicImage(@"", TUIThemeModuleDemo_Minimalist, [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"session_selected")]);
    msgItem.normalImage = TUIDynamicImage(@"", TUIThemeModuleDemo_Minimalist, [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"session_normal")]);
    ConversationController_Minimalist *convVC = [[ConversationController_Minimalist alloc] init];
    @weakify(self)
    convVC.getUnReadCount = ^NSUInteger{
        @strongify(self)
        return self.unReadCount;
    };
    convVC.clearUnreadMessage = ^{
        @strongify(self)
        [self redpoint_clearUnreadMessage];
    };
    
    TUINavigationController *msgNav = [[TUINavigationController alloc] initWithRootViewController:convVC];
    msgItem.controller = msgNav;
    msgNav.navigationItemBackArrowImage = backimg;
    msgNav.navigationBackColor = [UIColor whiteColor];
    msgItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TController_Background_Color_Dark];
    msgItem.badgeView = [[TUIBadgeView alloc] init];
    msgItem.badgeView.clearCallback = ^{
        @strongify(self)
        [self redpoint_clearUnreadMessage];
    };
    [items addObject:msgItem];

    TUITabBarItem *callsItem = [self getCallsRecordTabBarItem:YES];
    if (callsItem) {
        [items addObject:callsItem];
        self.callsRecordItem = callsItem;
    }
    
    TUITabBarItem *contactItem = [[TUITabBarItem alloc] init];
    contactItem.title = NSLocalizedString(@"TabBarItemContactText_mini", nil);
    contactItem.identity = @"contactItem";
    contactItem.selectedImage = TUIDynamicImage(@"", TUIThemeModuleDemo_Minimalist, [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"contact_selected")]);
    contactItem.normalImage = TUIDynamicImage(@"", TUIThemeModuleDemo_Minimalist, [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"contact_normal")]);
    TUINavigationController *contactNav = [[TUINavigationController alloc] initWithRootViewController:[[ContactsController_Minimalist alloc] init]];
    contactNav.navigationItemBackArrowImage = backimg;
    contactNav.navigationBackColor = [UIColor whiteColor];
    contactItem.controller = contactNav;
    contactItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TController_Background_Color_Dark];
    contactItem.badgeView = [[TUIBadgeView alloc] init];
    [items addObject:contactItem];
    
    
    TUITabBarItem *setItem = [[TUITabBarItem alloc] init];
    setItem.title = NSLocalizedString(@"TabBarItemSettingText_mini", nil);
    setItem.identity = @"setItem";
    setItem.selectedImage = TUIDynamicImage(@"", TUIThemeModuleDemo_Minimalist, [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"setting_selected")]);
    setItem.normalImage = TUIDynamicImage(@"", TUIThemeModuleDemo_Minimalist, [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"setting_normal")]);
    SettingController_Minimalist *setVC = [[SettingController_Minimalist alloc] init];
    setVC.lastLoginUser = self.userID;
    setVC.confirmLogout = ^{
        [TUILogin logout:^{
            [[TCLoginModel sharedInstance] clearLoginedInfo];
            UIViewController *loginVc = [self getLoginController];
            self.window.rootViewController = loginVc;
            [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
        } fail:^(int code, NSString *msg) {
            NSLog(@"logout fail");
        }];
    };
    
    TUINavigationController *setNav = [[TUINavigationController alloc] initWithRootViewController:setVC];
    setNav.navigationItemBackArrowImage = backimg;
    setNav.navigationBackColor = [UIColor whiteColor];
    setItem.controller = setNav;
    setItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TController_Background_Color_Dark];
    [items addObject:setItem];
    tbc.tabBarItems = items;
    
    tbc.tabBar.backgroundColor = [UIColor whiteColor];
    tbc.tabBar.barTintColor = [UIColor whiteColor];
    return tbc;
}

- (TUITabBarItem *)getCallsRecordTabBarItem:(BOOL)isMinimalist {
    BOOL showCallsRecord = isMinimalist ? [NSUserDefaults.standardUserDefaults boolForKey:kEnableCallsRecord_mini] : [NSUserDefaults.standardUserDefaults boolForKey:kEnableCallsRecord];
    TUICallingHistoryViewController *callsVc = [TUICallingHistoryViewController createCallingHistoryViewController:isMinimalist];
    if (showCallsRecord && callsVc) {
        NSString *title = isMinimalist ? NSLocalizedString(@"TabBarItemCallsRecordText_mini", nil) : NSLocalizedString(@"TabBarItemCallsRecordText_mini", nil);
        UIImage *selected = isMinimalist ? TUIDynamicImage(@"", TUIThemeModuleDemo_Minimalist, [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"tab_calls_selected")])
                                         : TUIDemoDynamicImage(@"tab_calls_selected_img", [UIImage imageNamed:TUIDemoImagePath(@"tab_calls_selected")]);
        UIImage *normal = isMinimalist ? TUIDynamicImage(@"", TUIThemeModuleDemo_Minimalist, [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"tab_calls_normal")])
                                       : TUIDemoDynamicImage(@"tab_calls_normal_img", [UIImage imageNamed:TUIDemoImagePath(@"tab_calls_normal")]);
        TUITabBarItem *callsItem = [[TUITabBarItem alloc] init];
        callsItem.title = title;
        callsItem.identity = @"callsItem";
        callsItem.selectedImage = selected;
        callsItem.normalImage = normal;
        TUINavigationController *callNav = [[TUINavigationController alloc] initWithRootViewController:callsVc];
        callNav.navigationBackColor = [UIColor whiteColor];
        callsItem.controller = callNav;
        
        return callsItem;
    }
    return nil;
}

#pragma mark - TIMPush
// TIMPush 
- (int)offlinePushCertificateID {
    
    NSInteger kAPNSBusiIdByType =  [NSUserDefaults.standardUserDefaults integerForKey:@"kAPNSBusiIdByType"];
    if (kAPNSBusiIdByType > 0) {
        return (int)kAPNSBusiIdByType;
    }
    return kAPNSBusiId;
}

- (NSString *)applicationGroupID {
    return kTIMPushAppGorupKey;
}


// If you need to customize the parsing of received remote push, you need to implement 'onRemoteNotificationReceived' in the AppDelegate.m file and return YES
/**
 - (BOOL)onRemoteNotificationReceived:(NSString *)notice {
     NSString *ext = notice;
     OfflinePushExtInfo *info = [OfflinePushExtInfo createWithExtString:ext];
     dispatch_async(dispatch_get_main_queue(), ^{
         // custom operation such as navigate chatVC;
         NSInteger chatType = info.entity.chatType;
         NSString *sender = info.entity.sender;
         NSString *userID = (chatType == 1) ? sender : nil;
         NSString *groupID = (chatType != 1) ? sender : nil;
         [self navigateToBuiltInChatViewController:userID groupID:groupID];
     });
     return YES ;
 }
 */

- (void)navigateToBuiltInChatViewController:(NSString *)userID groupID:(NSString *)groupID {
    UITabBarController *tab = [self getMainController];
    if (![tab isKindOfClass: UITabBarController.class]) {
        //Logging in
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
    if (![vc isKindOfClass:NSClassFromString(@"ConversationController")]
        && ![vc isKindOfClass:NSClassFromString(@"ConversationController_Minimalist")]) {
        return;
    }
    if ([vc respondsToSelector:NSSelectorFromString(@"pushToChatViewController:userID:")]) {
        [vc performSelector:NSSelectorFromString(@"pushToChatViewController:userID:") withObject:groupID withObject:userID];
    }
}

@end
