//
//  TUIConversationListController_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import "TUIConversationListController_Minimalist.h"
#import "TUIConversationCell_Minimalist.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"
#import "TUIConversationListDataProvider_Minimalist.h"
#import "TUIConversationCellData_Minimalist.h"

static NSString *kConversationCell_Minimalist_ReuseId = @"kConversationCell_Minimalist_ReuseId";

@interface TUIConversationListController_Minimalist () <
                                             UIGestureRecognizerDelegate,
                                             UITableViewDelegate,
                                             UITableViewDataSource,
                                             UIPopoverPresentationControllerDelegate,
                                             TUINotificationProtocol,
                                             TUIConversationListDataProviderDelegate
                                            >

@property (nonatomic, assign)BOOL showCheckBox;

@end

@implementation TUIConversationListController_Minimalist

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
    [self.provider loadNexPageConversations];
}

- (void)setupViews {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.view.backgroundColor = TUIConversationDynamicColor(@"conversation_bg_color", @"#FFFFFF");
    
    UIView *searchBar = nil;
    if (self.isEnableSearch) {
        NSDictionary *searchExtension = [TUICore getExtensionInfo:TUICore_TUIConversationExtension_GetSearchBar_Minimalist param:@{TUICore_TUIConversationExtension_ParentVC : self}];
        if (searchExtension) {
            searchBar = [searchExtension tui_objectForKey:TUICore_TUIConversationExtension_SearchBar asClass:UIView.class];
        }
    }
    //Fix  translucent = NO;
    CGRect rect = self.view.bounds;
    if (![UINavigationBar appearance].isTranslucent && [[[UIDevice currentDevice] systemVersion] doubleValue]<15.0) {
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - TabBar_Height - NavBar_Height );
    }
    _tableView = [[UITableView alloc] initWithFrame:rect];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [_tableView registerClass:[TUIConversationCell_Minimalist class] forCellReuseIdentifier:kConversationCell_Minimalist_ReuseId];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 0;
    _tableView.rowHeight = 64.0;
    if (searchBar) {
        [searchBar setFrame: CGRectMake(0, 0, self.view.bounds.size.width, 60)];
        searchBar.backgroundColor = [UIColor whiteColor];
        _tableView.tableHeaderView = searchBar;
    }
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delaysContentTouches = NO;
    [self.view addSubview:_tableView];
}

- (void)dealloc {
    [TUICore unRegisterEventByObject:self];
}

- (TUIConversationListDataProvider_Minimalist *)provider {
    if (!_provider) {
        _provider = [[TUIConversationListDataProvider_Minimalist alloc] init];
        _provider.delegate = self;
    }
    return (TUIConversationListBaseDataProvider *)_provider;
}

#pragma mark TUIConversationListDataProviderDelegate
- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(getConversationDisplayString:)]) {
        return [self.delegate getConversationDisplayString:conversation];
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
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
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
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
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
        self.dataSourceChanged(self.provider.conversationList.count);
    }
    return self.provider.conversationList.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *rowActions = [NSMutableArray array];
    TUIConversationCellData *cellData = self.provider.conversationList[indexPath.row];
    __weak typeof(self) weakSelf = self;

    // Mark as read action
    UITableViewRowAction *markAsReadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:(cellData.isMarkAsUnread||cellData.unreadCount > 0)  ? TUIKitLocalizableString(MarkAsRead) : TUIKitLocalizableString(MarkAsUnRead) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (cellData.isMarkAsUnread||cellData.unreadCount > 0) {
            [weakSelf.provider markConversationAsRead:cellData];
            if (cellData.isLocalConversationFoldList) {
                [TUIConversationListDataProvider_Minimalist  cacheConversationFoldListSettings_FoldItemIsUnread:NO];
            }
        }
        else {
            [weakSelf.provider markConversationAsUnRead:cellData];
            if (cellData.isLocalConversationFoldList) {
                [TUIConversationListDataProvider_Minimalist  cacheConversationFoldListSettings_FoldItemIsUnread:YES];
            }
        }
        
    }];
    markAsReadAction.backgroundColor = RGB(20, 122, 255);
        
    // Mark as hide action
    UITableViewRowAction *markHideAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:TUIKitLocalizableString(MarkHide) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.provider markConversationHide:cellData];
        if (cellData.isLocalConversationFoldList) {
            [TUIConversationListDataProvider_Minimalist  cacheConversationFoldListSettings_HideFoldItem:YES];
        }
    }];
    markHideAction.backgroundColor = RGB(242, 147, 64);
    
    // More action
    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"more" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        weakSelf.tableView.editing = NO;
        [weakSelf showMoreAction:cellData];
    }];
    moreAction.backgroundColor = [UIColor blackColor];
    
    //config Actions
    if (cellData.isLocalConversationFoldList) {
        [rowActions addObject:markHideAction];
    } else {
        [rowActions addObject:markAsReadAction];
        [rowActions addObject:moreAction];
    }
    return rowActions;
}

