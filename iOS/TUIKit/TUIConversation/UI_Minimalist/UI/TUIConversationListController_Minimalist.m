//
//  TUIConversationListController_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationListController_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIFloatViewController.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIConversationCellData_Minimalist.h"
#import "TUIConversationCell_Minimalist.h"
#import "TUIFoldListViewController_Minimalist.h"

static NSString *kConversationCell_Minimalist_ReuseId = @"kConversationCell_Minimalist_ReuseId";

@interface TUIConversationListController_Minimalist () <UIGestureRecognizerDelegate,
                                                        UITableViewDelegate,
                                                        UITableViewDataSource,
                                                        UIPopoverPresentationControllerDelegate,
                                                        TUINotificationProtocol,
                                                        TUIConversationListDataProviderDelegate,
                                                        TUIPopViewDelegate>
@property(nonatomic, strong) UIBarButtonItem *moreItem;
@property(nonatomic, strong) UIBarButtonItem *editItem;
@property(nonatomic, strong) UIBarButtonItem *doneItem;
@property(nonatomic, assign) BOOL showCheckBox;
@end

@implementation TUIConversationListController_Minimalist

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
    self.showCheckBox = NO;

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onFriendInfoChanged:) name:@"FriendInfoChangedNotification" object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(startCreatGroupNotification:)
                                               name:@"kTUIConversationCreatGroupNotification"
                                             object:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [TUICore unRegisterEventByObject:self];
}

- (UIColor *)navBackColor {
    return [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor = [self navBackColor];
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.backgroundColor = [self navBackColor];
        navigationBar.barTintColor = [self navBackColor];
        navigationBar.shadowImage = [UIImage new];
        navigationBar.standardAppearance = appearance;
        navigationBar.scrollEdgeAppearance = appearance;
    } else {
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.backgroundColor = [self navBackColor];
        navigationBar.barTintColor = [self navBackColor];
        navigationBar.shadowImage = [UIImage new];
    }
}

- (void)onFriendInfoChanged:(NSNotification *)notice {
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

- (void)setupNavigation {
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setImage:[UIImage imageNamed:TUIConversationImagePath_Minimalist(@"nav_edit")] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    editButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [editButton setFrame:CGRectMake(0, 0, 18 + 21 * 2, 18)];

    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:TUIConversationImagePath_Minimalist(@"nav_add")] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [moreButton setFrame:CGRectMake(0, 0, 20, 20)];

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:TIMCommonLocalizableString(TUIKitDone) forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setFrame:CGRectMake(0, 0, 30, 30)];

    self.editItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];

    self.navigationItem.rightBarButtonItems = @[ self.moreItem, self.editItem ];

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
    [_tableView registerClass:[TUIConversationCell_Minimalist class] forCellReuseIdentifier:kConversationCell_Minimalist_ReuseId];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 0;
    _tableView.rowHeight = 64.0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delaysContentTouches = NO;
    [self.view addSubview:_tableView];

    if (self.isShowBanner) {
        CGSize size = CGSizeMake(self.view.bounds.size.width, 60);
        UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.tableView.tableHeaderView = bannerView;
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[TUICore_TUIConversationExtension_ConversationListBanner_BannerSize] = NSStringFromCGSize(size);
        param[TUICore_TUIConversationExtension_ConversationListBanner_ModalVC] = self;
        BOOL isResponserExist = [TUICore raiseExtension:TUICore_TUIConversationExtension_ConversationListBanner_MinimalistExtensionID
                                             parentView:bannerView
                                                  param:param];
        if (!isResponserExist) {
            self.tableView.tableHeaderView = nil;
        }
    }
}

- (void)doneBarButtonClick:(UIBarButtonItem *)doneBarButton {
    [self openMultiChooseBoard:NO];
    self.navigationItem.rightBarButtonItems = @[ self.moreItem, self.editItem ];
}

- (void)editBarButtonClick:(UIButton *)editBarButton {
    [self openMultiChooseBoard:YES];
    [self enableMultiSelectedMode:YES];
    self.navigationItem.rightBarButtonItems = @[ self.doneItem ];
}

