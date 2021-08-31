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
#import "LoginController.h"
#import "AppDelegate.h"
#import "TUIProfileCardCell.h"
#import "TUIButtonCell.h"
#import "THeader.h"
#import "TTextEditController.h"
#import "TDateEditController.h"
#import "TIMUserProfile+DataProvider.h"
#import "TUIUserProfileDataProviderService.h"
#import "TCServiceManager.h"
#import "TCommonTextCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIImage+TUIKIT.h"
#import "TUIKit.h"
#import "ProfileController.h"
#import "PAirSandbox.h"
#import "TUIAvatarViewController.h"
#import "TCommonSwitchCell.h"
#import "TCUtil.h"
@import ImSDK_Plus;
#import "UIColor+TUIDarkMode.h"

#define SHEET_COMMON 1
#define SHEET_AGREE  2
#define SHEET_SEX    3
#define SHEET_V2API  4

@interface MyUserProfileExpresser : TUIUserProfileDataProviderService
@end

@implementation MyUserProfileExpresser

+ (id)shareInstance
{
    static MyUserProfileExpresser *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

/**
 *获取签名
 */
- (NSString *)getSignature:(V2TIMUserFullInfo *)profile
{
    NSString *ret = [super getSignature:profile];
    if (ret.length != 0)
        return ret;
    return NSLocalizedString(@"no_personal_signature", nil); // @"暂无个性签名";
}

@end

@interface SettingController () <UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) BOOL memoryReport;
@property V2TIMUserFullInfo *profile;
@property (nonatomic, strong) TUIProfileCardCellData *profileCellData;
@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[TCServiceManager shareInstance] registerService:@protocol(TUIUserProfileDataProviderServiceProtocol) implClass:[MyUserProfileExpresser class]];
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
    self.title = NSLocalizedString(@"TabBarItemMeText", nil);
    self.parentViewController.title = NSLocalizedString(@"TabBarItemMeText", nil);

    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

    [self.tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[TUIProfileCardCell class] forCellReuseIdentifier:@"personalCell"];
    [self.tableView registerClass:[TUIButtonCell class] forCellReuseIdentifier:@"buttonCell"];
    [self.tableView registerClass:[TCommonSwitchCell class] forCellReuseIdentifier:@"switchCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSelfInfoUpdated:) name:TUIKitNotification_onSelfInfoUpdated object:nil];
    
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

- (void)onSelfInfoUpdated:(NSNotification *)no {
    self.profile = no.object;
    [self setupData];
}

/**
 *初始化视图显示数据
 */
- (void)setupData
{

    _data = [NSMutableArray array];

    TUIProfileCardCellData *personal = [[TUIProfileCardCellData alloc] init];
    personal.identifier = self.profile.userID;
    personal.avatarImage = DefaultAvatarImage;
    personal.avatarUrl = [NSURL URLWithString:self.profile.faceURL];
    personal.name = [self.profile showName];
    personal.genderString = [self.profile showGender];
    personal.signature = [self.profile showSignature];
    personal.cselector = @selector(didSelectCommon);
    personal.showAccessory = YES;
    self.profileCellData = personal;
    [_data addObject:@[personal]];


    TCommonTextCellData *friendApply = [TCommonTextCellData new];
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

//    TCommonTextCellData *messageNotify = [TCommonTextCellData new];
//    messageNotify.key = @"消息提醒";
//    messageNotify.showAccessory = YES;
//    messageNotify.cselector = @selector(didSelectNotifySet);
    [_data addObject:@[friendApply]];

    TCommonTextCellData *about = [TCommonTextCellData new];
    about.key = NSLocalizedString(@"MeAbout", nil); // @"关于腾讯·云通信";
    about.showAccessory = YES;
    about.cselector = @selector(didSelectAbout);
    [_data addObject:@[about]];

    TCommonTextCellData *log = [TCommonTextCellData new];
    log.key = NSLocalizedString(@"MeDevelop", nil); // @"开发调试";
    log.showAccessory = YES;
    log.cselector = @selector(didSelectLog);
    [_data addObject:@[log]];
    
    TCommonSwitchCellData *memory = [TCommonSwitchCellData new];
    memory.title = NSLocalizedString(@"MeReportMemoryLeak", nil); // @"内存泄露上报";
    memory.on = self.memoryReport;
    memory.cswitchSelector = @selector(onNotifySwitch:);
    [_data addObject:@[memory]];

    TUIButtonCellData *button =  [[TUIButtonCellData alloc] init];
    button.title = NSLocalizedString(@"logout", nil); // @"退出登录";
    button.style = ButtonRedText;
    button.cbuttonSelector = @selector(logout:);
    [_data addObject:@[button]];

    [self.tableView reloadData];
}
#pragma mark - Table view data source
/**
 *  tableView委托函数
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = _data[indexPath.section];
    TCommonCellData *data = array[indexPath.row];

    return [data heightOfWidth:Screen_Width];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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
    }  else if([data isKindOfClass:[TCommonTextCellData class]]) {
        TCommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell fillWithData:(TCommonTextCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TCommonSwitchCellData class]]) {
        TCommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell" forIndexPath:indexPath];
        [cell fillWithData:(TCommonSwitchCellData *)data];
        return cell;
    }
    return nil;
}

- (void)didSelectCommon
{
    [self setupData];
    //点击个人资料，跳转到详细界面。
    ProfileController *test = [[ProfileController alloc] init];
    [self.navigationController pushViewController:test animated:YES];

}

/**
 *点击 消息提醒 后执行的函数，使用户能够对消息提醒模式作出设置
 *消息提醒视图可以阅读 NotifySetupController.m 详细了解
 */
- (void)didSelectNotifySet
{
//    [[TIMManager sharedInstance] getAPNSConfig:^(TIMAPNSConfig *config){
//        NotifySetupController *vc = [[NotifySetupController alloc] init:config];
//        [self.navigationController pushViewController:vc animated:YES];
//    } fail:^(int code, NSString *err){
//
//    }];
}

/**
 *点击 退出登录 后执行的函数，负责账户登出的操作
 */
- (void)logout:(TUIButtonCell *)cell
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"confirm_log_out", nil)/*@"确定退出吗"*/ message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self didConfirmLogout];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didConfirmLogout
{
    [[V2TIMManager sharedInstance] logout:^{
        [self didLogoutInSettingController:self];;
    } fail:^(int code, NSString *msg) {
        NSLog(@"退出登录失败");
    }];
}

