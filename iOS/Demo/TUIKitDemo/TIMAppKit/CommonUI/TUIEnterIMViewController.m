//
//  TUIEnterIMViewController.m
//  TUIKitDemo
//
//  Created by lynxzhang on 2022/2/9.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUIEnterIMViewController.h"
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUICore.h>
#import <objc/runtime.h>
#import "ContactsController.h"
#import "ContactsController_Minimalist.h"
#import "ConversationController.h"
#import "ConversationController_Minimalist.h"
#import "SettingController.h"
#import "SettingController_Minimalist.h"
#import "TUIBaseChatViewController.h"
#import "TUIBaseChatViewController_Minimalist.h"
#import "TUICallingHistoryViewController.h"
#import "TUIChatConfig.h"
#import "TUIContactViewDataProvider.h"
#import "TUIIMIntroductionViewController.h"
#import "TUIStyleSelectViewController.h"
#import "TUITabBarController.h"
#import "TUIThemeSelectController.h"
#import "TUIUtil.h"
#import "TUIWarningView.h"
#import "TIMCommonMediator.h"
#import "TUIEmojiMeditorProtocol.h"


NSString *kHaveViewedIMIntroduction = @"TUIKitDemo_HaveViewedIMIntroduction";

@interface TUIEnterIMViewController () <TUIStyleSelectControllerDelegate, V2TIMConversationListener>
@property(nonatomic, strong) TUITabBarController *tbc;
@property(nonatomic, strong) TUIStyleSelectViewController *styleVC;
@property(nonatomic, strong) TUIThemeSelectController *themeVC;
@property(nonatomic, strong) TUIContactViewDataProvider *contactDataProvider;
@property(nonatomic, strong) ConversationController_Minimalist *convVC_Mini;
@property(nonatomic, strong) ContactsController_Minimalist *contactsVC_Mini;
@property(nonatomic, strong) SettingController_Minimalist *settingVC_Mini;
@property(nonatomic, strong) TUICallingHistoryViewController *callingVC;
@property(nonatomic, strong) UILabel *themeLabel;
@property(nonatomic, strong) UILabel *themeSubLabel;
@property(nonatomic, assign) NSUInteger unReadCount;
@property(nonatomic, assign) NSUInteger markUnreadCount;
@property(nonatomic, assign) NSUInteger markHideUnreadCount;
@property(nonatomic, strong) NSMutableDictionary *markUnreadMap;

@property(nonatomic, assign) BOOL windowIsClosed;
@property(nonatomic, strong) UIButton *dismissWindowBtn;
@property(nonatomic, strong) NSArray *convShowLeftBarButtonItems;
@property(nonatomic, strong) NSArray *convShowRightBarButtonItems;
@property(nonatomic, strong) NSArray *contactsShowLeftBarButtonItems;
@property(nonatomic, strong) NSArray *contactsShowRightBarButtonItems;
@property(nonatomic, strong) NSArray *settingShowLeftBarButtonItems;
@property(nonatomic, assign) BOOL inConversationVC;
@property(nonatomic, assign) BOOL inContactsVC;
@property(nonatomic, assign) BOOL inSettingVC;
@property(nonatomic, assign) BOOL inCallsRecordVC;
@property(nonatomic, strong) UIImage *originRTCBackImage;

@end

@implementation TUIEnterIMViewController

// MARK: life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.windowIsClosed) {
        return;
    }

    TUIRegisterThemeResourcePath(TUIDemoThemePath, TUIThemeModuleDemo);
    [TUIThemeSelectController disableFollowSystemStyle];
    [TUIThemeSelectController applyLastTheme];

    [self configIMNavigation];
    [self setupCustomSticker];
    [self setupChatSecurityWarningView];
    [self redpoint_setupTotalUnreadCount];
    [self setupView];

    [[V2TIMManager sharedInstance] addConversationListener:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMarkUnreadCount:)
                                                 name:TUIKitNotification_onConversationMarkUnreadCountChanged
                                               object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onDisplayCallsRecordForMinimalist:) name:kEnableCallsRecord_mini object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onDisplayCallsRecordForClassic:) name:kEnableCallsRecord object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIColor *)tintColor {
    return TIMCommonDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
}
- (void)configIMNavigation {
    self.originRTCBackImage = [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault];

    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.barTintColor = self.tintColor;
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;

    } else {
        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.backgroundColor = self.tintColor;
        self.navigationController.navigationBar.barTintColor = self.tintColor;
        self.navigationController.navigationBar.shadowImage = nil;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }
}

