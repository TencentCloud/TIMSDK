//
//  SettingController.m
//  TUIKitDemo
//
//  Created by lynxzhang on 2018/10/19.
//  Copyright © 2018 Tencent. All rights reserved.
//
#import "TUISettingController.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMConfig.h>
#import <TUICore/TUICore.h>
#import "TUIProfileController.h"
#import "TUIStyleSelectViewController.h"
#import "TUIThemeSelectController.h"

static NSString *const kKeyWeight = @"weight";
static NSString *const kKeyItems = @"items";
static NSString *const kKeyViews = @"views";  // Used to pass custom views from extensions.

@interface TUISettingController () <UIActionSheetDelegate,
                                    V2TIMSDKListener,
                                    TUIProfileCardDelegate,
                                    TUIStyleSelectControllerDelegate,
                                    TUIThemeSelectControllerDelegate>
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) V2TIMUserFullInfo *profile;
@property(nonatomic, strong) TUIProfileCardCellData *profileCellData;
@property(nonatomic, strong) NSString *styleName;
@property(nonatomic, strong) NSString *themeName;
@property(nonatomic, copy) NSArray *sortedDataList;
@end

@implementation TUISettingController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.showPersonalCell = YES;
        self.showMessageReadStatusCell = YES;
        self.showDisplayOnlineStatusCell = YES;
        self.showCallsRecordCell = YES;
        self.showSelectStyleCell = NO;
        self.showChangeThemeCell = NO;
        self.showAboutIMCell = YES;
        self.showLoginOutCell = YES;
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];

    [[V2TIMManager sharedInstance] addIMSDKListener:self];
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    if (!loginUser) {
        loginUser = self.lastLoginUser;
    }
    if (loginUser.length > 0) {
        @weakify(self);
        [[V2TIMManager sharedInstance] getUsersInfo:@[ loginUser ]
                                               succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                                                 @strongify(self);
                                                 self.profile = infoList.firstObject;
                                                 [self setupData];
                                               }
                                               fail:nil];
    }

    [TUITool addUnsupportNotificationInVC:self debugOnly:NO];
}

#pragma mark - Private
- (void)setupViews {
    self.tableView.delaysContentTouches = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");

    CGRect rect = self.view.bounds;
    [self.tableView registerClass:[TUICommonTextCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[TUIProfileCardCell class] forCellReuseIdentifier:@"personalCell"];
    [self.tableView registerClass:[TUIButtonCell class] forCellReuseIdentifier:@"buttonCell"];
    [self.tableView registerClass:[TUICommonSwitchCell class] forCellReuseIdentifier:@"switchCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"containerCell"];

    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
}

#pragma mark - V2TIMSDKListener
- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info {
    self.profile = Info;
    [self setupData];
}

#pragma mark - UITableView DataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sortedDataList.count;
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
    NSDictionary *dict = self.sortedDataList[section];
    // Extension settings.
    if (dict[kKeyViews] && [dict[kKeyViews] isKindOfClass:NSArray.class]) {
        NSArray *views = dict[kKeyViews];
        return views.count;
    }
    // Built-in settings.
    NSArray *items = dict[kKeyItems];
    return items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.sortedDataList[indexPath.section];
    // Extension settings.
    if (dict[kKeyViews] && [dict[kKeyViews] isKindOfClass:NSArray.class]) {
        UIView *view = dict[kKeyViews][indexPath.row];
        return view.bounds.size.height;
    }
    // Built-in settings.
    NSArray *array = dict[kKeyItems];
    TUICommonCellData *data = array[indexPath.row];
    return [data heightOfWidth:Screen_Width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.sortedDataList[indexPath.section];
    // Extension settings.
    if (dict[kKeyViews] && [dict[kKeyViews] isKindOfClass:NSArray.class]) {
        UIView *view = dict[kKeyViews][indexPath.row];
        if ([view isKindOfClass:[UITableViewCell class]] ) {
            return (id)view;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"containerCell" forIndexPath:indexPath];
            [cell addSubview:view];
            return cell;
        }
    }
    // Built-in settings.
    NSArray *array = dict[kKeyItems];
    NSDictionary *data = array[indexPath.row];
    if ([data isKindOfClass:[TUIProfileCardCellData class]]) {
        TUIProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personalCell" forIndexPath:indexPath];
        cell.delegate = self;
        [cell fillWithData:(TUIProfileCardCellData *)data];
        return cell;
    } else if ([data isKindOfClass:[TUIButtonCellData class]]) {
        TUIButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:TButtonCell_ReuseId];
        if (!cell) {
            cell = [[TUIButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TButtonCell_ReuseId];
        }
        [cell fillWithData:(TUIButtonCellData *)data];
        return cell;
    } else if ([data isKindOfClass:[TUICommonTextCellData class]]) {
        TUICommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonTextCellData *)data];
        return cell;
    } else if ([data isKindOfClass:[TUICommonSwitchCellData class]]) {
        TUICommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonSwitchCellData *)data];
        return cell;
    }
    return nil;
}

