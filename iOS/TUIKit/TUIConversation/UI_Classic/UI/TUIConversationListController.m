//
//  TUIConversationListController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import "TUIConversationListController.h"
#import "TUIFoldListViewController.h"
#import "TUIConversationCell.h"
#import <TUICore/TUICore.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIConversationListDataProvider.h"

static NSString *kConversationCell_ReuseId = @"TConversationCell";

@interface TUIConversationListController () <
                                             UIGestureRecognizerDelegate,
                                             UITableViewDelegate,
                                             UITableViewDataSource,
                                             UIPopoverPresentationControllerDelegate,
                                             TUINotificationProtocol,
                                             TUIConversationListDataProviderDelegate,
                                             TUIPopViewDelegate
                                            >
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation TUIConversationListController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isShowBanner = YES;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigation];
    [self setupViews];
    [self.dataProvider loadNexPageConversations];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onFriendInfoChanged:) name:@"FriendInfoChangedNotification" object:nil];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [TUICore unRegisterEventByObject:self];
}

- (void)onFriendInfoChanged:(NSNotification *)notice
{
    V2TIMFriendInfo *friendInfo = notice.object;
    if (friendInfo == nil) {
        return;
    }
    for (TUIConversationCellData *cellData in self.dataProvider.conversationList) {
        if ([cellData.userID isEqualToString:friendInfo.userID]) {
            NSString *title = friendInfo.friendRemark;
            if (title.length == 0) {
                title = friendInfo.userFullInfo.nickName;
            }
            if (title.length == 0) {
                title = friendInfo.userID;
            }
            cellData.title = title;
            [self.tableView reloadData];
            break;
        }
    }
}

- (void)setupNavigation
{
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:TIMCommonDynamicImage(@"nav_more_img", [UIImage imageNamed:TIMCommonImagePath(@"more")]) forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [moreButton.widthAnchor constraintEqualToConstant:24].active = YES;
    [moreButton.heightAnchor constraintEqualToConstant:24].active = YES;
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationController.navigationItem.rightBarButtonItem = moreItem;
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)setupViews {
    self.view.backgroundColor = TUIConversationDynamicColor(@"conversation_bg_color", @"#FFFFFF");

    CGRect rect = self.view.bounds;    
    _tableView = [[UITableView alloc] initWithFrame:rect];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [_tableView registerClass:[TUIConversationCell class] forCellReuseIdentifier:kConversationCell_ReuseId];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = TConversationCell_Height;
    _tableView.rowHeight = TConversationCell_Height;
    _tableView.delaysContentTouches = NO;
    [self.view addSubview:_tableView];
    [_tableView setSeparatorColor:TIMCommonDynamicColor(@"separator_color", @"#DBDBDB")];
    
    if (self.isShowBanner) {
        CGSize size = CGSizeMake(self.view.bounds.size.width, 60);
        UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.tableView.tableHeaderView = bannerView;
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[TUICore_TUIConversationExtension_ConversationListBanner_BannerSize] = NSStringFromCGSize(size);
        param[TUICore_TUIConversationExtension_ConversationListBanner_ModalVC] = self;
        [TUICore raiseExtension:TUICore_TUIConversationExtension_ConversationListBanner_ClassicExtensionID  parentView:bannerView param:param];
    }
}

- (void)rightBarButtonClick:(UIButton *)rightBarButton
{
    NSMutableArray *menus = [NSMutableArray array];
    TUIPopCellData *friend = [[TUIPopCellData alloc] init];
    
    friend.image = TUIConversationDynamicImage(@"pop_icon_new_chat_img", [UIImage imageNamed:TUIConversationImagePath(@"new_chat")]);
    friend.title = TIMCommonLocalizableString(ChatsNewChatText);
    [menus addObject:friend];
    
    TUIPopCellData *group = [[TUIPopCellData alloc] init];
    group.image = TUIConversationDynamicImage(@"pop_icon_new_group_img", [UIImage imageNamed:TUIConversationImagePath(@"new_groupchat")]);
    group.title = TIMCommonLocalizableString(ChatsNewGroupText);
    [menus addObject:group];

    CGFloat height = [TUIPopCell getHeight] * menus.count + TUIPopView_Arrow_Size.height;
    CGFloat orginY = StatusBar_Height + NavBar_Height;
    TUIPopView *popView = [[TUIPopView alloc] initWithFrame:CGRectMake(Screen_Width - 155, orginY, 145, height)];
    CGRect frameInNaviView = [self.navigationController.view convertRect:rightBarButton.frame fromView:rightBarButton.superview];
    popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
    popView.delegate = self;
    [popView setData:menus];
    [popView showInWindow:self.view.window];
}