static BOOL g_hasAddedCustomFace = NO;
- (void)setupCustomSticker {
    if (g_hasAddedCustomFace) {
        return;
    }
    g_hasAddedCustomFace = YES;
    id<TUIEmojiMeditorProtocol> service = [[TIMCommonMediator share] getObject:@protocol(TUIEmojiMeditorProtocol)];
    NSString *bundlePath = TUIBundlePath(@"CustomFaceResource", TUIDemoBundle_Key_Class);
    // 4350 group
    NSMutableArray *faces4350 = [NSMutableArray array];
    for (int i = 0; i <= 17; i++) {
        TUIFaceCellData *data = [[TUIFaceCellData alloc] init];
        NSString *name = [NSString stringWithFormat:@"yz%02d", i];
        NSString *path = [NSString stringWithFormat:@"4350/%@", name];
        data.name = name;
        data.path = [bundlePath stringByAppendingPathComponent:path];
        [faces4350 addObject:data];
    }
    if (faces4350.count != 0) {
        TUIFaceGroup *group4350 = [[TUIFaceGroup alloc] init];
        group4350.groupIndex = 1;
        group4350.groupPath = [bundlePath stringByAppendingPathComponent:@"4350/"];  // TUIChatFaceImagePath(@"4350/");
        group4350.faces = faces4350;
        group4350.rowCount = 2;
        group4350.itemCountPerRow = 5;
        group4350.menuPath = [bundlePath stringByAppendingPathComponent:@"4350/menu"];  // TUIChatFaceImagePath(@"4350/menu");
        [service appendFaceGroup:group4350];
    }

    // 4351 group
    NSMutableArray *faces4351 = [NSMutableArray array];
    for (int i = 0; i <= 15; i++) {
        TUIFaceCellData *data = [[TUIFaceCellData alloc] init];
        NSString *name = [NSString stringWithFormat:@"ys%02d", i];
        NSString *path = [NSString stringWithFormat:@"4351/%@", name];
        data.name = name;
        data.path = [bundlePath stringByAppendingPathComponent:path];  // TUIChatFaceImagePath(path);
        [faces4351 addObject:data];
    }
    if (faces4351.count != 0) {
        TUIFaceGroup *group4351 = [[TUIFaceGroup alloc] init];
        group4351.groupIndex = 2;
        group4351.groupPath = [bundlePath stringByAppendingPathComponent:@"4351/"];  // TUIChatFaceImagePath(@"4351/");
        group4351.faces = faces4351;
        group4351.rowCount = 2;
        group4351.itemCountPerRow = 5;
        group4351.menuPath = [bundlePath stringByAppendingPathComponent:@"4351/menu"];  // TUIChatFaceImagePath(@"4351/menu");
        [service appendFaceGroup:group4351];
    }

    // 4352 group
    NSMutableArray *faces4352 = [NSMutableArray array];
    for (int i = 0; i <= 16; i++) {
        TUIFaceCellData *data = [[TUIFaceCellData alloc] init];
        NSString *name = [NSString stringWithFormat:@"gcs%02d", i];
        NSString *path = [NSString stringWithFormat:@"4352/%@", name];
        data.name = name;
        data.path = [bundlePath stringByAppendingPathComponent:path];  // TUIChatFaceImagePath(path);
        [faces4352 addObject:data];
    }
    if (faces4352.count != 0) {
        TUIFaceGroup *group4352 = [[TUIFaceGroup alloc] init];
        group4352.groupIndex = 3;
        group4352.groupPath = [bundlePath stringByAppendingPathComponent:@"4352/"];  // TUIChatFaceImagePath(@"4352/");
        group4352.faces = faces4352;
        group4352.rowCount = 2;
        group4352.itemCountPerRow = 5;
        group4352.menuPath = [bundlePath stringByAppendingPathComponent:@"4352/menu"];  // TUIChatFaceImagePath(@"4352/menu");
        [service appendFaceGroup:group4352];
    }

}

- (void)setupStyleConfig {
    if ([TUIStyleSelectViewController isClassicEntrance]) {
        [self setupStyleConfig_Classic];
    } else {
        [TUIThemeSelectController applyTheme:@"light"];
        [NSUserDefaults.standardUserDefaults setObject:@"light" forKey:@"current_theme_id"];
        [NSUserDefaults.standardUserDefaults synchronize];
        [self setupStyleConfig_Minimalist];
    }
}

- (void)setupStyleConfig_Classic {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kEnableMsgReadStatus]) {
        TUIChatConfig.defaultConfig.msgNeedReadReceipt = [[NSUserDefaults standardUserDefaults] boolForKey:kEnableMsgReadStatus];
    } else {
        TUIChatConfig.defaultConfig.msgNeedReadReceipt = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEnableMsgReadStatus];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    TUIConfig.defaultConfig.displayOnlineStatusIcon = [[NSUserDefaults standardUserDefaults] boolForKey:kEnableOnlineStatus];
    TUIChatConfig.defaultConfig.enableMultiDeviceForCall = YES;
    TUIConfig.defaultConfig.avatarType = TAvatarTypeRadiusCorner;
}

- (void)setupStyleConfig_Minimalist {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kEnableMsgReadStatus_mini]) {
        TUIChatConfig.defaultConfig.msgNeedReadReceipt = [[NSUserDefaults standardUserDefaults] boolForKey:kEnableMsgReadStatus_mini];
    } else {
        TUIChatConfig.defaultConfig.msgNeedReadReceipt = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEnableMsgReadStatus_mini];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    TUIConfig.defaultConfig.displayOnlineStatusIcon = [[NSUserDefaults standardUserDefaults] boolForKey:kEnableOnlineStatus_mini];
    TUIChatConfig.defaultConfig.enableMultiDeviceForCall = YES;
    TUIConfig.defaultConfig.avatarType = TAvatarTypeRounded;
}

- (void)setupChatSecurityWarningView {
    NSString *tips = TIMCommonLocalizableString(TIMAppChatSecurityWarning);
    NSString *buttonTitle = TIMCommonLocalizableString(TIMAppChatSecurityWarningReport);
    NSString *gotButtonTitle = TIMCommonLocalizableString(TIMAppChatSecurityWarningGot);

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
    if ([TUIStyleSelectViewController isClassicEntrance]) {
        [TUIBaseChatViewController setCustomTopView:tipsView];
    } else {
        [TUIBaseChatViewController_Minimalist setCustomTopView:tipsView];
    }
}