#pragma mark - Private
- (void)setupData {
    self.dataList = [NSMutableArray array];

    if (self.showPersonalCell) {
        TUIProfileCardCellData *personal = [[TUIProfileCardCellData alloc] init];
        personal.identifier = self.profile.userID;
        personal.avatarImage = DefaultAvatarImage;
        personal.avatarUrl = [NSURL URLWithString:self.profile.faceURL];
        personal.name = [self.profile showName];
        personal.genderString = [self.profile showGender];
        personal.signature = self.profile.selfSignature.length
                                 ? [NSString stringWithFormat:TIMCommonLocalizableString(SignatureFormat), self.profile.selfSignature]
                                 : TIMCommonLocalizableString(no_personal_signature);
        personal.cselector = @selector(didSelectCommon);
        personal.showAccessory = YES;
        personal.showSignature = YES;
        self.profileCellData = personal;
        [self.dataList addObject:@{kKeyWeight : @1000, kKeyItems : @[ personal ]}];
    }

    TUICommonTextCellData *friendApply = [TUICommonTextCellData new];
    friendApply.key = TIMCommonLocalizableString(MeFriendRequest);
    friendApply.showAccessory = YES;
    friendApply.cselector = @selector(onEditFriendApply);
    if (self.profile.allowType == V2TIM_FRIEND_ALLOW_ANY) {
        friendApply.value = TIMCommonLocalizableString(MeFriendRequestMethodAgreeAll);
    }
    if (self.profile.allowType == V2TIM_FRIEND_NEED_CONFIRM) {
        friendApply.value = TIMCommonLocalizableString(MeFriendRequestMethodNeedConfirm);
    }
    if (self.profile.allowType == V2TIM_FRIEND_DENY_ANY) {
        friendApply.value = TIMCommonLocalizableString(MeFriendRequestMethodDenyAll);
    }
    [self.dataList addObject:@{kKeyWeight : @900, kKeyItems : @[ friendApply ]}];

    if (self.showMessageReadStatusCell) {
        TUICommonSwitchCellData *msgReadStatus = [TUICommonSwitchCellData new];
        msgReadStatus.title = TIMCommonLocalizableString(MeMessageReadStatus);
        msgReadStatus.desc =
            self.msgNeedReadReceipt ? TIMCommonLocalizableString(MeMessageReadStatusOpenDesc) : TIMCommonLocalizableString(MeMessageReadStatusCloseDesc);
        msgReadStatus.cswitchSelector = @selector(onSwitchMsgReadStatus:);
        msgReadStatus.on = self.msgNeedReadReceipt;
        [self.dataList addObject:@{kKeyWeight : @800, kKeyItems : @[ msgReadStatus ]}];
    }

    if (self.showDisplayOnlineStatusCell) {
        TUICommonSwitchCellData *onlineStatus = [TUICommonSwitchCellData new];
        onlineStatus.title = TIMCommonLocalizableString(ShowOnlineStatus);
        onlineStatus.desc = [TUIConfig defaultConfig].displayOnlineStatusIcon ? TIMCommonLocalizableString(ShowOnlineStatusOpenDesc)
                                                                              : TIMCommonLocalizableString(ShowOnlineStatusCloseDesc);
        onlineStatus.cswitchSelector = @selector(onSwitchOnlineStatus:);
        onlineStatus.on = [TUIConfig defaultConfig].displayOnlineStatusIcon;
        [self.dataList addObject:@{kKeyWeight : @700, kKeyItems : @[ onlineStatus ]}];
    }

    if (self.showSelectStyleCell) {
        TUICommonTextCellData *styleApply = [TUICommonTextCellData new];
        styleApply.key = TIMCommonLocalizableString(TIMAppSelectStyle);
        styleApply.showAccessory = YES;
        styleApply.cselector = @selector(onClickChangeStyle);
        [[RACObserve(self, styleName) distinctUntilChanged] subscribeNext:^(NSString *styleName) {
          styleApply.value = self.styleName;
        }];
        self.styleName =
            [TUIStyleSelectViewController isClassicEntrance] ? TIMCommonLocalizableString(TUIKitClassic) : TIMCommonLocalizableString(TUIKitMinimalist);
        [self.dataList addObject:@{kKeyWeight : @600, kKeyItems : @[ styleApply ]}];
    }

    if (self.showChangeThemeCell && [self.styleName isEqualToString:TIMCommonLocalizableString(TUIKitClassic)]) {
        TUICommonTextCellData *themeApply = [TUICommonTextCellData new];
        themeApply.key = TIMCommonLocalizableString(TIMAppChangeTheme);
        themeApply.showAccessory = YES;
        themeApply.cselector = @selector(onClickChangeTheme);
        [[RACObserve(self, themeName) distinctUntilChanged] subscribeNext:^(NSString *themeName) {
          themeApply.value = self.themeName;
        }];
        self.themeName = [TUIThemeSelectController getLastThemeName];
        [self.dataList addObject:@{kKeyWeight : @500, kKeyItems : @[ themeApply ]}];
    }

    if (self.showCallsRecordCell) {
        TUICommonSwitchCellData *record = [TUICommonSwitchCellData new];
        record.title = TIMCommonLocalizableString(ShowCallsRecord);
        record.desc = @"";
        record.cswitchSelector = @selector(onSwitchCallsRecord:);
        record.on = self.displayCallsRecord;
        [self.dataList addObject:@{kKeyWeight : @400, kKeyItems : @[ record ]}];
    }

    if (self.showAboutIMCell) {
        TUICommonTextCellData *about = [TUICommonTextCellData new];
        about.key = self.aboutIMCellText;
        about.showAccessory = YES;
        about.cselector = @selector(onClickAboutIM:);
        [self.dataList addObject:@{kKeyWeight : @300, kKeyItems : @[ about ]}];
    }

    if (self.showLoginOutCell) {
        TUIButtonCellData *button = [[TUIButtonCellData alloc] init];
        button.title = TIMCommonLocalizableString(logout);
        button.style = ButtonRedText;
        button.cbuttonSelector = @selector(onClickLogout:);
        button.hideSeparatorLine = YES;
        [self.dataList addObject:@{kKeyWeight : @200, kKeyItems : @[ button ]}];
    }

    [self setupExtensionsData];
    [self sortDataList];

    [self.tableView reloadData];
}

