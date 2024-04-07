//
//  TUINewFriendViewController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/4/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TUINewFriendViewController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUINewFriendViewDataProvider.h"

@interface TUINewFriendViewController () <UITableViewDelegate, UITableViewDataSource>
@property UITableView *tableView;
@property UIButton *moreBtn;
@property TUINewFriendViewDataProvider *viewModel;
@property(nonatomic, strong) UILabel *noDataTipsLabel;
@end

@implementation TUINewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TIMCommonLocalizableString(TUIKitContactsNewFriends);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;

    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");

    CGRect rect = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    if (@available(iOS 15.0, *)) {
        _tableView.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[TUICommonPendencyCell class] forCellReuseIdentifier:@"PendencyCell"];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 94, 0, 0);
    _tableView.backgroundColor = self.view.backgroundColor;

    _viewModel = TUINewFriendViewDataProvider.new;

    _moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _moreBtn.mm_h = 20;
    _tableView.tableFooterView = _moreBtn;
    _moreBtn.hidden = YES;

    @weakify(self);
    [RACObserve(_viewModel, dataList) subscribeNext:^(id _Nullable x) {
      @strongify(self);
      [self.tableView reloadData];
    }];

    self.noDataTipsLabel.frame = CGRectMake(10, 60, self.view.bounds.size.width - 20, 40);
    [self.tableView addSubview:self.noDataTipsLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData {
    [_viewModel loadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.noDataTipsLabel.hidden = (self.viewModel.dataList.count != 0);
    return self.viewModel.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 86;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUICommonPendencyCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PendencyCell" forIndexPath:indexPath];
    TUICommonPendencyCellData *data = self.viewModel.dataList[indexPath.row];
    data.cselector = @selector(cellClick:);
    data.cbuttonSelector = @selector(btnClick:);
    data.cRejectButtonSelector = @selector(rejectBtnClick:);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell fillWithData:data];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // add code here for when you hit delete
        [self.tableView beginUpdates];
        TUICommonPendencyCellData *data = self.viewModel.dataList[indexPath.row];
        [self.viewModel removeData:data];
        [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)btnClick:(TUICommonPendencyCell *)cell {
    [self.viewModel agreeData:cell.pendencyData];
    [self.tableView reloadData];
}

- (void)rejectBtnClick:(TUICommonPendencyCell *)cell {
    [self.viewModel rejectData:cell.pendencyData];
    [self.tableView reloadData];
}

- (void)cellClick:(TUICommonPendencyCell *)cell {
    if (self.cellClickBlock) {
        self.cellClickBlock(cell);
    }
}

- (UILabel *)noDataTipsLabel {
    if (_noDataTipsLabel == nil) {
        _noDataTipsLabel = [[UILabel alloc] init];
        _noDataTipsLabel.textColor = TIMCommonDynamicColor(@"nodata_tips_color", @"#999999");
        _noDataTipsLabel.font = [UIFont systemFontOfSize:14.0];
        _noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
        _noDataTipsLabel.text = TIMCommonLocalizableString(TUIKitContactNoNewApplicationRequest);
    }
    return _noDataTipsLabel;
}

@end