- (void)setupView {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kHaveViewedIMIntroduction]) {
        [self enterIM];
        return;
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveViewedIMIntroduction];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    self.view.backgroundColor = [UIColor whiteColor];

    UIImageView *imLogo = [[UIImageView alloc] initWithFrame:CGRectMake(kScale375(24), 56, 62, 31)];
    imLogo.image = TUIDemoDynamicImage(@"", [UIImage imageNamed:TUIDemoImagePath(@"im_logo")]);
    [self.view addSubview:imLogo];

    UIImageView *cloudLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.mm_w - 229, 6, 229, 215)];
    cloudLogo.image = TUIDemoDynamicImage(@"", [UIImage imageNamed:TUIDemoImagePath(@"cloud_logo")]);
    [self.view addSubview:cloudLogo];

    UILabel *imLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScale375(24), imLogo.mm_maxY + 10, 100, 36)];
    imLabel.text = TIMCommonLocalizableString(TIMAppTencentCloudIM);
    imLabel.font = [UIFont systemFontOfSize:24];
    imLabel.textColor = [UIColor blackColor];
    [self.view addSubview:imLabel];

    UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScale375(24), imLabel.mm_maxY + 9, 240, 17)];
    welcomeLabel.text = TIMCommonLocalizableString(TIMAppWelcomeToChat);
    welcomeLabel.font = [UIFont systemFontOfSize:12];
    welcomeLabel.textColor = RGB(102, 102, 102);
    [self.view addSubview:welcomeLabel];

    UIButton *welcomeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    welcomeBtn.frame = CGRectMake(welcomeLabel.mm_maxX + kScale375(10), welcomeLabel.mm_y, 16, 16);
    [welcomeBtn setImage:TUIDemoDynamicImage(@"", [UIImage imageNamed:TUIDemoImagePath(@"im_welcome")]) forState:UIControlStateNormal];
    [welcomeBtn addTarget:self action:@selector(welcomeIM) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:welcomeBtn];

    UILabel *styleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScale375(24), welcomeLabel.mm_maxY + 42, kScale375(70), 22)];
    styleLabel.text = TIMCommonLocalizableString(TIMAppSelectStyle);
    styleLabel.font = [UIFont systemFontOfSize:16];
    styleLabel.textColor = RGB(51, 51, 51);
    [self.view addSubview:styleLabel];

    UILabel *styleSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(styleLabel.mm_maxX + kScale375(9), styleLabel.mm_y + 4, 100, 17)];
    styleSubLabel.text = TIMCommonLocalizableString(TIMAppChatStyles);
    styleSubLabel.font = [UIFont systemFontOfSize:12];
    styleSubLabel.textColor = RGB(153, 153, 153);
    [self.view addSubview:styleSubLabel];

    self.styleVC = [[TUIStyleSelectViewController alloc] init];
    self.styleVC.delegate = self;
    self.styleVC.view.frame = CGRectMake(0, styleSubLabel.mm_maxY + 9, self.view.mm_w, 92);
    self.styleVC.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addChildViewController:self.styleVC];
    [self.view addSubview:self.styleVC.view];
    [self.styleVC setBackGroundColor:[UIColor whiteColor]];

    self.themeLabel = [[UILabel alloc] initWithFrame:CGRectMake(styleLabel.mm_x, self.styleVC.view.mm_maxY + 20, styleLabel.mm_w, styleLabel.mm_h)];
    self.themeLabel.text = TIMCommonLocalizableString(TIMAppChangeTheme);
    self.themeLabel.font = [UIFont systemFontOfSize:16];
    self.themeLabel.textColor = RGB(51, 51, 51);
    [self.view addSubview:self.themeLabel];

    self.themeSubLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(self.themeLabel.mm_maxX + kScale375(9), self.themeLabel.mm_y + 4, styleSubLabel.mm_w, styleSubLabel.mm_h)];
    self.themeSubLabel.text = TIMCommonLocalizableString(TIMAppChatThemes);
    self.themeSubLabel.font = [UIFont systemFontOfSize:12];
    self.themeSubLabel.textColor = RGB(153, 153, 153);
    [self.view addSubview:self.themeSubLabel];

    self.themeVC = [[TUIThemeSelectController alloc] init];
    self.themeVC.view.frame = CGRectMake(0, self.themeSubLabel.mm_maxY + 9, self.view.frame.size.width, 350);
    self.themeVC.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addChildViewController:self.themeVC];
    [self.view addSubview:self.themeVC.view];
    [self.themeVC setBackGroundColor:[UIColor whiteColor]];

    if (![TUIStyleSelectViewController isClassicEntrance]) {
        self.themeLabel.hidden = YES;
        self.themeSubLabel.hidden = YES;
        self.themeVC.view.hidden = YES;
    }

    UIButton *enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    enterBtn.backgroundColor = RGB(16, 78, 245);
    CGFloat btnWidth = 202;
    CGFloat btnHeight = 42;
    enterBtn.frame = CGRectMake((self.view.mm_w - btnWidth) / 2, self.view.mm_h - btnHeight - Bottom_SafeHeight, btnWidth, btnHeight);
    [enterBtn setTitle:TIMCommonLocalizableString(TIMAppEnterChat) forState:UIControlStateNormal];
    [enterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    enterBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    enterBtn.layer.cornerRadius = btnHeight / 2;
    enterBtn.layer.masksToBounds = YES;
    [enterBtn addTarget:self action:@selector(enterIM) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enterBtn];
}

- (void)welcomeIM {
    TUIIMIntroductionViewController *vc = [[TUIIMIntroductionViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)enterIM {
    [self showIMWindow];
}

static UIWindow *gImWindow = nil;
- (void)showIMWindow {
    if (!gImWindow) {
        gImWindow = [[UIWindow alloc] initWithFrame:CGRectZero];
        gImWindow.windowLevel = UIWindowLevelAlert - 1;
        gImWindow.backgroundColor = [UIColor whiteColor];

        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    gImWindow.windowScene = windowScene;
                    break;
                }
            }
        }

        gImWindow.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
        gImWindow.rootViewController = [self getMainController];
        gImWindow.hidden = NO;

        self.dismissWindowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.dismissWindowBtn.frame = CGRectMake(kScale375(15), StatusBar_Height + 6, 44, 32);
        [self.dismissWindowBtn setImage:TUIDemoDynamicImage(@"", [UIImage imageNamed:TUIDemoImagePath(@"dismiss_im_window")]) forState:UIControlStateNormal];
        [self.dismissWindowBtn addTarget:self action:@selector(dismissIMWindow) forControlEvents:UIControlEventTouchUpInside];
        [gImWindow addSubview:self.dismissWindowBtn];
    }

    [self setupStyleWindow];
    [self setupStyleConfig];
}

- (void)updateIMWindow {
    if (gImWindow) {
        gImWindow.rootViewController = [self getMainController];
        [self setupStyleWindow];
        [self setupStyleConfig];
    }
}