- (void)setupExtensionsData {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[TUICore_TUIContactExtension_MeSettingMenu_Nav] = self.navigationController;
    NSArray *extensionList = [TUICore getExtensionList:TUICore_TUIContactExtension_MeSettingMenu_ClassicExtensionID param:param];
    for (TUIExtensionInfo *info in extensionList) {
        NSAssert(info.data, @"extension for setting is invalid, check data");
        UIView *view = info.data[TUICore_TUIContactExtension_MeSettingMenu_View];
        NSInteger weight = [info.data[TUICore_TUIContactExtension_MeSettingMenu_Weight] integerValue];
        if (view) {
            [self.dataList addObject:@{kKeyWeight : @(weight), kKeyViews : @[ view ]}];
        }
    }
}

- (void)sortDataList {
    NSArray *sortedArray = [self.dataList sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
      if ([obj1[kKeyWeight] integerValue] <= [obj2[kKeyWeight] integerValue]) {
          return NSOrderedDescending;
      } else {
          return NSOrderedAscending;
      }
    }];
    self.sortedDataList = sortedArray;
}

#pragma mark-- Event
- (void)didSelectCommon {
    [self setupData];
    TUIProfileController *test = [[TUIProfileController alloc] init];
    [self.navigationController pushViewController:test animated:YES];
}

