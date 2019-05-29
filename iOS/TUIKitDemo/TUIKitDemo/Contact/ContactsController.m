//
//  ContactsController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "ContactsController.h"
#import "TContactController.h"
#import "QuickContactsTestViewController.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"
#import "AddFriendViewController.h"
#import "TSubGroupManagerController.h"
#import "TIMFriendshipManager.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TFriendProfileController.h"
#import "AddGroupController.h"
#import "TConversationCell.h"
#import "TConversationController.h"
#import "TBlackListController.h"
#import "TNewFriendViewController.h"
#import "ChatViewController.h"


@interface ContactsController () <TPopViewDelegate, TConversationControllerDelegagte>

@end

@implementation ContactsController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        TCommonContactCellData *data = [[TCommonContactCellData alloc] init];
        data.avatarImage = [UIImage imageNamed:TUIKitResource(@"new_friend")];
        data.title = @"新的联系人";
        data.cselector = @selector(onAddNewFriend:);
        data;
    })];
    [list addObject:({
        TCommonContactCellData *data = [[TCommonContactCellData alloc] init];
        data.avatarImage = [UIImage imageNamed:TUIKitResource(@"public_group")];
        data.title = @"群聊";
        data.cselector = @selector(onGroupConv:);
        data;
    })];
    [list addObject:({
        TCommonContactCellData *data = [[TCommonContactCellData alloc] init];
        data.avatarImage = [UIImage imageNamed:TUIKitResource(@"blacklist")];
        data.title = @"黑名单";
        data.cselector = @selector(onBlackList:);
        data;
    })];
    self.viewModel.firstGroupData = [NSArray arrayWithArray:list];
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

- (void)onRightItem:(UIButton *)rightBarButton;
{
    NSMutableArray *menus = [NSMutableArray array];
    TPopCellData *friend = [[TPopCellData alloc] init];
    friend.image = TUIKitResource(@"add_friend");
    friend.title = @"添加好友";
    [menus addObject:friend];
    
    TPopCellData *group = [[TPopCellData alloc] init];
    group.image = TUIKitResource(@"add_group40");
    group.title = @"添加群组";
    [menus addObject:group];
    
//    TPopCellData *group2 = [[TPopCellData alloc] init];
//    group2.image = TUIKitResource(@"group_manager");
//    group2.title = @"分组管理";
//    [menus addObject:group2];
    
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
        UIViewController *add = [[AddFriendViewController alloc] init];
        [self.navigationController pushViewController:add animated:YES];
    }
    if(index == 1){
        AddGroupController *add = [[AddGroupController alloc] init];
        [add setAddGroupType:AddGroupType_Join];
        
        UINavigationController *addNavi = [[UINavigationController alloc] initWithRootViewController:add];
        [self.navigationController presentViewController:addNavi animated:YES completion:nil];
    }
    if (index == 2) {
        [[TIMFriendshipManager sharedInstance] getFriendGroups:nil
                                                          succ:^(NSArray<TIMFriendGroup *> *groups) {
                                                              NSMutableArray *subGroups = [@[@"我的好友"] mutableCopy];
                                                              for (TIMFriendGroup *group in groups) {
                                                                  [subGroups addObject:group.name];
                                                              }
                                                              
                                                              TSubGroupManagerController *vc = [[TSubGroupManagerController alloc] init];
                                                              vc.subGroups = subGroups;
                                                              [self.navigationController pushViewController:vc animated:YES];
                                                          } fail:nil];
    }
}

- (void)onAddNewFriend:(TCommonTableViewCell *)cell
{
    TNewFriendViewController *vc = TNewFriendViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onGroupConv:(TCommonTableViewCell *)cell
{
    TConversationController *vc = TConversationController.new;
    vc.convFilter = TGroupMessage;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onBlackList:(TCommonContactCell *)cell
{
    TBlackListController *vc = TBlackListController.new;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)conversationController:(TConversationController *)conversationController didSelectConversation:(TConversationCellData *)conversation;
{
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversation = conversation;
    [self.navigationController pushViewController:chat animated:YES];
}
@end