- (void)dismissIMWindow {
    if (gImWindow) {
        gImWindow.hidden = YES;
        gImWindow = nil;
        self.windowIsClosed = YES;

        if (self.originRTCBackImage) {
            [[UINavigationBar appearance] setBackgroundImage:self.originRTCBackImage forBarMetrics:UIBarMetricsDefault];
        }

        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)setupStyleWindow {
    self.dismissWindowBtn.hidden = NO;
    [gImWindow bringSubviewToFront:self.dismissWindowBtn];

    if ([TUIStyleSelectViewController isClassicEntrance]) {
        for (UIBarButtonItem *item in self.contactsShowLeftBarButtonItems) {
            [item.customView removeFromSuperview];
        }
        for (UIBarButtonItem *item in self.contactsShowRightBarButtonItems) {
            [item.customView removeFromSuperview];
        }
        for (UIBarButtonItem *item in self.convShowLeftBarButtonItems) {
            [item.customView removeFromSuperview];
        }
        for (UIBarButtonItem *item in self.convShowRightBarButtonItems) {
            [item.customView removeFromSuperview];
        }
        for (UIBarButtonItem *item in self.settingShowLeftBarButtonItems) {
            [item.customView removeFromSuperview];
        }
        return;
    }

    [[[RACObserve(self.dismissWindowBtn, hidden) distinctUntilChanged] skip:1] subscribeNext:^(NSNumber *isHidden) {
      if ([TUIStyleSelectViewController isClassicEntrance]) {
          return;
      }
      if (YES == [isHidden boolValue]) {
          [self showConvBarButtonItems:NO];
          [self showContactBarButtonItems:NO];
          [self showSettingBarButtonItems:NO];
      }
    }];

    [[[RACObserve(self.convVC_Mini, showLeftBarButtonItems) distinctUntilChanged] skip:1] subscribeNext:^(NSArray<UIBarButtonItem *> *showLeftBarButtonItems) {
      self.convShowLeftBarButtonItems = [showLeftBarButtonItems copy];
      UIBarButtonItem *titleItem = showLeftBarButtonItems.lastObject;
      if (![gImWindow.subviews containsObject:titleItem.customView]) {
          titleItem.customView.mm_x = self.dismissWindowBtn.mm_x;
          titleItem.customView.mm_y = self.dismissWindowBtn.mm_maxY;
          [gImWindow addSubview:titleItem.customView];
      }
      [self.convVC_Mini.showLeftBarButtonItems removeAllObjects];
    }];

    [[[RACObserve(self.contactsVC_Mini, showLeftBarButtonItems) distinctUntilChanged] skip:1]
        subscribeNext:^(NSArray<UIBarButtonItem *> *showLeftBarButtonItems) {
          self.contactsShowLeftBarButtonItems = [showLeftBarButtonItems copy];
          UIBarButtonItem *titleItem = showLeftBarButtonItems.lastObject;
          if (![gImWindow.subviews containsObject:titleItem.customView]) {
              titleItem.customView.mm_x = self.dismissWindowBtn.mm_x;
              titleItem.customView.mm_y = self.dismissWindowBtn.mm_maxY;
              [gImWindow addSubview:titleItem.customView];
          }
          [self.contactsVC_Mini.showLeftBarButtonItems removeAllObjects];
        }];

    [[[RACObserve(self.settingVC_Mini, showLeftBarButtonItems) distinctUntilChanged] skip:1]
        subscribeNext:^(NSArray<UIBarButtonItem *> *showLeftBarButtonItems) {
          self.settingShowLeftBarButtonItems = [showLeftBarButtonItems copy];
          UIBarButtonItem *titleItem = showLeftBarButtonItems.lastObject;
          if (![gImWindow.subviews containsObject:titleItem.customView]) {
              titleItem.customView.mm_x = self.dismissWindowBtn.mm_x;
              titleItem.customView.mm_y = self.dismissWindowBtn.mm_maxY;
              [gImWindow addSubview:titleItem.customView];
          }
          [self.settingVC_Mini.showLeftBarButtonItems removeAllObjects];
        }];

    [[[RACObserve(self.convVC_Mini, showRightBarButtonItems) distinctUntilChanged] skip:1]
        subscribeNext:^(NSArray<UIBarButtonItem *> *showRightBarButtonItems) {
          self.convShowRightBarButtonItems = [showRightBarButtonItems copy];
          for (UIBarButtonItem *item in self.convShowRightBarButtonItems) {
              if (![gImWindow.subviews containsObject:item.customView]) {
                  UIBarButtonItemType type = (UIBarButtonItemType)item.tag;
                  switch (type) {
                      case UIBarButtonItemType_Edit:
                          item.customView.mm_x = Screen_Width - kScale375(90);
                          break;
                      case UIBarButtonItemType_More:
                          item.customView.mm_x = Screen_Width - kScale375(40);
                          break;
                      case UIBarButtonItemType_Done:
                          item.customView.mm_x = Screen_Width - kScale375(60);
                          break;
                      default:
                          break;
                  }
                  item.customView.mm_centerY = self.dismissWindowBtn.mm_centerY;
                  [gImWindow addSubview:item.customView];
              }
          }
          for (UIBarButtonItem *item in self.convVC_Mini.rightBarButtonItems) {
              if ([showRightBarButtonItems containsObject:item]) {
                  item.customView.hidden = NO;
              } else {
                  item.customView.hidden = YES;
              }
          }
          [self.convVC_Mini.showRightBarButtonItems removeAllObjects];
        }];

    [[[RACObserve(self.contactsVC_Mini, showRightBarButtonItems) distinctUntilChanged] skip:1]
        subscribeNext:^(NSArray<UIBarButtonItem *> *showRightBarButtonItems) {
          self.contactsShowRightBarButtonItems = [showRightBarButtonItems copy];
          UIBarButtonItem *item = showRightBarButtonItems.firstObject;
          if (![gImWindow.subviews containsObject:item.customView]) {
              item.customView.mm_x = Screen_Width - kScale375(40);
              item.customView.mm_centerY = self.dismissWindowBtn.mm_centerY;
              [gImWindow addSubview:item.customView];
          }
          item.customView.hidden = NO;
          [self.contactsVC_Mini.showRightBarButtonItems removeAllObjects];
        }];

    CGFloat vcOffsetY = 120;
    [[[RACObserve(self.convVC_Mini, conv) distinctUntilChanged] skip:1] subscribeNext:^(TUIConversationListController_Minimalist *conv) {
      UIViewController *vc = (UIViewController *)conv;
      vc.view.frame = CGRectMake(0, vcOffsetY, self.view.mm_w, self.view.mm_h - vcOffsetY);
    }];

    [[[RACObserve(self.contactsVC_Mini, contact) distinctUntilChanged] skip:1] subscribeNext:^(TUIContactController_Minimalist *contact) {
      UIViewController *vc = (UIViewController *)contact;
      vc.view.frame = CGRectMake(0, vcOffsetY, self.view.mm_w, self.view.mm_h - vcOffsetY);
    }];

    [[[RACObserve(self.settingVC_Mini, setting) distinctUntilChanged] skip:1] subscribeNext:^(TUISettingController_Minimalist *setting) {
      UIViewController *vc = (UIViewController *)setting;
      vc.view.frame = CGRectMake(0, vcOffsetY, self.view.mm_w, self.view.mm_h - vcOffsetY);
    }];

    [[[RACObserve(self.callingVC, callsVC) distinctUntilChanged] skip:1] subscribeNext:^(UIViewController *callsVC) {
      if (self.callingVC.isMimimalist) {
          callsVC.view.frame = CGRectMake(0, 40, self.view.mm_w, self.view.mm_h - 40);
      }
    }];

    [[[RACObserve(self, inConversationVC) distinctUntilChanged] skip:1] subscribeNext:^(NSNumber *inConversationVC) {
      if (YES == [inConversationVC boolValue]) {
          [self showConvBarButtonItems:YES];
          [self showContactBarButtonItems:NO];
          [self showSettingBarButtonItems:NO];
      }
    }];

    [[[RACObserve(self, inContactsVC) distinctUntilChanged] skip:1] subscribeNext:^(NSNumber *inContactsVC) {
      if (YES == [inContactsVC boolValue]) {
          [self showContactBarButtonItems:YES];
          [self showConvBarButtonItems:NO];
          [self showSettingBarButtonItems:NO];
      }
    }];

    [[[RACObserve(self, inSettingVC) distinctUntilChanged] skip:1] subscribeNext:^(NSNumber *inSettingVC) {
      if (YES == [inSettingVC boolValue]) {
          [self showConvBarButtonItems:NO];
          [self showContactBarButtonItems:NO];
          [self showSettingBarButtonItems:YES];
      }
    }];

    [[[RACObserve(self, inCallsRecordVC) distinctUntilChanged] skip:1] subscribeNext:^(NSNumber *inCallsRecordVC) {
      if (YES == [inCallsRecordVC boolValue]) {
          [self showConvBarButtonItems:NO];
          [self showContactBarButtonItems:NO];
          [self showContactBarButtonItems:NO];
      }
    }];
}

- (void)showConvBarButtonItems:(BOOL)isShow {
    for (UIBarButtonItem *item in self.convShowLeftBarButtonItems) {
        item.customView.hidden = !isShow;
    }
    for (UIBarButtonItem *item in self.convShowRightBarButtonItems) {
        item.customView.hidden = !isShow;
    }
}

- (void)showContactBarButtonItems:(BOOL)isShow {
    for (UIBarButtonItem *item in self.contactsShowLeftBarButtonItems) {
        item.customView.hidden = !isShow;
    }
    for (UIBarButtonItem *item in self.contactsShowRightBarButtonItems) {
        item.customView.hidden = !isShow;
    }
}

- (void)showSettingBarButtonItems:(BOOL)isShow {
    for (UIBarButtonItem *item in self.settingShowLeftBarButtonItems) {
        item.customView.hidden = !isShow;
    }
}

- (UITabBarController *)getMainController {
    if ([TUIStyleSelectViewController isClassicEntrance]) {
        return [self getMainController_Classic];
    } else {
        return [self getMainController_Minimalist];
    }
}

- (UITabBarController *)getMainController_Classic {
    self.tbc = [[TUITabBarController alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    TUITabBarItem *msgItem = [[TUITabBarItem alloc] init];
    msgItem.title = TIMCommonLocalizableString(TIMAppTabBarItemMessageText);
    msgItem.identity = @"msgItem";
    msgItem.selectedImage = TUIDemoDynamicImage(@"tab_msg_selected_img", [UIImage imageNamed:TUIDemoImagePath(@"session_selected")]);
    msgItem.normalImage = TUIDemoDynamicImage(@"tab_msg_normal_img", [UIImage imageNamed:TUIDemoImagePath(@"session_normal")]);
    ConversationController *convVC = [[ConversationController alloc] init];
    @weakify(self);
    convVC.viewWillAppear = ^(BOOL isAppear) {
      @strongify(self);
      self.inConversationVC = isAppear;
      if ((self.inContactsVC || self.inSettingVC || self.inCallsRecordVC) && !isAppear) {
          return;
      }
      self.dismissWindowBtn.hidden = !isAppear;
    };
    msgItem.controller = [[TUINavigationController alloc] initWithRootViewController:convVC];
    msgItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    msgItem.badgeView = [[TUIBadgeView alloc] init];
    msgItem.badgeView.clearCallback = ^{
      @strongify(self);
      [self redpoint_clearUnreadMessage];
    };
    [items addObject:msgItem];

    TUITabBarItem *callsItem = [self getCallsRecordTabBarItem:NO];
    if (callsItem) {
        [items addObject:callsItem];
    }

    TUITabBarItem *contactItem = [[TUITabBarItem alloc] init];
    contactItem.title = TIMCommonLocalizableString(TIMAppTabBarItemContactText);
    contactItem.identity = @"contactItem";
    contactItem.selectedImage = TUIDemoDynamicImage(@"tab_contact_selected_img", [UIImage imageNamed:TUIDemoImagePath(@"contact_selected")]);
    contactItem.normalImage = TUIDemoDynamicImage(@"tab_contact_normal_img", [UIImage imageNamed:TUIDemoImagePath(@"contact_normal")]);
    ContactsController *contactVC = [[ContactsController alloc] init];
    contactVC.viewWillAppear = ^(BOOL isAppear) {
      @strongify(self);
      self.inContactsVC = isAppear;
      if ((self.inConversationVC || self.inSettingVC || self.inCallsRecordVC) && !isAppear) {
          return;
      }
      self.dismissWindowBtn.hidden = !isAppear;
    };
    contactItem.controller = [[TUINavigationController alloc] initWithRootViewController:contactVC];
    contactItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    contactItem.badgeView = [[TUIBadgeView alloc] init];
    [items addObject:contactItem];

    TUITabBarItem *setItem = [[TUITabBarItem alloc] init];
    setItem.title = TIMCommonLocalizableString(TIMAppTabBarItemMeText);
    setItem.identity = @"setItem";
    setItem.selectedImage = TUIDemoDynamicImage(@"tab_me_selected_img", [UIImage imageNamed:TUIDemoImagePath(@"myself_selected")]);
    setItem.normalImage = TUIDemoDynamicImage(@"tab_me_normal_img", [UIImage imageNamed:TUIDemoImagePath(@"myself_normal")]);
    SettingController *setVC = [[SettingController alloc] init];
    setVC.showPersonalCell = NO;
    NSString *appName = [TUICore callService:@"TUICore_ConfigureService" method:@"TUICore_ConfigureService_getAppName" param:nil];
    setVC.showSelectStyleCell = [appName isEqualToString:@"RTCube"];
    setVC.showChangeThemeCell = YES;
    setVC.showAboutIMCell = NO;
    setVC.showLoginOutCell = NO;
    setVC.viewWillAppear = ^(BOOL isAppear) {
      @strongify(self);
      self.inSettingVC = isAppear;
      if ((self.inConversationVC || self.inContactsVC || self.inCallsRecordVC) && !isAppear) {
          return;
      }
      self.dismissWindowBtn.hidden = !isAppear;
    };
    setVC.changeStyle = ^{
      @strongify(self);
      [self updateIMWindow];
    };
    setVC.changeTheme = ^{
      @strongify(self);
      [self updateIMWindow];
    };
    setItem.controller = [[TUINavigationController alloc] initWithRootViewController:setVC];
    setItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [items addObject:setItem];
    self.tbc.tabBarItems = items;

    switch (self.defaultVC) {
        case DefaultVC_Conversation:
            self.tbc.selectedIndex = [items indexOfObject:msgItem];
            break;
        case DefaultVC_Contact:
            self.tbc.selectedIndex = [items indexOfObject:contactItem];
            break;
        case DefaultVC_Setting:
            self.tbc.selectedIndex = [items indexOfObject:setItem];
            break;
        default:
            break;
    }

    return self.tbc;
}

- (UITabBarController *)getMainController_Minimalist {
    self.tbc = [[TUITabBarController alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    TUITabBarItem *msgItem = [[TUITabBarItem alloc] init];
    msgItem.title = TIMCommonLocalizableString(TIMAppTabBarItemMessageText_mini);
    msgItem.identity = @"msgItem";
    msgItem.selectedImage = TUIDemoDynamicImage(@"tab_msg_selected_img", [UIImage imageNamed:TUIDemoImagePath(@"session_selected")]);
    msgItem.normalImage = TUIDemoDynamicImage(@"tab_msg_normal_img", [UIImage imageNamed:TUIDemoImagePath(@"session_normal")]);
    self.convVC_Mini = [[ConversationController_Minimalist alloc] init];
    @weakify(self);
    self.convVC_Mini.viewWillAppear = ^(BOOL isAppear) {
      @strongify(self);
      self.inConversationVC = isAppear;
      if ((self.inContactsVC || self.inSettingVC || self.inCallsRecordVC) && !isAppear) {
          return;
      }
      self.dismissWindowBtn.hidden = !isAppear;
    };
    msgItem.controller = [[TUINavigationController alloc] initWithRootViewController:self.convVC_Mini];
    msgItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TController_Background_Color_Dark];
    msgItem.badgeView = [[TUIBadgeView alloc] init];
    msgItem.badgeView.clearCallback = ^{
      @strongify(self);
      [self redpoint_clearUnreadMessage];
    };
    [items addObject:msgItem];

    TUITabBarItem *callsItem = [self getCallsRecordTabBarItem:YES];
    if (callsItem) {
        [items addObject:callsItem];
    }

    TUITabBarItem *contactItem = [[TUITabBarItem alloc] init];
    contactItem.title = TIMCommonLocalizableString(TIMAppTabBarItemContactText_mini);
    contactItem.identity = @"contactItem";
    contactItem.selectedImage = TUIDemoDynamicImage(@"tab_contact_selected_img", [UIImage imageNamed:TUIDemoImagePath(@"contact_selected")]);
    contactItem.normalImage = TUIDemoDynamicImage(@"tab_contact_normal_img", [UIImage imageNamed:TUIDemoImagePath(@"contact_normal")]);
    self.contactsVC_Mini = [[ContactsController_Minimalist alloc] init];
    self.contactsVC_Mini.viewWillAppear = ^(BOOL isAppear) {
      @strongify(self);
      self.inContactsVC = isAppear;
      if ((self.inConversationVC || self.inSettingVC || self.inCallsRecordVC) && !isAppear) {
          return;
      }
      self.dismissWindowBtn.hidden = !isAppear;
    };
    contactItem.controller = [[TUINavigationController alloc] initWithRootViewController:self.contactsVC_Mini];
    contactItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TController_Background_Color_Dark];
    contactItem.badgeView = [[TUIBadgeView alloc] init];
    [items addObject:contactItem];

    TUITabBarItem *setItem = [[TUITabBarItem alloc] init];
    setItem.title = TIMCommonLocalizableString(TIMAppTabBarItemSettingText_mini);
    setItem.identity = @"setItem";
    setItem.selectedImage = TUIDemoDynamicImage(@"tab_me_selected_img", [UIImage imageNamed:TUIDemoImagePath(@"myself_selected")]);
    setItem.normalImage = TUIDemoDynamicImage(@"tab_me_normal_img", [UIImage imageNamed:TUIDemoImagePath(@"myself_normal")]);
    self.settingVC_Mini = [[SettingController_Minimalist alloc] init];
    self.settingVC_Mini.showPersonalCell = NO;
    NSString *appName = [TUICore callService:@"TUICore_ConfigureService" method:@"TUICore_ConfigureService_getAppName" param:nil];
    self.settingVC_Mini.showSelectStyleCell = [appName isEqualToString:@"RTCube"];
    self.settingVC_Mini.showChangeThemeCell = YES;
    self.settingVC_Mini.showAboutIMCell = NO;
    self.settingVC_Mini.showLoginOutCell = NO;
    self.settingVC_Mini.viewWillAppear = ^(BOOL isAppear) {
      @strongify(self);
      self.inSettingVC = isAppear;
      if ((self.inConversationVC || self.inContactsVC || self.inCallsRecordVC) && !isAppear) {
          return;
      }
      self.dismissWindowBtn.hidden = !isAppear;
    };
    self.settingVC_Mini.changeStyle = ^{
      @strongify(self);
      [self updateIMWindow];
    };
    self.settingVC_Mini.changeTheme = ^{
      @strongify(self);
      [self updateIMWindow];
    };
    setItem.controller = [[TUINavigationController alloc] initWithRootViewController:self.settingVC_Mini];
    setItem.controller.view.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TController_Background_Color_Dark];
    [items addObject:setItem];
    self.tbc.tabBarItems = items;

    switch (self.defaultVC) {
        case DefaultVC_Conversation:
            self.tbc.selectedIndex = [items indexOfObject:msgItem];
            break;
        case DefaultVC_Contact:
            self.tbc.selectedIndex = [items indexOfObject:contactItem];
            break;
        case DefaultVC_Setting:
            self.tbc.selectedIndex = [items indexOfObject:setItem];
            break;
        default:
            break;
    }

    self.tbc.tabBar.backgroundColor = [UIColor whiteColor];
    self.tbc.tabBar.barTintColor = [UIColor whiteColor];
    return self.tbc;
}

- (void)setMarkUnreadMap:(NSMutableDictionary *)markUnreadMap {
    objc_setAssociatedObject(self, @selector(markUnreadMap), markUnreadMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)markUnreadMap {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)redpoint_clearUnreadMessage {
    NSLog(@"[Redpoint] %s", __func__);
    @weakify(self);
    [V2TIMManager.sharedInstance cleanConversationUnreadMessageCount:@"" cleanTimestamp:0 cleanSequence:0 succ:^{
        @strongify(self);
        [TUITool makeToast:TIMCommonLocalizableString(TIMAppMarkAllMessageAsReadSucc)];
        [self onTotalUnreadCountChanged:0];
    } fail:^(int code, NSString *desc) {
        @strongify(self);
        [TUITool makeToast:[NSString stringWithFormat:TIMCommonLocalizableString(TIMAppMarkAllMessageAsReadErrFormat), code, desc]];
        [self onTotalUnreadCountChanged:self.unReadCount];
    }];
    NSArray *conversations = [self.markUnreadMap allKeys];
    if (conversations.count) {
        [V2TIMManager.sharedInstance markConversation:conversations markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD) enableMark:NO succ:nil fail:nil];
    }
}

- (void)onTotalUnreadCountChanged:(UInt64)totalUnreadCount {
    NSLog(@"[Redpoint] %s, %llu", __func__, totalUnreadCount);
    NSUInteger total = totalUnreadCount;
    TUITabBarItem *item = self.tbc.tabBarItems.firstObject;
    item.badgeView.title = total ? [NSString stringWithFormat:@"%@", total > 99 ? @"99+" : @(total)] : nil;
    self.unReadCount = total;
}

- (TUIContactViewDataProvider *)contactDataProvider {
    if (_contactDataProvider == nil) {
        _contactDataProvider = [[TUIContactViewDataProvider alloc] init];
    }
    return _contactDataProvider;
}

- (void)redpoint_setupTotalUnreadCount {
    NSLog(@"[Redpoint] %s", __func__);
    // Getting total unread count
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance
        getTotalUnreadMessageCount:^(UInt64 totalCount) {
          [weakSelf onTotalUnreadCountChanged:totalCount];
        }
                              fail:^(int code, NSString *desc){

                              }];

    // Getting the count of friends application
    @weakify(self);
    [RACObserve(self.contactDataProvider, pendencyCnt) subscribeNext:^(NSNumber *x) {
      @strongify(self);
      [self onFriendApplicationCountChanged:[x integerValue]];
    }];
    [self.contactDataProvider loadFriendApplication];
}

- (void)onFriendApplicationCountChanged:(NSInteger)applicationCount {
    NSLog(@"[Redpoint] %s, %zd", __func__, applicationCount);
    TUITabBarController *tab = self.tbc;
    if (tab.tabBarItems.count < 2) {
        return;
    }
    TUITabBarItem *contactItem = nil;
    for (TUITabBarItem *item in tab.tabBarItems) {
        if ([item.identity isEqualToString:@"contactItem"]) {
            contactItem = item;
            break;
        }
    }
    contactItem.badgeView.title = applicationCount == 0 ? @"" : [NSString stringWithFormat:@"%zd", applicationCount];
}

- (NSInteger)caculateRealResultAboutSDKTotalCount:(UInt64)totalCount
                                  markUnreadCount:(NSInteger)markUnreadCount
                              markHideUnreadCount:(NSInteger)markHideUnreadCount {
    NSInteger unreadCalculationResults = totalCount + markUnreadCount - markHideUnreadCount;
    if (unreadCalculationResults < 0) {
        // error protect
        unreadCalculationResults = 0;
    }
    return unreadCalculationResults;
}

#pragma mark - NSNotification
- (void)updateMarkUnreadCount:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    NSInteger markUnreadCount = [[userInfo objectForKey:TUIKitNotification_onConversationMarkUnreadCountChanged_MarkUnreadCount] integerValue];
    NSInteger markHideUnreadCount = [[userInfo objectForKey:TUIKitNotification_onConversationMarkUnreadCountChanged_MarkHideUnreadCount] integerValue];
    self.markUnreadCount = markUnreadCount;
    self.markHideUnreadCount = markHideUnreadCount;
    if ([userInfo objectForKey:TUIKitNotification_onConversationMarkUnreadCountChanged_MarkUnreadMap]) {
        self.markUnreadMap =
            [NSMutableDictionary dictionaryWithDictionary:[userInfo objectForKey:TUIKitNotification_onConversationMarkUnreadCountChanged_MarkUnreadMap]];
    }
    @weakify(self);
    [V2TIMManager.sharedInstance
        getTotalUnreadMessageCount:^(UInt64 totalCount) {
          @strongify(self);
          NSInteger unreadCalculationResults = [self caculateRealResultAboutSDKTotalCount:totalCount
                                                                          markUnreadCount:markUnreadCount
                                                                      markHideUnreadCount:markHideUnreadCount];
          [self onTotalUnreadCountChanged:unreadCalculationResults];
        }
                              fail:^(int code, NSString *desc){
                              }];
}