- (void)onEditFriendApply {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.tag = SHEET_AGREE;
    [sheet addButtonWithTitle:TIMCommonLocalizableString(MeFriendRequestMethodAgreeAll)];
    [sheet addButtonWithTitle:TIMCommonLocalizableString(MeFriendRequestMethodNeedConfirm)];
    [sheet addButtonWithTitle:TIMCommonLocalizableString(MeFriendRequestMethodDenyAll)];
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:TIMCommonLocalizableString(Cancel)]];
    [sheet setDelegate:self];
    [sheet showInView:self.view];
    [self setupData];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == SHEET_AGREE) {
        if (buttonIndex >= 3) return;
        self.profile.allowType = buttonIndex;
        [self setupData];
        V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
        info.allowType = [NSNumber numberWithInteger:buttonIndex].intValue;
        [[V2TIMManager sharedInstance] setSelfInfo:info succ:nil fail:nil];
    }
    // PRIVATEMARK
}

- (void)didTapOnAvatar:(TUIProfileCardCell *)cell {
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}

- (void)onSwitchMsgReadStatus:(TUICommonSwitchCell *)cell {
    BOOL on = cell.switcher.isOn;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSwitchMsgReadStatus:)]) {
        [self.delegate onSwitchMsgReadStatus:on];
    }

    TUICommonSwitchCellData *switchData = cell.switchData;
    switchData.on = on;
    if (on) {
        switchData.desc = TIMCommonLocalizableString(MeMessageReadStatusOpenDesc);
        [TUITool hideToast];
        [TUITool makeToast:TIMCommonLocalizableString(ShowPackageToast)];
    } else {
        switchData.desc = TIMCommonLocalizableString(MeMessageReadStatusCloseDesc);
    }
    [cell fillWithData:switchData];
}

- (void)onSwitchOnlineStatus:(TUICommonSwitchCell *)cell {
    BOOL on = cell.switcher.isOn;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSwitchOnlineStatus:)]) {
        [self.delegate onSwitchOnlineStatus:on];
    }
    TUIConfig.defaultConfig.displayOnlineStatusIcon = on;

    TUICommonSwitchCellData *switchData = cell.switchData;
    switchData.on = on;
    if (on) {
        switchData.desc = TIMCommonLocalizableString(ShowOnlineStatusOpenDesc);
    } else {
        switchData.desc = TIMCommonLocalizableString(ShowOnlineStatusCloseDesc);
    }

    if (on) {
        [TUITool hideToast];
        [TUITool makeToast:TIMCommonLocalizableString(ShowPackageToast)];
    }

    [cell fillWithData:switchData];
}

- (void)onSwitchCallsRecord:(TUICommonSwitchCell *)cell {
    BOOL on = cell.switcher.isOn;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSwitchCallsRecord:)]) {
        [self.delegate onSwitchCallsRecord:on];
    }

    TUICommonSwitchCellData *data = cell.switchData;
    data.on = on;
    [cell fillWithData:data];
}

- (void)onClickAboutIM:(TUICommonTextCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickAboutIM)]) {
        [self.delegate onClickAboutIM];
    }
}

- (void)onClickChangeStyle {
    TUIStyleSelectViewController *styleVC = [[TUIStyleSelectViewController alloc] init];
    styleVC.delegate = self;
    [self.navigationController pushViewController:styleVC animated:YES];
}

- (void)onClickChangeTheme {
    TUIThemeSelectController *vc = [[TUIThemeSelectController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark TUIStyleSelectControllerDelegate

- (void)onSelectStyle:(TUIStyleSelectCellModel *)cellModel {
    if (![cellModel.styleName isEqualToString:self.styleName]) {
        self.styleName = cellModel.styleName;
        if (self.delegate && [self.delegate respondsToSelector:@selector(onChangeStyle)]) {
            [self.delegate onChangeStyle];
        }
    }
}

#pragma mark TUIThemeSelectControllerDelegate
- (void)onSelectTheme:(TUIThemeSelectCollectionViewCellModel *)cellModel {
    if (![cellModel.themeName isEqualToString:self.themeName]) {
        self.themeName = cellModel.themeName;
        if (self.delegate && [self.delegate respondsToSelector:@selector(onChangeTheme)]) {
            [self.delegate onChangeTheme];
        }
    }
}

- (void)onClickLogout:(TUIButtonCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickLogout)]) {
        [self.delegate onClickLogout];
    }
}
@end
