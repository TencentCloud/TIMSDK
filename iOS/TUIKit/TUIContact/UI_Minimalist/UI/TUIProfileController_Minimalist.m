//
//  TUIProfileController_Minimalist.m
//  TUIContact
//
//  Created by lynxzhang on 2018/10/19.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TUIProfileController_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMConfig.h>
#import <TUICore/TUIThemeManager.h>
#import "TUITextEditController_Minimalist.h"

#define SHEET_COMMON 1
#define SHEET_AGREE 2
#define SHEET_SEX 3

typedef void (^TUIProfileClickback)(void);

@interface ProfileControllerHeaderView_Minimalist : UIView
@property(nonatomic, copy) void (^headImgClickBlock)(void);
@property(nonatomic, copy) void (^editButtonClickBlock)(void);
@property(nonatomic, strong) UIImageView *headImg;
@property(nonatomic, strong) UIButton *editButton;
@property(nonatomic, strong) UILabel *descriptionLabel;
@end

@implementation ProfileControllerHeaderView_Minimalist

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.headImg = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self addSubview:self.headImg];
    self.headImg.userInteractionEnabled = YES;
    self.headImg.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageClick)];
    [self.headImg addGestureRecognizer:tap];

    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self addSubview:self.editButton];
    [self.editButton setTitle:TIMCommonLocalizableString(ProfileEdit) forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editButtonClick) forControlEvents:UIControlEventTouchUpInside];

    self.descriptionLabel = [[UILabel alloc] init];
    [self addSubview:self.descriptionLabel];
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    self.descriptionLabel.text = loginUser;
}

- (void)applyData {
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    if (loginUser.length > 0) {
        @weakify(self);
        [[V2TIMManager sharedInstance] getUsersInfo:@[ loginUser ]
                                               succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                                                 @strongify(self);
                                                 V2TIMUserFullInfo *profile = infoList.firstObject;
                                                 if (profile && profile.faceURL) {
                                                     [self.headImg sd_setImageWithURL:[NSURL URLWithString:profile.faceURL]
                                                                     placeholderImage:DefaultAvatarImage];
                                                 }
                                               }
                                               fail:nil];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.headImg.frame = CGRectMake((self.bounds.size.width - kScale390(94)) * 0.5, kScale390(42), kScale390(94), kScale390(94));
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImg.layer.masksToBounds = YES;
        self.headImg.layer.cornerRadius = self.headImg.frame.size.height / 2.0;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImg.layer.masksToBounds = YES;
        self.headImg.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    [self.editButton.titleLabel sizeToFit];
    self.editButton.frame = CGRectMake((self.bounds.size.width - self.editButton.titleLabel.frame.size.width) * 0.5,
                                       self.headImg.frame.origin.y + self.headImg.frame.size.height + kScale390(10),
                                       self.editButton.titleLabel.frame.size.width, self.editButton.titleLabel.frame.size.height);

    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.frame = CGRectMake((self.bounds.size.width - self.descriptionLabel.frame.size.width) * 0.5,
                                             self.editButton.frame.origin.y + self.editButton.frame.size.height + kScale390(10),
                                             self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height);
}

// MARK: action
- (void)headImageClick {
    if (self.headImgClickBlock) {
        self.headImgClickBlock();
    }
}
- (void)editButtonClick {
    if (self.editButtonClickBlock) {
        self.editButtonClickBlock();
    }
}

@end
@interface TUIProfileController_Minimalist () <UIActionSheetDelegate, V2TIMSDKListener, TUIModifyViewDelegate>
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) NSMutableArray *data;
@property V2TIMUserFullInfo *profile;
@property(nonatomic, strong) ProfileControllerHeaderView_Minimalist *headerView;
@property(nonatomic, weak) UIDatePicker *picker;
@property(nonatomic, strong) UIView *datePicker;
@end

@implementation TUIProfileController_Minimalist {
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

- (void)setupViews {
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TIMCommonLocalizableString(ProfileDetails)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];

    [self.tableView registerClass:[TUICommonTextCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[TUICommonAvatarCell class] forCellReuseIdentifier:@"avatarCell"];
    [[V2TIMManager sharedInstance] addIMSDKListener:self];

    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[ loginUser ]
                                           succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                                             self.profile = infoList.firstObject;
                                             [self setupData];
                                           }
                                           fail:nil];

    self.headerView = [[ProfileControllerHeaderView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kScale390(240))];

    self.tableView.tableHeaderView = self.headerView;
}

