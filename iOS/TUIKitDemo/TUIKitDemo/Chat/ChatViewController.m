//
//  ChatViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 聊天视图
 *  本文件实现了聊天视图
 *  在用户需要收发群组、以及其他用户消息时提供UI
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 *
 */
#import "ChatViewController.h"
#import "GroupInfoController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "TUIVideoMessageCell.h"
#import "TUIFileMessageCell.h"
#import "TUITextMessageCell.h"
#import "TUISystemMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "TUIImageMessageCell.h"
#import "TUIFaceMessageCell.h"
#import "TUIVideoMessageCell.h"
#import "TUIFileMessageCell.h"
#import "TUserProfileController.h"
#import "TIMFriendshipManager.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "MyCustomCell.h"
#import "TCUtil.h"
#import "THelper.h"
#import "ChatViewController+video.h"
#import "VideoCallManager.h"

// MLeaksFinder 会对这个类误报，这里需要关闭一下
@implementation UIImagePickerController (Leak)

- (BOOL)willDealloc {
    return NO;
}

@end

@interface ChatViewController () <TUIChatControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) TUIChatController *chat;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:_conversationData.convType receiver:_conversationData.convId];
    _chat = [[TUIChatController alloc] initWithConversation:conv];
    _chat.delegate = self;
    [self addChildViewController:_chat];
    [self.view addSubview:_chat.view];


    RAC(self, title) = [RACObserve(_conversationData, title) distinctUntilChanged];

    NSMutableArray *moreMenus = [NSMutableArray arrayWithArray:_chat.moreMenus];
    
    if (_conversationData.convType == TIM_C2C) {
        [moreMenus addObject:({
            TUIInputMoreCellData *data = [TUIInputMoreCellData new];
            data.image = [UIImage tk_imageNamed:@"more_video"];
            data.title = @"视频通话";
            data;
        })];
    }

    [moreMenus addObject:({
        TUIInputMoreCellData *data = [TUIInputMoreCellData new];
        data.image = [UIImage tk_imageNamed:@"more_custom"];
        data.title = @"自定义";
        data;
    })];
    _chat.moreMenus = moreMenus;

    [self setupNavigator];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRefreshNotification:)
                                                 name:TUIKitNotification_TIMRefreshListener
                                               object:nil];

    //添加未读计数的监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChangeUnReadCount:)
                                                 name:TUIKitNotification_onChangeUnReadCount
                                               object:nil];


}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        [_chat saveDraft];
    }
}

// 聊天窗口标题由上层维护，需要自行设置标题
- (void)onRefreshNotification:(NSNotification *)notifi
{

    NSArray<TIMConversation *> *convs = notifi.object;
    if ([convs isKindOfClass:[NSArray class]]) {
        for (TIMConversation *conv in convs) {
            if ([[conv getReceiver] isEqualToString:_conversationData.convId]) {
                if (_conversationData.convType == TIM_GROUP) {
                    _conversationData.title = [conv getGroupName];
                } else if (_conversationData.convType == TIM_C2C) {
                       TIMUserProfile *user = [[TIMFriendshipManager sharedInstance] queryUserProfile:_conversationData.convId];
                    if (user) {
                        _conversationData.title = [user showName];
                    }
                }
            }
        }
    }


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[VideoCallManager shareInstance] setCurrentChatVC:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[VideoCallManager shareInstance] setCurrentChatVC:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigator
{
    //left
    _unRead = [[TUnReadView alloc] init];

    //_unRead.backgroundColor = [UIColor grayColor];//可通过此处将未读标记设置为灰色，类似微信，但目前仍使用红色未读视图
    UIBarButtonItem *urBtn = [[UIBarButtonItem alloc] initWithCustomView:_unRead];


    self.navigationItem.leftBarButtonItems = @[urBtn];

    //既显示返回按钮，又显示未读视图
    self.navigationItem.leftItemsSupplementBackButton = YES;



    //right，根据当前聊天页类型设置右侧按钮格式
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    if(_conversationData.convType == TIM_C2C){
        [rightButton setImage:[UIImage tk_imageNamed:@"person_nav"] forState:UIControlStateNormal];
        //[rightButton setImage:[UIImage tk_imageNamed:@"person_nav_hover"] forState:UIControlStateHighlighted];
    }
    else if(_conversationData.convType == TIM_GROUP){
        [rightButton setImage:[UIImage tk_imageNamed:(@"group_nav")] forState:UIControlStateNormal];
        //[rightButton setImage:[UIImage tk_imageNamed:(@"group_nav_hover")] forState:UIControlStateHighlighted];
    }
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];


    self.navigationItem.rightBarButtonItems = @[rightItem];


}

-(void)leftBarButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonClick
{
    //当前为用户和用户之间通信时，右侧按钮响应为用户信息视图入口
    if (_conversationData.convType == TIM_C2C) {
        @weakify(self)
        [[TIMFriendshipManager sharedInstance] getFriendList:^(NSArray<TIMFriend *> *friends) {
            @strongify(self)
            for (TIMFriend *firend in friends) {
                if ([firend.identifier isEqualToString:self.conversationData.convId]) {
                    id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
                    if ([vc isKindOfClass:[UIViewController class]]) {
                        vc.friendProfile = firend;
                        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                        return;
                    }
                }
            }

            [[TIMFriendshipManager sharedInstance] getUsersProfile:@[self.conversationData.convId] forceUpdate:YES succ:^(NSArray<TIMUserProfile *> *profiles) {
                TUserProfileController *myProfile = [[TUserProfileController alloc] init];
                myProfile.userProfile = profiles.firstObject;
                myProfile.actionType = PCA_ADD_FRIEND;
                [self.navigationController pushViewController:myProfile animated:YES];
            } fail:^(int code, NSString *msg) {

            }];
        } fail:^(int code, NSString *msg) {

        }];


    //当前为群组通信时，右侧按钮响应为群组信息入口
    } else {
        GroupInfoController *groupInfo = [[GroupInfoController alloc] init];
        groupInfo.groupId = _conversationData.convId;
        [self.navigationController pushViewController:groupInfo animated:YES];
    }
}

