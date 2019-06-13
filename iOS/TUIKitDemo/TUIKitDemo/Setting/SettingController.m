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
#import "TUIProfileCardCell.h"
#import "TUIButtonCell.h"
#import "THeader.h"
#import "TAlertView.h"
#import "IMMessageExt.h"
#import "TTextEditController.h"
#import "TDateEditController.h"
#import "NotifySetupController.h"
#import "TIMUserProfile+DataProvider.h"
#import "TUIUserProfileDataProviderService.h"
#import "TCServiceManager.h"
#import "TCommonTextCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIImage+TUIKIT.h"
#import "TUIKit.h"

@import ImSDK;

#define SHEET_COMMON 1
#define SHEET_AGREE  2
#define SHEET_SEX    3

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

- (NSString *)getSignature:(TIMUserProfile *)profile
{
    NSString *ret = [super getSignature:profile];
    if (ret.length != 0)
        return ret;
    return @"暂无个性签名";
}

- (NSString *)getLocation:(TIMUserProfile *)profile
{
    NSString *ret = [super getLocation:profile];
    if (ret.length != 0)
        return ret;
    return @"未知";
}

@end

@interface SettingController () <UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property TIMUserProfile *profile;
@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[TCServiceManager shareInstance] registerService:@protocol(TUIUserProfileDataProviderServiceProtocol) implClass:[MyUserProfileExpresser class]];
    [self setupViews];

}

- (void)setupViews
{
    self.title = @"我";
    self.parentViewController.title = @"我";
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = TSettingController_Background_Color;
    
    [self.tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[TUIProfileCardCell class] forCellReuseIdentifier:@"personalCell"];
    [self.tableView registerClass:[TUIButtonCell class] forCellReuseIdentifier:@"buttonCell"];

    [[TIMFriendshipManager sharedInstance] getSelfProfile:^(TIMUserProfile *profile) {
        self.profile = profile;
        [self setupData];
    } fail:^(int code, NSString *msg) {
        
    }];
}

- (void)setupData
{

    _data = [NSMutableArray array];
    
    TUIProfileCardCellData *personal = [[TUIProfileCardCellData alloc] init];
    personal.identifier = self.profile.identifier;
    personal.avatarImage = DefaultAvatarImage;
    personal.name = [self.profile showName];
    personal.signature = [self.profile showSignature];
    personal.cselector = @selector(didSelectCommon);
    personal.showAccessory = YES;
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
    
    TCommonTextCellData *about = [TCommonTextCellData new];
    about.key = @"关于云通信IM";
    about.showAccessory = YES;
    about.cselector = @selector(didSelectAbout);
    [_data addObject:@[about]];
    
    TUIButtonCellData *button =  [[TUIButtonCellData alloc] init];
    button.title = @"退出登录";
    button.style = ButtonRedText;
    button.cbuttonSelector = @selector(logout:);
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
    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.profile.nickname = x;
        [self setupData];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_Nick: x}
                                                            succ:nil fail:nil];
    }];
}

- (void)didSelectChangeSignature
{
    TTextEditController *vc = [[TTextEditController alloc] initWithText:[self.profile showSignature]];
    vc.title = @"修改个性签名";
    [self.navigationController pushViewController:vc animated:YES];
    
    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.profile.selfSignature = [x dataUsingEncoding:NSUTF8StringEncoding];
        [self setupData];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_SelfSignature: x}
                                                            succ:nil fail:nil];
    }];
}

- (void)didSelectLocal
{
    TTextEditController *vc = [[TTextEditController alloc] initWithText:[self.profile showLocation]];
    vc.title = @"修改所在地";
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.profile.location = [x dataUsingEncoding:NSUTF8StringEncoding];
        [self setupData];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_Location: x}
                                                            succ:nil fail:nil];
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
    @weakify(self)
    [[RACObserve(vc, dateValue) skip:1] subscribeNext:^(NSDate *value) {
        @strongify(self)
        [self.profile setShowBirthday:value];
        [self setupData];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_Birthday: @(self.profile.birthday)}
                                                            succ:nil fail:nil];
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

- (void)logout:(TUIButtonCell *)cell
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定退出吗" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self didConfirmLogout];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didConfirmLogout
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
        self.profile.allowType = buttonIndex;
        [self setupData];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_AllowType:[NSNumber numberWithInteger:buttonIndex]} succ:nil fail:nil];
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
        self.profile.gender = gender;
        [self setupData];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_Gender: @(gender)}
                                                            succ:nil fail:nil];
    }
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
@end
