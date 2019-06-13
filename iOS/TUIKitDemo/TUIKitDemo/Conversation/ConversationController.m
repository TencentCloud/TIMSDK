//
//  ConversationViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "ConversationController.h"
#import "TUIConversationListController.h"
#import "ChatViewController.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"
#import "Toast/Toast.h"
#import "TUIContactSelectController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TIMUserProfile+DataProvider.h"
#import "TNaviBarIndicatorView.h"
#import "TUIKit.h"

@import ImSDK;

@interface ConversationController () <TUIConversationListControllerDelegagte, TPopViewDelegate>
@property (nonatomic, strong) TNaviBarIndicatorView *titleView;
@end

@implementation ConversationController

- (void)viewDidLoad {
    [super viewDidLoad];
    TUIConversationListController *conv = [[TUIConversationListController alloc] init];
    conv.delegate = self;
    [self addChildViewController:conv];
    [self.view addSubview:conv.view];
    
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [moreButton setImage:[UIImage imageNamed:TUIKitResource(@"more")] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
    
    [self setupNavigation];
}

- (void)setupNavigation
{
    _titleView = [[TNaviBarIndicatorView alloc] init];
    [_titleView setTitle:@"云通信IM"];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkChanged:) name:TUIKitNotification_TIMConnListener object:nil];
}

- (void)onNetworkChanged:(NSNotification *)notification
{
    TUINetStatus status = (TUINetStatus)[notification.object intValue];
    switch (status) {
        case TNet_Status_Succ:
            [_titleView setTitle:@"云通信IM"];
            [_titleView stopAnimating];
            break;
        case TNet_Status_Connecting:
            [_titleView setTitle:@"连接中..."];
            [_titleView startAnimating];
            break;
        case TNet_Status_Disconnect:
            [_titleView setTitle:@"云通信IM(未连接)"];
            [_titleView stopAnimating];
            break;
        case TNet_Status_ConnFailed:
            [_titleView setTitle:@"云通信IM(未连接)"];
            [_titleView stopAnimating];
            break;
            
        default:
            break;
    }
}

- (void)conversationListController:(TUIConversationListController *)conversationController didSelectConversation:(TUIConversationCell *)conversation
{
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversationData = conversation.convData;
    [self.navigationController pushViewController:chat animated:YES];
}

- (void)rightBarButtonClick:(UIButton *)rightBarButton
{
    NSMutableArray *menus = [NSMutableArray array];
    TPopCellData *friend = [[TPopCellData alloc] init];
    friend.image = TUIKitResource(@"add_friend");
    friend.title = @"发起会话";
    [menus addObject:friend];
    
    TPopCellData *group3 = [[TPopCellData alloc] init];
    group3.image = TUIKitResource(@"create_group");
    group3.title = @"创建讨论组";
    [menus addObject:group3];
    
    TPopCellData *group = [[TPopCellData alloc] init];
    group.image = TUIKitResource(@"create_group");
    group.title = @"创建群聊";
    [menus addObject:group];

    TPopCellData *room = [[TPopCellData alloc] init];
    room.image = TUIKitResource(@"create_group");
    room.title = @"创建聊天室";
    [menus addObject:room];

    
    CGFloat height = [TPopCell getHeight] * menus.count + TPopView_Arrow_Size.height;
    CGFloat orginY = StatusBar_Height + NavBar_Height;
    TPopView *popView = [[TPopView alloc] initWithFrame:CGRectMake(Screen_Width - 145, orginY, 135, height)];
    CGRect frameInNaviView = [self.navigationController.view convertRect:rightBarButton.frame fromView:rightBarButton.superview];
    popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
    popView.delegate = self;
    [popView setData:menus];
    [popView showInWindow:self.view.window];
}

- (void)popView:(TPopView *)popView didSelectRowAtIndex:(NSInteger)index
{
    @weakify(self)
    if(index == 0){
        TUIContactSelectController *vc = [TUIContactSelectController new];
        vc.title = @"选择联系人";
        vc.maxSelectCount = 1;
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *array) {
            @strongify(self)
            TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
            data.convId = array.firstObject.identifier;
            data.convType = TIM_C2C;
            data.title = array.firstObject.title;
            ChatViewController *chat = [[ChatViewController alloc] init];
            chat.conversationData = data;
            [self.navigationController pushViewController:chat animated:YES];
            
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [tempArray removeObjectAtIndex:tempArray.count-2];
            self.navigationController.viewControllers = tempArray;
        };
        return;
    }
    else if(index == 1){
        TUIContactSelectController *vc = [TUIContactSelectController new];
        vc.title = @"选择联系人";
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *array) {
            @strongify(self)
            [self addGroup:@"Private" addOption:0 withContacts:array];
        };
        return;
    } else if(index == 2){
        TUIContactSelectController *vc = [TUIContactSelectController new];
        vc.title = @"选择联系人";
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *array) {
            @strongify(self)
            [self addGroup:@"Public" addOption:TIM_GROUP_ADD_ANY withContacts:array];
        };
        return;
    } else if(index == 3){
        TUIContactSelectController *vc = [TUIContactSelectController new];
        vc.title = @"选择联系人";
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *array) {
            @strongify(self)
            [self addGroup:@"ChatRoom" addOption:TIM_GROUP_ADD_ANY withContacts:array];
        };
        return;
    }
    else {
        return;
    }
}

- (void)addGroup:(NSString *)groupType addOption:(TIMGroupAddOpt)addOption withContacts:(NSArray<TCommonContactSelectCellData *>  *)contacts
{
    NSMutableString *groupName = [[[TIMFriendshipManager sharedInstance] querySelfProfile] showName].mutableCopy;
    NSMutableArray *members = [NSMutableArray array];
    
    for (TCommonContactSelectCellData *item in contacts) {
        TIMCreateGroupMemberInfo *member = [[TIMCreateGroupMemberInfo alloc] init];
        member.member = item.identifier;
        member.role = TIM_GROUP_MEMBER_ROLE_MEMBER;
        [groupName appendFormat:@"、%@", item.title];
        [members addObject:member];
    }

    if ([groupName length] > 10) {
        groupName = [groupName substringToIndex:10].mutableCopy;
    }
    
    TIMCreateGroupInfo *info = [[TIMCreateGroupInfo alloc] init];
    info.groupName = groupName;
    info.groupType = groupType;
    if([info.groupType isEqualToString:@"Private"]){
        info.setAddOpt = false;
    }
    else{
        info.setAddOpt = true;
        info.addOpt = addOption;
    }
    info.membersInfo = members;
    
    @weakify(self)
    [[TIMGroupManager sharedInstance] createGroup:info succ:^(NSString *groupId) {
        @strongify(self)
        TIMMessage *tip = [[TIMMessage alloc] init];
        TIMCustomElem *custom = [[TIMCustomElem alloc] init];
        custom.data = [@"group_create" dataUsingEncoding:NSUTF8StringEncoding];
        custom.ext = [NSString stringWithFormat:@"\"%@\"创建群组", [[TIMManager sharedInstance] getLoginUser]];
        [tip addElem:custom];
        TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:groupId];
        [conv sendMessage:tip succ:nil fail:nil];
        
        
        TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
        data.convId = groupId;
        data.convType = TIM_GROUP;
        data.title = groupName;
        ChatViewController *chat = [[ChatViewController alloc] init];
        chat.conversationData = data;
        [self.navigationController pushViewController:chat animated:YES];
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [tempArray removeObjectAtIndex:tempArray.count-2];
        self.navigationController.viewControllers = tempArray;
        
    } fail:^(int code, NSString *msg) {
        [self.view makeToast:msg];
    }];
}
@end