// available ios 11 +
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    if (self.showCheckBox) {
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    TUIConversationCellData *cellData = self.provider.conversationList[indexPath.row];
    NSMutableArray *arrayM = [NSMutableArray array];
    NSString *language = [TUIGlobalization tk_localizableLanguageKey];
    
    // Mark as read action
    UIContextualAction *markAsReadAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        completionHandler(YES);
        if (cellData.isMarkAsUnread||cellData.unreadCount > 0) {
            [weakSelf.provider markConversationAsRead:cellData];
            if (cellData.isLocalConversationFoldList) {
                [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_FoldItemIsUnread:NO];
            }
        }
        else {
            [weakSelf.provider markConversationAsUnRead:cellData];
            if (cellData.isLocalConversationFoldList) {
                [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_FoldItemIsUnread:YES];
            }
        }
    }];
    BOOL read = (cellData.isMarkAsUnread || cellData.unreadCount > 0);
    markAsReadAction.backgroundColor = read ? RGB(37, 104, 240) : RGB(102, 102, 102);
    NSString *markAsReadImageName = read ? @"icon_conversation_swipe_read" : @"icon_conversation_swipe_unread";
    if ([language containsString:@"zh-"]) {
        markAsReadImageName = [markAsReadImageName stringByAppendingString:@"_zh"];
    }
    markAsReadAction.image = TUIDynamicImage(@"", TUIThemeModuleConversation_Minimalist,[UIImage imageNamed:TUIConversationImagePath_Minimalist(markAsReadImageName)]);
    
    // Mark as hide action
    UIContextualAction *markHideAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:TUIKitLocalizableString(MarkHide) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        completionHandler(YES);
        [weakSelf.provider markConversationHide:cellData];
        if (cellData.isLocalConversationFoldList) {
            [TUIConversationListDataProvider_Minimalist  cacheConversationFoldListSettings_HideFoldItem:YES];
        }
    }];
    markHideAction.backgroundColor = [UIColor tui_colorWithHex:@"#0365F9"];

    // More action
    UIContextualAction *moreAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        completionHandler(YES);
        weakSelf.tableView.editing = NO;
        [weakSelf showMoreAction:cellData];
    }];
    moreAction.backgroundColor = RGB(0, 0, 0);
    NSString *moreImageName = [language containsString:@"zh-"] ? @"icon_conversation_swipe_more_zh" : @"icon_conversation_swipe_more";
    moreAction.image = TUIDynamicImage(@"", TUIThemeModuleConversation_Minimalist,[UIImage imageNamed:TUIConversationImagePath_Minimalist(moreImageName)]);
    
    //config Actions
    if (cellData.isLocalConversationFoldList) {
        [arrayM addObject:markHideAction];
    } else {
        [arrayM addObject:markAsReadAction];
        [arrayM addObject:moreAction];
    }
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:[NSArray arrayWithArray:arrayM]];
    configuration.performsFirstActionWithFullSwipe = NO;
    
    // fix bug:
    // In ios 12, image in SwipeActions will be renderd with template
    // The method is adding an new image to the origin
    // The purpose of using async is to ensure UISwipeActionPullView has been renderd in UITableView
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 12.0, *)) {
            [self reRenderingSwipeView];
        }
    });
    return configuration;
}

