//
//  TUISearchResultListController_Minimalist.m
//  Pods
//
//  Created by harvy on 2020/12/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISearchResultListController_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import "TUISearchBar_Minimalist.h"
#import "TUISearchEmptyView_Minimalist.h"
#import "TUISearchResultCellModel.h"
#import "TUISearchResultCell_Minimalist.h"
#import "TUISearchResultHeaderFooterView_Minimalist.h"

@interface TUISearchResultListController_Minimalist () <UITableViewDelegate, UITableViewDataSource, TUISearchBarDelegate_Minimalist, TUISearchResultDelegate>

@property(nonatomic, strong) NSMutableArray<TUISearchResultCellModel *> *results;
@property(nonatomic, copy) NSString *keyword;
@property(nonatomic, assign) TUISearchResultModule module;
@property(nonatomic, strong) NSDictionary<TUISearchParamKey, id> *param;
@property(nonatomic, strong) TUISearchDataProvider *dataProvider;

@property(nonatomic, strong) TUISearchBar_Minimalist *searchBar;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) TUISearchEmptyView_Minimalist *noDataEmptyView;

@property(nonatomic, assign) BOOL allowPageRequest;
@property(nonatomic, assign) NSUInteger pageIndex;

@end

@implementation TUISearchResultListController_Minimalist
static NSString *const Id = @"cell";
static NSString *const HFId = @"HFId";
static NSString *const HistoryHFId = @"HistoryHFId";

- (instancetype)initWithResults:(NSArray<TUISearchResultCellModel *> *__nullable)results
                        keyword:(NSString *__nullable)keyword
                         module:(TUISearchResultModule)module
                          param:(NSDictionary<TUISearchParamKey, id> *__nullable)param;
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

    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.view.backgroundColor = [UIColor whiteColor];

    UIImage *image = [UIImage imageNamed:TIMCommonImagePath(@"nav_back")];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    image = [image rtl_imageFlippedForRightToLeftLayoutDirection];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItems = @[ back ];
    self.navigationItem.leftItemsSupplementBackButton = NO;

    _searchBar = [[TUISearchBar_Minimalist alloc] init];
    [_searchBar setEntrance:NO];
    _searchBar.delegate = self;
    _searchBar.searchBar.text = self.keyword;
    self.navigationItem.titleView = _searchBar;

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = 60.f;
    [_tableView registerClass:TUISearchResultCell_Minimalist.class forCellReuseIdentifier:Id];
    [_tableView registerClass:TUISearchResultHeaderFooterView_Minimalist.class forHeaderFooterViewReuseIdentifier:HFId];
    [_tableView registerClass:TUISearchChatHistoryResultHeaderView_Minimalist.class forHeaderFooterViewReuseIdentifier:HistoryHFId];
    [self.view addSubview:_tableView];
    self.noDataEmptyView.frame = CGRectMake(0, kScale390(42), self.view.bounds.size.width - 20, 200);
    [self.tableView addSubview:self.noDataEmptyView];

    if (self.module == TUISearchResultModuleChatHistory) {
        [self.dataProvider searchForKeyword:self.searchBar.searchBar.text forModules:self.module param:self.param];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    self.searchBar.frame = CGRectMake(0, 0, self.view.mm_w, 44);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.backgroundColor = nil;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
}