- (void)setupData {
    _data = [NSMutableArray array];

    [self.headerView.headImg sd_setImageWithURL:[NSURL URLWithString:self.profile.faceURL] placeholderImage:DefaultAvatarImage];
    self.headerView.descriptionLabel.text = self.profile.showName;
    @weakify(self);
    self.headerView.headImgClickBlock = ^{
      @strongify(self);
      [self didSelectAvatar];
    };

    self.headerView.editButtonClickBlock = ^{
      @strongify(self);
      [self didSelectChangeNick];
    };

    //    TUICommonAvatarCellData *avatarData = [TUICommonAvatarCellData new];
    //    avatarData.key = TIMCommonLocalizableString(ProfilePhoto);
    //    avatarData.showAccessory = YES;
    //    avatarData.cselector = @selector(didSelectAvatar);
    //    avatarData.avatarUrl = [NSURL URLWithString:self.profile.faceURL];
    //    [_data addObject:@[avatarData]];

    //    TUICommonTextCellData *nicknameData = [TUICommonTextCellData new];
    //    nicknameData.key = TIMCommonLocalizableString(ProfileName);
    //    nicknameData.value = self.profile.showName;
    //    nicknameData.showAccessory = YES;
    //    nicknameData.cselector = @selector(didSelectChangeNick);

    TUICommonTextCellData *IDData = [TUICommonTextCellData new];
    IDData.key = TIMCommonLocalizableString(ProfileAccount);
    IDData.value = [NSString stringWithFormat:@"%@      ", self.profile.userID];
    IDData.showAccessory = NO;
    [_data addObject:@[ IDData ]];

    TUICommonTextCellData *signatureData = [TUICommonTextCellData new];
    signatureData.key = TIMCommonLocalizableString(ProfileSignature);
    signatureData.value = self.profile.selfSignature.length ? self.profile.selfSignature : @"";
    signatureData.showAccessory = YES;
    signatureData.cselector = @selector(didSelectChangeSignature);

    TUICommonTextCellData *sexData = [TUICommonTextCellData new];
    sexData.key = TIMCommonLocalizableString(ProfileGender);
    sexData.value = [self.profile showGender];
    sexData.showAccessory = YES;
    sexData.cselector = @selector(didSelectSex);

    TUICommonTextCellData *birthdayData = [TUICommonTextCellData new];
    birthdayData.key = TIMCommonLocalizableString(ProfileBirthday);
    birthdayData.value = [_dateFormatter stringFromDate:NSDate.new];
    if (self.profile.birthday) {
        NSInteger year = self.profile.birthday / 10000;
        NSInteger month = (self.profile.birthday - year * 10000) / 100;
        NSInteger day = (self.profile.birthday - year * 10000 - month * 100);
        birthdayData.value = [NSString stringWithFormat:@"%04zd-%02zd-%02zd", year, month, day];
    }
    birthdayData.showAccessory = YES;
    birthdayData.cselector = @selector(didSelectBirthday);

    [_data addObject:@[ signatureData, sexData, birthdayData ]];

    [self.headerView setNeedsLayout];

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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    UIView *line = [[UIView alloc] init];
    if (section != 0) {
        line.backgroundColor = TUIDemoDynamicColor(@"separator_color", @"#DBDBDB");
        ;
        line.frame = CGRectMake(kScale390(16), view.frame.size.height - 0.5, Screen_Width - kScale390(16), 0.5);
        [view addSubview:line];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0 : kScale390(20);
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
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
    if ([data isKindOfClass:[TUICommonTextCellData class]]) {
        TUICommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonTextCellData *)data];
        return cell;
    } else if ([data isKindOfClass:[TUICommonAvatarCellData class]]) {
        TUICommonAvatarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"avatarCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonAvatarCellData *)data];
        return cell;
    }
    return nil;
}

- (void)modifyView:(TUIModifyView *)modifyView didModiyContent:(NSString *)content {
    if (modifyView.tag == 0) {
        if (![self validForSignatureAndNick:content]) {
            [TUITool makeToast:TIMCommonLocalizableString(ProfileEditNameDesc)];
            return;
        }
        V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
        info.nickName = content;
        [[V2TIMManager sharedInstance] setSelfInfo:info
                                              succ:^{
                                                self.profile.nickName = content;
                                                [self setupData];
                                              }
                                              fail:nil];
    } else if (modifyView.tag == 1) {
        if (![self validForSignatureAndNick:content]) {
            [TUITool makeToast:TIMCommonLocalizableString(ProfileEditNameDesc)];
            return;
        }
        V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
        info.selfSignature = content;
        [[V2TIMManager sharedInstance] setSelfInfo:info
                                              succ:^{
                                                self.profile.selfSignature = content;
                                                [self setupData];
                                              }
                                              fail:nil];
    }
}

- (BOOL)validForSignatureAndNick:(NSString *)content {
    NSString *reg = @"^[a-zA-Z0-9_\u4e00-\u9fa5]*$";
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    return [regex evaluateWithObject:content];
}

- (void)didSelectChangeNick {
    TUIModifyViewData *data = [[TUIModifyViewData alloc] init];
    data.title = TIMCommonLocalizableString(ProfileEditName);
    data.desc = TIMCommonLocalizableString(ProfileEditNameDesc);
    data.content = self.profile.showName;
    TUIModifyView *modify = [[TUIModifyView alloc] init];
    modify.tag = 0;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}

