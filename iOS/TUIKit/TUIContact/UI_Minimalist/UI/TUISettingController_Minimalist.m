//
//  TUISettingController_Minimalist.m
//  TUIContact
//
//  Created by lynxzhang on 2018/10/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//
#import "TUISettingController_Minimalist.h"
#import "TUIProfileController_Minimalist.h"
#import "TUICommonModel.h"
#import "TUILogin.h"
#import "TUIDarkModel.h"
#import "TUICommonModel.h"
#import "TUIThemeManager.h"
#import "TUIConfig.h"
#import "TUIContactProfileCardCell_Minimalist.h"

@interface TUILogOutButtonCell : TUIButtonCell

@end
@implementation TUILogOutButtonCell
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.button.mm_width(Screen_Width - 2 * kScale390(16))
    .mm_height(self.mm_h - TButtonCell_Margin)
    .mm_left(kScale390(16));
    self.button.layer.cornerRadius = kScale390(10);
    self.button.layer.masksToBounds = YES;
    self.button.backgroundColor = [UIColor tui_colorWithHex:@"f9f9f9"];
}
@end

@interface TUISettingController_Minimalist () <UIActionSheetDelegate, V2TIMSDKListener, TUIProfileCardDelegate>
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) V2TIMUserFullInfo *profile;
@property (nonatomic, strong) TUIContactProfileCardCellData_Minimalist *profileCellData;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation TUISettingController_Minimalist

