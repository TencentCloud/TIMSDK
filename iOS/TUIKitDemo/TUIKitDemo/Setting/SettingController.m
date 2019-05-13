//
//  SettingController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "SettingController.h"
#import "LoginController.h"
#import "AppDelegate.h"
#import "TPersonalCommonCell.h"
#import "TButtonCell.h"
#import "THeader.h"
#import "TAlertView.h"
#import "IMMessageExt.h"
#import "TUserProfileController.h"
#import "TTextEditController.h"
#import "TDateEditController.h"
#import "NotifySetupController.h"
#import "KVOController/KVOController.h"
#import "TIMUserProfile+DataProvider.h"
#import "TDataProviderService.h"
#import "TCServiceManager.h"
#import "TCommonTextCell.h"
#import "MMLayout/UIView+MMLayout.h"
@import ImSDK;

#define SHEET_COMMON 1
#define SHEET_AGREE  2
#define SHEET_SEX    3

@interface MyUserProfileExpresser : TDataProviderService
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

- (NSString *)getSignature:(TIMUserProfile *)profile
{
    NSString *ret = [super getSignature:profile];
    if (ret.length != 0)
        return ret;
    return @"暂无个性签名";
}

@end

@interface SettingController () <TButtonCellDelegate, TAlertViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property TPersonalCommonCell *personalCell;
@property TUserProfileController *profileController;
@property TIMUserProfile *profile;
@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[TCServiceManager shareInstance] registerService:@protocol(TDataProviderServiceProtocol) implClass:[MyUserProfileExpresser class]];
    [self setupViews];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[TIMFriendshipManager sharedInstance] getSelfProfile:^(TIMUserProfile *profile) {
        [self setupData];
    } fail:^(int code, NSString *msg) {
        
    }];
}

- (void)setupViews
{
    self.title = @"我";
    self.parentViewController.title = @"我";
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = TSettingController_Background_Color;
    
    [self.tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[TPersonalCommonCell class] forCellReuseIdentifier:@"personalCell"];
    [self.tableView registerClass:[TButtonCell class] forCellReuseIdentifier:@"buttonCell"];

}

- (void)setupData
{
    self.profile = [[TIMFriendshipManager sharedInstance] querySelfProfile];

    _data = [NSMutableArray array];
    
    TPersonalCommonCellData *personal = [[TPersonalCommonCellData alloc] init];
    personal.identifier = self.profile.identifier;
    personal.head = TUIKitResource(@"default_head");
    personal.name = [self.profile showName];
    personal.signature = [self.profile showSignature];
    personal.selector = @selector(didSelectCommon);
    [_data addObject:@[personal]];
    
    TCommonTextCellData *birthdayData = [TCommonTextCellData new];
    birthdayData.key = @"生日";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY年M月d日";
    if ([self.profile showBirthday])
        birthdayData.value = [formatter stringFromDate:[self.profile showBirthday]];
    birthdayData.showAccessory = YES;
    birthdayData.cselector = @selector(didSelectBirthday);
    
    TCommonTextCellData *sexData = [TCommonTextCellData new];
    sexData.key = @"性别";
    sexData.value = [self.profile showGender];
    sexData.showAccessory = YES;
    sexData.cselector = @selector(didSelectSex);
    
    TCommonTextCellData *localData = [TCommonTextCellData new];
    localData.key = @"所在地";
    localData.value = [self.profile showLocation];
    localData.showAccessory = YES;
    localData.cselector = @selector(didSelectLocal);
    [_data addObject:@[birthdayData, sexData, localData]];
    
    
    TCommonTextCellData *friendApply = [TCommonTextCellData new];
    friendApply.key = @"好友申请";
    friendApply.showAccessory = YES;
    friendApply.cselector = @selector(onEditFriendApply);
    if (self.profile.allowType == TIM_FRIEND_ALLOW_ANY) {
        friendApply.value = @"同意任何用户加好友";
    }
    if (self.profile.allowType == TIM_FRIEND_NEED_CONFIRM) {
        friendApply.value = @"需要验证";
    }
    if (self.profile.allowType == TIM_FRIEND_DENY_ANY) {
        friendApply.value = @"拒绝任何人加好友";
    }
    
    TCommonTextCellData *messageNotify = [TCommonTextCellData new];
    messageNotify.key = @"消息提醒";
    messageNotify.showAccessory = YES;
    messageNotify.cselector = @selector(didSelectNotifySet);
    [_data addObject:@[friendApply, messageNotify]];
    
    
    
    TButtonCellData *button =  [[TButtonCellData alloc] init];
    button.title = @"退 出";
    [_data addObject:@[button]];
    
    [self.tableView reloadData];
}
#pragma mark - Table view data source

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
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TPersonalCommonCellData class]]){
        return [TPersonalCommonCell getHeight];
    }
    else if([data isKindOfClass:[TButtonCellData class]]){
        return [TButtonCell getHeight];
    }

    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    SEL selector = 0;
    if ([data isKindOfClass:[TPersonalCommonCellData class]]){
        selector = ((TPersonalCommonCellData *)data).selector;
    }
    if (selector){
        [self performSelector:selector];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TPersonalCommonCellData class]]){
        TPersonalCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:TPersonalCommonCell_ReuseId];
        if(!cell){
            cell = [[TPersonalCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TPersonalCommonCell_ReuseId];
        }
        [cell setData:(TPersonalCommonCellData *)data];
        self.personalCell = cell;
        return cell;
    }
    else if([data isKindOfClass:[TButtonCellData class]]){
        TButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:TButtonCell_ReuseId];
        if(!cell){
            cell = [[TButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TButtonCell_ReuseId];
            cell.delegate = self;
        }
        [cell setData:(TButtonCellData *)data];
        return cell;
    }  else if([data isKindOfClass:[TCommonTextCellData class]]) {
        TCommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell fillWithData:(TCommonTextCellData *)data];
        return cell;
    }
    return nil;
}