- (void)didSelectChangeSignature {
    TUIModifyViewData *data = [[TUIModifyViewData alloc] init];
    data.title = TIMCommonLocalizableString(ProfileEditSignture);
    data.desc = TIMCommonLocalizableString(ProfileEditNameDesc);
    data.content = self.profile.selfSignature;
    TUIModifyView *modify = [[TUIModifyView alloc] init];
    modify.tag = 1;
    modify.delegate = self;
    [modify setData:data];
    [modify showInWindow:self.view.window];
}

- (void)didSelectSex {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.tag = SHEET_SEX;
    sheet.title = TIMCommonLocalizableString(ProfileEditGender);
    [sheet addButtonWithTitle:TIMCommonLocalizableString(Male)];
    [sheet addButtonWithTitle:TIMCommonLocalizableString(Female)];
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:TIMCommonLocalizableString(Canel)]];
    [sheet setDelegate:self];
    [sheet showInView:self.view];
}

- (void)didSelectAvatar {
    TUISelectAvatarController *vc = [[TUISelectAvatarController alloc] init];
    vc.selectAvatarType = TUISelectAvatarTypeUserAvatar;
    vc.profilFaceURL = self.profile.faceURL;
    [self.navigationController pushViewController:vc animated:YES];

    __weak typeof(self) weakSelf = self;
    vc.selectCallBack = ^(NSString *_Nonnull urlStr) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      if (urlStr.length > 0) {
          V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
          info.faceURL = urlStr;
          [[V2TIMManager sharedInstance] setSelfInfo:info
                                                succ:^{
                                                  [strongSelf.profile setFaceURL:urlStr];
                                                  [strongSelf setupData];
                                                }
                                                fail:^(int code, NSString *desc){

                                                }];
      }
    };
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
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
        [[V2TIMManager sharedInstance] setSelfInfo:info
                                              succ:^{
                                                self.profile.gender = gender;
                                                [self setupData];
                                              }
                                              fail:nil];
    }
}

- (void)addLongPressGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressAtCell:)];
    [self.tableView addGestureRecognizer:longPress];
}

- (void)didLongPressAtCell:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath *pathAtView = [self.tableView indexPathForRowAtPoint:point];
        NSObject *data = [self.tableView cellForRowAtIndexPath:pathAtView];

        if ([data isKindOfClass:[TUICommonTextCell class]]) {
            TUICommonTextCell *textCell = (TUICommonTextCell *)data;
            if (textCell.textData.value && ![textCell.textData.value isEqualToString:TIMCommonLocalizableString(no_set)]) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = textCell.textData.value;
                NSString *toastString = [NSString stringWithFormat:@"copy %@", textCell.textData.key];
                [TUITool makeToast:toastString];
            }
        } else if ([data isKindOfClass:[TUIProfileCardCell class]]) {
            TUIProfileCardCell *profileCard = (TUIProfileCardCell *)data;
            if (profileCard.cardData.identifier) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = profileCard.cardData.identifier;
                NSString *toastString = [NSString stringWithFormat:@"copy"];
                [TUITool makeToast:toastString];
            }
        }
    }
}

- (void)didSelectBirthday {
    [self hideDatePicker];
    [UIApplication.sharedApplication.keyWindow addSubview:self.datePicker];
}

- (UIView *)datePicker {
    if (_datePicker == nil) {
        UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
        cover.backgroundColor = TUIGroupDynamicColor(@"group_modify_view_bg_color", @"#0000007F");
        [cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDatePicker)]];

        UIView *menuView = [[UIView alloc] init];
        menuView.backgroundColor = TUIGroupDynamicColor(@"group_modify_container_view_bg_color", @"#FFFFFF");
        menuView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - 340, UIScreen.mainScreen.bounds.size.width, 40);
        [cover addSubview:menuView];

        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:TIMCommonLocalizableString(Cancel) forState:UIControlStateNormal];
        [cancelButton setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(10, 0, 60, 35);
        [cancelButton addTarget:self action:@selector(hideDatePicker) forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:cancelButton];

        UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [okButton setTitle:TIMCommonLocalizableString(Confirm) forState:UIControlStateNormal];
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

- (void)hideDatePicker {
    [self.datePicker removeFromSuperview];
}

- (void)onOKDatePicker {
    [self hideDatePicker];
    NSDate *date = self.picker.date;
    NSString *dateStr = [_dateFormatter stringFromDate:date];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    int birthday = [dateStr intValue];
    V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
    info.birthday = birthday;
    [[V2TIMManager sharedInstance] setSelfInfo:info
                                          succ:^{
                                            self.profile.birthday = birthday;
                                            [self setupData];
                                          }
                                          fail:nil];
}

@end
