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

#import "ContactsController_Minimalist.h"
#import "TUIContactController_Minimalist.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "TUIKit.h"
#import "TUISearchFriendViewController_Minimalist.h"
#import "TUISearchGroupViewController_Minimalist.h"
#import "TUIFriendProfileController_Minimalist.h"
#import "TUIConversationCell.h"
#import "TUIBlackListController_Minimalist.h"
#import "TUINewFriendViewController_Minimalist.h"
#import "TUIC2CChatViewController_Minimalist.h"
#import "TUIGroupChatViewController_Minimalist.h"
#import "TUIContactSelectController_Minimalist.h"
#import "TUIUserProfileController_Minimalist.h"
#import "TUICommonModel.h"

#import "TUIFindContactViewController_Minimalist.h"
#import "TUIFriendRequestViewController_Minimalist.h"
#import "TUIGroupRequestViewController_Minimalist.h"
#import "TUIThemeManager.h"
#import "TUIGroupConversationListController_Minimalist.h"

@interface ContactsController_Minimalist () <TPopViewDelegate, TUIContactControllerListener_Minimalist>
@property (nonatomic, strong) TUIContactController_Minimalist *convVC;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UIBarButtonItem *moreItem;

@end

@implementation ContactsController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavigation];
    
    [self.convVC.viewModel loadContacts];
    self.convVC = [[TUIContactController_Minimalist alloc] init];
    self.convVC.delegate = self;
    [self addChildViewController:self.convVC];
    [self.view addSubview:self.convVC.view];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onFriendInfoChanged:) name:@"FriendInfoChangedNotification" object:nil];
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
    [_titleView setTitle:NSLocalizedString(@"TabBarItemContactText_mini", nil)];
    _titleView.label.textColor = TUIDynamicColor(@"nav_title_text_color", TUIThemeModuleDemo_Minimalist, @"#000000");
    
    UIBarButtonItem * titleItem = [[UIBarButtonItem alloc] initWithCustomView:_titleView];
    
    UIBarButtonItem *leftSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSpaceItem.width = kScale390(13);
    
    self.navigationItem.title = @"";
    self.navigationItem.leftBarButtonItems = @[leftSpaceItem,titleItem];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:TUIDemoDynamicImage(@"", [UIImage imageNamed:TUIDemoImagePath_Minimalist(@"nav_add")]) forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(onRightItem:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [moreButton setFrame:CGRectMake(0, 0, 20, 20)];

    
    self.moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    self.navigationItem.rightBarButtonItems = @[self.moreItem];
    
}
- (void)onFriendInfoChanged:(NSNotification *)notice
{
    [self.convVC.viewModel loadContacts];
}

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
    TUIFindContactViewController_Minimalist *add = [[TUIFindContactViewController_Minimalist alloc] init];
    add.type = index == 0 ? TUIFindContactTypeC2C : TUIFindContactTypeGroup;
    __weak typeof(self) weakSelf = self;
    add.onSelect = ^(TUIFindContactCellModel * cellModel) {
        if (cellModel.type == TUIFindContactTypeC2C) {
            TUIFriendRequestViewController_Minimalist *frc = [[TUIFriendRequestViewController_Minimalist alloc] init];
            frc.profile = cellModel.userInfo;
            [weakSelf.navigationController popViewControllerAnimated:NO];
            [weakSelf.navigationController pushViewController:frc animated:YES];
        } else {
            TUIGroupRequestViewController_Minimalist *frc = [[TUIGroupRequestViewController_Minimalist alloc] init];
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
    TUIFriendProfileController_Minimalist *vc = [[TUIFriendProfileController_Minimalist alloc] init];
    vc.friendProfile = data.friendProfile;
    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
}

- (void)onAddNewFriend:(TUICommonTableViewCell *)cell
{
    TUINewFriendViewController_Minimalist *vc = TUINewFriendViewController_Minimalist.new;
    vc.cellClickBlock = ^(TUICommonPendencyCell * _Nonnull cell) {
        TUIUserProfileController_Minimalist *controller = [[TUIUserProfileController_Minimalist alloc] init];
        [[V2TIMManager sharedInstance] getUsersInfo:@[cell.pendencyData.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *profiles) {
            controller.userFullInfo = profiles.firstObject;
            controller.pendency = cell.pendencyData;
            controller.actionType = PCA_PENDENDY_CONFIRM_MINI;
            [self.navigationController pushViewController:(UIViewController *)controller animated:YES];
        } fail:nil];
    };
    [self.navigationController pushViewController:vc animated:YES];
    [self.convVC.viewModel clearApplicationCnt];
}

- (void)onGroupConversation:(TUICommonTableViewCell *)cell
{
    TUIGroupConversationListController_Minimalist *vc = TUIGroupConversationListController_Minimalist.new;
    @weakify(self)
    vc.onSelect = ^(TUICommonContactCellData * _Nonnull cellData) {
        @strongify(self)
        TUIChatConversationModel *data = [[TUIChatConversationModel alloc] init];
        data.groupID = cellData.identifier;
        TUIGroupChatViewController_Minimalist *chatVc = [[TUIGroupChatViewController_Minimalist alloc] init];
        chatVc.conversationData = data;
        [self.navigationController pushViewController:chatVc animated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}



@end
