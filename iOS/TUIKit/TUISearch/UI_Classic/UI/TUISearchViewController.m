//
//  TUISearchViewController.m
//  Pods
//
//  Created by harvy on 2020/12/24.
//

#import <TIMCommon/TIMDefine.h>
#import "TUISearchViewController.h"
#import "TUISearchBar.h"
#import "TUISearchResultHeaderFooterView.h"
#import "TUISearchResultCell.h"
#import "TUISearchResultCellModel.h"
#import "TUISearchResultListController.h"
#import "TUISearchDataProvider.h"
#import <TUICore/TUICore.h>

@interface TUISearchViewController () <UITableViewDelegate, UITableViewDataSource, TUISearchBarDelegate, TUISearchResultDelegate>

@property (nonatomic, strong) TUISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TUISearchDataProvider *dataProvider;

@end

@implementation TUISearchViewController

static NSString * const Id = @"cell";
static NSString * const HFId = @"HFId";

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataProvider = [[TUISearchDataProvider alloc] init];
    _dataProvider.delegate = self;
    [self setupViews];
    [TUITool addUnsupportNotificationInVC:self];
}

- (void)dealloc {
    NSLog(@"%s dealloc", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _searchBar = [[TUISearchBar alloc] init];
    [_searchBar setEntrance:NO];
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = 60.f;
    [_tableView registerClass:TUISearchResultCell.class forCellReuseIdentifier:Id];
    [_tableView registerClass:TUISearchResultHeaderFooterView.class forHeaderFooterViewReuseIdentifier:HFId];
    [self.view addSubview:_tableView];
    
    [_searchBar.searchBar becomeFirstResponder];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    self.searchBar.frame = CGRectMake(0, 0, self.view.mm_w, 44);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - TUISearchResultDelegate
- (void)onSearchError:(NSString *)errMsg
{
    
}

- (void)onSearchResults:(NSDictionary<NSNumber *,NSArray<TUISearchResultCellModel *> *> *)results forModules:(TUISearchResultModule)modules
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource、TUITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataProvider.resultSet.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *results = [self resultForSection:section];
    return results.count > kMaxNumOfPerModule ? kMaxNumOfPerModule : results.count;
}

- (TUISearchResultCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUISearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:Id forIndexPath:indexPath];
    TUISearchResultModule module = TUISearchResultModuleContact;
    NSArray *results = [self resultForSection:indexPath.section module:&module];
    if (results.count <= indexPath.row) {
        return cell;
    }
    [cell fillWithData:results[indexPath.row]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    TUISearchResultModule module = TUISearchResultModuleContact;
    NSArray *results = [self resultForSection:section module:&module];
    if (results.count < kMaxNumOfPerModule) {
        return [UIView new];
    }
    __weak typeof(self) weakSelf = self;
    TUISearchResultHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HFId];
    footerView.isFooter = YES;
    footerView.title = titleForModule(module, NO);
    footerView.onTap = ^{
        [weakSelf onSelectMoreModule:module results:results];
    };
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSArray *results = [self resultForSection:section];
    if (results.count < kMaxNumOfPerModule) {
        return 10;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TUISearchResultModule module = TUISearchResultModuleContact;
    [self resultForSection:section module:&module];
    TUISearchResultHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HFId];
    headerView.isFooter = NO;
    headerView.title = titleForModule(module, YES);
    headerView.onTap = nil;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [self.searchBar endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TUISearchResultModule module = TUISearchResultModuleContact;
    NSArray *results = [self resultForSection:indexPath.section module:&module];
    if (results.count <= indexPath.row) {
        return;
    }
    TUISearchResultCellModel *cellModel = results[indexPath.row];
    [self onSelectModel:cellModel module:module];
}

#pragma mark - action
- (void)onSelectModel:(TUISearchResultCellModel *)cellModel module:(TUISearchResultModule)module
{
    [self.searchBar endEditing:YES];
    
    if (module == TUISearchResultModuleChatHistory) {
        if (![cellModel.context isKindOfClass:NSDictionary.class]) {
            return;
        }
        NSDictionary *convInfo = cellModel.context;
        NSString *conversationId = convInfo[kSearchChatHistoryConversationId];
        V2TIMConversation *conversation = convInfo[kSearchChatHistoryConverationInfo];
        NSArray *msgs = convInfo[kSearchChatHistoryConversationMsgs];
        if (msgs.count == 1) {
            NSDictionary *param = @{TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_TitleKey : cellModel.title ?: @"",
                                    TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_UserIDKey : conversation.userID ?: @"",
                                    TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_GroupIDKey : conversation.groupID ?: @"",
                                    TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_HighlightKeywordKey : self.searchBar.searchBar.text ?: @"",
                                    TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_LocateMessageKey : msgs.firstObject,
            };
            UIViewController *chatVC = [TUICore createObject:TUICore_TUIChatObjectFactory key:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod param:param];
            [chatVC setTitle:cellModel.title?:cellModel.titleAttributeString.string];
            [self.navigationController pushViewController:chatVC animated:YES];
            return;
        }

        NSMutableArray *results = [NSMutableArray array];
        for (V2TIMMessage *message in msgs) {
            TUISearchResultCellModel *model = [[TUISearchResultCellModel alloc] init];
            model.title = message.nickName?:message.sender;
            NSString *desc = [TUISearchDataProvider matchedTextForMessage:message withKey:self.searchBar.searchBar.text];
            model.detailsAttributeString = [TUISearchDataProvider attributeStringWithText:desc key:self.searchBar.searchBar.text];
            model.avatarUrl = message.faceURL;
            model.groupType = conversation.groupType;
            model.avatarImage = conversation.type == V2TIM_C2C ? DefaultAvatarImage : DefaultGroupAvatarImageByGroupType(conversation.groupType);;
            model.context = message;
            [results addObject:model];
        }
        TUISearchResultListController *vc = [[TUISearchResultListController alloc] initWithResults:results
                                                                                           keyword:self.searchBar.searchBar.text
                                                                                            module:module
                                                                                             param:@{TUISearchChatHistoryParamKeyConversationId:conversationId}];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    NSDictionary *param = nil;

    if (module == TUISearchResultModuleContact && [cellModel.context isKindOfClass:V2TIMFriendInfo.class]) {
        V2TIMFriendInfo *friend = cellModel.context;
        param = @{TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_TitleKey : cellModel.title ?: @"",
                                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_UserIDKey : friend.userID ?: @"",
        };
    }

    if (module == TUISearchResultModuleGroup && [cellModel.context isKindOfClass:V2TIMGroupInfo.class]) {
        V2TIMGroupInfo *group = cellModel.context;
        param = @{TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_TitleKey : cellModel.title ?: @"",
                                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_GroupIDKey : group.groupID ?: @"",
        };
    }
    UIViewController *chatVc = [TUICore createObject:TUICore_TUIChatObjectFactory key:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod param:param];
    NSParameterAssert(chatVc);
    [(UIViewController *)chatVc setTitle:cellModel.title?:cellModel.titleAttributeString.string];
    [self.navigationController pushViewController:(UIViewController *)chatVc animated:YES];
}

- (void)onSelectMoreModule:(TUISearchResultModule)module results:(NSArray<TUISearchResultCellModel *> *)results
{
    TUISearchResultListController *vc = [[TUISearchResultListController alloc] initWithResults:results
                                                                                       keyword:self.searchBar.searchBar.text
                                                                                        module:module
                                                                                         param:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - viewmodel
- (NSArray *)resultForSection:(NSInteger)section
{
    return [self resultForSection:section module:nil];
}

- (NSArray *)resultForSection:(NSInteger)section module:(TUISearchResultModule *)module
{
    NSArray *keys = self.dataProvider.resultSet.allKeys;
    if (section >= keys.count) {
        return 0;
    }
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return  [obj1 intValue] < [obj2 intValue] ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSNumber *key = keys[section];
    if (module) {
        *module = (TUISearchResultModule)[key integerValue];
    }
    return [self.dataProvider.resultSet objectForKey:key];
}

#pragma mark - TUISearchBarDelegate
- (void)searchBarDidCancelClicked:(TUISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)searchBar:(TUISearchBar *)searchBar searchText:(NSString *)key
{
    [self.dataProvider searchForKeyword:key forModules:TUISearchResultModuleAll param:nil];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end

@interface IUSearchView : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUSearchView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end
