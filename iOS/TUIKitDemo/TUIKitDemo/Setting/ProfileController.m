//
//  SettingController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "ProfileController.h"
#import "LoginController.h"
#import "AppDelegate.h"
#import "TUIButtonCell.h"
#import "THeader.h"
#import "ImSDK.h"
#import "TTextEditController.h"
#import "TDateEditController.h"
#import "NotifySetupController.h"
#import "TIMUserProfile+DataProvider.h"
#import "TUIUserProfileDataProviderService.h"
#import "TCServiceManager.h"
#import "TCommonTextCell.h"
#import "TCommonAvatarCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIImage+TUIKIT.h"
#import "TUIKit.h"
#import "THelper.h"

#import <ImSDK/ImSDK.h>

#define SHEET_COMMON 1
#define SHEET_AGREE  2
#define SHEET_SEX    3

@interface UserProfileExpresser : TUIUserProfileDataProviderService
@end

@implementation UserProfileExpresser

+ (id)shareInstance
{
    static UserProfileExpresser *shareInstance;
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
    return @"未设置";
}

@end

@interface ProfileController () <UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property TIMUserProfile *profile;
@end

@implementation ProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[TCServiceManager shareInstance] registerService:@protocol(TUIUserProfileDataProviderServiceProtocol) implClass:[UserProfileExpresser class]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addLongPressGesture];//添加长按手势
    [self setupViews];

    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    self.tableView.delaysContentTouches = NO;
}
//实现该委托，保证数据刷新，同时保证 cell 的 select 能够符合显示逻辑

- (void)setupViews
{
    self.title = @"个人信息";
    self.parentViewController.title = @"个人信息";

    //self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = TSettingController_Background_Color;
    self.clearsSelectionOnViewWillAppear = YES;

    [self.tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[TCommonAvatarCell class] forCellReuseIdentifier:@"avatarCell"];

    [[TIMFriendshipManager sharedInstance] getSelfProfile:^(TIMUserProfile *profile) {
        self.profile = profile;
        [self setupData];
    } fail:^(int code, NSString *msg) {

    }];
}

- (void)setupData
{

    _data = [NSMutableArray array];

    TCommonAvatarCellData *avatarData = [TCommonAvatarCellData new];
    avatarData.key = @"头像";
    avatarData.showAccessory = YES;
    avatarData.cselector = @selector(didSelectAvatar);
    avatarData.avatarUrl = [NSURL URLWithString:self.profile.faceURL];
    [_data addObject:@[avatarData]];

    TCommonTextCellData *nicknameData = [TCommonTextCellData new];
    nicknameData.key = @"昵称";
    nicknameData.value = self.profile.showName;
    nicknameData.showAccessory = YES;
    nicknameData.cselector = @selector(didSelectChangeNick);

    TCommonTextCellData *IDData = [TCommonTextCellData new];
    IDData.key = @"账号";
    IDData.value = self.profile.identifier;
    IDData.showAccessory = NO;
    [_data addObject:@[nicknameData, IDData]];

    TCommonTextCellData *birthdayData = [TCommonTextCellData new];
    birthdayData.key = @"生日";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY年M月d日";
    if ([self.profile showBirthday])
        birthdayData.value = [formatter stringFromDate:[self.profile showBirthday]];
    else birthdayData.value = @"未设置";
    birthdayData.showAccessory = YES;
    birthdayData.cselector = @selector(didSelectBirthday);

    TCommonTextCellData *signatureData = [TCommonTextCellData new];
    signatureData.key = @"个性签名";
    signatureData.value = self.profile.showSignature;
    signatureData.showAccessory = YES;
    signatureData.cselector = @selector(didSelectChangeSignature);

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
    [_data addObject:@[signatureData, birthdayData, sexData, localData]];


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

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TCommonTextCellData class]]) {
        TCommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell fillWithData:(TCommonTextCellData *)data];
        return cell;
    }  else if([data isKindOfClass:[TCommonAvatarCellData class]]){
        TCommonAvatarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"avatarCell" forIndexPath:indexPath];
        [cell fillWithData:(TCommonAvatarCellData *)data];
        return cell;
    }
    return nil;
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

- (void)didSelectAvatar
{
    //点击头像的响应函数，换头像，上传头像URL
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"TUIKit为您选择一个头像" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = [THelper randAvatarUrl];
        [self.profile setFaceURL:url];
        [self setupData];
        [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_FaceUrl: self.profile.faceURL}
                                                            succ:nil fail:nil];

    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

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

/**
 *  以下两个函数实现了长按的复制功能。
 */
- (void)addLongPressGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressAtCell:)];
    [self.tableView addGestureRecognizer:longPress];
}

-(void) didLongPressAtCell:(UILongPressGestureRecognizer *)longPress {
    if(longPress.state == UIGestureRecognizerStateBegan){
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath *pathAtView = [self.tableView indexPathForRowAtPoint:point];
        NSObject *data = [self.tableView cellForRowAtIndexPath:pathAtView];

        //长按 TCommonTextCell，可以复制 cell 内的字符串。
        if([data isKindOfClass:[TCommonTextCell class]]){
            TCommonTextCell *textCell = (TCommonTextCell *)data;
            if(textCell.textData.value && ![textCell.textData.value isEqualToString:@"未设置"]){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = textCell.textData.value;
                NSString *toastString = [NSString stringWithFormat:@"已将 %@ 复制到粘贴板",textCell.textData.key];
                [THelper makeToast:toastString];
            }
        }else if([data isKindOfClass:[TUIProfileCardCell class]]){
            //长按 profileCard，复制自己的账号。
            TUIProfileCardCell *profileCard = (TUIProfileCardCell *)data;
            if(profileCard.cardData.identifier){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = profileCard.cardData.identifier;
                NSString *toastString = [NSString stringWithFormat:@"已将该用户账号复制到粘贴板"];
                [THelper makeToast:toastString];
            }

        }
    }
}

@end