- (uint32_t)onSetAPPUnreadCount {
    return (uint32_t)self.unReadCount;  // test
}

- (void)onDisplayCallsRecordForClassic:(NSNotification *)notice {
    [self onDisplayCallsRecord:notice isMinimalist:NO];
}

- (void)onDisplayCallsRecordForMinimalist:(NSNotification *)notice {
    [self onDisplayCallsRecord:notice isMinimalist:YES];
}

- (void)onDisplayCallsRecord:(NSNotification *)notice isMinimalist:(BOOL)isMinimalist {
    TUITabBarController *tabVC = (TUITabBarController *)gImWindow.rootViewController;
    NSNumber *value = notice.object;
    if (![value isKindOfClass:NSNumber.class] || ![tabVC isKindOfClass:TUITabBarController.class]) {
        return;
    }

    NSMutableArray *items = tabVC.tabBarItems;
    NSMutableArray *callItems = [NSMutableArray array];
    for (TUITabBarItem *item in items) {
        if ([item.identity isEqualToString:@"callItem"]) {
            [callItems addObject:item];
        }
    }
    [items removeObjectsInArray:callItems];

    BOOL isOn = value.boolValue;
    if (isOn) {
        TUITabBarItem *item = [self getCallsRecordTabBarItem:isMinimalist];
        if (item) {
            [items insertObject:item atIndex:1];
        }
    }
    tabVC.tabBarItems = items;

    [tabVC layoutBadgeViewIfNeeded];
    [self setupStyleWindow];
}