- (TUISearchEmptyView_Minimalist *)noDataEmptyView {
    if (_noDataEmptyView == nil) {
        _noDataEmptyView = [[TUISearchEmptyView_Minimalist alloc] initWithImage:TUISearchBundleThemeImage(@"", @"search_not_found_icon")
                                                                           Text:TIMCommonLocalizableString(TUIKitSearchNoResultLists)];
        _noDataEmptyView.hidden = YES;
    }
    return _noDataEmptyView;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUISearchResultCell_Minimalist *cell = [tableView dequeueReusableCellWithIdentifier:Id forIndexPath:indexPath];
    if (indexPath.row >= self.results.count) {
        return cell;
    }
    TUISearchResultCellModel *model = self.results[indexPath.row];
    model.avatarType = TAvatarTypeRadiusCorner;
    [cell fillWithData:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row >= self.results.count) {
        return;
    }
    TUISearchResultCellModel *cellModel = self.results[indexPath.row];
    TUISearchResultCell_Minimalist *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (self.module == TUISearchResultModuleChatHistory) {
        cellModel.avatarImage = self.headerConversationAvatar ?: cell.avatarView.image;
        cellModel.title = self.headerConversationShowName ?: cell.title_label.text;
    } else {
        cellModel.avatarImage = cell.avatarView.image;
        cellModel.title = cell.title_label.text;
    }
    [self onSelectModel:cellModel module:self.module];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.module == TUISearchResultModuleChatHistory) {
        if (self.results.count == 0) {
            return 0;
        } else {
            TUISearchResultCellModel *cellModel = self.results[0];
            if ([cellModel.context isKindOfClass:NSDictionary.class]) {
                return 0;
            } else {
                return kScale390(64);
            }
        }
    } else {
        return self.results.count == 0 ? 0 : 30;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.module == TUISearchResultModuleChatHistory) {
        TUISearchChatHistoryResultHeaderView_Minimalist *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HistoryHFId];
        TUISearchResultCellModel *cellModel = self.results[0];
        [headerView configPlaceHolderImage:self.headerConversationAvatar imgUrl:self.headerConversationURL Text:self.headerConversationShowName];
        headerView.onTap = ^{
          [self headerViewJump2ChatViewController:cellModel];
        };
        return headerView;
    } else {
        TUISearchResultHeaderFooterView_Minimalist *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HFId];
        headerView.showMoreBtn = NO;
        headerView.title = titleForModule(self.module, YES);
        headerView.isFooter = NO;
        return headerView;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
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

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)headerViewJump2ChatViewController:(TUISearchResultCellModel *)cellModel {
    if ([cellModel.context isKindOfClass:V2TIMMessage.class]) {
        V2TIMMessage *message = cellModel.context;
        NSString *title = message.userID;
        if (self.headerConversationShowName.length > 0) {
            title = self.headerConversationShowName;
        }
        NSDictionary *param = @{
            TUICore_TUIChatObjectFactory_ChatViewController_Title : title ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_UserID : message.userID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_GroupID : message.groupID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : self.headerConversationAvatar ?: [[UIImage alloc] init],
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : self.headerConversationURL ?: @"",
        };
        [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Minimalist param:param forResult:nil];
    } else if (([cellModel.context isKindOfClass:NSDictionary.class])) {
        NSDictionary *convInfo = cellModel.context;
        V2TIMConversation *conversation = convInfo[kSearchChatHistoryConverationInfo];
        NSString *title = cellModel.title ?: cellModel.titleAttributeString.string;
        if (self.headerConversationShowName.length > 0) {
            title = self.headerConversationShowName;
        }
        NSDictionary *param = @{
            TUICore_TUIChatObjectFactory_ChatViewController_Title : title ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_UserID : conversation.userID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_GroupID : conversation.groupID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : self.headerConversationAvatar ?: [[UIImage alloc] init],
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : self.headerConversationURL ?: @"",
        };
        [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Minimalist param:param forResult:nil];
    }
}
- (void)onSelectModel:(TUISearchResultCellModel *)cellModel module:(TUISearchResultModule)module {
    [self.searchBar endEditing:YES];
    if (module == TUISearchResultModuleChatHistory) {
        if (![cellModel.context isKindOfClass:NSDictionary.class]) {
            if ([cellModel.context isKindOfClass:V2TIMMessage.class]) {
                V2TIMMessage *message = cellModel.context;
                NSString *title = message.userID;
                if (cellModel.title.length > 0) {
                    title = cellModel.title;
                }
                NSDictionary *param = @{
                    TUICore_TUIChatObjectFactory_ChatViewController_Title : title ?: @"",
                    TUICore_TUIChatObjectFactory_ChatViewController_UserID : message.userID ?: @"",
                    TUICore_TUIChatObjectFactory_ChatViewController_GroupID : message.groupID ?: @"",
                    TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : cellModel.avatarImage ?: [[UIImage alloc] init],
                    TUICore_TUIChatObjectFactory_ChatViewController_HighlightKeyword : self.searchBar.searchBar.text ?: @"",
                    TUICore_TUIChatObjectFactory_ChatViewController_LocateMessage : message,
                };
                [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Minimalist param:param forResult:nil];
                return;
            }
            return;
        }
        NSDictionary *convInfo = cellModel.context;
        NSString *conversationId = convInfo[kSearchChatHistoryConversationId];
        V2TIMConversation *conversation = convInfo[kSearchChatHistoryConverationInfo];
        NSArray *msgs = convInfo[kSearchChatHistoryConversationMsgs];

        NSMutableArray *results = [NSMutableArray array];
        for (V2TIMMessage *message in msgs) {
            TUISearchResultCellModel *model = [[TUISearchResultCellModel alloc] init];
            model.title = message.nickName ?: message.sender;
            NSString *desc = [TUISearchDataProvider matchedTextForMessage:message withKey:self.searchBar.searchBar.text];
            model.detailsAttributeString = [TUISearchDataProvider attributeStringWithText:desc key:self.searchBar.searchBar.text];
            model.avatarUrl = message.faceURL;
            model.groupType = conversation.groupID;
            model.avatarImage = conversation.type == V2TIM_C2C ? DefaultAvatarImage : DefaultGroupAvatarImageByGroupType(conversation.groupType);
            model.context = message;
            [results addObject:model];
        }
        TUISearchResultListController_Minimalist *vc =
            [[TUISearchResultListController_Minimalist alloc] initWithResults:results
                                                                      keyword:self.searchBar.searchBar.text
                                                                       module:module
                                                                        param:@{TUISearchChatHistoryParamKeyConversationId : conversationId}];

        vc.headerConversationAvatar = cellModel.avatarImage;
        vc.headerConversationShowName = cellModel.title;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }

    NSDictionary *param = nil;
    NSString *title = cellModel.title ?: cellModel.titleAttributeString.string;
    if (module == TUISearchResultModuleContact && [cellModel.context isKindOfClass:V2TIMFriendInfo.class]) {
        V2TIMFriendInfo *friend = cellModel.context;
        param = @{
            TUICore_TUIChatObjectFactory_ChatViewController_Title : title ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_UserID : friend.userID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : cellModel.avatarImage ?: [UIImage new],

        };
    }

    if (module == TUISearchResultModuleGroup && [cellModel.context isKindOfClass:V2TIMGroupInfo.class]) {
        V2TIMGroupInfo *group = cellModel.context;
        param = @{
            TUICore_TUIChatObjectFactory_ChatViewController_Title : title ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_GroupID : group.groupID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : cellModel.avatarImage ?: [UIImage new],
        };
    }
    [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Minimalist param:param forResult:nil];
}