#pragma TUIPopViewDelegate
- (void)popView:(TUIPopView *)popView didSelectRowAtIndex:(NSInteger)index
{
    if (0 == index) {
        [self startConversation:V2TIM_C2C];
    } else {
        [self startConversation:V2TIM_GROUP];
    }
}

- (void)startConversation:(V2TIMConversationType)type {
    void (^selectContactCompletion)(NSArray<TUICommonContactSelectCellData *> *) = ^(NSArray<TUICommonContactSelectCellData *> *array){
        if (V2TIM_C2C == type) {
            NSDictionary *param = @{
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_TitleKey : array.firstObject.title ?: @"",
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_UserIDKey : array.firstObject.identifier ?: @"",
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AvatarImageKey : array.firstObject.avatarImage ? : [UIImage new],
                TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AvatarUrlKey : array.firstObject.avatarUrl.absoluteString ? : @""
            };
            
            UIViewController *chatVC = (UIViewController *)[TUICore createObject:TUICore_TUIChatObjectFactory key:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod param:param];
            [self.navigationController pushViewController:(UIViewController *)chatVC animated:YES];

            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [tempArray removeObjectAtIndex:tempArray.count-2];
            self.navigationController.viewControllers = tempArray;
        } else {
            @weakify(self)
            NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
            [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                @strongify(self)
                NSString *showName = loginUser;
                if (infoList.firstObject.nickName.length > 0) {
                    showName = infoList.firstObject.nickName;
                }
                NSMutableString *groupName = [NSMutableString stringWithString:showName];
                for (TUICommonContactSelectCellData *item in array) {
                    [groupName appendFormat:@"、%@", item.title];
                }

                if ([groupName length] > 10) {
                    groupName = [groupName substringToIndex:10].mutableCopy;
                }
                void(^createGroupCompletion)(BOOL , V2TIMGroupInfo *) = ^(BOOL isSuccess, V2TIMGroupInfo * _Nonnull info) {
                    NSDictionary *param = @{
                        TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_TitleKey : info.groupName ?: @"",
                        TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_GroupIDKey : info.groupID ?: @"",
                        TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AvatarUrlKey : info.faceURL ?: @""
                    };
                    
                    UIViewController *chatVC = (UIViewController *)[TUICore createObject:TUICore_TUIChatObjectFactory key:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod param:param];
                    [self.navigationController pushViewController:(UIViewController *)chatVC animated:YES];
                    
                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                        for (UIViewController * vc in self.navigationController.viewControllers) {
                            if ([vc isKindOfClass:NSClassFromString(@"TUIGroupCreateController")] ||
                                [vc isKindOfClass:NSClassFromString(@"TUIContactSelectController")]) {
                                [tempArray removeObject:vc];
                            }
                        }
                        
                    self.navigationController.viewControllers = tempArray;

                };
                
                NSDictionary *param = @{
                    TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_TitleKey : array.firstObject.title ?: @"",
                    TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_GroupNameKey : groupName ?: @"",
                    TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_GroupTypeKey : GroupType_Work,
                    TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_CompletionKey : createGroupCompletion,
                    TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_ContactListKey: array?:@[]
                };
                
                UIViewController *groupVC = (UIViewController *)[TUICore createObject:TUICore_TUIContactObjectFactory
                                                                                  key:TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod
                                                                                param:param];
                [self.navigationController pushViewController:(UIViewController *)groupVC animated:YES];
            } fail:nil];
        }
    };
    NSDictionary *param = @{
        TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey:  TIMCommonLocalizableString(ChatsSelectContact),
        TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_MaxSelectCount: @(type == V2TIM_C2C ? 1 : INT_MAX),
        TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey : selectContactCompletion
    };
    UIViewController *vc = [TUICore createObject:TUICore_TUIContactObjectFactory key:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod param:param];
    [self.navigationController pushViewController:vc animated:YES];
}