- (void)rightBarButtonClick:(UIButton *)rightBarButton {
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
    CGFloat orginX = Screen_Width - 155;
    if(isRTL()){
        orginX = 10;
    }
    TUIPopView *popView = [[TUIPopView alloc] initWithFrame:CGRectMake(orginX, orginY, 145, height)];
    CGRect frameInNaviView = [self.navigationController.view convertRect:rightBarButton.frame fromView:rightBarButton.superview];
    popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
    popView.delegate = self;
    [popView setData:menus];
    [popView showInWindow:self.view.window];
}

#pragma TUIPopViewDelegate
- (void)popView:(TUIPopView *)popView didSelectRowAtIndex:(NSInteger)index {
    if (0 == index) {
        [self startConversation:V2TIM_C2C];
    } else {
        [self startConversation:V2TIM_GROUP];
    }
}

- (void)startConversation:(V2TIMConversationType)type {
    TUIFloatViewController *floatVC = [[TUIFloatViewController alloc] init];

    void (^selectContactCompletion)(NSArray<TUICommonContactSelectCellData *> *) = ^(NSArray<TUICommonContactSelectCellData *> *array) {
      if (V2TIM_C2C == type) {
          NSDictionary *param = @{
              TUICore_TUIChatObjectFactory_ChatViewController_Title : array.firstObject.title ?: @"",
              TUICore_TUIChatObjectFactory_ChatViewController_UserID : array.firstObject.identifier ?: @"",
              TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : array.firstObject.avatarImage ?: DefaultAvatarImage,
              TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : array.firstObject.avatarUrl.absoluteString ?: @""
          };
          [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Minimalist param:param forResult:nil];
      } else {
          @weakify(self);
          NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
          [[V2TIMManager sharedInstance]
              getUsersInfo:@[ loginUser ]
                      succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                        @strongify(self);
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
                        void (^createGroupCompletion)(BOOL, V2TIMGroupInfo *, UIImage *) = ^(BOOL isSuccess, V2TIMGroupInfo *_Nonnull info,
                                                                                             UIImage *_Nonnull submitShowImage) {
                          NSDictionary *param = @{
                              TUICore_TUIChatObjectFactory_ChatViewController_Title : info.groupName ?: @"",
                              TUICore_TUIChatObjectFactory_ChatViewController_GroupID : info.groupID ?: @"",
                              TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : info.faceURL ?: @"",
                              TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : submitShowImage ?: [UIImage new],
                          };
                          [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Minimalist param:param forResult:nil];

                          NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                          for (UIViewController *vc in self.navigationController.viewControllers) {
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
                            TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_ContactListKey : array ?: @[]
                        };

                        UIViewController *groupVC = (UIViewController *)[TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist
                                                                                          key:TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod
                                                                                        param:param];

                        TUIFloatViewController *afloatVC = [[TUIFloatViewController alloc] init];
                        [afloatVC appendChildViewController:groupVC topMargin:kScale390(87.5)];
                        [afloatVC.topGestureView setTitleText:TIMCommonLocalizableString(ChatsNewGroupText)
                                                 subTitleText:@""
                                                  leftBtnText:TIMCommonLocalizableString(TUIKitCreateCancel)
                                                 rightBtnText:TIMCommonLocalizableString(TUIKitCreateFinish)];
                        [self presentViewController:afloatVC animated:YES completion:nil];
                      }
                      fail:nil];
      }
    };
    NSDictionary *param = @{
        TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey : TIMCommonLocalizableString(ChatsSelectContact),
        TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_MaxSelectCount : @(type == V2TIM_C2C ? 1 : INT_MAX),
        TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey : selectContactCompletion
    };
    UIViewController *vc = [TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist
                                             key:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod
                                           param:param];
    [floatVC appendChildViewController:vc topMargin:kScale390(87.5)];
    [floatVC.topGestureView setTitleText:((V2TIM_C2C == type)) ? TIMCommonLocalizableString(ChatsNewChatText) : TIMCommonLocalizableString(ChatsNewGroupText)
                            subTitleText:@""
                             leftBtnText:TIMCommonLocalizableString(TUIKitCreateCancel)
                            rightBtnText:(V2TIM_C2C == type) ? @"" : TIMCommonLocalizableString(TUIKitCreateNext)];

    floatVC.topGestureView.rightButton.enabled = NO;

    __weak typeof(floatVC) weakFloatVC = floatVC;
    floatVC.childVC.floatDataSourceChanged = ^(NSArray *_Nonnull arr) {
      if (arr.count != 0) {
          weakFloatVC.topGestureView.rightButton.enabled = YES;
      } else {
          weakFloatVC.topGestureView.rightButton.enabled = NO;
      }
    };

    [self presentViewController:floatVC animated:YES completion:nil];
}