- (TUITabBarItem *)getCallsRecordTabBarItem:(BOOL)isMinimalist {
    BOOL showCallsRecord = isMinimalist ? [NSUserDefaults.standardUserDefaults boolForKey:kEnableCallsRecord_mini]
                                        : [NSUserDefaults.standardUserDefaults boolForKey:kEnableCallsRecord];
    self.callingVC = [TUICallingHistoryViewController createCallingHistoryViewController:isMinimalist];
    @weakify(self);
    self.callingVC.viewWillAppear = ^(BOOL isAppear) {
      @strongify(self);
      self.inCallsRecordVC = isAppear;
      if ((self.inConversationVC || self.inContactsVC || self.inSettingVC) && !isAppear) {
          return;
      }
      self.dismissWindowBtn.hidden = (isMinimalist ? !isAppear : YES);
    };
    if (showCallsRecord && self.callingVC) {
        NSString *title = isMinimalist ? TIMCommonLocalizableString(TIMAppTabBarItemCallsRecordText_mini) :
                                         TIMCommonLocalizableString(TIMAppTabBarItemCallsRecordText_mini);
        UIImage *selected = isMinimalist
                                ? TUIDynamicImage(@"", TUIThemeModuleDemo_Minimalist, [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"tab_calls_selected")])
                                : TUIDemoDynamicImage(@"tab_calls_selected_img", [UIImage imageNamed:TUIDemoImagePath(@"tab_calls_selected")]);
        UIImage *normal = isMinimalist
                              ? TUIDynamicImage(@"", TUIThemeModuleDemo_Minimalist, [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"tab_calls_normal")])
                              : TUIDemoDynamicImage(@"tab_calls_normal_img", [UIImage imageNamed:TUIDemoImagePath(@"tab_calls_normal")]);
        TUITabBarItem *callsItem = [[TUITabBarItem alloc] init];
        callsItem.title = title;
        callsItem.selectedImage = selected;
        callsItem.normalImage = normal;
        callsItem.controller = [[TUINavigationController alloc] initWithRootViewController:self.callingVC];
        callsItem.identity = @"callItem";
        return callsItem;
    }
    return nil;
}

#pragma mark V2TIMConversationListener
- (void)onTotalUnreadMessageCountChanged:(UInt64)totalUnreadCount {
    NSInteger unreadCalculationResults = [self caculateRealResultAboutSDKTotalCount:totalUnreadCount
                                                                    markUnreadCount:_markUnreadCount
                                                                markHideUnreadCount:_markHideUnreadCount];
    [self onTotalUnreadCountChanged:unreadCalculationResults];
}

#pragma mark TUIStyleSelectControllerDelegate
- (void)onSelectStyle:(TUIStyleSelectCellModel *)cellModel {
    if ([cellModel.styleID isEqualToString:@"Minimalist"]) {
        self.themeLabel.hidden = YES;
        self.themeSubLabel.hidden = YES;
        self.themeVC.view.hidden = YES;
    } else {
        self.themeLabel.hidden = NO;
        self.themeSubLabel.hidden = NO;
        self.themeVC.view.hidden = NO;
    }
}
@end
