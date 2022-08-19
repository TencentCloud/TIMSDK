//
//  TUISearchResultListController.m
//  Pods
//
//  Created by harvy on 2020/12/25.
//

#import "TUISearchResultListController.h"
#import "TUISearchResultCellModel.h"
#import "TUISearchResultCell.h"
#import "TUISearchBar.h"
#import "TUISearchResultHeaderFooterView.h"
#import "TUICore.h"
#import "TUIDefine.h"

@interface TUISearchResultListController () <UITableViewDelegate, UITableViewDataSource, TUISearchBarDelegate, TUISearchResultDelegate>

@property (nonatomic, strong) NSMutableArray<TUISearchResultCellModel *> *results;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) TUISearchResultModule module;
@property (nonatomic, strong) NSDictionary<TUISearchParamKey, id> *param;
@property (nonatomic, strong) TUISearchDataProvider *dataProvider;

@property (nonatomic, strong) TUISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL allowPageRequest;
@property (nonatomic, assign) NSUInteger pageIndex;

@end

@implementation TUISearchResultListController
static NSString * const Id = @"cell";
static NSString * const HFId  = @"HFId";

- (instancetype)initWithResults:(NSArray<TUISearchResultCellModel *> * __nullable)results
                        keyword:(NSString * __nullable)keyword
                         module:(TUISearchResultModule)module
                          param:(NSDictionary<TUISearchParamKey, id> * __nullable)param;
{
    if (self = [super init]) {
        _results = (module == TUISearchResultModuleChatHistory) ? [NSMutableArray arrayWithArray:@[]] : [NSMutableArray arrayWithArray:results];
        _keyword = keyword;
        _module = module;
        _dataProvider = [[TUISearchDataProvider alloc] init];
        _dataProvider.delegate = self;
        _param = param;
        _allowPageRequest = (module == TUISearchResultModuleChatHistory);
        _pageIndex = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor groupTableViewBackgroundColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIImage *image = [UIImage imageNamed:@"ic_back_white"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItems = @[back];
    self.navigationItem.leftItemsSupplementBackButton = NO;
    
    _searchBar = [[TUISearchBar alloc] init];
    [_searchBar setEntrance:NO];
    _searchBar.delegate = self;
    _searchBar.searchBar.text = self.keyword;
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
    
    if (self.module == TUISearchResultModuleChatHistory) {
        [self.dataProvider searchForKeyword:self.searchBar.searchBar.text forModules:self.module param:self.param];
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
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
    self.navigationController.navigationBar.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor groupTableViewBackgroundColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.backgroundColor = nil;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUISearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:Id forIndexPath:indexPath];
    if (indexPath.row >= self.results.count) {
        return cell;
    }
    [cell fillWithData:self.results[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row >= self.results.count) {
        return;
    }
    TUISearchResultCellModel *cellModel = self.results[indexPath.row];
    [self onSelectModel:cellModel module:self.module];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.results.count == 0 ? 0 : 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TUISearchResultHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HFId];
    headerView.isFooter = NO;
    headerView.title = titleForModule(self.module, YES);
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [self.searchBar endEditing:YES];
    
    if (self.allowPageRequest && scrollView.contentOffset.y + scrollView.bounds.size.height > scrollView.contentSize.height) {
        self.allowPageRequest = NO;
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.param];
        param[TUISearchChatHistoryParamKeyPage] = @(self.pageIndex);
        param[TUISearchChatHistoryParamKeyCount] = @(TUISearchDefaultPageSize);
        self.param = [NSDictionary dictionaryWithDictionary:param];
        [self.dataProvider searchForKeyword:self.searchBar.searchBar.text forModules:self.module param:self.param];
    }
}

- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSelectModel:(TUISearchResultCellModel *)cellModel module:(TUISearchResultModule)module
{
    [self.searchBar endEditing:YES];
    if (module == TUISearchResultModuleChatHistory) {
        if (![cellModel.context isKindOfClass:NSDictionary.class]) {
            if ([cellModel.context isKindOfClass:V2TIMMessage.class]) {
                V2TIMMessage *message = cellModel.context;
                NSDictionary *param = @{TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey : cellModel.title ?: @"",
                                        TUICore_TUIChatService_GetChatViewControllerMethod_UserIDKey : message.userID ?: @"",
                                        TUICore_TUIChatService_GetChatViewControllerMethod_GroupIDKey : message.groupID ?: @"",
                                        TUICore_TUIChatService_GetChatViewControllerMethod_HighlightKeywordKey : self.searchBar.searchBar.text ?: @"",
                                        TUICore_TUIChatService_GetChatViewControllerMethod_LocateMessageKey : message,
                };
                UIViewController *chatVC = [TUICore callService:TUICore_TUIChatService
                                                         method:TUICore_TUIChatService_GetChatViewControllerMethod
                                                          param:param];
                [chatVC setTitle:message.userID];
                [self.navigationController pushViewController:chatVC animated:YES];
                return;
            }
            return;
        }
        NSDictionary *convInfo = cellModel.context;
        NSString *conversationId = convInfo[kSearchChatHistoryConversationId];
        V2TIMConversation *conversation = convInfo[kSearchChatHistoryConverationInfo];
        NSArray *msgs = convInfo[kSearchChatHistoryConversationMsgs];
        if (msgs.count == 1) {
            NSDictionary *param = @{TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey : cellModel.title ?: @"",
                                    TUICore_TUIChatService_GetChatViewControllerMethod_UserIDKey : conversation.userID ?: @"",
                                    TUICore_TUIChatService_GetChatViewControllerMethod_GroupIDKey : conversation.groupID ?: @"",
                                    TUICore_TUIChatService_GetChatViewControllerMethod_HighlightKeywordKey : self.searchBar.searchBar.text ?: @"",
                                    TUICore_TUIChatService_GetChatViewControllerMethod_LocateMessageKey : msgs.firstObject,
            };
            UIViewController *chatVC = [TUICore callService:TUICore_TUIChatService
                                                     method:TUICore_TUIChatService_GetChatViewControllerMethod
                                                      param:param];
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
            model.groupType = conversation.groupID;
            model.avatarImage = conversation.type == V2TIM_C2C ? DefaultAvatarImage : DefaultGroupAvatarImageByGroupType(conversation.groupType);
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
        param = @{TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey : cellModel.title ?: @"",
                  TUICore_TUIChatService_GetChatViewControllerMethod_UserIDKey : friend.userID ?: @"",
                  
        };
    }

    if (module == TUISearchResultModuleGroup && [cellModel.context isKindOfClass:V2TIMGroupInfo.class]) {
        V2TIMGroupInfo *group = cellModel.context;
        param = @{TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey : cellModel.title ?: @"",
                  TUICore_TUIChatService_GetChatViewControllerMethod_GroupIDKey : group.groupID ?: @"",
                  
        };
    }

    UIViewController *chatVc = (UIViewController *)[TUICore callService:TUICore_TUIChatService
                                                                 method:TUICore_TUIChatService_GetChatViewControllerMethod
                                                                  param:param];
    [chatVc setTitle:cellModel.title?:cellModel.titleAttributeString.string];
    [self.navigationController pushViewController:(UIViewController *)chatVc animated:YES];
}

#pragma mark - TUISearchBarDelegate
- (void)searchBarDidCancelClicked:(TUISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)searchBar:(TUISearchBar *)searchBar searchText:(NSString *)key
{
    [self.results removeAllObjects];
    self.allowPageRequest = YES;
    self.pageIndex = 0;
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.param];
    param[TUISearchChatHistoryParamKeyPage] = @(self.pageIndex);
    self.param = [NSDictionary dictionaryWithDictionary:param];

    [self.dataProvider searchForKeyword:key forModules:self.module param:self.param];
}

#pragma mark - TUISearchResultDelegate
- (void)onSearchResults:(NSDictionary<NSNumber *,NSArray<TUISearchResultCellModel *> *> *)results forModules:(TUISearchResultModule)modules
{
    NSArray *arrayM = [results objectForKey:@(modules)];
    if (arrayM == nil) {
        arrayM = @[];
    }
    
    [self.results addObjectsFromArray:arrayM];
    [self.tableView reloadData];
    
    self.allowPageRequest = (arrayM.count >= TUISearchDefaultPageSize);
    self.pageIndex = (arrayM.count < TUISearchDefaultPageSize) ? self.pageIndex : self.pageIndex + 1;
    
    if (!self.allowPageRequest) {
    }
}

- (void)onSearchError:(NSString *)errMsg
{
    NSLog(@"search error: %@", errMsg);
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