- (TUIConversationListBaseDataProvider *)dataProvider {
    if (!_dataProvider) {
        _dataProvider = [[TUIConversationListDataProvider_Minimalist alloc] init];
        _dataProvider.delegate = self;
    }
    return (TUIConversationListDataProvider_Minimalist *)_dataProvider;
}

#pragma mark - edit
- (void)openMultiChooseBoard:(BOOL)open {
    [self.view endEditing:YES];
    self.showCheckBox = open;

    if (_multiChooseView) {
        [_multiChooseView removeFromSuperview];
    }

    if (open) {
        _multiChooseView = [[TUIConversationMultiChooseView_Minimalist alloc] init];
        _multiChooseView.frame = UIScreen.mainScreen.bounds;
        _multiChooseView.titleLabel.text = @"";
        _multiChooseView.toolView.hidden = YES;

        [_multiChooseView.readButton setTitle:TIMCommonLocalizableString(ReadAll) forState:UIControlStateNormal];
        [_multiChooseView.hideButton setTitle:TIMCommonLocalizableString(Hide) forState:UIControlStateNormal];
        [_multiChooseView.deleteButton setTitle:TIMCommonLocalizableString(Delete) forState:UIControlStateNormal];
        _multiChooseView.readButton.enabled = YES;
        _multiChooseView.hideButton.enabled = NO;
        _multiChooseView.deleteButton.enabled = NO;
        @weakify(self);
        _multiChooseView.readButton.clickCallBack = ^(id _Nonnull button) {
          @strongify(self);
          [self chooseViewReadAll];
        };
        _multiChooseView.hideButton.clickCallBack = ^(id _Nonnull button) {
          @strongify(self);
          [self choosViewActionHide];
        };
        _multiChooseView.deleteButton.clickCallBack = ^(id _Nonnull button) {
          @strongify(self);
          [self chooseViewActionDelete];
        };

        if (@available(iOS 12.0, *)) {
            if (@available(iOS 13.0, *)) {
                // > ios 12
                [UIApplication.sharedApplication.keyWindow addSubview:_multiChooseView];
            } else {
                // ios = 12
                UIView *view = self.navigationController.view;
                if (view == nil) {
                    view = self.view;
                }
                [view addSubview:_multiChooseView];
            }
        } else {
            // < ios 12
            [UIApplication.sharedApplication.keyWindow addSubview:_multiChooseView];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onCloseConversationMultiChooseBoard)]) {
            [self.delegate onCloseConversationMultiChooseBoard];
        }
        [self enableMultiSelectedMode:NO];
        self.navigationItem.rightBarButtonItems = @[ self.moreItem, self.editItem ];
    }
}

- (void)chooseViewReadAll {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClearAllConversationUnreadCount)]) {
        [self.delegate onClearAllConversationUnreadCount];
    }
    [self openMultiChooseBoard:NO];
}

- (void)choosViewActionHide {
    NSArray *uiMsgs = [self getMultiSelectedResult];
    if (uiMsgs.count == 0) {
        return;
    }
    for (TUIConversationCellData *data in uiMsgs) {
        [self.dataProvider markConversationHide:data];
    }

    [self openMultiChooseBoard:NO];
}

- (void)chooseViewActionRead {
    NSArray *uiMsgs = [self getMultiSelectedResult];
    if (uiMsgs.count == 0) {
        return;
    }
    for (TUIConversationCellData *data in uiMsgs) {
        [self.dataProvider markConversationAsRead:data];
    }

    [self openMultiChooseBoard:NO];
}

