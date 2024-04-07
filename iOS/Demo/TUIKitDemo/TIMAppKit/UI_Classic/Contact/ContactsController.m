//
//  ContactsController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019 kennethmiao. All rights reserved.
//

#import "ContactsController.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import "TUIContactController.h"

@interface ContactsController () <TUIPopViewDelegate>
@property(nonatomic, strong) TUIContactController *contactVC;
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation ContactsController
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

    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [moreButton setImage:TUICoreDynamicImage(@"nav_more_img", [UIImage imageNamed:TUICoreImagePath(@"more")]) forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(onRightItem:) forControlEvents:UIControlEventTouchUpInside];
    [moreButton.widthAnchor constraintEqualToConstant:24].active = YES;
    [moreButton.heightAnchor constraintEqualToConstant:24].active = YES;
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;

    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TIMCommonLocalizableString(TIMAppTabBarItemContactText)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    self.contactVC = [[TUIContactController alloc] init];
    [self addChildViewController:self.contactVC];
    [self.view addSubview:self.contactVC.view];
}

- (void)onRightItem:(UIButton *)rightBarButton;
{
    NSMutableArray *menus = [NSMutableArray array];
    TUIPopCellData *friend = [[TUIPopCellData alloc] init];
    friend.image = TUIContactDynamicImage(@"pop_icon_add_friend_img", [UIImage imageNamed:TUIContactImagePath(@"add_friend")]);
    friend.title = TIMCommonLocalizableString(ContactsAddFriends);
    [menus addObject:friend];

    TUIPopCellData *group = [[TUIPopCellData alloc] init];
    group.image = TUIContactDynamicImage(@"pop_icon_add_group_img", [UIImage imageNamed:TUIContactImagePath(@"add_group")]);

    group.title = TIMCommonLocalizableString(ContactsJoinGroup);  
    [menus addObject:group];

    CGFloat height = [TUIPopCell getHeight] * menus.count + TUIPopView_Arrow_Size.height;
    CGFloat orginY = StatusBar_Height + NavBar_Height;
    CGFloat orginX = Screen_Width - 140;
    if(isRTL()){
        orginX = 10;
    }
    TUIPopView *popView = [[TUIPopView alloc] initWithFrame:CGRectMake(orginX, orginY, 130, height)];
    CGRect frameInNaviView = [self.navigationController.view convertRect:rightBarButton.frame fromView:rightBarButton.superview];
    popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
    popView.delegate = self;
    [popView setData:menus];
    [popView showInWindow:self.view.window];
}

- (void)popView:(TUIPopView *)popView didSelectRowAtIndex:(NSInteger)index {
    [self.contactVC addToContactsOrGroups:(index == 0 ? TUIFindContactTypeC2C : TUIFindContactTypeGroup)];
}

@end
