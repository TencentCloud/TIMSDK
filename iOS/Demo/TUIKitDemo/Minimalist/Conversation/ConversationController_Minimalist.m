//
//  ConversationController_Minimalist.m
//  TUIKitDemo
//
//  Created by wyl on 2022/10/12.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "ConversationController_Minimalist.h"
#import "TUIConversationListController_Minimalist.h"
#import "TUIC2CChatViewController_Minimalist.h"
#import "TUIGroupChatViewController_Minimalist.h"
#import "TUIContactSelectController_Minimalist.h"
#import "TUIThemeManager.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "TUIDefine.h"
#import "TUITool.h"
#import "TUIKit.h"
#import "TCUtil.h"
#import "TUIGroupService_Minimalist.h"
#import "TUIFoldListViewController_Minimalist.h"
#import "TUIGroupCreateController_Minimalist.h"
#import "TUIConversationMultiChooseView_Minimalist.h"
#import "AppDelegate+Redpoint.h"

@interface ConversationController_Minimalist () <TUIConversationListControllerListener, TPopViewDelegate, V2TIMSDKListener>
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UIBarButtonItem *moreItem;
@property (nonatomic, strong) UIBarButtonItem *editItem;
@property (nonatomic, strong) UIBarButtonItem *doneItem;
@property (nonatomic, strong) TUIConversationMultiChooseView_Minimalist *multiChooseView;
@property (nonatomic, assign) BOOL showCheckBox;
@property (nonatomic, strong) TUIConversationListController_Minimalist *convListVc;
@end

@implementation ConversationController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];

    TUIConversationListController_Minimalist *conv = [[TUIConversationListController_Minimalist alloc] init];
    self.convListVc = conv;
    conv.delegate = self;
    [self addChildViewController:conv];
    [self.view addSubview:conv.view];
    
    self.showCheckBox = NO;
    [self setupNavigation];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onFriendInfoChanged:) name:@"FriendInfoChangedNotification" object:nil];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)onFriendInfoChanged:(NSNotification *)notice
{
    V2TIMFriendInfo *friendInfo = notice.object;
    if (friendInfo == nil) {
        return;
    }
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:TUIConversationListController_Minimalist.class]) {
            // 此处需要优化，目前修改备注通知均是demo层发出来的，所以.....
            TUIConversationListDataProvider_Minimalist *dataProvider = [(TUIConversationListController_Minimalist *)vc provider];
            for (TUIConversationCellData *cellData in dataProvider.conversationList) {
                if ([cellData.userID isEqualToString:friendInfo.userID]) {
                    NSString *title = friendInfo.friendRemark;
                    if (title.length == 0) {
                        title = friendInfo.userFullInfo.nickName;
                    }
                    if (title.length == 0) {
                        title = friendInfo.userID;
                    }
                    cellData.title = title;
                    [[(TUIConversationListController_Minimalist *)vc tableView] reloadData];
                    break;
                }
            }
            break;
        }
    }
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

- (void)setupNavigation
{
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    _titleView.label.font = [UIFont boldSystemFontOfSize:34];
    [_titleView setTitle:NSLocalizedString(@"Chat", nil)];
    _titleView.label.textColor = TUIDynamicColor(@"nav_title_text_color", TUIThemeModuleDemo_Minimalist, @"#000000");
    
    UIBarButtonItem * titleItem = [[UIBarButtonItem alloc] initWithCustomView:_titleView];
    
    UIBarButtonItem *leftSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSpaceItem.width = kScale390(13);
    
    self.navigationItem.title = @"";
    self.navigationItem.leftBarButtonItems = @[leftSpaceItem,titleItem];
    
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setImage:
     TUIDynamicImage(@"", TUIThemeModuleDemo_Minimalist, [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"nav_edit")])
                forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    editButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [editButton setFrame:CGRectMake(0, 0, 18 + 21 * 2, 18)];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:TUIDemoDynamicImage(@"", [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"nav_add")]) forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [moreButton setFrame:CGRectMake(0, 0, 20, 20)];

    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:NSLocalizedString(@"TUIKitDone", nil) forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setFrame:CGRectMake(0, 0, 30, 30)];
    
    self.editItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    self.navigationItem.rightBarButtonItems = @[self.moreItem,self.editItem];

    [[V2TIMManager sharedInstance] addIMSDKListener:self];
}


