//
//  SettingController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//
#import "SettingController.h"
#import "AppDelegate.h"
#import "TUIProfileCardCell.h"
#import "TUITextEditController.h"
#import "TUIDateEditController.h"
#import "TUICommonTextCell.h"
#import "UIView+TUILayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIKit.h"
#import "TUILogin.h"
#import "ProfileController.h"
#import "PAirSandbox.h"
#import "TUIAvatarViewController.h"
#import "TUICommonSwitchCell.h"
#import "TCUtil.h"
#import "TCLoginModel.h"
#import "TUIDarkModel.h"
#import "TUICommonModel.h"
#import "TUIThemeManager.h"
#import "TUIAboutUsViewController.h"
#import "TUIBaseChatViewController.h"
#import "TUIChatConfig.h"
#import <TUICore/TUIConfig.h>

NSString * kEnableMsgReadStatus = @"TUIKitDemo_EnableMsgReadStatus";
NSString * kEnableOnlineStatus = @"TUIKitDemo_EnableOnlineStatus";

@interface SettingController () <UIActionSheetDelegate, V2TIMSDKListener>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) BOOL memoryReport;
@property (nonatomic, strong) V2TIMUserFullInfo *profile;
@property (nonatomic, strong) TUIProfileCardCellData *profileCellData;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation SettingController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    
    self.tableView.delaysContentTouches = NO;
    [TUITool addUnsupportNotificationInVC:self debugOnly:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    if (loginUser.length > 0) {
        @weakify(self)
        [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            @strongify(self)
            self.profile = infoList.firstObject;
        } fail:nil];
    }
}

#pragma mark - Debug
- (void)setupViews
{
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:NSLocalizedString(@"TabBarItemMeText", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    
    self.parentViewController.title = NSLocalizedString(@"TabBarItemMeText", nil);
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapTest:)];
    tap.numberOfTapsRequired = 5;
    [self.parentViewController.view addGestureRecognizer:tap];

    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");
    
    //Fix  translucent = NO;
    CGRect rect = self.view.bounds;
    if (![UINavigationBar appearance].isTranslucent && [[[UIDevice currentDevice] systemVersion] doubleValue]<15.0) {
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - TabBar_Height - NavBar_Height );
        self.tableView.frame = rect;
    }
    
    [self.tableView registerClass:[TUICommonTextCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[TUIProfileCardCell class] forCellReuseIdentifier:@"personalCell"];
    [self.tableView registerClass:[TUIButtonCell class] forCellReuseIdentifier:@"buttonCell"];
    [self.tableView registerClass:[TUICommonSwitchCell class] forCellReuseIdentifier:@"switchCell"];
    
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    
    [[V2TIMManager sharedInstance] addIMSDKListener:self];
    
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    if (loginUser.length > 0) {
        @weakify(self)
        [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            @strongify(self)
            self.profile = infoList.firstObject;
            [self setupData];
        } fail:nil];
    }
}
- (void)onTapTest:(UIGestureRecognizer *)recognizer {
    //PRIVATEMARK
}

#pragma mark - V2TIMSDKListener
- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info {
    self.profile = Info;
    [self setupData];
}

#pragma mark - UITableView DataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0 : 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    TUICommonCellData *data = array[indexPath.row];

    return [data heightOfWidth:Screen_Width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TUIProfileCardCellData class]]){
        TUIProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personalCell" forIndexPath:indexPath];
        cell.delegate = self;
        [cell fillWithData:(TUIProfileCardCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TUIButtonCellData class]]){
        TUIButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:TButtonCell_ReuseId];
        if(!cell){
            cell = [[TUIButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TButtonCell_ReuseId];
        }
        [cell fillWithData:(TUIButtonCellData *)data];
        return cell;
    }  else if([data isKindOfClass:[TUICommonTextCellData class]]) {
        TUICommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonTextCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TUICommonSwitchCellData class]]) {
        TUICommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonSwitchCellData *)data];
        return cell;
    }
    return nil;
}