- (void)didSelectCommon
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.tag = SHEET_COMMON;
    [sheet addButtonWithTitle:@"修改昵称"];
    [sheet addButtonWithTitle:@"修改个性签名"];
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:@"取消"]];
    [sheet setDelegate:self];
    [sheet showInView:self.view];
}

- (void)didSelectChangeNick
{
    TTextEditController *vc = [[TTextEditController alloc] initWithText:self.profile.nickname];
    vc.title = @"修改昵称";
    [self.navigationController pushViewController:vc animated:YES];
    
    [self.KVOControllerNonRetaining observe:vc keyPath:@"textValue" options:NSKeyValueObservingOptionNew block:^(SettingController *observer, TTextEditController *object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSString *nick = change[NSKeyValueChangeNewKey];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_Nick: nick}
                                                            succ:^{
                                                                [observer setupData];
                                                            } fail:nil];
    }];
}

- (void)didSelectChangeSignature
{
    TTextEditController *vc = [[TTextEditController alloc] initWithText:[self.profile showSignature]];
    vc.title = @"修改个性签名";
    [self.navigationController pushViewController:vc animated:YES];
    
    [self.KVOControllerNonRetaining observe:vc keyPath:@"textValue" options:NSKeyValueObservingOptionNew block:^(SettingController *observer, TTextEditController *object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSString *value = change[NSKeyValueChangeNewKey];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_SelfSignature: value}
                                                            succ:^{
                                                                [observer setupData];
                                                            } fail:nil];
    }];
}

- (void)didSelectLocal
{
    TTextEditController *vc = [[TTextEditController alloc] initWithText:[self.profile showLocation]];
    vc.title = @"修改所在地";
    [self.navigationController pushViewController:vc animated:YES];
    [self.KVOControllerNonRetaining observe:vc keyPath:@"textValue" options:NSKeyValueObservingOptionNew block:^(SettingController *observer, TTextEditController *object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSString *value = change[NSKeyValueChangeNewKey];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_Location: value}
                                                            succ:^{
                                                                [observer setupData];
                                                            } fail:nil];
    }];
}

- (void)didSelectNotifySet
{
    [[TIMManager sharedInstance] getAPNSConfig:^(TIMAPNSConfig *config){
        
        NotifySetupController *vc = [[NotifySetupController alloc] init:config];
        [self.navigationController pushViewController:vc animated:YES];
    } fail:^(int code, NSString *err){

    }];
}

- (void)didSelectBirthday
{
    TDateEditController *vc = [[TDateEditController alloc] initWithDate:[self.profile showBirthday]];
    vc.title = @"修改生日";
    [self.navigationController pushViewController:vc animated:YES];
    //监听值的改变
    [self.KVOControllerNonRetaining observe:vc keyPath:@"dateValue" options:NSKeyValueObservingOptionNew block:^(SettingController *observer, TTextEditController *object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSDate *value = change[NSKeyValueChangeNewKey];
        [observer.profile setShowBirthday:value];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_Birthday: @(observer.profile.birthday)}
                                                            succ:^{
                                                                [observer setupData];
                                                            } fail:nil];
    }];
}

- (void)didSelectSex
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.tag = SHEET_SEX;
    sheet.title = @"修改性别";
    [sheet addButtonWithTitle:@"男"];
    [sheet addButtonWithTitle:@"女"];
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:@"取消"]];
    [sheet setDelegate:self];
    [sheet showInView:self.view];
}

- (void)didTouchUpInsideInButtonCell:(TButtonCell *)cell
{
    TAlertView *alert = [[TAlertView alloc] initWithTitle:@"确定退出吗"];
    alert.delegate = self;
    [alert showInWindow:self.view.window];
}

- (void)didConfirmInAlertView:(TAlertView *)alertView
{
    [[TIMManager sharedInstance] logout:^{
        [self didLogoutInSettingController:self];
    } fail:^(int code, NSString *msg) {
        NSLog(@"");
    }];
}

- (void)onEditFriendApply
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.tag = SHEET_AGREE;
    [sheet addButtonWithTitle:@"同意任何用户加好友"];
    [sheet addButtonWithTitle:@"需要验证"];
    [sheet addButtonWithTitle:@"拒绝任何人加好友"];
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:@"取消"]];
    [sheet setDelegate:self];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == SHEET_AGREE) {
        if (buttonIndex >= 3)
            return;
        
        [self setupData];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_AllowType:[NSNumber numberWithInteger:buttonIndex]} succ:^{
            [self setupData];
        } fail:nil];
    }
    if (actionSheet.tag == SHEET_COMMON) {
        if (buttonIndex == 0) {
            [self didSelectChangeNick];
        }
        if (buttonIndex == 1) {
            [self didSelectChangeSignature];
        }
    }
    if (actionSheet.tag == SHEET_SEX) {
        TIMGender gender = TIM_GENDER_UNKNOWN;
        if (buttonIndex == 0) {
            gender = TIM_GENDER_MALE;
        }
        if (buttonIndex == 1) {
            gender = TIM_GENDER_FEMALE;
        }
        
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_Gender: @(gender)}
                                                            succ:^{
                                                                [self setupData];
                                                            } fail:nil];
    }
}

- (void)didLogoutInSettingController:(SettingController *)controller
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_User];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_Pwd];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_Sig];
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LoginController *login = [board instantiateViewControllerWithIdentifier:@"LoginController"];
    self.view.window.rootViewController = login;
}
@end
