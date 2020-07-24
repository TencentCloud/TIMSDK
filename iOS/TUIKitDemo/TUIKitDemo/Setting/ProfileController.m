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
#import "TTextEditController.h"
#import "TDateEditController.h"
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
#import "TCUtil.h"
#import "UIColor+TUIDarkMode.h"
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

- (NSString *)getSignature:(V2TIMUserFullInfo *)profile
{
    NSString *ret = [super getSignature:profile];
    if (ret.length != 0)
        return ret;
    return @"暂无个性签名";
}

@end

@interface ProfileController () <UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property V2TIMUserFullInfo *profile;
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
    self.tableView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    self.clearsSelectionOnViewWillAppear = YES;

    [self.tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[TCommonAvatarCell class] forCellReuseIdentifier:@"avatarCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSelfInfoUpdated:) name:TUIKitNotification_onSelfInfoUpdated object:nil];
    
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        self.profile = infoList.firstObject;
        [self setupData];
    } fail:nil];
}

- (void)onSelfInfoUpdated:(NSNotification *)no {
    self.profile = no.object;
    [self setupData];
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
    IDData.key = @"帐号";
    IDData.value = self.profile.userID;
    IDData.showAccessory = NO;
    [_data addObject:@[nicknameData, IDData]];

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

    [_data addObject:@[signatureData, sexData]];


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
    TTextEditController *vc = [[TTextEditController alloc] initWithText:self.profile.nickName];
    vc.title = @"修改昵称";
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
        @strongify(self)
        V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
        info.nickName = x;
        [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
            self.profile.nickName = x;
            [self setupData];
        } fail:nil];
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
        V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
        info.selfSignature = x;
        [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
            self.profile.selfSignature = x;
            [self setupData];
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

- (void)didSelectAvatar
{
    //点击头像的响应函数，换头像，上传头像URL
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"TUIKit为您选择一个头像" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = [THelper randAvatarUrl];
        V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
        info.faceURL = url;
        [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
            [self.profile setFaceURL:url];
            [self setupData];
        } fail:^(int code, NSString *desc) {
            
        }];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == SHEET_SEX) {
        V2TIMGender gender = V2TIM_GENDER_UNKNOWN;
        if (buttonIndex == 0) {
            gender = V2TIM_GENDER_MALE;
        }
        if (buttonIndex == 1) {
            gender = V2TIM_GENDER_FEMALE;
        }
        V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
        info.gender = gender;
        [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
            self.profile.gender = gender;
            [self setupData];
        } fail:nil];
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