- (TUIConversationListBaseDataProvider *)dataProvider {
    if (!_dataProvider) {
        _dataProvider = [[TUIConversationListDataProvider alloc] init];
        _dataProvider.delegate = self;
    }
    return _dataProvider;
}

#pragma mark TUIConversationListDataProviderDelegate
- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(getConversationDisplayString:)]) {
        return [self.delegate getConversationDisplayString:conversation];
    }
    V2TIMMessage *msg = conversation.lastMessage;
    if (msg.customElem == nil || msg.customElem.data == nil) {
        return nil;
    }
    NSDictionary *param = [TUITool jsonData2Dictionary:msg.customElem.data];
    if (param != nil && [param isKindOfClass:[NSDictionary class]]) {
        NSString *businessID = param[@"businessID"];
        if (![businessID isKindOfClass:[NSString class]]) {
            return nil;
        }

        // whether custom jump message
        if ([businessID isEqualToString:BussinessID_TextLink] || ([(NSString *)param[@"text"] length] > 0 && [(NSString *)param[@"link"] length] > 0)) {
            NSString *desc = param[@"text"];
            if (msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
                if(msg.isSelf){
                    desc = TIMCommonLocalizableString(TUIKitMessageTipsYouRecallMessage);
                } else if (msg.userID.length > 0){
                    desc = TIMCommonLocalizableString(TUIkitMessageTipsOthersRecallMessage);
                } else if (msg.groupID.length > 0) {
                    /**
                     * 对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
                     * For the name display of group messages, the group business card is displayed first, the nickname has the second priority, and the user ID has the lowest priority.
                     */
                    NSString *userName = msg.nameCard;
                    if (userName.length == 0) {
                        userName = msg.nickName?:msg.sender;
                    }
                    desc = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
                }
            }
            return desc;
        }

        // whether the tips message of creating group
        else if ([businessID isEqualToString:BussinessID_GroupCreate] || [param.allKeys containsObject:BussinessID_GroupCreate]) {
            return [NSString stringWithFormat:@"\"%@\"%@",param[@"opUser"],param[@"content"]];
        }
    }
    return nil;
}

