//
//  TUISearchViewController_Minimalist.m
//  Pods
//
//  Created by harvy on 2020/12/24.
//

#import "TUIDefine.h"
#import "TUISearchViewController_Minimalist.h"
#import "TUISearchBar_Minimalist.h"
#import "TUISearchResultHeaderFooterView_Minimalist.h"
#import "TUISearchResultCell_Minimalist.h"
#import "TUISearchResultCellModel.h"
#import "TUISearchResultListController_Minimalist.h"
#import "TUISearchDataProvider.h"
#import "TUICore.h"
#import "TUISearchEmptyView_Minimalist.h"

@interface TUISearchViewController_Minimalist () <UITableViewDelegate, UITableViewDataSource, TUISearchBarDelegate_Minimalist, TUISearchResultDelegate>

@property (nonatomic, strong) TUISearchBar_Minimalist *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TUISearchDataProvider *dataProvider;
@property (nonatomic, strong) TUISearchEmptyView_Minimalist *noDataEmptyView;
@end

@implementation TUISearchViewController_Minimalist

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
    self.view.backgroundColor = [UIColor whiteColor];
    _searchBar = [[TUISearchBar_Minimalist alloc] init];
    [_searchBar setEntrance:NO];
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = kScale390(72);
    [_tableView registerClass:TUISearchResultCell_Minimalist.class forCellReuseIdentifier:Id];
    [_tableView registerClass:TUISearchResultHeaderFooterView_Minimalist.class forHeaderFooterViewReuseIdentifier:HFId];
    [self.view addSubview:_tableView];
    
    self.noDataEmptyView.frame = CGRectMake(0, kScale390(42), self.view.bounds.size.width - 20, 200);
    [self.tableView addSubview:self.noDataEmptyView];

    [_searchBar.searchBar becomeFirstResponder];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    self.searchBar.frame = CGRectMake(0, 0, self.view.mm_w, 44);
}

- (UIColor *)navBackColor {
    return  [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor =  [self navBackColor];
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.backgroundColor = [self navBackColor];
        navigationBar.barTintColor = [self navBackColor];
        navigationBar.shadowImage = [UIImage new];
        navigationBar.standardAppearance = appearance;
        navigationBar.scrollEdgeAppearance= appearance;
    }
    else {
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.backgroundColor = [self navBackColor];
        navigationBar.barTintColor = [self navBackColor];
        navigationBar.shadowImage = [UIImage new];
        [[UINavigationBar appearance] setTranslucent:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-  (TUISearchEmptyView_Minimalist *)noDataEmptyView {
    if (_noDataEmptyView == nil) {
        _noDataEmptyView = [[TUISearchEmptyView_Minimalist alloc] initWithImage:TUISearchBundleThemeImage(@"", @"search_not_found_icon") Text:TUIKitLocalizableString(TUIKitSearchNoResultLists)];
        _noDataEmptyView.hidden = YES;
    }
    return _noDataEmptyView;
}

#pragma mark - TUISearchResultDelegate
- (void)onSearchError:(NSString *)errMsg
{
    
}

- (void)onSearchResults:(NSDictionary<NSNumber *,NSArray<TUISearchResultCellModel *> *> *)results forModules:(TUISearchResultModule)modules
{
    self.noDataEmptyView.hidden = YES;
    if (!results || results.allKeys.count  == 0) {
        self.noDataEmptyView.hidden = NO;
        if(self.searchBar.searchBar.text.length == 0) {
            self.noDataEmptyView.hidden = YES;
        }
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUISearchResultCell_Minimalist *cell = [tableView dequeueReusableCellWithIdentifier:Id forIndexPath:indexPath];
    TUISearchResultModule module = TUISearchResultModuleContact;
    NSArray *results = [self resultForSection:indexPath.section module:&module];
    if (results.count <= indexPath.row) {
        return cell;
    }
    TUISearchResultCellModel *model = results[indexPath.row];
    model.avatarType = TAvatarTypeRadiusCorner;
    [cell fillWithData:model];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TUISearchResultModule module = TUISearchResultModuleContact;
    [self resultForSection:section module:&module];
    TUISearchResultHeaderFooterView_Minimalist *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HFId];
    headerView.isFooter = NO;
    headerView.showMoreBtn = YES;
    headerView.title = titleForModule(module, YES);
    __weak typeof(self) weakSelf = self;
    NSArray *results = [self resultForSection:section module:&module];
    headerView.onTap = ^{
        [weakSelf onSelectMoreModule:module results:results];
    };
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
    TUISearchResultCell_Minimalist *cell = [tableView cellForRowAtIndexPath:indexPath];
    cellModel.avatarImage = cell.avatarView.image;
    cellModel.title = cell.title_label.text;
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
        TUISearchResultListController_Minimalist *vc = [[TUISearchResultListController_Minimalist alloc] initWithResults:results
                                                                                           keyword:self.searchBar.searchBar.text
                                                                                            module:module
                                                                                             param:@{TUISearchChatHistoryParamKeyConversationId:conversationId}];
        vc.headerConversationAvatar =  cellModel.avatarImage;
        vc.headerConversationShowName = cellModel.title;

        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    NSDictionary *param = nil;

    if (module == TUISearchResultModuleContact && [cellModel.context isKindOfClass:V2TIMFriendInfo.class]) {
        V2TIMFriendInfo *friend = cellModel.context;
        param = @{TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey : cellModel.title ?: @"",
                  TUICore_TUIChatService_GetChatViewControllerMethod_UserIDKey : friend.userID ?: @"",
                  TUICore_TUIChatService_GetChatViewControllerMethod_AvatarImageKey : cellModel.avatarImage ?: [UIImage new],
        };
    }

    if (module == TUISearchResultModuleGroup && [cellModel.context isKindOfClass:V2TIMGroupInfo.class]) {
        V2TIMGroupInfo *group = cellModel.context;
        param = @{TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey : cellModel.title ?: @"",
                  TUICore_TUIChatService_GetChatViewControllerMethod_GroupIDKey : group.groupID ?: @"",
                  TUICore_TUIChatService_GetChatViewControllerMethod_AvatarImageKey : cellModel.avatarImage ?: [UIImage new],
        };
    }
    UIViewController *chatVc = [TUICore callService:TUICore_TUIChatService_Minimalist
                                             method:TUICore_TUIChatService_GetChatViewControllerMethod
                                              param:param];
    NSParameterAssert(chatVc);
    [(UIViewController *)chatVc setTitle:cellModel.title?:cellModel.titleAttributeString.string];
    [self.navigationController pushViewController:(UIViewController *)chatVc animated:YES];
}

- (void)onSelectMoreModule:(TUISearchResultModule)module results:(NSArray<TUISearchResultCellModel *> *)results
{
    TUISearchResultListController_Minimalist *vc = [[TUISearchResultListController_Minimalist alloc] initWithResults:results
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
- (void)searchBarDidCancelClicked:(TUISearchBar_Minimalist *)searchBar
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)searchBar:(TUISearchBar_Minimalist *)searchBar searchText:(NSString *)key
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

@interface IUSearchView_Minimalist : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUSearchView_Minimalist

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end
