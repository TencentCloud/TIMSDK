//
//  SettingController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 设置主界面视图
 *  本文件实现了设置视图控制器，即TabBar内 "我" 按钮对应的视图
 *
 *  您可以在此处查看、并修改您的个人信息，或是执行退出登录等操作
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import "SettingController.h"
#import "AppDelegate+Push.h"
#import "TUIProfileCardCell.h"
#import "TUIButtonCell.h"
#import "TUITextEditController.h"
#import "TUIDateEditController.h"
#import "TUICommonTextCell.h"
#import "UIView+TUILayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIKit.h"
#import "ProfileController.h"
#import "PAirSandbox.h"
#import "TUIAvatarViewController.h"
#import "TUICommonSwitchCell.h"
#import "TCUtil.h"

#import "TCLoginModel.h"
#import "TUIDarkModel.h"

#import "TUICommonModel.h"
#import "TUINaviBarIndicatorView.h"
#import "TUIThemeManager.h"


#import "TUIAboutUsViewController.h"

#define SHEET_COMMON 1
#define SHEET_AGREE  2
#define SHEET_SEX    3
#define SHEET_V2API  4


@interface SettingController () <UIActionSheetDelegate, V2TIMSDKListener>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) BOOL memoryReport;
@property V2TIMUserFullInfo *profile;
@property (nonatomic, strong) TUIProfileCardCellData *profileCellData;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];

    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    self.tableView.delaysContentTouches = NO;

}

//在此处设置一次 setuoData，才能使得“我”界面消息更新。否则由于 UITabBar 的维护，“我”界面的消息将一直无法更新。
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


#pragma mark - V2TIMSDKListener
- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info {
    self.profile = Info;
    [self setupData];
}

/**
 *初始化视图显示数据
 */
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
    friendApply.key = NSLocalizedString(@"MeFriendRequest", nil); // @"好友申请";
    friendApply.showAccessory = YES;
    friendApply.cselector = @selector(onEditFriendApply);
    if (self.profile.allowType == V2TIM_FRIEND_ALLOW_ANY) {
        friendApply.value = NSLocalizedString(@"MeFriendRequestMethodAgreeAll", nil); // @"同意任何用户加好友";
    }
    if (self.profile.allowType == V2TIM_FRIEND_NEED_CONFIRM) {
        friendApply.value = NSLocalizedString(@"MeFriendRequestMethodNeedConfirm", nil); // @"需要验证";
    }
    if (self.profile.allowType == V2TIM_FRIEND_DENY_ANY) {
        friendApply.value = NSLocalizedString(@"MeFriendRequestMethodDenyAll", nil); // @"拒绝任何人加好友";
    }
    [_data addObject:@[friendApply]];
    
    
    TUICommonTextCellData *about = [TUICommonTextCellData new];
    about.key = NSLocalizedString(@"MeAbout", nil); // @"关于腾讯·云通信";
    about.showAccessory = YES;
    about.cselector = @selector(didSelectAbout);
    [_data addObject:@[about]];
    
    

    TUIButtonCellData *button =  [[TUIButtonCellData alloc] init];
    button.title = NSLocalizedString(@"logout", nil); // @"退出登录";
    button.style = ButtonRedText;
    button.cbuttonSelector = @selector(logout:);
    [_data addObject:@[button]];

    [self.tableView reloadData];
}
#pragma mark - Table view data source
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TUIProfileCardCellData class]]){
        TUIProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personalCell" forIndexPath:indexPath];
        //设置 profileCard 的委托
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

- (void)didSelectCommon {
    [self setupData];
    //点击个人资料，跳转到详细界面。
    ProfileController *test = [[ProfileController alloc] init];
    [self.navigationController pushViewController:test animated:YES];
}

/**
 *点击 退出登录 后执行的函数，负责账户登出的操作
 */
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
    [[TUIKit sharedInstance] logout:^{
        [AppDelegate.sharedInstance push_unregisterIfLogouted];
        [self didLogoutInSettingController:self];
    } fail:^(int code, NSString *msg) {
        NSLog(@"退出登录失败");
    }];
    
}

/**
 *点击 好友申请 后执行的函数，使用户能够设置自己审核好友申请的程度
 */
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
}

/**
 *  点击头像查看大图的委托实现。
 */
- (void)didTapOnAvatar:(TUIProfileCardCell *)cell{
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}
@end
