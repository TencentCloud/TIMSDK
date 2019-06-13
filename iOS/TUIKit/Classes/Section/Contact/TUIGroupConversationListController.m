//
//  TUIGroupConversationListController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/10.
//

#import "TUIGroupConversationListController.h"
#import "TUIConversationListController.h"
#import "TUIConversationCell.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "TUILocalStorage.h"
#import "TIMUserProfile+DataProvider.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
@import ImSDK;

static NSString *kConversationCell_ReuseId = @"TConversationCell";

@interface TUIGroupConversationListController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate>

@end

@implementation TUIGroupConversationListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRefreshConversations:) name:TUIKitNotification_TIMRefreshListener object:nil];
    
    
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
    
    [_tableView registerClass:[TUIConversationCell class] forCellReuseIdentifier:kConversationCell_ReuseId]; 

    
    self.viewModel = [TUIGroupConversationListViewModel new];
    [self updateConversations];
    
    @weakify(self)
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateConversations];
}

- (void)updateConversations
{
    [self.viewModel loadConversation];
}

- (void)onRefreshConversations:(NSNotification *)notification
{
    [self updateConversations];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.viewModel.groupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataDict[self.viewModel.groupList[section]].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUIConversationCellData *data = self.viewModel.dataDict[self.viewModel.groupList[indexPath.section]][indexPath.row];
    return [data heightOfWidth:Screen_Width];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        TUIConversationCellData *data = self.viewModel.dataDict[self.viewModel.groupList[indexPath.section]][indexPath.row];
        [self.viewModel removeData:data];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
#define TEXT_TAG 1
    static NSString *headerViewId = @"ContactDrawerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewId];
    if (!headerView)
    {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewId];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.tag = TEXT_TAG;
        textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        [headerView addSubview:textLabel];
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    label.text = self.viewModel.groupList[section];
    label.mm_sizeToFit().mm_left(12).mm__centerY(15);
    
    return headerView;
}

- (void)didSelectConversation:(TUIConversationCell *)cell
{
    
    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:cell.convData.convType receiver:cell.convData.convId];
    
    TUIChatController *chat = [[TUIChatController alloc] initWithConversation:conv];
    chat.title = cell.convData.title;
    [self.navigationController pushViewController:chat animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_ReuseId forIndexPath:indexPath];
    TUIConversationCellData *data = self.viewModel.dataDict[self.viewModel.groupList[indexPath.section]][indexPath.row];
    if (!data.cselector) {
        data.cselector = @selector(didSelectConversation:);
    }
    [cell fillWithData:data];
    return cell;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