- (void)insertConversationsAtIndexPaths:(NSArray *)indexPaths {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf insertConversationsAtIndexPaths:indexPaths];
        });
        return;
    }
    [UIView performWithoutAnimation:^{
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)reloadConversationsAtIndexPaths:(NSArray *)indexPaths {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf reloadConversationsAtIndexPaths:indexPaths];
        });
        return;
    }
    if (self.tableView.isEditing) {
        self.tableView.editing = NO;
    }
    [UIView performWithoutAnimation:^{
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)deleteConversationAtIndexPaths:(NSArray *)indexPaths {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf deleteConversationAtIndexPaths:indexPaths];
        });
        return;
    }
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadAllConversations {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf reloadAllConversations];
        });
        return;
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSourceChanged) {
        self.dataSourceChanged(self.dataProvider.conversationList.count);
    }
    return self.dataProvider.conversationList.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *rowActions = [NSMutableArray array];
    TUIConversationCellData *cellData = self.dataProvider.conversationList[indexPath.row];
    __weak typeof(self) weakSelf = self;

    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:TIMCommonLocalizableString(Delete) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.dataProvider removeConversation:cellData];
    }];
    deleteAction.backgroundColor = RGB(242, 77, 76);

    UITableViewRowAction *stickyonTopAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:cellData.isOnTop?TIMCommonLocalizableString(CancelStickonTop):TIMCommonLocalizableString(StickyonTop) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.dataProvider pinConversation:cellData pin:!cellData.isOnTop];
    }];
    stickyonTopAction.backgroundColor = RGB(242, 147, 64);
    

    UITableViewRowAction *clearHistoryAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:TIMCommonLocalizableString(ClearHistoryChatMessage) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.dataProvider clearHistoryMessage:cellData];
    }];
    clearHistoryAction.backgroundColor = RGB(32, 124, 231);
    
    
    UITableViewRowAction *markAsReadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:(cellData.isMarkAsUnread||cellData.unreadCount > 0)  ? TIMCommonLocalizableString(MarkAsRead) : TIMCommonLocalizableString(MarkAsUnRead) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (cellData.isMarkAsUnread||cellData.unreadCount > 0) {
            [weakSelf.dataProvider markConversationAsRead:cellData];
            if (cellData.isLocalConversationFoldList) {
                [TUIConversationListDataProvider  cacheConversationFoldListSettings_FoldItemIsUnread:NO];
            }
        }
        else {
            [weakSelf.dataProvider markConversationAsUnRead:cellData];
            if (cellData.isLocalConversationFoldList) {
                [TUIConversationListDataProvider  cacheConversationFoldListSettings_FoldItemIsUnread:YES];
            }
        }
        
    }];
    markAsReadAction.backgroundColor = RGB(20, 122, 255);
        
    
    UITableViewRowAction *markHideAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:TIMCommonLocalizableString(MarkHide) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.dataProvider markConversationHide:cellData];
        if (cellData.isLocalConversationFoldList) {
            [TUIConversationListDataProvider  cacheConversationFoldListSettings_HideFoldItem:YES];
        }
    }];
    markHideAction.backgroundColor = RGB(242, 147, 64);
    
    //config Actions
    if (cellData.isLocalConversationFoldList) {
        [rowActions addObject:markHideAction];
    }
    else {
        
        [rowActions addObject:deleteAction];

        //        [rowActions addObject:stickyonTopAction];

        //        [rowActions addObject:clearHistoryAction];
        
        [rowActions addObject:markAsReadAction];
        
        [rowActions addObject:markHideAction];
    }
    
    return rowActions;
}

