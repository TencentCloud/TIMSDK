//
//  SettingController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/19.
//  Copyright © 2018 Tencent. All rights reserved.
//
#import "SettingController.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUILogin.h>
#import "TUIAboutUsViewController.h"
#import "TUIChatConfig.h"
#import "TUISettingController.h"
#import "TUIUtil.h"

NSString *kEnableMsgReadStatus = @"TUIKitDemo_EnableMsgReadStatus";
NSString *kEnableOnlineStatus = @"TUIKitDemo_EnableOnlineStatus";
NSString *kEnableCallsRecord = @"TUIKitDemo_EnableCallsRecord";

@interface SettingController () <TUISettingControllerDelegate, V2TIMSDKListener, UIActionSheetDelegate>
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation SettingController

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.showPersonalCell = YES;
        self.showAboutIMCell = YES;
        self.showLoginOutCell = YES;
        self.showCallsRecordCell = YES;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.viewWillAppear) {
        self.viewWillAppear(YES);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.viewWillAppear) {
        self.viewWillAppear(NO);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TIMCommonLocalizableString(TIMAppTabBarItemMeText)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapTest:)];
    tap.numberOfTapsRequired = 5;
    [self.parentViewController.view addGestureRecognizer:tap];

    TUISettingController *vc = [[TUISettingController alloc] init];
    vc.lastLoginUser = self.lastLoginUser;
    vc.delegate = self;
    vc.aboutIMCellText = TIMCommonLocalizableString(TIMAppMeAbout);
    vc.showPersonalCell = self.showPersonalCell;
    vc.showSelectStyleCell = self.showSelectStyleCell;
    vc.showChangeThemeCell = self.showChangeThemeCell;
    vc.showAboutIMCell = self.showAboutIMCell;
    vc.showLoginOutCell = self.showLoginOutCell;
    vc.showCallsRecordCell = self.showCallsRecordCell;
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];

    [TUIChatConfig defaultConfig].msgNeedReadReceipt = [self msgReadStatus];
    [TUIConfig defaultConfig].displayOnlineStatusIcon = [self onlineStatus];
    vc.displayCallsRecord = [[NSUserDefaults.standardUserDefaults objectForKey:kEnableCallsRecord] boolValue];
    vc.msgNeedReadReceipt = [TUIChatConfig defaultConfig].msgNeedReadReceipt;
}

- (void)onTapTest:(UIGestureRecognizer *)recognizer {
    // PRIVATEMARK
}

#pragma mark TUISettingControllerDelegate
- (void)onSwitchMsgReadStatus:(BOOL)isOn {
    [TUIChatConfig defaultConfig].msgNeedReadReceipt = isOn;
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kEnableMsgReadStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)msgReadStatus {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kEnableMsgReadStatus];
}

- (void)onSwitchOnlineStatus:(BOOL)isOn {
    [NSUserDefaults.standardUserDefaults setBool:isOn forKey:kEnableOnlineStatus];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (BOOL)onlineStatus {
    return [NSUserDefaults.standardUserDefaults boolForKey:kEnableOnlineStatus];
}

- (void)onSwitchCallsRecord:(BOOL)isOn {
    [NSUserDefaults.standardUserDefaults setObject:@(isOn) forKey:kEnableCallsRecord];
    [NSUserDefaults.standardUserDefaults synchronize];
    [NSNotificationCenter.defaultCenter postNotificationName:kEnableCallsRecord object:@(isOn)];
}

- (void)onClickAboutIM {
    TUIAboutUsViewController *vc = [[TUIAboutUsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onChangeStyle {
    if (self.changeStyle) {
        self.changeStyle();
    }
}

- (void)onChangeTheme {
    if (self.changeTheme) {
        self.changeTheme();
    }
}

- (void)onClickLogout {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TIMAppConfirmLogout) /*@""*/
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TIMAppCancel)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *_Nonnull action){

                                                     }]];
    [alert tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TIMAppConfirm)
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction *_Nonnull action) {
                                                       [self didConfirmLogout];
                                                     }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didConfirmLogout {
    if (self.confirmLogout) {
        self.confirmLogout();
    }
}

@end
