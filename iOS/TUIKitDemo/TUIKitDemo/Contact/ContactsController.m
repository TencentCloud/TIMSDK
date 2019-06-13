//
//  ContactsController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "ContactsController.h"
#import "TUIContactController.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"
#import "SearchFriendViewController.h"
#import "SearchGroupViewController.h"
#import "TIMFriendshipManager.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "Toast/Toast.h"
#import "TFriendProfileController.h"
#import "TUIConversationCell.h"
#import "TUIConversationListController.h"
#import "TUIBlackListController.h"
#import "TUINewFriendViewController.h"
#import "ChatViewController.h"
#import "TUIContactSelectController.h"
#import "TIMUserProfile+DataProvider.h"
@import ImSDK;


@interface ContactsController () <TPopViewDelegate>

@end

@implementation ContactsController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [moreButton setImage:[UIImage imageNamed:TUIKitResource(@"more")] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(onRightItem:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
    
    self.title = @"通讯录";
}


- (void)onAddFriendReqs {
    
}

- (void)onRightItem:(UIButton *)rightBarButton;
{
    NSMutableArray *menus = [NSMutableArray array];
    TPopCellData *friend = [[TPopCellData alloc] init];
    friend.image = TUIKitResource(@"new_friend");
    friend.title = @"添加好友";
    [menus addObject:friend];
    
    TPopCellData *group = [[TPopCellData alloc] init];
    group.image = TUIKitResource(@"add_group");
    group.title = @"添加群组";
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
    if(index == 0){
        UIViewController *add = [[SearchFriendViewController alloc] init];
        [self.navigationController pushViewController:add animated:YES];
    }
    if(index == 1){
        UIViewController *add = [[SearchGroupViewController alloc] init];
        [self.navigationController pushViewController:add animated:YES];
    }
}





@end
