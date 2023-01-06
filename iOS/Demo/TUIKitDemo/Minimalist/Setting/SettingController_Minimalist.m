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
    [_titleView setTitle:NSLocalizedString(@"TabBarItemMeText", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapTest:)];
    tap.numberOfTapsRequired = 5;
    [self.parentViewController.view addGestureRecognizer:tap];
    
    TUISettingController_Minimalist *vc = [[TUISettingController_Minimalist alloc] init];
    vc.delegate = self;
    vc.aboutCellText = NSLocalizedString(@"MeAbout", nil);
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    
    [TUIChatConfig defaultConfig].msgNeedReadReceipt = [self msgReadStatus];
    [TUIConfig defaultConfig].displayOnlineStatusIcon = [self onlineStatus];
}

- (void)onTapTest:(UIGestureRecognizer *)recognizer {
    //PRIVATEMARK
}

#pragma mark TUISettingControllerDelegate_Minimalist
- (void)onSwitchMsgReadStatus:(BOOL)isOn {
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