- (void)chatController:(TUIChatController *)chatController onSelectMoreCell:(TUIInputMoreCell *)cell
{
    if ([cell.data.title isEqualToString:@"自定义"]) {
        NSString *text = @"欢迎加入云通信IM大家庭！";
        NSString *link = @"https://cloud.tencent.com/document/product/269/3794";
        MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:MsgDirectionOutgoing];
        cellData.text = text;
        cellData.link = link;

        cellData.innerMessage = [[TIMMessage alloc] init];
        TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
        custom_elem.data = [TCUtil dictionary2JsonData:@{@"text":text,@"link":link,@"version":@(1)}];
        [cellData.innerMessage addElem:custom_elem];

        [chatController sendMessage:cellData];
    } else if ([cell.data.title isEqualToString:@"视频通话"]) {
        [[VideoCallManager shareInstance] setConversationData:self.conversationData];
        [[VideoCallManager shareInstance] videoCall:chatController];
    }
}

- (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewMessage:(TIMMessage *)msg
{
    if (msg && msg.elemCount > 0) {
        TIMElem *elem = [msg getElem:0];
        if([elem isKindOfClass:[TIMCustomElem class]]) {
            NSDictionary *param = [TCUtil jsonData2Dictionary:[(TIMCustomElem *)elem data]];
            if (param != nil && [param[@"version"] integerValue] == 1) {
                MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
                cellData.text = param[@"text"];
                cellData.link = param[@"link"];
                cellData.avatarUrl = [NSURL URLWithString:[[TIMFriendshipManager sharedInstance] querySelfProfile].faceURL];
                return cellData;
            } else if (param != nil && [param[@"version"] integerValue] == 2) {
                return [self chatController:controller onNewVideoCallMessage:msg];
            }
        }
    }
    return nil;
}

- (TUIMessageCell *)chatController:(TUIChatController *)controller onShowMessageData:(TUIMessageCellData *)data
{
    if ([data isKindOfClass:[MyCustomCellData class]]) {
        MyCustomCell *myCell = [[MyCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"];
        [myCell fillWithData:(MyCustomCellData *)data];
        return myCell;
    }
    
    if ([data isKindOfClass:[VideoCallCellData class]]) {
        UInt32 state = [(VideoCallCellData *)data videoState];
        if (state == VIDEOCALL_REQUESTING || state == VIDEOCALL_USER_CONNECTTING) {
            return nil;
        } else {
            VideoCallCell *videoCallCell = [[VideoCallCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VideoCell"];
            [videoCallCell fillWithData:(VideoCallCellData *)data];
            @weakify(self);
            @weakify(controller);
            [videoCallCell setVidelClick:^{
                @strongify(self);
                @strongify(controller);
                [[VideoCallManager shareInstance] setConversationData:self.conversationData];
                [[VideoCallManager shareInstance] videoCall:controller];
            }];
            return videoCallCell;
        }
    }

    return nil;
}

- (void)chatController:(TUIChatController *)controller onSelectMessageContent:(TUIMessageCell *)cell
{
    if ([cell isKindOfClass:[MyCustomCell class]]) {
        MyCustomCellData *cellData = [(MyCustomCell *)cell customData];
        if (cellData.link) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cellData.link]];
        }
    }
}

- (void) onChangeUnReadCount:(NSNotification *)notifi{
    NSNumber *count = notifi.object;

    //此处获取本对话的未读计数，并减去本对话的未读。如果不减去，则在本对话中收到消息时，消息不会自动设为已读，从而会错误显示左上角未读计数。
    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:_conversationData.convType receiver:_conversationData.convId];
    count = [NSNumber numberWithInteger:(count.integerValue - conv.getUnReadMessageNum)];

    [_unRead setNum:count.integerValue];
}



///此处可以修改导航栏按钮的显示位置，但是无法修改响应位置，暂时不建议使用
- (void)resetBarItemSpacesWithController:(UIViewController *)viewController {
    CGFloat space = 16;
    for (UIBarButtonItem *buttonItem in viewController.navigationItem.leftBarButtonItems) {
        if (buttonItem.customView == nil) { continue; }
        /// 根据实际情况(自己项目UIBarButtonItem的层级)获取button
        UIButton *itemBtn = nil;
        if ([buttonItem.customView isKindOfClass:[UIButton class]]) {
            itemBtn = (UIButton *)buttonItem.customView;
        }
        /// 设置button图片/文字偏移
        itemBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -space,0, 0);
        itemBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -space,0, 0);
        itemBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -space,0, 0);
        /// 改变button事件响应区域
        // itemBtn.hitEdgeInsets = UIEdgeInsetsMake(0, -space, 0, space);
    }
    for (UIBarButtonItem *buttonItem in viewController.navigationItem.rightBarButtonItems) {
        if (buttonItem.customView == nil) { continue; }
        UIButton *itemBtn = nil;
        if ([buttonItem.customView isKindOfClass:[UIButton class]]) {
            itemBtn = (UIButton *)buttonItem.customView;
        }
        itemBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0,0, -space);
        itemBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0,0, -space);
        itemBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0,0, -space);
        //itemBtn.hitEdgeInsets = UIEdgeInsetsMake(0, space, 0, -space);
    }
}

- (void)sendMessage:(TUIMessageCellData*)msg {
    [_chat sendMessage:msg];
}

//- (void)chatController:(TUIChatController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell
//{
//
//}
@end
