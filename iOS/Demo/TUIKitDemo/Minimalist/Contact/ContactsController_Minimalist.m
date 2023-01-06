//
//  ContactsController_Minimalist.m
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
#import "TUIKit.h"
#import "TUICommonModel.h"

@interface ContactsController_Minimalist () <TUIPopViewDelegate>
@property (nonatomic, strong) TUIContactController_Minimalist *contactVC;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation ContactsController_Minimalist

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [moreButton setImage:TUICoreDynamicImage(@"nav_more_img", [UIImage imageNamed:TUICoreImagePath(@"more")]) forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(onRightItem:) forControlEvents:UIControlEventTouchUpInside];
    [moreButton.widthAnchor constraintEqualToConstant:24].active = YES;
    [moreButton.heightAnchor constraintEqualToConstant:24].active = YES;
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;

    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:NSLocalizedString(@"TabBarItemContactText", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    
    self.contactVC = [[TUIContactController_Minimalist alloc] init];
    [self addChildViewController:self.contactVC];
    [self.view addSubview:self.contactVC.view];

}

- (void)onRightItem:(UIButton *)rightBarButton;
{
    NSMutableArray *menus = [NSMutableArray array];
    TUIPopCellData *friend = [[TUIPopCellData alloc] init];
    friend.image =
    TUIContactDynamicImage(@"pop_icon_add_friend_img", [UIImage imageNamed:TUIContactImagePath(@"add_friend")]);
    friend.title = TUIKitLocalizableString(ContactsAddFriends); //@"添加好友";
    [menus addObject:friend];

    TUIPopCellData *group = [[TUIPopCellData alloc] init];
    group.image =
    TUIContactDynamicImage(@"pop_icon_add_group_img", [UIImage imageNamed:TUIContactImagePath(@"add_group")]);

    group.title = TUIKitLocalizableString(ContactsJoinGroup);//@"添加群组";
    [menus addObject:group];

    CGFloat height = [TUIPopCell getHeight] * menus.count + TUIPopView_Arrow_Size.height;
    CGFloat orginY = StatusBar_Height + NavBar_Height;
    TUIPopView *popView = [[TUIPopView alloc] initWithFrame:CGRectMake(Screen_Width - 140, orginY, 130, height)];
    CGRect frameInNaviView = [self.navigationController.view convertRect:rightBarButton.frame fromView:rightBarButton.superview];
    popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
    popView.delegate = self;
    [popView setData:menus];
    [popView showInWindow:self.view.window];
}

- (void)popView:(TUIPopView *)popView didSelectRowAtIndex:(NSInteger)index
{
    if (0 == index) {
        [self.contactVC addToContacts];
    } else {
        [self.contactVC addGroups];
    }
}




@end
