//
//  ConversationViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 对话列表视图
 *  本文件实现了对话列表视图控制器，即下方按钮“消息”对应的视图控制器
 *  您可以从此处查看最近消息，整理您的消息列表
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
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
#import "THelper.h"
#import "TCUtil.h"
#import "VideoCallManager.h"
#import "TIMUserProfile+DataProvider.h"

#import <ImSDK/ImSDK.h>

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

    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    conv.tableView.delaysContentTouches = NO;


    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [moreButton setImage:[UIImage imageNamed:TUIKitResource(@"more")] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;

    [self setupNavigation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(onNewMessageNotification:) name:TUIKitNotification_TIMMessageListener object:nil];
}

/**
 *初始化导航栏
 */
- (void)setupNavigation
{
    _titleView = [[TNaviBarIndicatorView alloc] init];
    [_titleView setTitle:@"腾讯·云通信"];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkChanged:) name:TUIKitNotification_TIMConnListener object:nil];
}

/**
 *初始化导航栏Title，不同连接状态下Title显示内容不同
 */
- (void)onNetworkChanged:(NSNotification *)notification
{
    TUINetStatus status = (TUINetStatus)[notification.object intValue];
    switch (status) {
        case TNet_Status_Succ:
            [_titleView setTitle:@"腾讯·云通信"];
            [_titleView stopAnimating];
            break;
        case TNet_Status_Connecting:
            [_titleView setTitle:@"连接中..."];
            [_titleView startAnimating];
            break;
        case TNet_Status_Disconnect:
            [_titleView setTitle:@"腾讯·云通信(未连接)"];
            [_titleView stopAnimating];
            break;
        case TNet_Status_ConnFailed:
            [_titleView setTitle:@"腾讯·云通信(未连接)"];
            [_titleView stopAnimating];
            break;

        default:
            break;
    }
}

/**
 *在消息列表内，点击了某一具体会话后的响应函数
 */
- (void)conversationListController:(TUIConversationListController *)conversationController didSelectConversation:(TUIConversationCell *)conversation
{
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversationData = conversation.convData;
    [self.navigationController pushViewController:chat animated:YES];
}

/**
 *对导航栏右侧的按钮（即视图右上角按钮）进行初始化，创建对应的popView
 */
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

/**
 *点击了popView中具体某一行后的响应函数，popView初始化请参照上述 rightBarButtonClick: 函数
 */
- (void)popView:(TPopView *)popView didSelectRowAtIndex:(NSInteger)index
{
    @weakify(self)
    if(index == 0){
        //发起会话
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
        //创建讨论组
        TUIContactSelectController *vc = [TUIContactSelectController new];
        vc.title = @"选择联系人";
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *array) {
            @strongify(self)
            [self addGroup:@"Private" addOption:0 withContacts:array];
        };
        return;
    } else if(index == 2){
        //创建群聊
        TUIContactSelectController *vc = [TUIContactSelectController new];
        vc.title = @"选择联系人";
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *array) {
            @strongify(self)
            [self addGroup:@"Public" addOption:TIM_GROUP_ADD_ANY withContacts:array];
        };
        return;
    } else if(index == 3){
        //创建聊天室
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

/**
 *创建讨论组、群聊、聊天室的函数
 *groupType:创建的具体类型 Private--讨论组  Public--群聊 ChatRoom--聊天室
 *addOption:创建后加群时的选项          TIM_GROUP_ADD_FORBID       禁止任何人加群
                                     TIM_GROUP_ADD_AUTH        加群需要管理员审批
                                     TIM_GROUP_ADD_ANY         任何人可以加群
 *withContacts:群成员的信息数组。数组内每一个元素分别包含了对应成员的头像、ID等信息。具体信息可参照 TCommonContactSelectCellData 定义
 */
- (void)addGroup:(NSString *)groupType addOption:(TIMGroupAddOpt)addOption withContacts:(NSArray<TCommonContactSelectCellData *>  *)contacts
{
    NSMutableString *groupName = [[[TIMFriendshipManager sharedInstance] querySelfProfile] showName].mutableCopy;
    NSMutableArray *members = [NSMutableArray array];
    //遍历contacts，初始化群组成员信息、群组名称信息
    for (TCommonContactSelectCellData *item in contacts) {
        TIMCreateGroupMemberInfo *member = [[TIMCreateGroupMemberInfo alloc] init];
        member.member = item.identifier;
        member.role = TIM_GROUP_MEMBER_ROLE_MEMBER;
        [groupName appendFormat:@"、%@", item.title];
        [members addObject:member];
    }

    //群组名称默认长度不超过10，如有需求可在此更改，但可能会出现UI上的显示bug
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

    //发送创建请求后的回调函数
    @weakify(self)
    [[TIMGroupManager sharedInstance] createGroup:info succ:^(NSString *groupId) {
        //创建成功后，在群内推送创建成功的信息
        @strongify(self)
        TIMMessage *tip = [[TIMMessage alloc] init];
        TIMCustomElem *custom = [[TIMCustomElem alloc] init];
        custom.data = [@"group_create" dataUsingEncoding:NSUTF8StringEncoding];

        //对于创建群消息时的名称显示（此时还未设置群名片），优先显示用户昵称。
        NSString *userId = [[TIMManager sharedInstance] getLoginUser];
        TIMUserProfile *user = [[TIMFriendshipManager sharedInstance] queryUserProfile:userId];

        if([info.groupType isEqualToString:@"Private"]) {
            custom.ext = [NSString stringWithFormat:@"\"%@\"创建讨论组",user.showName];
        } else if([info.groupType isEqualToString:@"Public"]){
            custom.ext = [NSString stringWithFormat:@"\"%@\"创建群聊",user.showName];
        } else if([info.groupType isEqualToString:@"ChatRoom"]) {
            custom.ext = [NSString stringWithFormat:@"\"%@\"创建聊天室",user.showName];
        } else {
            custom.ext = [NSString stringWithFormat:@"\"%@\"创建群组",user.showName];
        }


        [tip addElem:custom];
        TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:groupId];
        [conv sendMessage:tip succ:nil fail:nil];


        //创建成功后，默认跳转到群组对应的聊天界面
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
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)onNewMessageNotification:(NSNotification *)no
{
    NSArray<TIMMessage *> *msgs = no.object;
    for (TIMMessage *msg in msgs) {
        
        TIMElem *elem = [msg getElem:0];
        if ([elem isKindOfClass:[TIMCustomElem class]]) {
            TIMCustomElem *custom = (TIMCustomElem *)elem;
            NSDictionary *param = [TCUtil jsonData2Dictionary:[custom data]];
            if (param != nil && [param[@"version"] integerValue] == 2) {
                [[VideoCallManager shareInstance] onNewVideoCallMessage:msg];
            }
        }
    }
}

@end