/**
 *点击 好友申请 后执行的函数，使用户能够设置自己审核好友申请的程度
 */
- (void)onEditFriendApply
{
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

- (void)didLogoutInSettingController:(SettingController *)controller
{
    [[TUILocalStorage sharedInstance] logout];
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LoginController *login = [board instantiateViewControllerWithIdentifier:@"LoginController"];
    self.view.window.rootViewController = login;
}

- (void)didSelectAbout
{
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cloud.tencent.com/product/im"]
                                           options:@{} completionHandler:^(BOOL success) {
                                               if (success) {
                                                   NSLog(@"Opened url");
                                               }
                                           }];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cloud.tencent.com/product/im"]];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == SHEET_AGREE) {
        if (buttonIndex >= 3)
            return;
        self.profile.allowType = buttonIndex;
        [self setupData];
        V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
        info.allowType = [NSNumber numberWithInteger:buttonIndex].intValue;
        [[V2TIMManager sharedInstance] setSelfInfo:info succ:nil fail:nil];
    }
    else if (actionSheet.tag == SHEET_V2API) {
//        if (buttonIndex == 0) {
//            V2ManageTestViewController *vc = [[V2ManageTestViewController alloc] initWithNibName:@"V2ManageTestViewController" bundle:nil];
//            [self presentViewController:vc animated:YES completion:nil];
//        }
//        else if (buttonIndex == 1) {
//            V2GroupTestViewController *vc = [[V2GroupTestViewController alloc] initWithNibName:@"V2GroupTestViewController" bundle:nil];
//            [self presentViewController:vc animated:YES completion:nil];
//        }
//        else if (buttonIndex == 2) {
//            V2FriendTestViewController *vc = [[V2FriendTestViewController alloc] initWithNibName:@"V2FriendTestViewController" bundle:nil];
//            [self presentViewController:vc animated:YES completion:nil];
//        }
    }

}
- (void)didSelectLog
{
//#ifdef DEBUG
//    UIActionSheet *sheet = [[UIActionSheet alloc] init];
//    sheet.tag = SHEET_V2API;
//    [sheet addButtonWithTitle:@"manager + apns + message + conv"];
//    [sheet addButtonWithTitle:@"group"];
//    [sheet addButtonWithTitle:@"friend"];
//    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:@"取消"]];
//    [sheet setDelegate:self];
//    [sheet showInView:self.view];
//#else
    [[PAirSandbox sharedInstance] showSandboxBrowser];
//#endif
}

- (void)onNotifySwitch:(TCommonSwitchCell *)cell
{
    //定时去上报内存泄露，1min 上报一次
    if (cell.switcher.isOn) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW,5 *NSEC_PER_SEC);
        uint64_t intevel = 5 * NSEC_PER_SEC;
        dispatch_source_set_timer(_timer, start, intevel, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
            //[QAPMQQLeakProfile executeLeakCheck];
        });
        dispatch_resume(_timer);
        self.memoryReport = YES;
    } else {
        if (_timer) {
            dispatch_cancel(_timer);
            _timer = nil;
        }
        self.memoryReport = NO;
    }
}

/**
 *  点击头像查看大图的委托实现。
 */
-(void)didTapOnAvatar:(TUIProfileCardCell *)cell{
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}
@end
