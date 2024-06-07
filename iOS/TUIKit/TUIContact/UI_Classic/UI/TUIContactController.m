//
//  TContactsController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TUIContactController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIBlackListController.h"
#import "TUIContactActionCell.h"
#import "TUIFindContactViewController.h"
#import "TUIFriendProfileController.h"
#import "TUIFriendRequestViewController.h"
#import "TUIGroupConversationListController.h"
#import "TUINewFriendViewController.h"
#import "TUIUserProfileController.h"

#define kContactCellReuseId @"ContactCellReuseId"
#define kContactActionCellReuseId @"ContactActionCellReuseId"

@interface TUIContactController () <UITableViewDelegate, UITableViewDataSource, V2TIMFriendshipListener, TUIPopViewDelegate>
@property NSArray<TUIContactActionCellData *> *firstGroupData;
@end

@implementation TUIContactController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
              TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
              data.icon = TUIContactDynamicImage(@"contact_new_friend_img", [UIImage imageNamed:TUIContactImagePath(@"new_friend")]);
              data.title = TIMCommonLocalizableString(TUIKitContactsNewFriends);
              data.cselector = @selector(onAddNewFriend:);
              data;
          })];
    [list addObject:({
              TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
              data.icon = TUIContactDynamicImage(@"contact_public_group_img", [UIImage imageNamed:TUIContactImagePath(@"public_group")]);
              data.title = TIMCommonLocalizableString(TUIKitContactsGroupChats);
              data.cselector = @selector(onGroupConversation:);
              data;
          })];
    [list addObject:({
              TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
              data.icon = TUIContactDynamicImage(@"contact_blacklist_img", [UIImage imageNamed:TUIContactImagePath(@"blacklist")]);
              data.title = TIMCommonLocalizableString(TUIKitContactsBlackList);
              data.cselector = @selector(onBlackList:);
              data;
          })];
    
    [self addExtensionsToList:list];
    self.firstGroupData = [NSArray arrayWithArray:list];

    [self setupNavigator];
    [self setupViews];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginSucceeded) name:TUILoginSuccessNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onFriendInfoChanged) name:@"FriendInfoChangedNotification" object:nil];
}

- (void)addExtensionsToList:(NSMutableArray *)list {
    NSDictionary *param = @{TUICore_TUIContactExtension_ContactMenu_Nav: self.navigationController};
    NSArray<TUIExtensionInfo *> *extensionList = [TUICore getExtensionList:TUICore_TUIContactExtension_ContactMenu_ClassicExtensionID param:param];
    NSArray *sortedExtensionList = [extensionList sortedArrayUsingComparator:^NSComparisonResult(TUIExtensionInfo *obj1, TUIExtensionInfo *obj2) {
        if (obj1.weight <= obj2.weight) {
          return NSOrderedDescending;
        } else {
          return NSOrderedAscending;
        }
    }];
    for (TUIExtensionInfo *info in sortedExtensionList) {
        [list addObject:({
            TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
            data.icon = info.icon;
            data.title = info.text;
            data.cselector = @selector(onExtensionClicked:);
            data.onClicked = info.onClicked;
            data;
        })];
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)onLoginSucceeded {
    [self.viewModel loadContacts];
}

- (void)onFriendInfoChanged {
    [self.viewModel loadContacts];
}

- (void)setupNavigator {
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [moreButton setImage:TIMCommonDynamicImage(@"nav_more_img", [UIImage imageNamed:TIMCommonImagePath(@"more")]) forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(onRightItem:) forControlEvents:UIControlEventTouchUpInside];
    [moreButton.widthAnchor constraintEqualToConstant:24].active = YES;
    [moreButton.heightAnchor constraintEqualToConstant:24].active = YES;
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)setupViews {
    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    CGRect rect = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
    [_tableView setBackgroundColor:self.view.backgroundColor];

    _tableView.delaysContentTouches = NO;
    if (@available(iOS 15.0, *)) {
        _tableView.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:_tableView];

    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);
    [_tableView registerClass:[TUICommonContactCell class] forCellReuseIdentifier:kContactCellReuseId];
    [_tableView registerClass:[TUIContactActionCell class] forCellReuseIdentifier:kContactActionCellReuseId];

    @weakify(self);
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id finished) {
      @strongify(self);
      if ([(NSNumber *)finished boolValue]) {
          [self.tableView reloadData];
      }
    }];
    [RACObserve(self.viewModel, pendencyCnt) subscribeNext:^(NSNumber *x) {
      @strongify(self);
      self.firstGroupData[0].readNum = [x integerValue];
    }];
}

