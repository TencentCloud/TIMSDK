//
//  TUIGroupConversationListController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupConversationListController.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>

static NSString *gConversationCell_ReuseId = @"TConversationCell";

@interface TUIGroupConversationListController () <UIGestureRecognizerDelegate,
                                                  UITableViewDelegate,
                                                  UITableViewDataSource,
                                                  UIPopoverPresentationControllerDelegate>

@property(nonatomic, strong) UILabel *noDataTipsLabel;

@end

@implementation TUIGroupConversationListController

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TIMCommonLocalizableString(TUIKitContactsGroupChats);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];

    self.navigationItem.titleView = titleLabel;

    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    CGRect rect = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    if (@available(iOS 15.0, *)) {
        _tableView.sectionHeaderTopPadding = 0;
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];

    _tableView.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);

    [_tableView registerClass:[TUICommonContactCell class] forCellReuseIdentifier:gConversationCell_ReuseId];

    self.viewModel = [TUIGroupConversationListViewDataProvider new];
    [self updateConversations];

    @weakify(self);
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id _Nullable x) {
      @strongify(self);
      [self.tableView reloadData];
    }];

    self.noDataTipsLabel.frame = CGRectMake(10, 60, self.view.bounds.size.width - 20, 40);
    [self.tableView addSubview:self.noDataTipsLabel];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateConversations {
    [self.viewModel loadConversation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    self.noDataTipsLabel.hidden = (self.viewModel.groupList.count != 0);
    return self.viewModel.groupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataDict[self.viewModel.groupList[section]].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUICommonContactCellData *data = self.viewModel.dataDict[self.viewModel.groupList[indexPath.section]][indexPath.row];
    return [data heightOfWidth:Screen_Width];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TIMCommonLocalizableString(Delete);
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        TUICommonContactCellData *data = self.viewModel.dataDict[self.viewModel.groupList[indexPath.section]][indexPath.row];
        [self.viewModel removeData:data];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
#define TEXT_TAG 1
    static NSString *headerViewId = @"ContactDrawerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewId];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewId];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.tag = TEXT_TAG;
        textLabel.textColor = RGB(0x80, 0x80, 0x80);
        [headerView addSubview:textLabel];
        textLabel.mm_fill().mm_left(12);
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    label.text = self.viewModel.groupList[section];
    headerView.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    headerView.contentView.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 33;
}

- (void)didSelectConversation:(TUICommonContactCell *)cell {
    if (self.onSelect) {
        self.onSelect(cell.contactData);
        return;
    }

    NSDictionary *param = @{
        TUICore_TUIChatObjectFactory_ChatViewController_Title : cell.contactData.title ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_GroupID : cell.contactData.identifier ?: @"",
    };
    [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Classic param:param forResult:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUICommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:gConversationCell_ReuseId forIndexPath:indexPath];
    TUICommonContactCellData *data = self.viewModel.dataDict[self.viewModel.groupList[indexPath.section]][indexPath.row];
    if (!data.cselector) {
        data.cselector = @selector(didSelectConversation:);
    }
    [cell fillWithData:data];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (UILabel *)noDataTipsLabel {
    if (_noDataTipsLabel == nil) {
        _noDataTipsLabel = [[UILabel alloc] init];
        _noDataTipsLabel.textColor = TIMCommonDynamicColor(@"nodata_tips_color", @"#999999");
        _noDataTipsLabel.font = [UIFont systemFontOfSize:14.0];
        _noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
        _noDataTipsLabel.text = TIMCommonLocalizableString(TUIKitContactNoGroupChats);
    }
    return _noDataTipsLabel;
}

@end
