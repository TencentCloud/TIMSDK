//
//  ConversationViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018 Tencent. All rights reserved.
//
#import "ConversationController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIC2CChatViewController.h"
#import "TUIConversationListController.h"
#import "TUIGroupChatViewController.h"

@interface ConversationController () <V2TIMSDKListener, TUIPopViewDelegate, V2TIMSDKListener>
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) NSString *titleViewTitle;

@property(nonatomic, strong) TUIConversationListController *conv;
@end

@implementation ConversationController
- (instancetype) init {
    self = [super init];
    if (self) {
        [[V2TIMManager sharedInstance] addIMSDKListener:self];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigation];

    self.conv = [[TUIConversationListController alloc] init];
    [self addChildViewController:self.conv];
    [self.view addSubview:self.conv.view];
}

- (void)setupNavigation {
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:TUICoreDynamicImage(@"nav_more_img", [UIImage imageNamed:TUICoreImagePath(@"more")]) forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [moreButton.widthAnchor constraintEqualToConstant:24].active = YES;
    [moreButton.heightAnchor constraintEqualToConstant:24].active = YES;
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;

    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:(self.titleViewTitle.length > 0 ? self.titleViewTitle : TIMCommonLocalizableString(TIMAppMainTitle))];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
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
        [self.conv startConversation:V2TIM_C2C];
    } else {
        [self.conv startConversation:V2TIM_GROUP];
    }
}

- (void)pushToChatViewController:(NSString *)groupID userID:(NSString *)userID {
    UIViewController *topVc = self.navigationController.topViewController;
    BOOL isSameTarget = NO;
    BOOL isInChat = NO;
    if ([topVc isKindOfClass:TUIC2CChatViewController.class] || [topVc isKindOfClass:TUIGroupChatViewController.class]) {
        TUIChatConversationModel *cellData = [(TUIBaseChatViewController *)topVc conversationData];
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
    TUIBaseChatViewController *chatVC = [self getChatViewController:conversationData];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (TUIBaseChatViewController *)getChatViewController:(TUIChatConversationModel *)model {
    TUIBaseChatViewController *chat = nil;
    if (model.userID.length > 0) {
        chat = [[TUIC2CChatViewController alloc] init];
    } else if (model.groupID.length > 0) {
        chat = [[TUIGroupChatViewController alloc] init];
    }
    chat.conversationData = model;
    return chat;
}

#pragma mark - V2TIMSDKListener
- (void)onConnecting {
    self.titleViewTitle = TIMCommonLocalizableString(TIMAppMainConnectingTitle);
    [self.titleView setTitle:self.titleViewTitle];
    [self.titleView startAnimating];
}

- (void)onConnectSuccess {
    self.titleViewTitle = TIMCommonLocalizableString(TIMAppMainTitle);
    [self.titleView setTitle:self.titleViewTitle];
    [self.titleView stopAnimating];
}

- (void)onConnectFailed:(int)code err:(NSString *)err {
    self.titleViewTitle = TIMCommonLocalizableString(TIMAppMainDisconnectTitle);
    [self.titleView setTitle:self.titleViewTitle];
    [self.titleView stopAnimating];
}

@end