- (instancetype) init {
    self = [super init];
    if (self) {
        self.showMessageReadStatusCell = YES;
        self.showDisplayOnlineStatusCell = YES;
        self.showLoginOutCell = YES;
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    
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
    
    [TUITool addUnsupportNotificationInVC:self debugOnly:NO];
}

#pragma mark - Debug
- (void)setupViews
{
    self.tableView.delaysContentTouches = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //Fix  translucent = NO;
    CGRect rect = self.view.bounds;
    if (![UINavigationBar appearance].isTranslucent && [[[UIDevice currentDevice] systemVersion] doubleValue]<15.0) {
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - TabBar_Height - NavBar_Height );
        self.tableView.frame = rect;
    }
    
    [self.tableView registerClass:[TUICommonTextCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[TUIContactProfileCardCell_Minimalist class] forCellReuseIdentifier:@"personalCell"];
    [self.tableView registerClass:[TUILogOutButtonCell class] forCellReuseIdentifier:@"buttonCell"];
    [self.tableView registerClass:[TUICommonSwitchCell class] forCellReuseIdentifier:@"switchCell"];
    
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
    return self.dataList.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    UIView *line = [[UIView alloc] init];
    if(section != 1 ) {
        line.backgroundColor = TUIDemoDynamicColor(@"separator_color", @"#DBDBDB");;
        line.frame = CGRectMake(kScale390(16), view.frame.size.height - 0.5, Screen_Width - kScale390(32), 0.5);
        [view addSubview:line];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0) {
        height = 0;
    }
    else if (section == self.dataList.count -1) {
        height = kScale390(37);
    }
    else {
        height = 10;
    }
    return height;}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = self.dataList[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = self.dataList[indexPath.section];
    TUICommonCellData *data = array[indexPath.row];

    return [data heightOfWidth:Screen_Width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _dataList[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TUIContactProfileCardCellData_Minimalist class]]){
        TUIContactProfileCardCell_Minimalist *cell = [tableView dequeueReusableCellWithIdentifier:@"personalCell" forIndexPath:indexPath];
        cell.delegate = self;
        [cell fillWithData:(TUIContactProfileCardCellData_Minimalist *)data];
        return cell;
    }
    else if([data isKindOfClass:[TUIButtonCellData class]]){
        TUILogOutButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:TButtonCell_ReuseId];
        if(!cell){
            cell = [[TUILogOutButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TButtonCell_ReuseId];
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
    self.dataList = [NSMutableArray array];

    TUIContactProfileCardCellData_Minimalist *personal = [[TUIContactProfileCardCellData_Minimalist alloc] init];
    personal.identifier = self.profile.userID;
    personal.avatarImage = DefaultAvatarImage;
    personal.avatarUrl = [NSURL URLWithString:self.profile.faceURL];
    personal.name = [self.profile showName];
    personal.genderString = [self.profile showGender];
    personal.signature = self.profile.selfSignature.length ? [NSString stringWithFormat:TUIKitLocalizableString(SignatureFormat), self.profile.selfSignature] : TUIKitLocalizableString(no_personal_signature);
    personal.cselector = @selector(didSelectCommon);
    personal.showAccessory = NO;
    personal.showSignature = YES;
    self.profileCellData = personal;
    [self.dataList addObject:@[personal]];

    TUICommonTextCellData *friendApply = [TUICommonTextCellData new];
    friendApply.key = TUIKitLocalizableString(MeFriendRequest);
    friendApply.showAccessory = YES;
    friendApply.cselector = @selector(onEditFriendApply);
    if (self.profile.allowType == V2TIM_FRIEND_ALLOW_ANY) {
        friendApply.value = TUIKitLocalizableString(MeFriendRequestMethodAgreeAll);
    }
    if (self.profile.allowType == V2TIM_FRIEND_NEED_CONFIRM) {
        friendApply.value = TUIKitLocalizableString(MeFriendRequestMethodNeedConfirm);
    }
    if (self.profile.allowType == V2TIM_FRIEND_DENY_ANY) {
        friendApply.value = TUIKitLocalizableString(MeFriendRequestMethodDenyAll);
    }
    [self.dataList addObject:@[friendApply]];
    
    if (self.showMessageReadStatusCell) {
        TUICommonSwitchCellData *msgReadStatus = [TUICommonSwitchCellData new];
        msgReadStatus.title =  TUIKitLocalizableString(MeMessageReadStatus);
        msgReadStatus.desc = self.msgNeedReadReceipt ? TUIKitLocalizableString(MeMessageReadStatusOpenDesc) : TUIKitLocalizableString(MeMessageReadStatusCloseDesc);
        msgReadStatus.cswitchSelector = @selector(onSwitchMsgReadStatus:);
        msgReadStatus.on = self.msgNeedReadReceipt;
        [self.dataList addObject:@[msgReadStatus]];
    }
    
    if (self.showDisplayOnlineStatusCell) {
        TUICommonSwitchCellData *onlineStatus = [TUICommonSwitchCellData new];
        onlineStatus.title =  TUIKitLocalizableString(ShowOnlineStatus);
        onlineStatus.desc = [TUIConfig defaultConfig].displayOnlineStatusIcon ? TUIKitLocalizableString(ShowOnlineStatusOpenDesc) : TUIKitLocalizableString(ShowOnlineStatusCloseDesc);
        onlineStatus.cswitchSelector = @selector(onSwitchOnlineStatus:);
        onlineStatus.on = [TUIConfig defaultConfig].displayOnlineStatusIcon;
        [self.dataList addObject:@[onlineStatus]];
    }
    
    if (self.aboutCellText.length > 0) {
        TUICommonTextCellData *about = [TUICommonTextCellData new];
        about.key = self.aboutCellText;
        about.showAccessory = YES;
        about.cselector = @selector(onClickAbout:);
        [self.dataList addObject:@[about]];
    }

    if (self.showLoginOutCell) {
        TUIButtonCellData *button =  [[TUIButtonCellData alloc] init];
        button.title = TUIKitLocalizableString(logout);
        button.style = ButtonRedText;
        button.cbuttonSelector = @selector(onClickLogout:);
        button.hideSeparatorLine = YES;
        [self.dataList addObject:@[button]];
    }
    
    [self.tableView reloadData];
}

#pragma mark -- Event
- (void)didSelectCommon {
    [self setupData];
    TUIProfileController_Minimalist *test = [[TUIProfileController_Minimalist alloc] init];
    [self.navigationController pushViewController:test animated:YES];
}

- (void)onEditFriendApply {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.tag = SHEET_AGREE;
    [sheet addButtonWithTitle:TUIKitLocalizableString(MeFriendRequestMethodAgreeAll)];
    [sheet addButtonWithTitle:TUIKitLocalizableString(MeFriendRequestMethodNeedConfirm)];
    [sheet addButtonWithTitle:TUIKitLocalizableString(MeFriendRequestMethodDenyAll)];
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:TUIKitLocalizableString(Cancel)]];
    [sheet setDelegate:self];
    [sheet showInView:self.view];
    [self setupData];
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
    BOOL on = cell.switcher.isOn;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSwitchMsgReadStatus:)]) {
        [self.delegate onSwitchMsgReadStatus:on];
    }
    
    TUICommonSwitchCellData *switchData = cell.switchData;
    switchData.on = on;
    if (on) {
        switchData.desc = TUIKitLocalizableString(MeMessageReadStatusOpenDesc);
        [TUITool hideToast];
        [TUITool makeToast:TUIKitLocalizableString(ShowPackageToast)];
    } else {
        switchData.desc = TUIKitLocalizableString(MeMessageReadStatusCloseDesc);
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
        switchData.desc = TUIKitLocalizableString(ShowOnlineStatusOpenDesc);
    } else {
        switchData.desc = TUIKitLocalizableString(ShowOnlineStatusCloseDesc);
    }
    
    if (on) {
        [TUITool hideToast];
        [TUITool makeToast:TUIKitLocalizableString(ShowPackageToast)];
    }
    
    [cell fillWithData:switchData];
}

- (void)onClickAbout:(TUICommonTextCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickAbout)]){
        [self.delegate onClickAbout];
    }
}

- (void)onClickLogout:(TUIButtonCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickLogout)]) {
        [self.delegate onClickLogout];
    }
}
@end
