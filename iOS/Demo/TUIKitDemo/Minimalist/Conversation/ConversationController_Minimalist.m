//
//  ConversationViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//
#import "ConversationController_Minimalist.h"
#import "TUIConversationListController_Minimalist.h"
#import "TUIC2CChatViewController_Minimalist.h"
#import "TUIGroupChatViewController_Minimalist.h"
#import "AppDelegate+Redpoint.h"
#import "TUIThemeManager.h"
#import "TUIDefine.h"

@interface ConversationController_Minimalist () <TUIConversationListControllerListener, V2TIMSDKListener, TUIPopViewDelegate, V2TIMSDKListener>
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UIBarButtonItem *moreItem;
@property (nonatomic, strong) UIBarButtonItem *editItem;
@property (nonatomic, strong) UIBarButtonItem *doneItem;
@property (nonatomic, strong) TUIConversationListController_Minimalist *conv;
@end

@implementation ConversationController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];

    self.conv = [[TUIConversationListController_Minimalist alloc] init];
    self.conv.delegate = self;
    [self addChildViewController:self.conv];
    [self.view addSubview:self.conv.view];
    
    [self setupNavigation];
    
    [[V2TIMManager sharedInstance] addIMSDKListener:self];
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
    [editButton setTitle:TUIKitLocalizableString(Edit) forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    editButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [editButton setFrame:CGRectMake(0, 0, 18 + 21 * 2, 18)];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:TUIConversationImagePath_Minimalist(@"nav_add")] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [moreButton setFrame:CGRectMake(0, 0, 20, 20)];

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:TUIKitLocalizableString(TUIKitDone) forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setFrame:CGRectMake(0, 0, 30, 30)];

    self.editItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    self.navigationItem.rightBarButtonItems = @[self.moreItem,self.editItem];
}

- (void)rightBarButtonClick:(UIButton *)rightBarButton
{
    NSMutableArray *menus = [NSMutableArray array];
    TUIPopCellData *friend = [[TUIPopCellData alloc] init];
    
    friend.image = TUIConversationDynamicImage(@"pop_icon_new_chat_img", [UIImage imageNamed:TUIConversationImagePath(@"new_chat")]);
    friend.title = TUIKitLocalizableString(ChatsNewChatText);
    [menus addObject:friend];
    
    TUIPopCellData *group = [[TUIPopCellData alloc] init];
    group.image = TUIConversationDynamicImage(@"pop_icon_new_group_img", [UIImage imageNamed:TUIConversationImagePath(@"new_groupchat")]);
    group.title = TUIKitLocalizableString(ChatsNewGroupText);
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

- (void)doneBarButtonClick:(UIBarButtonItem *)doneBarButton {

    [self.conv openMultiChooseBoard:NO];
    self.navigationItem.rightBarButtonItems = @[self.moreItem,self.editItem];
}

- (void)editBarButtonClick:(UIButton *)editBarButton {
    [self.conv openMultiChooseBoard:YES];
    [self.conv enableMultiSelectedMode:YES];
    self.navigationItem.rightBarButtonItems = @[self.doneItem];
    
    AppDelegate * app = [AppDelegate sharedInstance];
    if (app.unReadCount <= 0) {
        self.conv.multiChooseView.readButton.enabled = NO;
    }
}

#pragma TUIPopViewDelegate
- (void)popView:(TUIPopView *)popView didSelectRowAtIndex:(NSInteger)index
{
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
    [[AppDelegate sharedInstance] redpoint_clearUnreadMessage];
}

- (void)onCloseConversationMultiChooseBoard {
    self.navigationItem.rightBarButtonItems = @[self.moreItem,self.editItem];
}


@end
