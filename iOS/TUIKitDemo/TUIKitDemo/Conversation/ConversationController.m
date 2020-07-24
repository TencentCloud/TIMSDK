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
 *推送默认跳转
 */
- (void)pushToChatViewController:(NSString *)groupID userID:(NSString *)userID {
    ChatViewController *chat = [[ChatViewController alloc] init];
    TUIConversationCellData *conversationData = [[TUIConversationCellData alloc] init];
    conversationData.groupID = groupID;
    conversationData.userID = userID;
    chat.conversationData = conversationData;
    [self.navigationController pushViewController:chat animated:YES];
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
            data.userID = array.firstObject.identifier;
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
            [self addGroup:GroupType_Work addOption:0 withContacts:array];
        };
        return;
    } else if(index == 2){
        //创建群聊
        TUIContactSelectController *vc = [TUIContactSelectController new];
        vc.title = @"选择联系人";
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *array) {
            @strongify(self)
            [self addGroup:GroupType_Public addOption:V2TIM_GROUP_ADD_ANY withContacts:array];
        };
        return;
    } else if(index == 3){
        //创建聊天室
        TUIContactSelectController *vc = [TUIContactSelectController new];
        vc.title = @"选择联系人";
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *array) {
            @strongify(self)
            [self addGroup:GroupType_Meeting addOption:V2TIM_GROUP_ADD_ANY withContacts:array];
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
- (void)addGroup:(NSString *)groupType addOption:(V2TIMGroupAddOpt)addOption withContacts:(NSArray<TCommonContactSelectCellData *>  *)contacts
{
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        NSString *showName = loginUser;
        if (infoList.firstObject.nickName.length > 0) {
            showName = infoList.firstObject.nickName;
        }
        NSMutableString *groupName = [NSMutableString stringWithString:showName];
        NSMutableArray *members = [NSMutableArray array];
        //遍历contacts，初始化群组成员信息、群组名称信息
        for (TCommonContactSelectCellData *item in contacts) {
            V2TIMCreateGroupMemberInfo *member = [[V2TIMCreateGroupMemberInfo alloc] init];
            member.userID = item.identifier;
            member.role = V2TIM_GROUP_MEMBER_ROLE_MEMBER;
            [groupName appendFormat:@"、%@", item.title];
            [members addObject:member];
        }

        //群组名称默认长度不超过10，如有需求可在此更改，但可能会出现UI上的显示bug
        if ([groupName length] > 10) {
            groupName = [groupName substringToIndex:10].mutableCopy;
        }

        V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
        info.groupName = groupName;
        info.groupType = groupType;
        if(![info.groupType isEqualToString:GroupType_Work]){
            info.groupAddOpt = addOption;
        }

        //发送创建请求后的回调函数
        @weakify(self)
        [[V2TIMManager sharedInstance] createGroup:info memberList:members succ:^(NSString *groupID) {
            //创建成功后，在群内推送创建成功的信息
            @strongify(self)
            NSString *content = nil;
            if([info.groupType isEqualToString:GroupType_Work]) {
                content = @"创建讨论组";
            } else if([info.groupType isEqualToString:GroupType_Public]){
                content = @"创建群聊";
            } else if([info.groupType isEqualToString:GroupType_Meeting]) {
                content = @"创建聊天室";
            } else {
                content = @"创建群组";
            }
            NSDictionary *dic = @{@"version": @(Version),@"businessID": @"group_create",@"opUser":showName,@"content":@"创建群组"};
            NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:data];
            [[V2TIMManager sharedInstance] sendMessage:msg receiver:nil groupID:groupID priority:V2TIM_PRIORITY_DEFAULT onlineUserOnly:NO offlinePushInfo:nil progress:nil succ:nil fail:nil];

            //创建成功后，默认跳转到群组对应的聊天界面
            TUIConversationCellData *cellData = [[TUIConversationCellData alloc] init];
            cellData.groupID = groupID;
            cellData.title = groupName;
            ChatViewController *chat = [[ChatViewController alloc] init];
            chat.conversationData = cellData;
            [self.navigationController pushViewController:chat animated:YES];

            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [tempArray removeObjectAtIndex:tempArray.count-2];
            self.navigationController.viewControllers = tempArray;
        } fail:^(int code, NSString *msg) {
            [THelper makeToastError:code msg:msg];
        }];
    } fail:^(int code, NSString *msg) {
        // to do
    }];
}
@end
