//
//  TUINewFriendViewController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/4/19.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TUINewFriendViewController.h"
#import "TUINewFriendViewModel.h"
#import "ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "Toast/Toast.h"
#import "UIColor+TUIDarkMode.h"
#import "THeader.h"
#import "NSBundle+TUIKIT.h"

@interface TUINewFriendViewController ()<UITableViewDelegate,UITableViewDataSource>
@property UITableView *tableView;
@property UIButton  *moreBtn;
@property TUINewFriendViewModel *viewModel;
@end

@implementation TUINewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = TUILocalizableString(TUIKitContactsNewFriends); // @"新的联系人";
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[TCommonPendencyCell class] forCellReuseIdentifier:@"PendencyCell"];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 94, 0, 0);
    _tableView.backgroundColor = self.view.backgroundColor;

    _viewModel = TUINewFriendViewModel.new;

    _moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _moreBtn.mm_h = 20;
    _tableView.tableFooterView = _moreBtn;
    _moreBtn.hidden = YES;

    @weakify(self)
    [RACObserve(_viewModel, dataList) subscribeNext:^(id  _Nullable x) {
       @strongify(self)
       [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData
{
    [_viewModel loadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCommonPendencyCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PendencyCell" forIndexPath:indexPath];
    TCommonPendencyCellData *data = self.viewModel.dataList[indexPath.row];
    data.cselector = @selector(cellClick:);
    data.cbuttonSelector = @selector(btnClick:);
    [cell fillWithData:data];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [self.tableView beginUpdates];
        TCommonPendencyCellData *data = self.viewModel.dataList[indexPath.row];
        [self.viewModel removeData:data];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)btnClick:(TCommonPendencyCell *)cell
{
    [self.viewModel agreeData:cell.pendencyData];
    [self.tableView reloadData];
}

- (void)cellClick:(TCommonPendencyCell *)cell
{
    id<TUIUserProfileControllerServiceProtocol> controller = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
    if ([controller isKindOfClass:[UIViewController class]]) {
        [[V2TIMManager sharedInstance] getUsersInfo:@[cell.pendencyData.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *profiles) {
            controller.userFullInfo = profiles.firstObject;
            controller.pendency = cell.pendencyData;
            controller.actionType = PCA_PENDENDY_CONFIRM;
            [self.navigationController pushViewController:(UIViewController *)controller animated:YES];
        } fail:nil];
    }
}

@end