// available ios 11 +
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    __weak typeof(self) weakSelf = self;
    TUIConversationCellData *cellData = self.dataProvider.conversationList[indexPath.row];
    NSMutableArray *arrayM = [NSMutableArray array];
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:TIMCommonLocalizableString(Delete) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        completionHandler(YES);
        weakSelf.tableView.editing = NO;
        [weakSelf.dataProvider removeConversation:cellData];
    }];
    deleteAction.backgroundColor = RGB(242, 77, 76);
        
    UIContextualAction *stickyonTopAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:cellData.isOnTop?TIMCommonLocalizableString(CancelStickonTop):TIMCommonLocalizableString(StickyonTop) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        completionHandler(YES);
        weakSelf.tableView.editing = NO;
        [weakSelf.dataProvider pinConversation:cellData pin:!cellData.isOnTop];
    }];
    stickyonTopAction.backgroundColor = RGB(242, 147, 64);

    UIContextualAction *clearHistoryAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:TIMCommonLocalizableString(ClearHistoryChatMessage) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        completionHandler(YES);
        weakSelf.tableView.editing = NO;
        [weakSelf.dataProvider clearHistoryMessage:cellData];
    }];
    clearHistoryAction.backgroundColor = RGB(32, 124, 231);
    
    UIContextualAction *markAsReadAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:(cellData.isMarkAsUnread||cellData.unreadCount > 0)  ? TIMCommonLocalizableString(MarkAsRead) : TIMCommonLocalizableString(MarkAsUnRead) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        if (cellData.isMarkAsUnread||cellData.unreadCount > 0) {
            [weakSelf.dataProvider markConversationAsRead:cellData];
            if (cellData.isLocalConversationFoldList) {
                [TUIConversationListDataProvider  cacheConversationFoldListSettings_FoldItemIsUnread:NO];
            }
        }
        else {
            [weakSelf.dataProvider markConversationAsUnRead:cellData];
            if (cellData.isLocalConversationFoldList) {
                [TUIConversationListDataProvider  cacheConversationFoldListSettings_FoldItemIsUnread:YES];
            }
        }
    }];
    markAsReadAction.backgroundColor = RGB(20, 122, 255);
    
    UIContextualAction *markHideAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:TIMCommonLocalizableString(MarkHide) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [weakSelf.dataProvider markConversationHide:cellData];
        if (cellData.isLocalConversationFoldList) {
            [TUIConversationListDataProvider  cacheConversationFoldListSettings_HideFoldItem:YES];
        }
    }];
    markHideAction.backgroundColor = RGB(242, 147, 64);
    
    //config Actions
    if (cellData.isLocalConversationFoldList) {
        [arrayM addObject:markHideAction];
    }
    else {
        
        [arrayM addObject:deleteAction];

        //        [arrayM addObject:stickyonTopAction];

        //        [arrayM addObject:clearHistoryAction];

        [arrayM addObject:markHideAction];
        
        [arrayM addObject:markAsReadAction];
    }
    


    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:[NSArray arrayWithArray:arrayM]];
    configuration.performsFirstActionWithFullSwipe = NO;
    return configuration;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_ReuseId forIndexPath:indexPath];
    TUIConversationCellData *data = [self.dataProvider.conversationList objectAtIndex:indexPath.row];
    [cell fillWithData:data];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TUIConversationCellData *data = [self.dataProvider.conversationList objectAtIndex:indexPath.row];
    if (data.isLocalConversationFoldList) {
        [TUIConversationListDataProvider cacheConversationFoldListSettings_FoldItemIsUnread:NO];
        
        TUIFoldListViewController *foldVC = [[TUIFoldListViewController alloc] init];
        [self.navigationController pushViewController:foldVC animated:YES];
        
        @weakify(self)
        foldVC.dismissCallback = ^(NSMutableAttributedString * _Nonnull foldStr, NSArray * _Nonnull sortArr , NSArray * _Nonnull needRemoveFromCacheMapArray) {
            @strongify(self)
            data.foldSubTitle  = foldStr;
            data.subTitle = data.foldSubTitle;
            data.isMarkAsUnread = NO;
            
            if (sortArr.count <= 0 ) {
                data.orderKey = 0;
                if ([self.dataProvider.conversationList  containsObject:data]) {
                    [self.dataProvider hideConversation:data];
                }
            }
            
            for (NSString * removeId in needRemoveFromCacheMapArray) {
                if ([self.dataProvider.markFoldMap objectForKey:removeId] ) {
                    [self.dataProvider.markFoldMap removeObjectForKey:removeId];
                }
            }
            
            [TUIConversationListDataProvider cacheConversationFoldListSettings_FoldItemIsUnread:NO];
            [self.tableView reloadData];
        };
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(conversationListController:didSelectConversation:)]) {
        [self.delegate conversationListController:self didSelectConversation:data];
    } else {
        NSDictionary *param = @{
            TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_TitleKey : data.title ?: @"",
            TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_UserIDKey : data.userID ?: @"",
            TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_GroupIDKey : data.groupID ?: @"",
            TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AvatarImageKey : data.avatarImage ?: [UIImage new],
            TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AvatarUrlKey : data.faceUrl ?: @"",
            TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_ConversationIDKey : data.conversationID ?: @"",
            TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AtMsgSeqsKey : data.atMsgSeqs ?: @[],
            TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_DraftKey: data.draftText ?: @""
        };
        
        UIViewController *chatVC = (UIViewController *)[TUICore createObject:TUICore_TUIChatObjectFactory key:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod param:param];
        [self.navigationController pushViewController:(UIViewController *)chatVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //通过开启或关闭这个开关，控制最后一行分割线的长度
    //Turn on or off the length of the last line of dividers by controlling this switch
    BOOL needLastLineFromZeroToMax = NO;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
           [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
        if (needLastLineFromZeroToMax && indexPath.row == (self.dataProvider.conversationList.count - 1)) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }

    // Prevent the cell from inheriting the Table View's margin settings
    if (needLastLineFromZeroToMax && [cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Explictly set your cell's layout margins
    if (needLastLineFromZeroToMax && [cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.dataProvider loadNexPageConversations];
}

@end

@interface IUConversationView : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUConversationView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end