#pragma mark - TUISearchBarDelegate
- (void)searchBarDidCancelClicked:(TUISearchBar_Minimalist *)searchBar {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)searchBar:(TUISearchBar_Minimalist *)searchBar searchText:(NSString *)key {
    [self.results removeAllObjects];
    self.allowPageRequest = YES;
    self.pageIndex = 0;
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.param];
    param[TUISearchChatHistoryParamKeyPage] = @(self.pageIndex);
    self.param = [NSDictionary dictionaryWithDictionary:param];

    [self.dataProvider searchForKeyword:key forModules:self.module param:self.param];
}

#pragma mark - TUISearchResultDelegate
- (void)onSearchResults:(NSDictionary<NSNumber *, NSArray<TUISearchResultCellModel *> *> *)results forModules:(TUISearchResultModule)modules {
    NSArray *arrayM = [results objectForKey:@(modules)];
    if (arrayM == nil) {
        arrayM = @[];
    }
    self.noDataEmptyView.hidden = YES;
    if ((arrayM.count == 0) && (self.results.count == 0)) {
        self.noDataEmptyView.hidden = NO;
        if (self.searchBar.searchBar.text.length == 0) {
            self.noDataEmptyView.hidden = YES;
        }
    }

    [self.results addObjectsFromArray:arrayM];
    [self.tableView reloadData];

    self.allowPageRequest = (arrayM.count >= TUISearchDefaultPageSize);
    self.pageIndex = (arrayM.count < TUISearchDefaultPageSize) ? self.pageIndex : self.pageIndex + 1;

    if (!self.allowPageRequest) {
    }
}

- (void)onSearchError:(NSString *)errMsg {
    NSLog(@"search error: %@", errMsg);
}

- (UIImage *)imageWithColor:(UIColor *)color {
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
