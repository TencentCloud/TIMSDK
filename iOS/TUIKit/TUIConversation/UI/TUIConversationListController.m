//
//  TUIConversationListController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import "TUIConversationListController.h"
#import "TUIConversationCell.h"
#import "TUICore.h"
#import "TUIDefine.h"

static NSString *kConversationCell_ReuseId = @"TConversationCell";

@interface TUIConversationListController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, TUIConversationListDataProviderDelegate, TUINotificationProtocol>
@end

@implementation TUIConversationListController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isEnableSearch = YES;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    
    // 获取扩展 searchBar
    UIView *searchBar = nil;
    if (self.isEnableSearch) {
        NSDictionary *searchExtension = [TUICore getExtensionInfo:TUICore_TUIConversationExtension_GetSearchBar param:@{TUICore_TUIConversationExtension_ParentVC : self}];
        if (searchExtension) {
            searchBar = [searchExtension tui_objectForKey:TUICore_TUIConversationExtension_SearchBar asClass:UIView.class];
        }
    }
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [_tableView registerClass:[TUIConversationCell class] forCellReuseIdentifier:kConversationCell_ReuseId];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = TConversationCell_Height;
    _tableView.rowHeight = TConversationCell_Height;
    if (searchBar) {
        [searchBar setFrame: CGRectMake(0, 0, self.view.bounds.size.width, 60)];
        _tableView.tableHeaderView = searchBar;
    }
    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    _tableView.delaysContentTouches = NO;
    [self.view addSubview:_tableView];

    @weakify(self)
    [RACObserve(self.dataProvider, dataList) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
}

- (void)dealloc {
    [TUICore unRegisterEventByObject:self];
}

- (TUIConversationListDataProvider *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [TUIConversationListDataProvider new];
        _dataProvider.delegate = self;
        [_dataProvider loadConversation];
    }
    return _dataProvider;
}

#pragma mark TUIConversationListDataProviderDelegate
- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(getConversationDisplayString:)]) {
        return [self.delegate getConversationDisplayString:conversation];
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataProvider.dataList.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *rowActions = [NSMutableArray array];
    TUIConversationCellData *cellData = self.dataProvider.dataList[indexPath.row];
    __weak typeof(self) weakSelf = self;
    
    {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:TUIKitLocalizableString(Delete) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [tableView beginUpdates];
            [weakSelf.dataProvider removeData:cellData];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
        }];
        action.backgroundColor = RGB(242, 77, 76);
        [rowActions addObject:action];
    }
    
    {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:cellData.isOnTop?TUIKitLocalizableString(CancelStickonTop):TUIKitLocalizableString(StickyonTop) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            if (cellData.isOnTop) {
                [TUIConversationPin.sharedInstance removeTopConversation:cellData.conversationID callback:nil];
            } else {
                [TUIConversationPin.sharedInstance addTopConversation:cellData.conversationID callback:nil];
            }
        }];
        action.backgroundColor = RGB(242, 147, 64);
        [rowActions addObject:action];
    }
    
    {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:TUIKitLocalizableString(ClearHistoryChatMessage) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            if (cellData.groupID.length) {
                [self.dataProvider clearGroupHistoryMessage:cellData.groupID];
            } else {
                [self.dataProvider clearC2CHistoryMessage:cellData.userID];
            }
        }];
        action.backgroundColor = RGB(32, 124, 231);
        [rowActions addObject:action];
    }
    return rowActions;
}

// available ios 11 +
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    __weak typeof(self) weakSelf = self;
    TUIConversationCellData *cellData = self.dataProvider.dataList[indexPath.row];
    NSMutableArray *arrayM = [NSMutableArray array];
    [arrayM addObject:({
        UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:TUIKitLocalizableString(Delete) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [tableView beginUpdates];
            [weakSelf.dataProvider removeData:cellData];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
        }];
        action.backgroundColor = RGB(242, 77, 76);
        action;
    })];
    
    [arrayM addObject:({
        UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:cellData.isOnTop?TUIKitLocalizableString(CancelStickonTop):TUIKitLocalizableString(StickyonTop) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            if (cellData.isOnTop) {
                [TUIConversationPin.sharedInstance removeTopConversation:cellData.conversationID callback:^(BOOL success, NSString * _Nullable errorMessage) {
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                }];
            } else {
                [TUIConversationPin.sharedInstance addTopConversation:cellData.conversationID callback:^(BOOL success, NSString * _Nullable errorMessage) {
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                }];
            }
        }];
        action.backgroundColor = RGB(242, 147, 64);
        action;
    })];
    
    [arrayM addObject:({
        UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:TUIKitLocalizableString(ClearHistoryChatMessage) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            if (cellData.groupID.length) {
                [self.dataProvider clearGroupHistoryMessage:cellData.groupID];
            } else {
                [self.dataProvider clearC2CHistoryMessage:cellData.userID];
            }
        }];
        action.backgroundColor = RGB(32, 124, 231);
        action;
    })];
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:[NSArray arrayWithArray:arrayM]];
    configuration.performsFirstActionWithFullSwipe = NO;
    return configuration;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)didSelectConversation:(TUIConversationCell *)cell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(conversationListController:didSelectConversation:)]) {
        [self.delegate conversationListController:self didSelectConversation:cell];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_ReuseId forIndexPath:indexPath];
    TUIConversationCellData *data = [self.dataProvider.dataList objectAtIndex:indexPath.row];
    // cselector 由使用 data 数据的 cell 点击触发
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
        if (indexPath.row == (self.dataProvider.dataList.count - 1)) {
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
    [self.dataProvider loadConversation];
}
@end