- (void)reRenderingSwipeView API_AVAILABLE(ios(12.0)) {
    if (@available(iOS 13.0, *)) {
        return;
    }
    static NSUInteger kSwipeImageViewTag;
    if (kSwipeImageViewTag == 0) {
        kSwipeImageViewTag = [NSStringFromClass(self.class) hash];
    }
    
    for (UIView *view in self.tableView.subviews) {
        if (![view isKindOfClass:NSClassFromString(@"UISwipeActionPullView")]) {
            continue;
        }
        for (UIView *subview in view.subviews) {
            if (![subview isKindOfClass:NSClassFromString(@"UISwipeActionStandardButton")]) {
                continue;
            }
            for (UIView *sub in subview.subviews) {
                if (![sub isKindOfClass:[UIImageView class]]) {
                    continue;
                }
                if ([sub viewWithTag:kSwipeImageViewTag] == nil) {
                    UIImageView *addedImageView = [[UIImageView alloc] initWithFrame:sub.bounds];
                    addedImageView.tag = kSwipeImageViewTag;
                    addedImageView.image= [[(UIImageView *)sub image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    [sub addSubview:addedImageView];
                }
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell_Minimalist *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_Minimalist_ReuseId forIndexPath:indexPath];
    TUIConversationCellData *data = [self.provider.conversationList objectAtIndex:indexPath.row];
    data.showCheckBox = self.showCheckBox;
    if (data.isLocalConversationFoldList) {
        data.showCheckBox = NO;
    }
    [cell fillWithData:data];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TUIConversationCell_Minimalist *cell = [tableView cellForRowAtIndexPath:indexPath];
    TUIConversationCellData *data = [self.provider.conversationList objectAtIndex:indexPath.row];
    data.avatarImage = cell.headImageView.image;
    if (self.delegate && [self.delegate respondsToSelector:@selector(conversationListController:didSelectConversation:)]) {
        [self.delegate conversationListController:self didSelectConversation:data];
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //通过开启或关闭这个开关，控制最后一行分割线的长度
    //Turn on or off the length of the last line of dividers by controlling this switch
    BOOL needLastLineFromZeroToMax = NO;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
           [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
        if (needLastLineFromZeroToMax && indexPath.row == (self.provider.conversationList.count - 1)) {
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
    [self.provider loadNexPageConversations];
}

- (void)enableMultiSelectedMode:(BOOL)enable {
    self.showCheckBox = enable;
    if (!enable) {
        for (TUIConversationCellData_Minimalist *cellData in self.provider.conversationList) {
            cellData.selected = NO;
        }
    }
    [self.tableView reloadData];
}
- (NSArray<TUIConversationCellData_Minimalist *> *)getMultiSelectedResult {
    NSMutableArray *arrayM = [NSMutableArray array];
    if (!self.showCheckBox) {
        return [NSArray arrayWithArray:arrayM];
    }
    for (TUIConversationCellData_Minimalist *data in self.provider.conversationList) {
        if (data.selected) {
            [arrayM addObject:data];
        }
    }
    return [NSArray arrayWithArray:arrayM];
}

//MARK: action
- (void)showMoreAction:(TUIConversationCellData *) cellData {
        
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self)weakSelf = self;
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(MarkHide) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.provider markConversationHide:cellData];
        if (cellData.isLocalConversationFoldList) {
            [TUIConversationListDataProvider_Minimalist  cacheConversationFoldListSettings_HideFoldItem:YES];
        }
    }]];

    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:cellData.isOnTop?TUIKitLocalizableString(UnPin):TUIKitLocalizableString(Pin) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.provider pinConversation:cellData pin:!cellData.isOnTop];
    }]];

    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(ClearHistoryChatMessage) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.provider markConversationAsRead:cellData];
        [strongSelf.provider clearHistoryMessage:cellData];
    }]];

    
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Delete) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.provider removeConversation:cellData];
    }]];
    
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}
@end

@interface IUConversationView_Minimalist : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUConversationView_Minimalist

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end
