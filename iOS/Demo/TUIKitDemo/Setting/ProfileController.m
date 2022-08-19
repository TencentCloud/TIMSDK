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
#import "TUITextEditController.h"
#import "TUIDateEditController.h"
#import "TUICommonModel.h"
#import "TUICommonTextCell.h"
#import "TUICommonModel.h"
#import "TUIKit.h"
#import "TCUtil.h"
#import "TUICommonAvatarCell.h"
#import "TUIModifyView.h"
#import "TUIThemeManager.h"
#import "TUISelectAvatarController.h"

#define SHEET_COMMON 1
#define SHEET_AGREE  2
#define SHEET_SEX    3

@interface ProfileController () <UIActionSheetDelegate, V2TIMSDKListener, TModifyViewDelegate>
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) NSMutableArray *data;
@property V2TIMUserFullInfo *profile;
@property (nonatomic, weak) UIDatePicker *picker;
@property (nonatomic, strong) UIView *datePicker;
@end

@implementation ProfileController {
    NSDateFormatter *_dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addLongPressGesture];
    [self setupViews];

    self.tableView.delaysContentTouches = NO;
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = @"yyyy-MM-dd";
}

- (void)setupViews
{
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:NSLocalizedString(@"ProfileDetails", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");

    [self.tableView registerClass:[TUICommonTextCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[TUICommonAvatarCell class] forCellReuseIdentifier:@"avatarCell"];
    [[V2TIMManager sharedInstance] addIMSDKListener:self];
    
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        self.profile = infoList.firstObject;
        [self setupData];
    } fail:nil];
}

- (void)setupData
{

    _data = [NSMutableArray array];

    TUICommonAvatarCellData *avatarData = [TUICommonAvatarCellData new];
    avatarData.key = NSLocalizedString(@"ProfilePhoto", nil);
    avatarData.showAccessory = YES;
    avatarData.cselector = @selector(didSelectAvatar);
    avatarData.avatarUrl = [NSURL URLWithString:self.profile.faceURL];
    [_data addObject:@[avatarData]];

    TUICommonTextCellData *nicknameData = [TUICommonTextCellData new];
    nicknameData.key = NSLocalizedString(@"ProfileName", nil);
    nicknameData.value = self.profile.showName;
    nicknameData.showAccessory = YES;
    nicknameData.cselector = @selector(didSelectChangeNick);

    TUICommonTextCellData *IDData = [TUICommonTextCellData new];
    IDData.key = NSLocalizedString(@"ProfileAccount", nil);
    IDData.value = [NSString stringWithFormat:@"%@      ", self.profile.userID];
    IDData.showAccessory = NO;
    [_data addObject:@[nicknameData, IDData]];

    TUICommonTextCellData *signatureData = [TUICommonTextCellData new];
    signatureData.key = NSLocalizedString(@"ProfileSignature", nil);
    signatureData.value = self.profile.selfSignature.length ? self.profile.selfSignature : @"";
    signatureData.showAccessory = YES;
    signatureData.cselector = @selector(didSelectChangeSignature);

    TUICommonTextCellData *sexData = [TUICommonTextCellData new];
    sexData.key = NSLocalizedString(@"ProfileGender", nil);
    sexData.value = [self.profile showGender];
    sexData.showAccessory = YES;
    sexData.cselector = @selector(didSelectSex);
    
    TUICommonTextCellData *birthdayData = [TUICommonTextCellData new];
    birthdayData.key = NSLocalizedString(@"birthday", nil);
    birthdayData.value = [_dateFormatter stringFromDate:NSDate.new];
    if (self.profile.birthday) {
        NSInteger year = self.profile.birthday / 10000;
        NSInteger month = (self.profile.birthday - year * 10000) / 100;
        NSInteger day = (self.profile.birthday - year * 10000 - month * 100);
        birthdayData.value = [NSString stringWithFormat:@"%04zd-%02zd-%02zd", year, month, day];
    }
    birthdayData.showAccessory = YES;
    birthdayData.cselector = @selector(didSelectBirthday);

    [_data addObject:@[signatureData, sexData, birthdayData]];


    [self.tableView reloadData];
}

#pragma mark - V2TIMSDKListener
- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info {
    self.profile = Info;
    [self setupData];
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
    return section == 0 ? 0 : 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = _data[indexPath.section];
    TUICommonCellData *data = array[indexPath.row];

    return [data heightOfWidth:Screen_Width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TUICommonTextCellData class]]) {
        TUICommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonTextCellData *)data];
        return cell;
    }  else if([data isKindOfClass:[TUICommonAvatarCellData class]]){
        TUICommonAvatarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"avatarCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonAvatarCellData *)data];
        return cell;
    }
    return nil;
}

- (void)modifyView:(TUIModifyView *)modifyView didModiyContent:(NSString *)content
{
    if (modifyView.tag == 0) {
        if (![self validForSignatureAndNick:content]) {
            [TUITool makeToast:NSLocalizedString(@"ProfileEditNameDesc", nil)];
            return;
        }
        V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
        info.nickName = content;
        [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
            self.profile.nickName = content;
            [self setupData];
        } fail:nil];
    } else if (modifyView.tag == 1) {
        if (![self validForSignatureAndNick:content]) {
            [TUITool makeToast:NSLocalizedString(@"ProfileEditNameDesc", nil)];
            return;
        }
        V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
        info.selfSignature = content;
        [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
            self.profile.selfSignature = content;
            [self setupData];
        } fail:nil];
    }
    
}

- (BOOL)validForSignatureAndNick:(NSString *)content
{
    NSString *reg = @"^[a-zA-Z0-9_\u4e00-\u9fa5]*$";
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    return [regex evaluateWithObject:content];
}


