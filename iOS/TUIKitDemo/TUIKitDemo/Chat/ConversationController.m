//
//  ConversationViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "ConversationController.h"
#import "TConversationController.h"
#import "ChatViewController.h"
#import "TChatController.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"

#import "AddC2CController.h"
#import "AddGroupController.h"

@interface ConversationController () <TConversationControllerDelegagte, TPopViewDelegate>

@end

@implementation ConversationController

- (void)viewDidLoad {
    [super viewDidLoad];
    TConversationController *conv = [[TConversationController alloc] init];
    conv.delegate = self;
    [self addChildViewController:conv];
    [self.view addSubview:conv.view];
    
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [moreButton setImage:[UIImage imageNamed:TUIKitResource(@"more")] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
}

- (void)conversationController:(TConversationController *)conversationController didSelectConversation:(TConversationCellData *)conversation
{
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversation = conversation;
    [self.navigationController pushViewController:chat animated:YES];
}

- (void)rightBarButtonClick:(UIButton *)rightBarButton
{
    NSMutableArray *menus = [NSMutableArray array];
    TPopCellData *friend = [[TPopCellData alloc] init];
    friend.image = TUIKitResource(@"add_friend");
    friend.title = @"添加会话";
    [menus addObject:friend];
    
    TPopCellData *group = [[TPopCellData alloc] init];
    group.image = TUIKitResource(@"add_group");
    group.title = @"创建群聊";
    [menus addObject:group];
    
    TPopCellData *group2 = [[TPopCellData alloc] init];
    group2.image = TUIKitResource(@"add_group");
    group2.title = @"加入群聊";
    [menus addObject:group2];
    
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
    UIViewController *add = nil;
    if(index == 0){
        add = [[AddC2CController alloc] init];
    }
    else if(index == 1){
        add = [[AddGroupController alloc] init];
        [(AddGroupController *)add setAddGroupType:AddGroupType_Create];
    }
    else if(index == 2){
        add = [[AddGroupController alloc] init];
        [(AddGroupController *)add setAddGroupType:AddGroupType_Join];
    }
    UINavigationController *addNavi = [[UINavigationController alloc] initWithRootViewController:add];
    [self.navigationController presentViewController:addNavi animated:YES completion:nil];
}

@end
