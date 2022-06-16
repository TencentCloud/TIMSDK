//
//  ContactsController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//
/** 腾讯云IM Demo好友列表视图
 *  本文件实现了好友列表的视图控制器，使用户可以浏览自己的好友、群组并对其进行管理
 *  本文件所实现的视图控制器，对应了下方barItemView中的 "通讯录" 视图
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */

#import "ContactsController.h"
#import "TUIContactController.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "TUIKit.h"
#import "TUISearchFriendViewController.h"
#import "TUISearchGroupViewController.h"
#import "TUIFriendProfileController.h"
#import "TUIConversationCell.h"
#import "TUIBlackListController.h"
#import "TUINewFriendViewController.h"
#import "TUIC2CChatViewController.h"
#import "TUIGroupChatViewController.h"
#import "TUIContactSelectController.h"
#import "TUIUserProfileController.h"
#import "TUICommonModel.h"

#import "TUIFindContactViewController.h"
#import "TUIFriendRequestViewController.h"
#import "TUIGroupRequestViewController.h"
#import "TUIThemeManager.h"
#import "TUIGroupConversationListController.h"

@interface ContactsController () <TPopViewDelegate, TUIContactControllerListener>
@property (nonatomic, strong) TUIContactController *convVC;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation ContactsController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [moreButton setImage:TUIDemoDynamicImage(@"nav_more_img", [UIImage imageNamed:TUIDemoImagePath(@"more")]) forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(onRightItem:) forControlEvents:UIControlEventTouchUpInside];
    [moreButton.widthAnchor constraintEqualToConstant:24].active = YES;
    [moreButton.heightAnchor constraintEqualToConstant:24].active = YES;
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;

    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:NSLocalizedString(@"TabBarItemContactText", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    
    [self.convVC.viewModel loadContacts];
    self.convVC = [[TUIContactController alloc] init];
    self.convVC.delegate = self;
    [self addChildViewController:self.convVC];
    [self.view addSubview:self.convVC.view];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onFriendInfoChanged:) name:@"FriendInfoChangedNotification" object:nil];
}

- (void)onFriendInfoChanged:(NSNotification *)notice
{
    [self.convVC.viewModel loadContacts];
}

/**
 *在导航栏中添加右侧按钮，使用popView展示进一步的内容
 */
- (void)onRightItem:(UIButton *)rightBarButton;
{
    NSMutableArray *menus = [NSMutableArray array];
    TPopCellData *friend = [[TPopCellData alloc] init];
    friend.image =
    TUIDemoDynamicImage(@"pop_icon_add_friend_img", [UIImage imageNamed:TUIDemoImagePath(@"add_friend")]);
    friend.title = NSLocalizedString(@"ContactsAddFriends", nil); //@"添加好友";
    [menus addObject:friend];

    TPopCellData *group = [[TPopCellData alloc] init];
    group.image =
    TUIDemoDynamicImage(@"pop_icon_add_group_img", [UIImage imageNamed:TUIDemoImagePath(@"add_group")]);

    group.title = NSLocalizedString(@"ContactsJoinGroup", nil);//@"添加群组";
    [menus addObject:group];

    CGFloat height = [TPopCell getHeight] * menus.count + TPopView_Arrow_Size.height;
    CGFloat orginY = StatusBar_Height + NavBar_Height;
    TPopView *popView = [[TPopView alloc] initWithFrame:CGRectMake(Screen_Width - 140, orginY, 130, height)];
    CGRect frameInNaviView = [self.navigationController.view convertRect:rightBarButton.frame fromView:rightBarButton.superview];
    popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
    popView.delegate = self;
    [popView setData:menus];
    [popView showInWindow:self.view.window];
}

- (void)popView:(TPopView *)popView didSelectRowAtIndex:(NSInteger)index
{
    TUIFindContactViewController *add = [[TUIFindContactViewController alloc] init];
    add.type = index == 0 ? TUIFindContactTypeC2C : TUIFindContactTypeGroup;
    __weak typeof(self) weakSelf = self;
    add.onSelect = ^(TUIFindContactCellModel * cellModel) {
        if (cellModel.type == TUIFindContactTypeC2C) {
            TUIFriendRequestViewController *frc = [[TUIFriendRequestViewController alloc] init];
            frc.profile = cellModel.userInfo;
            [weakSelf.navigationController popViewControllerAnimated:NO];
            [weakSelf.navigationController pushViewController:frc animated:YES];
        } else {
            TUIGroupRequestViewController *frc = [[TUIGroupRequestViewController alloc] init];
            frc.groupInfo = cellModel.groupInfo;
            [weakSelf.navigationController popViewControllerAnimated:NO];
            [weakSelf.navigationController pushViewController:frc animated:YES];
        }
    };
    [self.navigationController pushViewController:add animated:YES];
}

- (void)onSelectFriend:(TUICommonContactCell *)cell
{
    TUICommonContactCellData *data = cell.contactData;

    TUIFriendProfileController *vc = [[TUIFriendProfileController alloc] init];
    vc.friendProfile = data.friendProfile;
    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
}

- (void)onAddNewFriend:(TUICommonTableViewCell *)cell
{
    TUINewFriendViewController *vc = TUINewFriendViewController.new;
    vc.cellClickBlock = ^(TUICommonPendencyCell * _Nonnull cell) {
        TUIUserProfileController *controller = [[TUIUserProfileController alloc] init];
        [[V2TIMManager sharedInstance] getUsersInfo:@[cell.pendencyData.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *profiles) {
            controller.userFullInfo = profiles.firstObject;
            controller.pendency = cell.pendencyData;
            controller.actionType = PCA_PENDENDY_CONFIRM;
            [self.navigationController pushViewController:(UIViewController *)controller animated:YES];
        } fail:nil];
    };
    [self.navigationController pushViewController:vc animated:YES];
    [self.convVC.viewModel clearApplicationCnt];
}

- (void)onGroupConversation:(TUICommonTableViewCell *)cell
{
    TUIGroupConversationListController *vc = TUIGroupConversationListController.new;
    @weakify(self)
    vc.onSelect = ^(TUICommonContactCellData * _Nonnull cellData) {
        @strongify(self)
        TUIChatConversationModel *data = [[TUIChatConversationModel alloc] init];
        data.groupID = cellData.identifier;
        TUIGroupChatViewController *chatVc = [[TUIGroupChatViewController alloc] init];
        chatVc.conversationData = data;
        [self.navigationController pushViewController:chatVc animated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}



@end