- (void)chooseViewActionDelete {
    NSArray *uiMsgs = [self getMultiSelectedResult];
    if (uiMsgs.count == 0) {
        return;
    }

    for (TUIConversationCellData *data in uiMsgs) {
        [self.dataProvider removeConversation:data];
    }

    [self openMultiChooseBoard:NO];
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
                V2TIMUserFullInfo *info = msg.revokerInfo;
                NSString *  revokeReason = msg.revokeReason;
                BOOL hasRiskContent = msg.hasRiskContent;
                if (hasRiskContent) {
                    desc =  TIMCommonLocalizableString(TUIKitMessageTipsRecallRiskContent);
                }
                else if (info) {
                    NSString *userName = info.nickName;
                    desc  = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
                }
                else if (msg.isSelf) {
                    desc = TIMCommonLocalizableString(TUIKitMessageTipsYouRecallMessage);
                } else if (msg.userID.length > 0) {
                    desc = TIMCommonLocalizableString(TUIKitMessageTipsOthersRecallMessage);
                } else if (msg.groupID.length > 0) {
                    /**
                     * For the name display of group messages, the group business card is displayed first, the nickname has the second priority, and the user ID
                     * has the lowest priority.
                     */
                    NSString *userName = msg.nameCard;
                    if (userName.length == 0) {
                        userName = msg.nickName ?: msg.sender;
                    }
                    desc = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
                }
            }
            return desc;
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

    // Mark as read action
    UITableViewRowAction *markAsReadAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                           title:(cellData.isMarkAsUnread || cellData.unreadCount > 0) ? TIMCommonLocalizableString(MarkAsRead)
                                                                                                       : TIMCommonLocalizableString(MarkAsUnRead)
                                         handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                                           if (cellData.isMarkAsUnread || cellData.unreadCount > 0) {
                                               [weakSelf.dataProvider markConversationAsRead:cellData];
                                               if (cellData.isLocalConversationFoldList) {
                                                   [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_FoldItemIsUnread:NO];
                                               }
                                           } else {
                                               [weakSelf.dataProvider markConversationAsUnRead:cellData];
                                               if (cellData.isLocalConversationFoldList) {
                                                   [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_FoldItemIsUnread:YES];
                                               }
                                           }
                                         }];
    markAsReadAction.backgroundColor = RGB(20, 122, 255);

    // Mark as hide action
    UITableViewRowAction *markHideAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                           title:TIMCommonLocalizableString(MarkHide)
                                         handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                                           [weakSelf.dataProvider markConversationHide:cellData];
                                           if (cellData.isLocalConversationFoldList) {
                                               [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_HideFoldItem:YES];
                                           }
                                         }];
    markHideAction.backgroundColor = RGB(242, 147, 64);

    // More action
    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                          title:@"more"
                                                                        handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                                                                          weakSelf.tableView.editing = NO;
                                                                          [weakSelf showMoreAction:cellData];
                                                                        }];
    moreAction.backgroundColor = [UIColor blackColor];

    // config Actions
    if (cellData.isLocalConversationFoldList) {
        [rowActions addObject:markHideAction];
    } else {
        [rowActions addObject:markAsReadAction];
        [rowActions addObject:moreAction];
    }
    return rowActions;
}