- (void)onRightItem:(UIButton *)rightBarButton;
{
    NSMutableArray *menus = [NSMutableArray array];
    TUIPopCellData *friend = [[TUIPopCellData alloc] init];
    friend.image = TUIDemoDynamicImage(@"pop_icon_add_friend_img", [UIImage imageNamed:TUIDemoImagePath(@"add_friend")]);
    friend.title = TIMCommonLocalizableString(ContactsAddFriends);  //@"";
    [menus addObject:friend];

    TUIPopCellData *group = [[TUIPopCellData alloc] init];
    group.image = TUIDemoDynamicImage(@"pop_icon_add_group_img", [UIImage imageNamed:TUIDemoImagePath(@"add_group")]);

    group.title = TIMCommonLocalizableString(ContactsJoinGroup);  //@"";
    [menus addObject:group];

    CGFloat height = [TUIPopCell getHeight] * menus.count + TUIPopView_Arrow_Size.height;
    CGFloat orginY = StatusBar_Height + NavBar_Height;
    CGFloat orginX = Screen_Width - 140;
    if(isRTL()){
        orginX = 10;
    }
    TUIPopView *popView = [[TUIPopView alloc] initWithFrame:CGRectMake(orginX, orginY, 130, height)];
    CGRect frameInNaviView = [self.navigationController.view convertRect:rightBarButton.frame fromView:rightBarButton.superview];
    popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
    popView.delegate = self;
    [popView setData:menus];
    [popView showInWindow:self.view.window];
}

- (void)popView:(TUIPopView *)popView didSelectRowAtIndex:(NSInteger)index {
    [self addToContactsOrGroups:(index == 0 ? TUIFindContactTypeC2C : TUIFindContactTypeGroup)];
}

- (void)addToContactsOrGroups:(TUIFindContactType)type {
    TUIFindContactViewController *add = [[TUIFindContactViewController alloc] init];
    add.type = type;
    @weakify(self);
    add.onSelect = ^(TUIFindContactCellModel *cellModel) {
      @strongify(self);
      if (cellModel.type == TUIFindContactTypeC2C) {
          TUIFriendRequestViewController *frc = [[TUIFriendRequestViewController alloc] init];
          frc.profile = cellModel.userInfo;
          [self.navigationController popViewControllerAnimated:NO];
          [self.navigationController pushViewController:frc animated:YES];
      } else {
          NSDictionary *param = @{TUICore_TUIGroupObjectFactory_GetGroupRequestViewControllerMethod_GroupInfoKey : cellModel.groupInfo};
          UIViewController *vc = [TUICore createObject:TUICore_TUIGroupObjectFactory
                                                   key:TUICore_TUIGroupObjectFactory_GetGroupRequestViewControllerMethod
                                                 param:param];
          [self.navigationController pushViewController:vc animated:YES];
      }
    };
    [self.navigationController pushViewController:add animated:YES];
}

- (TUIContactViewDataProvider *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [TUIContactViewDataProvider new];
        [_viewModel loadContacts];
    }
    return _viewModel;
}

- (void)onFriendListChanged {
    [_viewModel loadContacts];
}

