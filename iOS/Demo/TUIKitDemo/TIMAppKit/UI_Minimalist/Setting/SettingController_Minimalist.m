//
//  SettingController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/19.
//  Copyright © 2018 Tencent. All rights reserved.
//
#import "SettingController_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUILogin.h>
#import "TUIAboutUsViewController.h"
#import "TUIChatConfig.h"
#import "TUISettingController_Minimalist.h"
#import "TUIUtil.h"

NSString *kEnableMsgReadStatus_mini = @"TUIKitDemo_EnableMsgReadStatus";
NSString *kEnableOnlineStatus_mini = @"TUIKitDemo_EnableOnlineStatus";
NSString *kEnableCallsRecord_mini = @"TUIKitDemo_EnableCallsRecord_mini";

@interface SettingController_Minimalist () <TUISettingControllerDelegate_Minimalist, V2TIMSDKListener, UIActionSheetDelegate>
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation SettingController_Minimalist

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

- (UIColor *)navBackColor {
    return [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor = [self navBackColor];
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.backgroundColor = [self navBackColor];
        navigationBar.barTintColor = [self navBackColor];
        navigationBar.shadowImage = [UIImage new];
        navigationBar.standardAppearance = appearance;
        navigationBar.scrollEdgeAppearance = appearance;
    } else {
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.backgroundColor = [self navBackColor];
        navigationBar.barTintColor = [self navBackColor];
        navigationBar.shadowImage = [UIImage new];
    }
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
    [self setupNavigation];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapTest:)];
    tap.numberOfTapsRequired = 5;
    [self.parentViewController.view addGestureRecognizer:tap];

    self.setting = [[TUISettingController_Minimalist alloc] init];
    self.setting.lastLoginUser = self.lastLoginUser;
    self.setting.delegate = self;
    self.setting.aboutIMCellText = TIMCommonLocalizableString(TIMAppMeAbout);
    self.setting.showPersonalCell = self.showPersonalCell;
    self.setting.showSelectStyleCell = self.showSelectStyleCell;
    self.setting.showChangeThemeCell = self.showChangeThemeCell;
    self.setting.showAboutIMCell = self.showAboutIMCell;
    self.setting.showLoginOutCell = self.showLoginOutCell;
    self.setting.showCallsRecordCell = self.showCallsRecordCell;
    if (self.setting.view.frame.size.width == 0) {
        self.setting.view.frame = self.view.bounds;
    }
    [self addChildViewController:self.setting];
    [self.view addSubview:self.setting.view];

    [TUIChatConfig defaultConfig].msgNeedReadReceipt = [self msgReadStatus];
    [TUIConfig defaultConfig].displayOnlineStatusIcon = [self onlineStatus];
    self.setting.displayCallsRecord = [[NSUserDefaults.standardUserDefaults objectForKey:kEnableCallsRecord_mini] boolValue];
    self.setting.msgNeedReadReceipt = [TUIChatConfig defaultConfig].msgNeedReadReceipt;
}

- (void)setupNavigation {
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    _titleView.label.font = [UIFont boldSystemFontOfSize:34];
    [_titleView setTitle:TIMCommonLocalizableString(TIMAppTabBarItemSettingText_mini)];
    _titleView.label.textColor = TUIDynamicColor(@"nav_title_text_color", TUIThemeModuleDemo_Minimalist, @"#000000");

    UIBarButtonItem *leftTitleItem = [[UIBarButtonItem alloc] initWithCustomView:_titleView];
    UIBarButtonItem *leftSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSpaceItem.width = kScale390(13);
    self.showLeftBarButtonItems = [NSMutableArray arrayWithArray:@[ leftSpaceItem, leftTitleItem ]];

    self.navigationItem.title = @"";
    self.navigationItem.leftBarButtonItems = self.showLeftBarButtonItems;
}

- (void)onTapTest:(UIGestureRecognizer *)recognizer {
    // PRIVATEMARK
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

- (void)onSwitchCallsRecord:(BOOL)isOn {
    [NSUserDefaults.standardUserDefaults setObject:@(isOn) forKey:kEnableCallsRecord_mini];
    [NSUserDefaults.standardUserDefaults synchronize];
    [NSNotificationCenter.defaultCenter postNotificationName:kEnableCallsRecord_mini object:@(isOn)];
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