- (void)onNetworkChanged:(TUINetStatus)status
{

}

- (void)pushToChatViewController:(NSString *)groupID userID:(NSString *)userID {

    UIViewController *topVc = self.navigationController.topViewController;
    BOOL isSameTarget = NO;
    BOOL isInChat = NO;
    if ([topVc isKindOfClass:TUIC2CChatViewController_Minimalist.class] || [topVc isKindOfClass:TUIGroupChatViewController_Minimalist.class]) {
        TUIChatConversationModel *cellData = [(TUIBaseChatViewController_Minimalist *)topVc conversationData];
        isSameTarget = [cellData.groupID isEqualToString:groupID] || [cellData.userID isEqualToString:userID];
        isInChat = YES;
    }
    if (isInChat && isSameTarget) {
        return;
    }
    
    if (isInChat && !isSameTarget) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    TUIChatConversationModel *conversationData = [[TUIChatConversationModel alloc] init];
    conversationData.userID = userID;
    conversationData.groupID = groupID;
    TUIBaseChatViewController_Minimalist *chatVC = [self getChatViewController:conversationData];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)doneBarButtonClick:(UIBarButtonItem *)doneBarButton {

    [self openMultiChooseBoard:NO];
    self.navigationItem.rightBarButtonItems = @[self.moreItem,self.editItem];
}
- (void)editBarButtonClick:(UIButton *)editBarButton {
    
    [self openMultiChooseBoard:YES];
    [self.convListVc enableMultiSelectedMode:YES];
    self.navigationItem.rightBarButtonItems = @[self.doneItem];
}
- (void)rightBarButtonClick:(UIButton *)rightBarButton
{
    NSMutableArray *menus = [NSMutableArray array];
    TPopCellData *friend = [[TPopCellData alloc] init];
    
    friend.image = TUIDemoDynamicImage(@"pop_icon_new_chat_img", [UIImage imageNamed:TUIDemoImagePath(@"new_chat")]);
    friend.title = NSLocalizedString(@"ChatsNewChatText", nil);
    [menus addObject:friend];
    
    TPopCellData *group = [[TPopCellData alloc] init];
    group.image = TUIDemoDynamicImage(@"pop_icon_new_group_img", [UIImage imageNamed:TUIDemoImagePath(@"new_groupchat")]);
    group.title = NSLocalizedString(@"ChatsNewGroupText", nil);
    [menus addObject:group];

    CGFloat height = [TPopCell getHeight] * menus.count + TPopView_Arrow_Size.height;
    CGFloat orginY = StatusBar_Height + NavBar_Height;
    TPopView *popView = [[TPopView alloc] initWithFrame:CGRectMake(Screen_Width - 155, orginY, 145, height)];
    CGRect frameInNaviView = [self.navigationController.view convertRect:rightBarButton.frame fromView:rightBarButton.superview];
    popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
    popView.delegate = self;
    [popView setData:menus];
    [popView showInWindow:self.view.window];
}