- (void)onFriendApplicationListChanged {
    [_viewModel loadFriendApplication];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{ return self.viewModel.groupList.count + 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.firstGroupData.count;
    } else {
        NSString *group = self.viewModel.groupList[section - 1];
        NSArray *list = self.viewModel.dataDict[group];
        return list.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) return nil;

#define TEXT_TAG 1
    static NSString *headerViewId = @"ContactDrawerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewId];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewId];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.tag = TEXT_TAG;
        textLabel.font = [UIFont systemFontOfSize:16];
        textLabel.textColor = RGB(0x80, 0x80, 0x80);
        [textLabel setRtlAlignment:TUITextRTLAlignmentLeading];
        [headerView addSubview:textLabel];
        [textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(headerView.mas_leading).mas_offset(12);
            make.top.bottom.trailing.mas_equalTo(headerView);
        }];
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    label.text = self.viewModel.groupList[section - 1];
    headerView.contentView.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) return 0;

    return 33;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *array = [NSMutableArray arrayWithObject:@""];
    [array addObjectsFromArray:self.viewModel.groupList];
    return array;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TUIContactActionCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactActionCellReuseId forIndexPath:indexPath];
        [cell fillWithData:self.firstGroupData[indexPath.row]];
        cell.changeColorWhenTouched = YES;
        return cell;
    } else {
        TUICommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellReuseId forIndexPath:indexPath];
        NSString *group = self.viewModel.groupList[indexPath.section - 1];
        NSArray *list = self.viewModel.dataDict[group];
        TUICommonContactCellData *data = list[indexPath.row];
        data.cselector = @selector(onSelectFriend:);
        [cell fillWithData:data];
        cell.changeColorWhenTouched = YES;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark -
- (void)onSelectFriend:(TUICommonContactCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectFriend:)]) {
        [self.delegate onSelectFriend:cell];
        return;
    }
    TUICommonContactCellData *data = cell.contactData;
    TUIFriendProfileController *vc = [[TUIFriendProfileController alloc] init];
    vc.friendProfile = data.friendProfile;
    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
}

- (void)onAddNewFriend:(TUICommonTableViewCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onAddNewFriend:)]) {
        [self.delegate onAddNewFriend:cell];
        return;
    }
    TUINewFriendViewController *vc = TUINewFriendViewController.new;
    vc.cellClickBlock = ^(TUICommonPendencyCell *_Nonnull cell) {
      TUIUserProfileController *controller = [[TUIUserProfileController alloc] init];
      [[V2TIMManager sharedInstance] getUsersInfo:@[ cell.pendencyData.identifier ]
                                             succ:^(NSArray<V2TIMUserFullInfo *> *profiles) {
                                               controller.userFullInfo = profiles.firstObject;
                                               controller.pendency = cell.pendencyData;
                                               controller.actionType = PCA_PENDENDY_CONFIRM;
                                               [self.navigationController pushViewController:(UIViewController *)controller animated:YES];
                                             }
                                             fail:nil];
    };
    [self.navigationController pushViewController:vc animated:YES];
    [self.viewModel clearApplicationCnt];
}

- (void)onGroupConversation:(TUICommonTableViewCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onGroupConversation:)]) {
        [self.delegate onGroupConversation:cell];
        return;
    }
    TUIGroupConversationListController *vc = TUIGroupConversationListController.new;
    @weakify(self);
    vc.onSelect = ^(TUICommonContactCellData *_Nonnull cellData) {
      @strongify(self);
      NSDictionary *param = @{TUICore_TUIChatObjectFactory_ChatViewController_GroupID : cellData.identifier ?: @""};
      [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Classic param:param forResult:nil];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onBlackList:(TUICommonContactCell *)cell {
    TUIBlackListController *vc = TUIBlackListController.new;
    @weakify(self);
    vc.didSelectCellBlock = ^(TUICommonContactCell *_Nonnull cell) {
      @strongify(self);
      [self onSelectFriend:cell];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onExtensionClicked:(TUIContactActionCell *)cell {
    if (cell.actionData.onClicked) {
        cell.actionData.onClicked(nil);
    }
}

- (void)runSelector:(SEL)selector withObject:(id)object {
    if ([self respondsToSelector:selector]) {
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self, selector, object);
    }
}

@end

@interface IUContactView : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUContactView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end
