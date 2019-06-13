//
//  TContactsController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TUIContactController.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "NSString+Common.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIBlackListController.h"
#import "TUINewFriendViewController.h"
#import "TUIConversationListController.h"
#import "TUIChatController.h"
#import "TUIGroupConversationListController.h"

@import ImSDK;

#define kContactCellReuseId @"ContactCellReuseId"
#define kContactActionCellReuseId @"ContactActionCellReuseId"

@interface TUIContactController () <UITableViewDelegate,UITableViewDataSource,TUIConversationListControllerDelegagte>
@property UITableView *tableView;
@property NSArray<TCommonContactCellData *> *firstGroupData;
@end

@implementation TUIContactController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        TCommonContactCellData *data = [[TCommonContactCellData alloc] init];
        data.avatarImage = [UIImage imageNamed:TUIKitResource(@"new_friend")];
        data.title = @"新的联系人";
        data.cselector = @selector(onAddNewFriend:);
        data;
    })];
    [list addObject:({
        TCommonContactCellData *data = [[TCommonContactCellData alloc] init];
        data.avatarImage = [UIImage imageNamed:TUIKitResource(@"public_group")];
        data.title = @"群聊";
        data.cselector = @selector(onGroupConversation:);
        data;
    })];
    [list addObject:({
        TCommonContactCellData *data = [[TCommonContactCellData alloc] init];
        data.avatarImage = [UIImage imageNamed:TUIKitResource(@"blacklist")];
        data.title = @"黑名单";
        data.cselector = @selector(onBlackList:);
        data;
    })];
    self.firstGroupData = [NSArray arrayWithArray:list];
    
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
    [_tableView setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1]];
    //cell无数据时，不显示间隔线
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];
    
    _tableView.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);
    
    [_tableView registerClass:[TCommonContactCell class] forCellReuseIdentifier:kContactCellReuseId];
    [_tableView registerClass:[TCommonContactCell class] forCellReuseIdentifier:kContactActionCellReuseId];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:TUIKitNotification_onAddFriends object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:TUIKitNotification_onDelFriends object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:TUIKitNotification_onFriendProfileUpdate object:nil];
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAddFriendReqs:) name:TUIKitNotification_onAddFriendReqs object:nil];
    
    @weakify(self)
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id finished) {
        @strongify(self)
        if ([(NSNumber *)finished boolValue]) {
            [self.tableView reloadData];
        }
    }];
    [self reloadData];
}

- (TContactViewModel *)viewModel
{
    if (_viewModel == nil) {
        _viewModel = [TContactViewModel new];
    }
    return _viewModel;
}


- (void)reloadData {
    [_viewModel loadContacts];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.viewModel.groupList.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.firstGroupData.count;
    } else {
        NSString *group = self.viewModel.groupList[section-1];
        NSArray *list = self.viewModel.dataDict[group];
        return list.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return nil;
    
#define TEXT_TAG 1
    static NSString *headerViewId = @"ContactDrawerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewId];
    if (!headerView)
    {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewId];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.tag = TEXT_TAG;
        textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        textLabel.textColor = RGB(0x80, 0x80, 0x80);
        [headerView addSubview:textLabel];
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    label.text = self.viewModel.groupList[section-1];
    label.mm_sizeToFit().mm_left(12).mm__centerY(12);
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0;
    
    return 22;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *array = [NSMutableArray arrayWithObject:@""];
    [array addObjectsFromArray:self.viewModel.groupList];
    return array;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TCommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactActionCellReuseId forIndexPath:indexPath];
        [cell fillWithData:self.firstGroupData[indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else {
        TCommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellReuseId forIndexPath:indexPath];
        NSString *group = self.viewModel.groupList[indexPath.section-1];
        NSArray *list = self.viewModel.dataDict[group];
        TCommonContactCellData *data = list[indexPath.row];
        data.cselector = @selector(onSelectFriend:);
        [cell fillWithData:data];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
}

- (void)onSelectFriend:(TCommonContactCell *)cell
{
    TCommonContactCellData *data = cell.contactData;
    
    id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
    if ([vc isKindOfClass:[UIViewController class]]) {
        vc.friendProfile = data.friendProfile;
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }
}

- (void)onAddFriendReqs:(NSNotification *)notify
{
    // TODO: 新朋友请求
}

//
- (void)onAddNewFriend:(TCommonTableViewCell *)cell
{
    TUINewFriendViewController *vc = TUINewFriendViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onGroupConversation:(TCommonTableViewCell *)cell
{
    TUIGroupConversationListController *vc = TUIGroupConversationListController.new;
    vc.title = @"群聊";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onBlackList:(TCommonContactCell *)cell
{
    TUIBlackListController *vc = TUIBlackListController.new;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)conversationListController:(TUIConversationListController *)conversationController didSelectConversation:(TUIConversationCell *)conversation;
{
    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:conversation.convData.convType receiver:conversation.convData.convId];
    TUIChatController *chat = [[TUIChatController alloc] initWithConversation:conv];
    chat.title = conversation.convData.title;
    [self.navigationController pushViewController:chat animated:YES];
}
@end