#pragma mark - Private
- (void)setupData {
    _data = [NSMutableArray array];

    TUIProfileCardCellData *personal = [[TUIProfileCardCellData alloc] init];
    personal.identifier = self.profile.userID;
    personal.avatarImage = DefaultAvatarImage;
    personal.avatarUrl = [NSURL URLWithString:self.profile.faceURL];
    personal.name = [self.profile showName];
    personal.genderString = [self.profile showGender];
    personal.signature = self.profile.selfSignature.length ? [NSString stringWithFormat:NSLocalizedString(@"SignatureFormat", nil), self.profile.selfSignature] : NSLocalizedString(@"no_personal_signature", nil);
    personal.cselector = @selector(didSelectCommon);
    personal.showAccessory = YES;
    personal.showSignature = YES;
    self.profileCellData = personal;
    [_data addObject:@[personal]];

    TUICommonTextCellData *friendApply = [TUICommonTextCellData new];
    friendApply.key = NSLocalizedString(@"MeFriendRequest", nil);
    friendApply.showAccessory = YES;
    friendApply.cselector = @selector(onEditFriendApply);
    if (self.profile.allowType == V2TIM_FRIEND_ALLOW_ANY) {
        friendApply.value = NSLocalizedString(@"MeFriendRequestMethodAgreeAll", nil);
    }
    if (self.profile.allowType == V2TIM_FRIEND_NEED_CONFIRM) {
        friendApply.value = NSLocalizedString(@"MeFriendRequestMethodNeedConfirm", nil);
    }
    if (self.profile.allowType == V2TIM_FRIEND_DENY_ANY) {
        friendApply.value = NSLocalizedString(@"MeFriendRequestMethodDenyAll", nil);
    }
    [_data addObject:@[friendApply]];
    
    TUICommonSwitchCellData *msgReadStatus = [TUICommonSwitchCellData new];
    msgReadStatus.title =  NSLocalizedString(@"MeMessageReadStatus", nil);
    msgReadStatus.desc = [self msgReadStatus] ? NSLocalizedString(@"MeMessageReadStatusOpenDesc", nil) : NSLocalizedString(@"MeMessageReadStatusCloseDesc", nil);
    msgReadStatus.cswitchSelector = @selector(onSwitchMsgReadStatus:);
    msgReadStatus.on = [self msgReadStatus];
    [_data addObject:@[msgReadStatus]];
    
    TUICommonSwitchCellData *onlineStatus = [TUICommonSwitchCellData new];
    onlineStatus.title =  NSLocalizedString(@"ShowOnlineStatus", nil);
    onlineStatus.desc = [self onlineStatus] ? NSLocalizedString(@"ShowOnlineStatusOpenDesc", nil) : NSLocalizedString(@"ShowOnlineStatusCloseDesc", nil);
    onlineStatus.cswitchSelector = @selector(onSwitchOnlineStatus:);
    onlineStatus.on = [self onlineStatus];
    [_data addObject:@[onlineStatus]];
    
    TUICommonTextCellData *about = [TUICommonTextCellData new];
    about.key = NSLocalizedString(@"MeAbout", nil);
    about.showAccessory = YES;
    about.cselector = @selector(didSelectAbout);
    [_data addObject:@[about]];
    
    TUIButtonCellData *button =  [[TUIButtonCellData alloc] init];
    button.title = NSLocalizedString(@"logout", nil);
    button.style = ButtonRedText;
    button.cbuttonSelector = @selector(logout:);
    button.hideSeparatorLine = YES;
    [_data addObject:@[button]];
    
    
    [self.tableView reloadData];
}

#pragma mark -- Event
- (void)didSelectCommon {
    [self setupData];
    ProfileController *test = [[ProfileController alloc] init];
    [self.navigationController pushViewController:test animated:YES];
}

- (void)logout:(TUIButtonCell *)cell {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"confirm_log_out", nil)/*@"确定退出吗"*/ message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self didConfirmLogout];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didConfirmLogout {
    [TUILogin logout:^{
        [[TCLoginModel sharedInstance] clearLoginedInfo];
        [self didLogoutInSettingController:self];
    } fail:^(int code, NSString *msg) {
        NSLog(@"logout fail");
    }];
    
}

- (void)onEditFriendApply {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.tag = SHEET_AGREE;
    [sheet addButtonWithTitle:NSLocalizedString(@"MeFriendRequestMethodAgreeAll", nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"MeFriendRequestMethodNeedConfirm", nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"MeFriendRequestMethodDenyAll", nil)];
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:NSLocalizedString(@"cancel", nil)]];
    [sheet setDelegate:self];
    [sheet showInView:self.view];
    [self setupData];
}

- (void)didLogoutInSettingController:(SettingController *)controller {
    UIViewController *loginVc = [AppDelegate.sharedInstance getLoginController];
    self.view.window.rootViewController = loginVc;
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TUILoginShowPrivacyPopViewNotfication" object:nil];
}

- (void)didSelectAbout {
    TUIAboutUsViewController *vc = [[TUIAboutUsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == SHEET_AGREE) {
        if (buttonIndex >= 3)
            return;
        self.profile.allowType = buttonIndex;
        [self setupData];
        V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
        info.allowType = [NSNumber numberWithInteger:buttonIndex].intValue;
        [[V2TIMManager sharedInstance] setSelfInfo:info succ:nil fail:nil];
    }
    //PRIVATEMARK
}

- (void)didTapOnAvatar:(TUIProfileCardCell *)cell{
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}

- (void)onSwitchMsgReadStatus:(TUICommonSwitchCell *)cell {
    [self setReadStatus:cell.switcher.on];
    
    BOOL on = cell.switcher.isOn;
    TUICommonSwitchCellData *switchData = cell.switchData;
    switchData.on = on;
    if (on) {
        switchData.desc = NSLocalizedString(@"MeMessageReadStatusOpenDesc", nil);
        [TUITool hideToast];
        [TUITool makeToast:NSLocalizedString(@"ShowPackageToast", nil)];
    } else {
        switchData.desc = NSLocalizedString(@"MeMessageReadStatusCloseDesc", nil);
    }
    [cell fillWithData:switchData];
}

- (BOOL)msgReadStatus {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kEnableMsgReadStatus];
}

- (void)setReadStatus:(BOOL)on {
    [TUIChatConfig defaultConfig].msgNeedReadReceipt = on;
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:kEnableMsgReadStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)onSwitchOnlineStatus:(TUICommonSwitchCell *)cell {
    BOOL on = cell.switcher.isOn;
    TUICommonSwitchCellData *switchData = cell.switchData;
    switchData.on = on;
    if (on) {
        switchData.desc = NSLocalizedString(@"ShowOnlineStatusOpenDesc", nil);
    } else {
        switchData.desc = NSLocalizedString(@"ShowOnlineStatusCloseDesc", nil);
    }
    
    TUIConfig.defaultConfig.displayOnlineStatusIcon = on;
    [NSUserDefaults.standardUserDefaults setBool:on forKey:kEnableOnlineStatus];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    if (on) {
        [TUITool hideToast];
        [TUITool makeToast:NSLocalizedString(@"ShowPackageToast", nil)];
    }
    
    [cell fillWithData:switchData];
}

- (BOOL)onlineStatus {
    return [NSUserDefaults.standardUserDefaults boolForKey:kEnableOnlineStatus];
}

@end
