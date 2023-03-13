//
//  SettingController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//
#import "SettingController_Minimalist.h"
#import "TUISettingController_Minimalist.h"
#import "TUIAboutUsViewController.h"
#import "AppDelegate.h"

#import "TUIKit.h"
#import "TUILogin.h"
#import "TCUtil.h"
#import "TCLoginModel.h"
#import "TUICommonModel.h"
#import "TUIChatConfig.h"

NSString * kEnableMsgReadStatus_mini = @"TUIKitDemo_EnableMsgReadStatus";
NSString * kEnableOnlineStatus_mini = @"TUIKitDemo_EnableOnlineStatus";

@interface SettingController_Minimalist () <TUISettingControllerDelegate_Minimalist, V2TIMSDKListener, UIActionSheetDelegate>
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation SettingController_Minimalist

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    _titleView.label.font = [UIFont boldSystemFontOfSize:34];
    [_titleView setTitle:NSLocalizedString(@"TabBarItemSettingText_mini", nil)];
    _titleView.label.textColor = TUIDynamicColor(@"nav_title_text_color", TUIThemeModuleDemo_Minimalist, @"#000000");
    
    UIBarButtonItem * titleItem = [[UIBarButtonItem alloc] initWithCustomView:_titleView];
    
    UIBarButtonItem *leftSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSpaceItem.width = kScale390(13);
    
    self.navigationItem.title = @"";
    self.navigationItem.leftBarButtonItems = @[leftSpaceItem,titleItem];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapTest:)];
    tap.numberOfTapsRequired = 5;
    [self.parentViewController.view addGestureRecognizer:tap];

    
    TUISettingController_Minimalist *vc = [[TUISettingController_Minimalist alloc] init];
    vc.delegate = self;
    vc.msgNeedReadReceipt = [TUIChatConfig defaultConfig].msgNeedReadReceipt;
    vc.aboutCellText = NSLocalizedString(@"MeAbout", nil);
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    
    [TUIChatConfig defaultConfig].msgNeedReadReceipt = [self msgReadStatus];
    [TUIConfig defaultConfig].displayOnlineStatusIcon = [self onlineStatus];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor =  [self navBackColor];
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.backgroundColor = [self navBackColor];
        navigationBar.barTintColor = [self navBackColor];
        navigationBar.shadowImage = [UIImage new];
        navigationBar.standardAppearance = appearance;
        navigationBar.scrollEdgeAppearance= appearance;
    }
    else {
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.backgroundColor = [self navBackColor];
        navigationBar.barTintColor = [self navBackColor];
        navigationBar.shadowImage = [UIImage new];
        [[UINavigationBar appearance] setTranslucent:NO];
    }
}

- (UIColor *)navBackColor {
    return  [UIColor whiteColor];
}

- (void)onTapTest:(UIGestureRecognizer *)recognizer {
    //PRIVATEMARK
}

#pragma mark TUISettingControllerDelegate_Minimalist
- (void)onSwitchMsgReadStatus:(BOOL)isOn {
    [TUIChatConfig defaultConfig].msgNeedReadReceipt = isOn;
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kEnableMsgReadStatus_mini];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)msgReadStatus {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kEnableMsgReadStatus_mini];
}


- (void)onSwitchOnlineStatus:(BOOL)isOn {
    [NSUserDefaults.standardUserDefaults setBool:isOn forKey:kEnableOnlineStatus_mini];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (BOOL)onlineStatus {
    return [NSUserDefaults.standardUserDefaults boolForKey:kEnableOnlineStatus_mini];
}

- (void)onClickAbout {
    TUIAboutUsViewController *vc = [[TUIAboutUsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onClickLogout {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"confirm_log_out", nil)/*@"确定退出吗"*/ message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert tuitheme_addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [alert tuitheme_addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self didConfirmLogout];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didConfirmLogout {
    [TUILogin logout:^{
        [[TCLoginModel sharedInstance] clearLoginedInfo];
        UIViewController *loginVc = [AppDelegate.sharedInstance getLoginController];
        self.view.window.rootViewController = loginVc;
        [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
    } fail:^(int code, NSString *msg) {
        NSLog(@"logout fail");
    }];
}

@end
