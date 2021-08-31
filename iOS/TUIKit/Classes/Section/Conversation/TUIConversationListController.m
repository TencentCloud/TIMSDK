//
//  TUIConversationListController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import "TUIConversationListController.h"
#import "TUIConversationCell.h"
#import "TUIKit.h"
#import "TUILocalStorage.h"
#import "TIMUserProfile+DataProvider.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIColor+TUIDarkMode.h"
#import "TUISearchBar.h"
#import "TUISearchViewController.h"
#import "TNavigationController.h"
#import "NSBundle+TUIKIT.h"

static NSString *kConversationCell_ReuseId = @"TConversationCell";

@interface TUIConversationListController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, TUISearchBarDelegate>
@end

@implementation TUIConversationListController

- (instancetype)init
{
    if (self = [super init]) {
        self.showSearchBar = YES;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupViews];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [_tableView registerClass:[TUIConversationCell class] forCellReuseIdentifier:kConversationCell_ReuseId];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    if (self.showSearchBar) {
        self.searchBar = [[TUISearchBar alloc] initWithEntrance:YES];
        self.searchBar.delegate = self;
        self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
        self.tableView.tableHeaderView = self.searchBar;
    }

    @weakify(self)
    [RACObserve(self.viewModel, dataList) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
}

- (TConversationListViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [TConversationListViewModel new];
    }
    return _viewModel;
}

#pragma mark - TUISearchBarDelegate
- (void)searchBarDidEnterSearch:(TUISearchBar *)searchBar
{
    TUISearchViewController *vc = [[TUISearchViewController alloc] init];
    TNavigationController *nav = [[TNavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:NO completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel.dataList[indexPath.row] heightOfWidth:Screen_Width];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *rowActions = [NSMutableArray array];
    TUIConversationCellData *cellData = self.viewModel.dataList[indexPath.row];
    __weak typeof(self) weakSelf = self;
    
    {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:TUILocalizableString(Delete) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [tableView beginUpdates];
            [weakSelf.viewModel removeData:cellData];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
        }];
        action.backgroundColor = [UIColor colorWithRed:242/255.0 green:77/255.0 blue:76/255.0 alpha:1.0];
        [rowActions addObject:action];
    }
    
    {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:cellData.isOnTop?TUILocalizableString(CancelStickonTop):TUILocalizableString(StickyonTop) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            if (cellData.isOnTop) {
                [TUILocalStorage.sharedInstance removeTopConversation:cellData.conversationID callback:nil];
            } else {
                [TUILocalStorage.sharedInstance addTopConversation:cellData.conversationID callback:nil];
            }
        }];
        action.backgroundColor = [UIColor colorWithRed:242/255.0 green:147/255.0 blue:64/255.0 alpha:1.0];
        [rowActions addObject:action];
    }
    
    {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:TUILocalizableString(ClearHistoryChatMessage) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            if (cellData.groupID.length) {
                [V2TIMManager.sharedInstance clearGroupHistoryMessage:cellData.groupID succ:^{
                    NSLog(@"clear group history messages, success");
                } fail:^(int code, NSString *desc) {
                    NSLog(@"clear group history messages, error|code:%d|desc:%@", code, desc);
                }];
            } else {
                [V2TIMManager.sharedInstance clearC2CHistoryMessage:cellData.userID succ:^{
                    NSLog(@"clear c2c history messages, success");
                } fail:^(int code, NSString *desc) {
                    NSLog(@"clear c2c history messages, error|code:%d|desc:%@", code, desc);
                }];
            }

        }];
        action.backgroundColor = [UIColor colorWithRed:32/255.0 green:124/255.0 blue:231/255.0 alpha:1.0];
        [rowActions addObject:action];
    }
    return rowActions;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)didSelectConversation:(TUIConversationCell *)cell
{
    for (id<TUIConversationListControllerListener> delegate in [TUIKitListenerManager sharedInstance].convListeners) {
        if (delegate && [delegate respondsToSelector:@selector(conversationListController:didSelectConversation:)]) {
            [delegate conversationListController:self didSelectConversation:cell];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_ReuseId forIndexPath:indexPath];
    TUIConversationCellData *data = [self.viewModel.dataList objectAtIndex:indexPath.row];
    if (!data.cselector) {
        data.cselector = @selector(didSelectConversation:);
    }
    [cell fillWithData:data];

    //可以在此处修改，也可以在对应cell的初始化中进行修改。用户可以灵活的根据自己的使用需求进行设置。
    cell.changeColorWhenTouched = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
           [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
        if (indexPath.row == (self.viewModel.dataList.count - 1)) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }

    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.viewModel loadConversation];
}
@end
