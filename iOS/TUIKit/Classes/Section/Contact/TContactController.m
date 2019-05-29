//
//  TContactsController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "TContactController.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "TContactGroupHeaderView.h"
#import "NSString+Common.h"
#import "TFriendProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"

@import ImSDK;

@interface TContactController () <UITableViewDelegate,UITableViewDataSource>
@property UITableView *tableView;
@end

@implementation TContactController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    [_tableView registerClass:[TCommonContactCell class] forCellReuseIdentifier:@"FriendCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:TUIKitNotification_onAddFriends object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:TUIKitNotification_onDelFriends object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAddFriendReqs) name:TUIKitNotification_onAddFriendReqs object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:TUIKitNotification_onFriendProfileUpdate object:nil];
   
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
        _viewModel.contactSelector = @selector(didSelectContactCell:);
    }
    return _viewModel;
}

- (void)onAddFriendReqs {
    
}

- (void)reloadData {
    [_viewModel loadContacts];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.viewModel.groupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *group = self.viewModel.groupList[section];
    NSArray *list = self.viewModel.dataDict[group];
    return list.count;
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
        [headerView addSubview:textLabel];
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    label.text = self.viewModel.groupList[section];
    label.mm_sizeToFit().mm_left(12).mm__centerY(15);
    
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
    
    return 30;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.viewModel.groupList;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];

    NSString *group = self.viewModel.groupList[indexPath.section];
    NSArray *list = self.viewModel.dataDict[group];
    [cell fillWithData:list[indexPath.row]];
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)didSelectContactCell:(TCommonContactCell *)cell
{
    TCommonContactCellData *data = cell.contactData;
    
    id<TFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TFriendProfileControllerServiceProtocol)];
    if ([vc isKindOfClass:[UIViewController class]]) {
        vc.friendProfile = data.friendProfile;
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }
}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            TNewFriendViewController *vc = TNewFriendViewController.new;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//        if (indexPath.row == 1) {
//            TConversationController *vc = TConversationController.new;
//            vc.convFilter = TGroupMessage;
//            vc.delegate = self;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//        if (indexPath.row == 2) {
//            TBlackListController *vc = TBlackListController.new;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//    } else {
//        NSString *group = self.viewModel.groupList[indexPath.section];
//        NSArray *list = self.viewModel.dataDict[group];
//        TCommonContactCellData *data = list[indexPath.row];
//
//        id<TFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TFriendProfileControllerServiceProtocol)];
//        if ([vc isKindOfClass:[UIViewController class]]) {
//            vc.friendProfile = data.friendProfile;
//            [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
//        }
//    }
//}



@end