- (void)popView:(TPopView *)popView didSelectRowAtIndex:(NSInteger)index
{
    @weakify(self)
    if(index == 0){
        // launch conversation
        TUIContactSelectController_Minimalist *vc = [TUIContactSelectController_Minimalist new];
        vc.title = NSLocalizedString(@"ChatsSelectContact", nil);
        vc.maxSelectCount = 1;
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TUICommonContactSelectCellData *> *array) {
            @strongify(self)
            TUIChatConversationModel *data = [[TUIChatConversationModel alloc] init];
            data.userID = array.firstObject.identifier;
            data.title = array.firstObject.title;
            TUIC2CChatViewController_Minimalist *chat = [[TUIC2CChatViewController_Minimalist alloc] init];
            chat.conversationData = data;
            [self.navigationController pushViewController:chat animated:YES];

            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [tempArray removeObjectAtIndex:tempArray.count-2];
            self.navigationController.viewControllers = tempArray;
        };
        return;
    }
    else {
        // create discuss group
        TUIContactSelectController_Minimalist *vc = [TUIContactSelectController_Minimalist new];
        vc.title = NSLocalizedString(@"ChatsSelectContact", nil);
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TUICommonContactSelectCellData *> *array) {
            @strongify(self)

            TUIGroupCreateController_Minimalist * groupCreateController = [[TUIGroupCreateController_Minimalist alloc] init];
            groupCreateController.title = @"";
            [[TUIGroupService_Minimalist shareInstance] getGroupNameNormalFormatByContacts:array completion:^(BOOL success, NSString * _Nonnull groupName) {
                V2TIMGroupInfo * createGroupInfo = [[V2TIMGroupInfo alloc] init];
                createGroupInfo.groupID = @"";
                createGroupInfo.groupName = groupName;
                createGroupInfo.groupType = @"Work";
                groupCreateController.createGroupInfo = createGroupInfo;
                groupCreateController.createContactArray = [NSArray arrayWithArray:array];
                [self.navigationController pushViewController:groupCreateController animated:YES];

            }];
            
            __weak typeof(groupCreateController) weakGroupCreateController = groupCreateController;
            groupCreateController.submitCallback = ^(BOOL isSuccess, V2TIMGroupInfo * _Nonnull info) {
                [self jumpToNewChatVCWhenCreatGroupSuccess:isSuccess info:info avatarImage:weakGroupCreateController.submitShowImage];
            };
            return;
        };
        return;
    }

}

- (void)jumpToNewChatVCWhenCreatGroupSuccess:(BOOL)isSuccess info:(V2TIMGroupInfo *)info avatarImage:(UIImage *)showImage {
    if (!isSuccess) {
        return;
    }
    TUIChatConversationModel *conversationData = [[TUIChatConversationModel alloc] init];
    conversationData.groupID = info.groupID;
    conversationData.title = info.groupName;
    conversationData.groupType = info.groupType;
    conversationData.avatarImage = showImage;
    TUIGroupChatViewController_Minimalist *vc = [[TUIGroupChatViewController_Minimalist alloc] init];
    vc.conversationData = conversationData;
    
    [self.navigationController pushViewController:vc animated:YES];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController * vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"TUIGroupCreateController_Minimalist")] ||
            [vc isKindOfClass:NSClassFromString(@"TUIContactSelectController_Minimalist")]) {
            [tempArray removeObject:vc];
        }
    }
    
    self.navigationController.viewControllers = tempArray;
}
- (void)addGroup:(NSString *)groupType
       addOption:(V2TIMGroupAddOpt)addOption
    withContacts:(NSArray<TUICommonContactSelectCellData *> *)contacts {
    [[TUIGroupService_Minimalist shareInstance] createGroup:groupType
                                    createOption:addOption
                                        contacts:contacts
                                      completion:^(BOOL success, NSString * _Nonnull groupID, NSString * _Nonnull groupName) {
        if (!success) {
            [TUITool makeToast:NSLocalizedString(@"ChatsCreateFailed", nil)];
            return;
        }
        TUIChatConversationModel *conversationData = [[TUIChatConversationModel alloc] init];
        conversationData.groupID = groupID;
        conversationData.title = groupName;
        conversationData.groupType = groupType;
        
        TUIGroupChatViewController_Minimalist *vc = [[TUIGroupChatViewController_Minimalist alloc] init];
        vc.conversationData = conversationData;
        
        [self.navigationController pushViewController:vc animated:YES];
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [tempArray removeObjectAtIndex:tempArray.count-2];
        self.navigationController.viewControllers = tempArray;
    }];
}

#pragma mark TUIConversationListControllerListener

- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation {
    V2TIMMessage *msg = conversation.lastMessage;
    if (msg.customElem == nil || msg.customElem.data == nil) {
        return nil;
    }
    NSDictionary *param = [TCUtil jsonData2Dictionary:msg.customElem.data];
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
                    desc = NSLocalizedString(@"MessageTipsYouRecallMessage", nil);
                } else if (msg.userID.length > 0){
                    desc = NSLocalizedString(@"MessageTipsOthersRecallMessage", nil);
                } else if (msg.groupID.length > 0) {
                    /**
                     * 对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
                     * For the name display of group messages, the group business card is displayed first, the nickname has the second priority, and the user ID has the lowest priority.
                     */
                    NSString *userName = msg.nameCard;
                    if (userName.length == 0) {
                        userName = msg.nickName?:msg.sender;
                    }
                    desc = [NSString stringWithFormat:NSLocalizedString(@"MessageTipsOthersRecallMessageFormat", nil), userName];
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

- (void)conversationListController:(TUIConversationListController_Minimalist *)conversationController didSelectConversation:(TUIConversationCellData *)conversation
{
    if (self.showCheckBox) {
        
        if (conversation.isLocalConversationFoldList) {
            return;
        }
        conversation.selected = !conversation.selected;
                
        NSArray *uiMsgs = [self.convListVc getMultiSelectedResult];
        if (uiMsgs.count == 0) {
            self.multiChooseView.readButton.enabled = NO;
            self.multiChooseView.deleteButton.enabled = NO;
            self.multiChooseView.hideButton.enabled = NO;
            return;
        }
        
        @weakify(self)

        if (uiMsgs.count > 0) {
            self.multiChooseView.hideButton.enabled = YES;
            self.multiChooseView.deleteButton.enabled = YES;
            [self.multiChooseView.readButton setTitle:NSLocalizedString(@"MarkAsRead", nil) forState:UIControlStateNormal];
            self.multiChooseView.readButton.clickCallBack = ^(id  _Nonnull button) {
                @strongify(self)
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
    if (conversation.isLocalConversationFoldList) {

        [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_FoldItemIsUnread:NO];
        
        TUIFoldListViewController_Minimalist *foldVC = [[TUIFoldListViewController_Minimalist alloc] init];
        [self.navigationController pushViewController:foldVC animated:YES];

        foldVC.dismissCallback = ^(NSMutableAttributedString * _Nonnull foldStr, NSArray * _Nonnull sortArr , NSArray * _Nonnull needRemoveFromCacheMapArray) {
            conversation.foldSubTitle  = foldStr;
            conversation.subTitle = conversation.foldSubTitle;
            conversation.isMarkAsUnread = NO;
        
            if (sortArr.count <= 0 ) {
                conversation.orderKey = 0;
                if ([conversationController.provider.conversationList  containsObject:conversation]) {
                    [conversationController.provider hideConversation:conversation];
                }
            }
            
            for (NSString * removeId in needRemoveFromCacheMapArray) {
                if ([conversationController.provider.markFoldMap objectForKey:removeId] ) {
                    [conversationController.provider.markFoldMap removeObjectForKey:removeId];
                }
            }
            
            [TUIConversationListDataProvider_Minimalist cacheConversationFoldListSettings_FoldItemIsUnread:NO];
            [[(TUIConversationListController_Minimalist *)conversationController tableView] reloadData];
        };
        return;
    }
    TUIBaseChatViewController_Minimalist *chatVc = [self getChatViewController:[self getConversationModel:conversation]];
    [self.navigationController pushViewController:chatVc animated:YES];
}


- (void)searchController:(UIViewController *)searchVC
                withKey:(NSString *)searchKey
           didSelectType:(TUISearchType)searchType
                    item:(NSObject *)searchItem
    conversationCellData:(TUIConversationCellData *)conversationCellData
{
    if (searchType == TUISearchTypeChatHistory && [searchItem isKindOfClass:V2TIMMessage.class]) {
        /**
         * 点击搜索到的聊天消息
         * Respond to clicked searched chat messages
         */
        TUIBaseChatViewController_Minimalist *chatVc = [self getChatViewController:[self getConversationModel:conversationCellData]];
        chatVc.title = conversationCellData.title;
        chatVc.highlightKeyword = searchKey;
        chatVc.locateMessage = (V2TIMMessage *)searchItem;
        [searchVC.navigationController pushViewController:chatVc animated:YES];
    } else {
        /**
         * 点击搜索到的群组和联系人
         * Respond to clicks on searched groups and contacts
         */
        TUIBaseChatViewController_Minimalist *chatVc = [self getChatViewController:[self getConversationModel:conversationCellData]];
        chatVc.title = conversationCellData.title;
        [searchVC.navigationController pushViewController:chatVc animated:YES];
    }
}

- (TUIChatConversationModel *)getConversationModel:(TUIConversationCellData *)data {
    TUIChatConversationModel *model = [[TUIChatConversationModel alloc] init];
    model.conversationID = data.conversationID;
    model.userID = data.userID;
    model.groupType = data.groupType;
    model.groupID = data.groupID;
    model.userID = data.userID;
    model.title = data.title;
    model.faceUrl = data.faceUrl;
    model.avatarImage = data.avatarImage;
    model.draftText = data.draftText;
    model.atMsgSeqs = data.atMsgSeqs;
    return model;
}

#pragma mark - V2TIMSDKListener
- (void)onConnecting {
    [self onNetworkChanged:TNet_Status_Connecting];
}

- (void)onConnectSuccess {
    [self onNetworkChanged:TNet_Status_Succ];
}

- (void)onConnectFailed:(int)code err:(NSString*)err {
    [self onNetworkChanged:TNet_Status_ConnFailed];
}

- (TUIBaseChatViewController_Minimalist *)getChatViewController:(TUIChatConversationModel *)model {
    TUIBaseChatViewController_Minimalist *chat = nil;
    if (model.userID.length > 0) {
        chat = [[TUIC2CChatViewController_Minimalist alloc] init];
    } else if (model.groupID.length > 0) {
        chat = [[TUIGroupChatViewController_Minimalist alloc] init];
    }
    chat.conversationData = model;
    return chat;
}

#pragma mark - edit


- (void)openMultiChooseBoard:(BOOL)open
{
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

        [_multiChooseView.readButton setTitle:NSLocalizedString(@"ReadAll", nil) forState:UIControlStateNormal];
        [_multiChooseView.hideButton setTitle:NSLocalizedString(@"Hide", nil) forState:UIControlStateNormal];
        [_multiChooseView.deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
        _multiChooseView.readButton.enabled = YES;
        _multiChooseView.hideButton.enabled = NO;
        _multiChooseView.deleteButton.enabled = NO;
        @weakify(self);
        AppDelegate * app = [AppDelegate sharedInstance];
        if (app.unReadCount <= 0) {
            _multiChooseView.readButton.enabled = NO;
        }
        _multiChooseView.readButton.clickCallBack = ^(id  _Nonnull button) {
            @strongify(self);
            [self chooseViewReadAll];
        };
        _multiChooseView.hideButton.clickCallBack = ^(id  _Nonnull button) {
            @strongify(self);
            [self choosViewActionHide];
        };
        _multiChooseView.deleteButton.clickCallBack = ^(id  _Nonnull button) {
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
        [self.convListVc enableMultiSelectedMode:NO];
        self.navigationItem.rightBarButtonItems = @[self.moreItem,self.editItem];
    }
}

- (void)chooseViewReadAll {
    
    [[AppDelegate sharedInstance] redpoint_clearUnreadMessage];
    
    [self openMultiChooseBoard:NO];

}
- (void)choosViewActionHide{
    NSArray *uiMsgs = [self.convListVc getMultiSelectedResult];
    if (uiMsgs.count == 0) {
        return;
    }
    for (TUIConversationCellData *data in uiMsgs) {
        [self.convListVc.provider markConversationHide:data];
    }

    [self openMultiChooseBoard:NO];
    
}

- (void)chooseViewActionRead {
    
    NSArray *uiMsgs = [self.convListVc getMultiSelectedResult];
    if (uiMsgs.count == 0) {
        return;
    }
    for (TUIConversationCellData *data in uiMsgs) {
        [self.convListVc.provider markConversationAsRead:data];
    }

    [self openMultiChooseBoard:NO];

}

- (void)chooseViewActionDelete {
    
    NSArray *uiMsgs = [self.convListVc getMultiSelectedResult];
    if (uiMsgs.count == 0) {
        return;
    }

    for (TUIConversationCellData *data in uiMsgs) {
        [self.convListVc.provider removeConversation:data];
    }

    [self openMultiChooseBoard:NO];

}



@end
