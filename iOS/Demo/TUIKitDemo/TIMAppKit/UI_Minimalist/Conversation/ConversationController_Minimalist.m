//
//  ConversationViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018 Tencent. All rights reserved.
//
#import "ConversationController_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIC2CChatViewController_Minimalist.h"
#import "TUIConversationListController_Minimalist.h"
#import "TUIGroupChatViewController_Minimalist.h"

@interface ConversationController_Minimalist () <TUIConversationListControllerListener, V2TIMSDKListener, TUIPopViewDelegate, V2TIMSDKListener>
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) NSString *titleViewTitle;

@property(nonatomic, strong) UIBarButtonItem *moreItem;
@property(nonatomic, strong) UIBarButtonItem *editItem;
@property(nonatomic, strong) UIBarButtonItem *doneItem;
@end

@implementation ConversationController_Minimalist

- (instancetype)init {
    self = [super init];
    if (self) {
        self.leftSpaceWidth = kScale390(13);
        [[V2TIMManager sharedInstance] addIMSDKListener:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigation];

    self.conv = [[TUIConversationListController_Minimalist alloc] init];
    self.conv.delegate = self;
    [self addChildViewController:self.conv];
    [self.view addSubview:self.conv.view];
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
    if (self.viewWillAppear) {
        self.viewWillAppear(YES);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.viewWillAppear) {
        self.viewWillAppear(NO);
    }
}

- (void)setupNavigation {
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    _titleView.label.font = [UIFont boldSystemFontOfSize:34];
    _titleView.maxLabelLength = Screen_Width;
    [_titleView setTitle:(self.titleViewTitle.length > 0 ? self.titleViewTitle : TIMCommonLocalizableString(TIMAppChat))];
    _titleView.label.textColor = TUIDynamicColor(@"nav_title_text_color", TUIThemeModuleDemo_Minimalist, @"#000000");

    UIBarButtonItem *leftTitleItem = [[UIBarButtonItem alloc] initWithCustomView:_titleView];
    UIBarButtonItem *leftSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSpaceItem.width = self.leftSpaceWidth;
    self.showLeftBarButtonItems = [NSMutableArray arrayWithArray:@[ leftSpaceItem, leftTitleItem ]];

    self.navigationItem.title = @"";
    self.navigationItem.leftBarButtonItems = self.showLeftBarButtonItems;

    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setTitle:TIMCommonLocalizableString(Edit) forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    editButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [editButton setFrame:CGRectMake(0, 0, 40, 26)];

    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:TUIConversationImagePath_Minimalist(@"nav_add")] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [moreButton setFrame:CGRectMake(0, 0, 26, 26)];

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:TIMCommonLocalizableString(TUIKitDone) forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setFrame:CGRectMake(0, 0, 40, 26)];

    self.editItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.editItem.tag = UIBarButtonItemType_Edit;
    self.moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.moreItem.tag = UIBarButtonItemType_More;
    self.doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.doneItem.tag = UIBarButtonItemType_Done;
    self.rightBarButtonItems = @[ self.editItem, self.moreItem, self.doneItem ];

    self.showRightBarButtonItems = [NSMutableArray arrayWithArray:@[ self.moreItem, self.editItem ]];
    self.navigationItem.rightBarButtonItems = self.showRightBarButtonItems;
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

- (void)doneBarButtonClick:(UIBarButtonItem *)doneBarButton {
    [self.conv openMultiChooseBoard:NO];
    self.showRightBarButtonItems = [NSMutableArray arrayWithArray:@[ self.moreItem, self.editItem ]];
    self.navigationItem.rightBarButtonItems = self.showRightBarButtonItems;
}

- (void)editBarButtonClick:(UIButton *)editBarButton {
    [self.conv openMultiChooseBoard:YES];
    [self.conv enableMultiSelectedMode:YES];
    self.showRightBarButtonItems = [NSMutableArray arrayWithArray:@[ self.doneItem ]];
    self.navigationItem.rightBarButtonItems = self.showRightBarButtonItems;

    if (self.getUnReadCount && self.getUnReadCount() <= 0) {
        self.conv.multiChooseView.readButton.enabled = NO;
    }
}

#pragma TUIPopViewDelegate
- (void)popView:(TUIPopView *)popView didSelectRowAtIndex:(NSInteger)index {
    if (0 == index) {
        [self.conv startConversation:V2TIM_C2C];
    } else {
        [self.conv startConversation:V2TIM_GROUP];
    }
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

#pragma mark TUIConversationListControllerListener
- (void)onClearAllConversationUnreadCount {
    if (self.clearUnreadMessage) {
        self.clearUnreadMessage();
    }
}

- (void)onCloseConversationMultiChooseBoard {
    self.showRightBarButtonItems = [NSMutableArray arrayWithArray:@[ self.moreItem, self.editItem ]];
    self.navigationItem.rightBarButtonItems = self.showRightBarButtonItems;
}

#pragma mark - V2TIMSDKListener
- (void)onConnecting {
    self.titleViewTitle = TIMCommonLocalizableString(TIMAppMainConnectingTitle);
    [self.titleView setTitle:self.titleViewTitle];
    [self.titleView startAnimating];
}

- (void)onConnectSuccess {
    self.titleViewTitle = TIMCommonLocalizableString(TIMAppChat);
    [self.titleView setTitle:self.titleViewTitle];
    [self.titleView stopAnimating];
}

- (void)onConnectFailed:(int)code err:(NSString *)err {
    self.titleViewTitle = TIMCommonLocalizableString(TIMAppChatDisconnectTitle);
    [self.titleView setTitle:self.titleViewTitle];
    [self.titleView stopAnimating];
}

@end