- (void)didSelectChangeNick
{
    TModifyViewData *data = [[TModifyViewData alloc] init];
    data.title = NSLocalizedString(@"ProfileEditName", nil);
    data.desc = NSLocalizedString(@"ProfileEditNameDesc", nil);
    data.content = self.profile.showName;
    TUIModifyView *modify = [[TUIModifyView alloc] init];
    modify.tag = 0;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}

- (void)didSelectChangeSignature
{
    TModifyViewData *data = [[TModifyViewData alloc] init];
    data.title = NSLocalizedString(@"ProfileEditSignture", nil);
    data.desc = NSLocalizedString(@"ProfileEditNameDesc", nil);
    data.content = self.profile.selfSignature;
    TUIModifyView *modify = [[TUIModifyView alloc] init];
    modify.tag = 1;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}

- (void)didSelectSex
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.tag = SHEET_SEX;
    sheet.title = NSLocalizedString(@"ProfileEditGender", nil);
    [sheet addButtonWithTitle:NSLocalizedString(@"Male", nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"Female", nil)];
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:NSLocalizedString(@"Canel", nil)]];
    [sheet setDelegate:self];
    [sheet showInView:self.view];
}

- (void)didSelectAvatar
{
    
    TUISelectAvatarController * vc = [[TUISelectAvatarController alloc] init];
    vc.selectAvatarType = TUISelectAvatarTypeUserAvatar;
    vc.profilFaceURL = self.profile.faceURL;
    [self.navigationController pushViewController:vc animated:YES];

    __weak typeof(self)weakSelf = self;
    vc.selectCallBack = ^(NSString * _Nonnull urlStr) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (urlStr.length > 0) {
            V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
            info.faceURL = urlStr;
            [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
                [strongSelf.profile setFaceURL:urlStr];
                [strongSelf setupData];
            } fail:^(int code, NSString *desc) {
                
            }];
        }
    };
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

- (void)addLongPressGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressAtCell:)];
    [self.tableView addGestureRecognizer:longPress];
}

-(void) didLongPressAtCell:(UILongPressGestureRecognizer *)longPress {
    if(longPress.state == UIGestureRecognizerStateBegan){
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath *pathAtView = [self.tableView indexPathForRowAtPoint:point];
        NSObject *data = [self.tableView cellForRowAtIndexPath:pathAtView];

        if([data isKindOfClass:[TUICommonTextCell class]]){
            TUICommonTextCell *textCell = (TUICommonTextCell *)data;
            if(textCell.textData.value && ![textCell.textData.value isEqualToString:NSLocalizedString(@"no_set", nil)]){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = textCell.textData.value;
                NSString *toastString = [NSString stringWithFormat:@"copy %@",textCell.textData.key];
                [TUITool makeToast:toastString];
            }
        }else if([data isKindOfClass:[TUIProfileCardCell class]]){
            TUIProfileCardCell *profileCard = (TUIProfileCardCell *)data;
            if(profileCard.cardData.identifier){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = profileCard.cardData.identifier;
                NSString *toastString = [NSString stringWithFormat:@"copy"];
                [TUITool makeToast:toastString];
            }

        }
    }
}

- (void)didSelectBirthday
{
    [self hideDatePicker];
    [UIApplication.sharedApplication.keyWindow addSubview:self.datePicker];
}

- (UIView *)datePicker
{
    if (_datePicker == nil) {
        UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
        cover.backgroundColor = TUIGroupDynamicColor(@"group_modify_view_bg_color", @"#0000007F");
        [cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDatePicker)]];
        
        UIView *menuView = [[UIView alloc] init];
        menuView.backgroundColor = TUIGroupDynamicColor(@"group_modify_container_view_bg_color", @"#FFFFFF");
        menuView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - 340, UIScreen.mainScreen.bounds.size.width, 40);
        [cover addSubview:menuView];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [cancelButton setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(10, 0, 60, 35);
        [cancelButton addTarget:self action:@selector(hideDatePicker) forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:cancelButton];
        
        UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [okButton setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
        [okButton setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
        okButton.frame = CGRectMake(cover.bounds.size.width - 10 - 60, 0, 60, 35);
        [okButton addTarget:self action:@selector(onOKDatePicker) forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:okButton];
        
        UIDatePicker *picker = [[UIDatePicker alloc] init];
        NSString *language = [TUIGlobalization tk_localizableLanguageKey];
        picker.locale = [[NSLocale alloc] initWithLocaleIdentifier:language];
        if (@available(iOS 13.0, *)) {
            picker.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        } else {
            // Fallback on earlier versions
        }
        if (@available(iOS 13.4, *)) {
            picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        picker.backgroundColor = TUIGroupDynamicColor(@"group_modify_container_view_bg_color", @"#FFFFFF");
        picker.datePickerMode = UIDatePickerModeDate;
        picker.frame = CGRectMake(0, CGRectGetMaxY(menuView.frame), cover.bounds.size.width, 300);
        [cover addSubview:picker];
        self.picker = picker;
        
        _datePicker = cover;
    }
    return _datePicker;
}

- (void)hideDatePicker
{
    [self.datePicker removeFromSuperview];
}

- (void)onOKDatePicker
{
    [self hideDatePicker];
    NSDate *date = self.picker.date;
    NSString *dateStr = [_dateFormatter stringFromDate:date];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    int birthday = [dateStr intValue];
    V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
    info.birthday = birthday;
    [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
        self.profile.birthday = birthday;
        [self setupData];
    } fail:nil];
}


@end
