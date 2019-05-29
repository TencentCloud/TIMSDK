//
//  TNewFriendViewController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/4/19.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "TNewFriendViewController.h"
#import "TNewFriendViewModel.h"
#import "TAlertView.h"
#import "ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
@import ImSDK;

@interface TNewFriendViewController ()<UITableViewDelegate,UITableViewDataSource>
@property UITableView *tableView;
@property UIButton  *moreBtn;
@property TNewFriendViewModel *viewModel;
@end

@implementation TNewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"新的联系人";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[TCommonPendencyCell class] forCellReuseIdentifier:@"PendencyCell"];
    
    _tableView.separatorInset = UIEdgeInsetsMake(0, 94, 0, 0);
    
    _viewModel = TNewFriendViewModel.new;
    
    _moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _moreBtn.mm_h = 20;
    _tableView.tableFooterView = _moreBtn;
    
    [self.moreBtn addTarget:self action:@selector(loadNextData) forControlEvents:UIControlEventTouchUpInside];
    [self.moreBtn setTitle:@"加载更多数据" forState:UIControlStateNormal];
    [self.moreBtn setTitle:@"没有了" forState:UIControlStateDisabled];
    RAC(_moreBtn, hidden) = RACObserve(_viewModel, isLoading);
    RAC(_moreBtn, enabled) = RACObserve(_viewModel, hasNextData);
    @weakify(self)
    [RACObserve(_viewModel, dataList) subscribeNext:^(id  _Nullable x) {
       @strongify(self)
       [self.tableView reloadData];
    }];
    [self loadData];
}

- (void)loadData
{
    [_viewModel loadData];
}

- (void)loadNextData
{
    [_viewModel loadNextData];
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
    [cell fillWithData:self.viewModel.dataList[indexPath.row]];
    cell.pendencyData.cagreeSelector = @selector(agreeClick:);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)agreeClick:(TCommonPendencyCell *)cell
{
    TCommonPendencyCellData *data = cell.pendencyData;
    TIMFriendResponse *rsp = TIMFriendResponse.new;
    rsp.identifier = data.identifier;
    rsp.responseType = TIM_FRIEND_RESPONSE_AGREE_AND_ADD;
    [[TIMFriendshipManager sharedInstance] doResponse:rsp succ:^(TIMFriendResult *result) {
        data.isAccepted = YES;
        [self.tableView reloadData];
    } fail:^(int code, NSString *msg) {
        TAlertView *alert = [[TAlertView alloc] initWithTitle:msg];
        [alert showInWindow:self.view.window];
    }];
}

@end
