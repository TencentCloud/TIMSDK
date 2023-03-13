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
@property (nonatomic, strong) UIBarButtonItem *moreItem;

@end

@implementation ContactsController_Minimalist

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

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavigation];
    
    self.contactVC = [[TUIContactController_Minimalist alloc] init];
    [self addChildViewController:self.contactVC];
    [self.view addSubview:self.contactVC.view];

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