// available ios 11 +
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
    trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    if (self.showCheckBox) {
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    TUIConversationCellData *cellData = self.dataProvider.conversationList[indexPath.row];
    NSMutableArray *arrayM = [NSMutableArray array];
    NSString *language = [TUIGlobalization tk_localizableLanguageKey];

    // Mark as read action
    UIContextualAction *markAsReadAction = [UIContextualAction
        contextualActionWithStyle:UIContextualActionStyleNormal
                            title:@""
                          handler:^(UIContextualAction *_Nonnull action, __kindof UIView *_Nonnull sourceView, void (^_Nonnull completionHandler)(BOOL)) {
                            completionHandler(YES);
                            if (cellData.isMarkAsUnread || cellData.unreadCount > 0) {
                                [weakSelf.dataProvider markConversationAsRead:cellData];
                                if (cellData.isLocalConversationFoldList) {
                                    [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_FoldItemIsUnread:NO];
                                }
                            } else {
                                [weakSelf.dataProvider markConversationAsUnRead:cellData];
                                if (cellData.isLocalConversationFoldList) {
                                    [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_FoldItemIsUnread:YES];
                                }
                            }
                          }];
    BOOL read = (cellData.isMarkAsUnread || cellData.unreadCount > 0);
    markAsReadAction.backgroundColor = read ? RGB(37, 104, 240) : RGB(102, 102, 102);
    NSString *markAsReadImageName = read ? @"icon_conversation_swipe_read" : @"icon_conversation_swipe_unread";
    if ([language tui_containsString:@"zh-"]) {
        markAsReadImageName = [markAsReadImageName stringByAppendingString:@"_zh"];
    }
    else if ([language tui_containsString:@"ar"]) {
        markAsReadImageName = [markAsReadImageName stringByAppendingString:@"_ar"];
    }
    markAsReadAction.image =
        TUIDynamicImage(@"", TUIThemeModuleConversation_Minimalist, [UIImage imageNamed:TUIConversationImagePath_Minimalist(markAsReadImageName)]);

    // Mark as hide action
    UIContextualAction *markHideAction = [UIContextualAction
        contextualActionWithStyle:UIContextualActionStyleNormal
                            title:TIMCommonLocalizableString(MarkHide)
                          handler:^(UIContextualAction *_Nonnull action, __kindof UIView *_Nonnull sourceView, void (^_Nonnull completionHandler)(BOOL)) {
                            completionHandler(YES);
                            [weakSelf.dataProvider markConversationHide:cellData];
                            if (cellData.isLocalConversationFoldList) {
                                [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_HideFoldItem:YES];
                            }
                          }];
    markHideAction.backgroundColor = [UIColor tui_colorWithHex:@"#0365F9"];

    // More action
    UIContextualAction *moreAction = [UIContextualAction
        contextualActionWithStyle:UIContextualActionStyleNormal
                            title:@""
                          handler:^(UIContextualAction *_Nonnull action, __kindof UIView *_Nonnull sourceView, void (^_Nonnull completionHandler)(BOOL)) {
                            completionHandler(YES);
                            weakSelf.tableView.editing = NO;
                            [weakSelf showMoreAction:cellData];
                          }];
    moreAction.backgroundColor = RGB(0, 0, 0);
    NSString *moreImageName =  @"icon_conversation_swipe_more";
    if ([language tui_containsString:@"zh-"]) {
        moreImageName = [moreImageName stringByAppendingString:@"_zh"];
    }
    else if ([language tui_containsString:@"ar"]) {
        moreImageName = [moreImageName stringByAppendingString:@"_ar"];
    }
    moreAction.image = TUIDynamicImage(@"", TUIThemeModuleConversation_Minimalist, [UIImage imageNamed:TUIConversationImagePath_Minimalist(moreImageName)]);

    // config Actions
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
                    addedImageView.image = [[(UIImageView *)sub image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
    TUIConversationCellData *data = [self.dataProvider.conversationList objectAtIndex:indexPath.row];
    data.showCheckBox = self.showCheckBox;
    if (data.isLocalConversationFoldList) {
        data.showCheckBox = NO;
    }
    [cell fillWithData:data];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell_Minimalist *cell = [tableView cellForRowAtIndexPath:indexPath];
    TUIConversationCellData *data = [self.dataProvider.conversationList objectAtIndex:indexPath.row];
    data.avatarImage = cell.headImageView.image;
    [self.tableView reloadData];

    if (self.showCheckBox) {
        if (data.isLocalConversationFoldList) {
            return;
        }
        data.selected = !data.selected;

        NSArray *uiMsgs = [self getMultiSelectedResult];
        if (uiMsgs.count == 0) {
            self.multiChooseView.readButton.enabled = NO;
            self.multiChooseView.deleteButton.enabled = NO;
            self.multiChooseView.hideButton.enabled = NO;
            return;
        }

        @weakify(self);
        if (uiMsgs.count > 0) {
            self.multiChooseView.hideButton.enabled = YES;
            self.multiChooseView.deleteButton.enabled = YES;
            [self.multiChooseView.readButton setTitle:TIMCommonLocalizableString(MarkAsRead) forState:UIControlStateNormal];
            self.multiChooseView.readButton.clickCallBack = ^(id _Nonnull button) {
              @strongify(self);
              [self chooseViewActionRead];
            };
            for (TUIConversationCellData *data in uiMsgs) {
                if (data.unreadCount > 0) {
                    self.multiChooseView.readButton.enabled = YES;
                    break;
                }
            }
        }
        return;
    }

    if (data.isLocalConversationFoldList) {
        [TUIConversationListBaseDataProvider cacheConversationFoldListSettings_FoldItemIsUnread:NO];

        TUIFoldListViewController_Minimalist *foldVC = [[TUIFoldListViewController_Minimalist alloc] init];
        [self.navigationController pushViewController:foldVC animated:YES];

        @weakify(self);
        foldVC.dismissCallback = ^(NSMutableAttributedString *_Nonnull foldStr, NSArray *_Nonnull sortArr, NSArray *_Nonnull needRemoveFromCacheMapArray) {
          @strongify(self);
          data.foldSubTitle = foldStr;
          data.subTitle = data.foldSubTitle;
          data.isMarkAsUnread = NO;

          if (sortArr.count <= 0) {
              data.orderKey = 0;
              if ([self.dataProvider.conversationList containsObject:data]) {
                  [self.dataProvider hideConversation:data];
              }
          }

          for (NSString *removeId in needRemoveFromCacheMapArray) {
              if ([self.dataProvider.markFoldMap objectForKey:removeId]) {
                  [self.dataProvider.markFoldMap removeObjectForKey:removeId];
              }
          }

          [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_FoldItemIsUnread:NO];
          [self.tableView reloadData];
        };
        return;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(conversationListController:didSelectConversation:)]) {
        [self.delegate conversationListController:self didSelectConversation:data];
    } else {
        NSDictionary *param = @{
            TUICore_TUIChatObjectFactory_ChatViewController_Title : data.title ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_UserID : data.userID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_GroupID : data.groupID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : data.avatarImage ?: [UIImage new],
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : data.faceUrl ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_ConversationID : data.conversationID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_AtTipsStr : data.atTipsStr ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_AtMsgSeqs : data.atMsgSeqs ?: @[],
            TUICore_TUIChatObjectFactory_ChatViewController_Draft : data.draftText ?: @""
        };
        [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Minimalist param:param forResult:nil];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Turn on or off the length of the last line of dividers by controlling this switch
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

- (void)enableMultiSelectedMode:(BOOL)enable {
    self.showCheckBox = enable;
    if (!enable) {
        for (TUIConversationCellData_Minimalist *cellData in self.dataProvider.conversationList) {
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
    for (TUIConversationCellData_Minimalist *data in self.dataProvider.conversationList) {
        if (data.selected) {
            [arrayM addObject:data];
        }
    }
    return [NSArray arrayWithArray:arrayM];
}

// MARK: action
- (void)showMoreAction:(TUIConversationCellData *)cellData {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(MarkHide)
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                                    [strongSelf.dataProvider markConversationHide:cellData];
                                                    if (cellData.isLocalConversationFoldList) {
                                                        [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_HideFoldItem:YES];
                                                    }
                                                  }]];

    if (!cellData.isMarkAsFolded) {
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:cellData.isOnTop ? TIMCommonLocalizableString(UnPin) : TIMCommonLocalizableString(Pin)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                        __strong typeof(weakSelf) strongSelf = weakSelf;
                                                        [strongSelf.dataProvider pinConversation:cellData pin:!cellData.isOnTop];
                                                      }]];
    }

    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(ClearHistoryChatMessage)
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                                    [strongSelf.dataProvider markConversationAsRead:cellData];
                                                    [strongSelf.dataProvider clearHistoryMessage:cellData];
                                                  }]];

    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Delete)
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                                    [strongSelf.dataProvider removeConversation:cellData];
                                                  }]];

    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)startCreatGroupNotification:(NSNotification *)noti {
    [self startConversation:V2TIM_GROUP];
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
