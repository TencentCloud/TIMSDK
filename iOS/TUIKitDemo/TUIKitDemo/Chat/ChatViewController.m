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
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "MyCustomCell.h"
#import "GroupCreateCell.h"
#import "TCUtil.h"
#import "THelper.h"
#import "TCConstants.h"
#import "V2TIMManager.h"
#import "GenerateTestUserSig.h"
#import "Toast.h"
#import "TUIKitListenerManager.h"
#import "NSBundle+TUIKIT.h"
#import "TIMMessage+DataProvider.h"

#if ENABLELIVE
#import "TUIGroupLiveMessageCell.h"
#import "TUILiveRoomAnchorViewController.h"
#import "TUILiveRoomAudienceViewController.h"
#import "TUILiveDefaultGiftAdapterImp.h"
#import "TUIKitLive.h"
#import "TUILiveUserProfile.h"
#import "TUILiveRoomManager.h"
#import "TUILiveHeartBeatManager.h"
#endif

// MLeaksFinder 会对这个类误报，这里需要关闭一下
@implementation UIImagePickerController (Leak)

- (BOOL)willDealloc {
    return NO;
}

@end

@interface ChatViewController () <
TUIChatControllerListener,
#if ENABLELIVE
TUILiveRoomAnchorDelegate,
#endif
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIDocumentPickerDelegate>
@property (nonatomic, strong) TUIChatController *chat;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[TUIKitListenerManager sharedInstance] addChatControllerListener:self];
    
#if ENABLELIVE
    [[TUIKitLive shareInstance] setGroupLiveDelegate:self];
#endif
    
    _chat = [[TUIChatController alloc] init];
    [_chat setConversationData:self.conversationData];
    [self addChildViewController:_chat];
    [self.view addSubview:_chat.view];
    
    RAC(self, title) = [RACObserve(_conversationData, title) distinctUntilChanged];
    [self checkTitle:NO];

    // 导航栏
    [self setupNavigator];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRefreshNotification:)
                                                 name:TUIKitNotification_TIMRefreshListener_Changed
                                               object:nil];

    //添加未读计数的监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChangeUnReadCount:)
                                                 name:TUIKitNotification_onTotalUnreadMessageCountChanged
                                               object:nil];

    // 刷新未读数
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance getTotalUnreadMessageCount:^(UInt64 totalCount) {
        NSNotification *notice = [[NSNotification alloc] initWithName:TUIKitNotification_onTotalUnreadMessageCountChanged
                                                               object:@(totalCount)
                                                             userInfo:nil];
        [weakSelf onChangeUnReadCount:notice];
    } fail:^(int code, NSString *desc) {
        
    }];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onFriendInfoChanged:) name:@"FriendInfoChangedNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 发送第一条消息
    if (self.waitToSendMsg) {
        TUIMessageCellData *uiMsg = [self.waitToSendMsg cellData];
        if (uiMsg == nil) {
            uiMsg = [self chatController:self.chat onNewMessage:self.waitToSendMsg];
        }
        if (uiMsg == nil) {
            return;
        }
        uiMsg.innerMessage = self.waitToSendMsg;
        [self.chat sendMessage:uiMsg];
        self.waitToSendMsg = nil;
    }
}

- (void)dealloc
{
    [[TUIKitListenerManager sharedInstance] removeChatControllerListener:self];
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
    if(_conversationData.userID.length > 0){
        [rightButton setImage:[UIImage tk_imageNamed:@"person_nav"] forState:UIControlStateNormal];
        //[rightButton setImage:[UIImage tk_imageNamed:@"person_nav_hover"] forState:UIControlStateHighlighted];
    }
    else if(_conversationData.groupID.length > 0){
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
    if (_conversationData.userID.length > 0) {
        @weakify(self)
        [[V2TIMManager sharedInstance] getFriendList:^(NSArray<V2TIMFriendInfo *> *infoList) {
            @strongify(self)
            for (V2TIMFriendInfo *firend in infoList) {
                if ([firend.userFullInfo.userID isEqualToString:self.conversationData.userID]) {
                    id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
                    if ([vc isKindOfClass:[UIViewController class]]) {
                        vc.friendProfile = firend;
                        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                        return;
                    }
                }
            }
            [[V2TIMManager sharedInstance] getUsersInfo:@[self.conversationData.userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                TUserProfileController *myProfile = [[TUserProfileController alloc] init];
                myProfile.userFullInfo = infoList.firstObject;
                myProfile.actionType = PCA_ADD_FRIEND;
                [self.navigationController pushViewController:myProfile animated:YES];
            } fail:^(int code, NSString *msg) {
                NSLog(@"拉取用户资料失败！");
            }];
        } fail:^(int code, NSString *msg) {
            NSLog(@"拉取好友列表失败！");
        }];

    //当前为群组通信时，右侧按钮响应为群组信息入口
    } else {
        GroupInfoController *groupInfo = [[GroupInfoController alloc] init];
        groupInfo.groupId = _conversationData.groupID;
        [self.navigationController pushViewController:groupInfo animated:YES];
    }
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
    NSArray<V2TIMConversation *> *convs = notifi.object;
    for (V2TIMConversation *conv in convs) {
        if ([conv.conversationID isEqualToString:self.conversationData.conversationID]) {
            self.conversationData.title = conv.showName;
            break;
        }
    }
}

- (void) onChangeUnReadCount:(NSNotification *)notifi{
    id obj = notifi.object;
    if (![obj isKindOfClass:NSNumber.class]) {
        return;
    }
    
    // 此处异步的原因：当前聊天页面连续频繁收到消息，可能还没标记已读，此时也会收到未读数变更。理论上此时未读数不会包括当前会话的。
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.unRead setNum:[obj integerValue]];
    });
}

- (void)onFriendInfoChanged:(NSNotification *)notice
{
    [self checkTitle:YES];
}

- (void)checkTitle:(BOOL)force {
    if (force || _conversationData.title.length == 0) {
        if (_conversationData.userID.length > 0) {
            _conversationData.title = _conversationData.userID;
             @weakify(self)
            [[V2TIMManager sharedInstance] getFriendsInfo:@[_conversationData.userID] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
                @strongify(self)
                V2TIMFriendInfoResult *result = resultList.firstObject;
                if (result.friendInfo && result.friendInfo.friendRemark.length > 0) {
                    self.conversationData.title = result.friendInfo.friendRemark;
                } else {
                    [[V2TIMManager sharedInstance] getUsersInfo:@[self.conversationData.userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                        V2TIMUserFullInfo *info = infoList.firstObject;
                        if (info && info.nickName.length > 0) {
                            self.conversationData.title = info.nickName;
                        }
                    } fail:nil];
                }
            } fail:nil];
        }
        if (_conversationData.groupID.length > 0) {
            _conversationData.title = _conversationData.groupID;
             @weakify(self)
            [[V2TIMManager sharedInstance] getGroupsInfo:@[_conversationData.groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
                @strongify(self)
                V2TIMGroupInfoResult *result = groupResultList.firstObject;
                if (result.info && result.info.groupName.length > 0) {
                    self.conversationData.title = result.info.groupName;
                }
            } fail:nil];
        }
    }
}

- (void)chatController:(TUIChatController *)controller didSendMessage:(TUIMessageCellData *)msgCellData
{
    if ([_conversationData.groupID isEqualToString:@"im_demo_admin"] || [_conversationData.userID isEqualToString:@"im_demo_admin"]) {
        [TCUtil report:Action_Sendmsg2helper actionSub:@"" code:@(0) msg:@"sendmsg2helper"];
    }
    else if ([_conversationData.groupID isEqualToString:@"@TGS#33NKXK5FK"] || [_conversationData.userID isEqualToString:@"@TGS#33NKXK5FK"]) {
        [TCUtil report:Action_Sendmsg2defaultgrp actionSub:@"" code:@(0) msg:@"sendmsg2defaultgrp"];
    }
    if ([msgCellData isKindOfClass:[TUITextMessageCellData class]]) {
        [TCUtil report:Action_SendMsg actionSub:Action_Sub_Sendtext code:@(0) msg:@"sendtext"];
    }
    else if ([msgCellData isKindOfClass:[TUIVoiceMessageCellData class]]) {
        [TCUtil report:Action_SendMsg actionSub:Action_Sub_Sendaudio code:@(0) msg:@"sendaudio"];
    }
    else if ([msgCellData isKindOfClass:[TUIFaceMessageCellData class]]) {
        [TCUtil report:Action_SendMsg actionSub:Action_Sub_Sendface code:@(0) msg:@"sendface"];
    }
    else if ([msgCellData isKindOfClass:[TUIImageMessageCellData class]]) {
        [TCUtil report:Action_SendMsg actionSub:Action_Sub_Sendpicture code:@(0) msg:@"sendpicture"];
    }
    else if ([msgCellData isKindOfClass:[TUIVideoMessageCellData class]]) {
        [TCUtil report:Action_SendMsg actionSub:Action_Sub_Sendvideo code:@(0) msg:@"sendvideo"];
    }
    else if ([msgCellData isKindOfClass:[TUIFileMessageCellData class]]) {
        [TCUtil report:Action_SendMsg actionSub:Action_Sub_Sendfile code:@(0) msg:@"sendfile"];
    }
#if ENABLELIVE
    else if ([msgCellData isKindOfClass:[TUIGroupLiveMessageCell class]]) {
        [TCUtil report:Action_SendMsg actionSub:Action_Sub_Sendgrouplive code:@(0) msg:@"sendgrouplive"];
    }
#endif
}

- (NSArray <TUIInputMoreCellData *> *)chatController:(TUIChatController *)chatController onRegisterMoreCell:(MoreCellPriority *)priority {
    // 更多菜单
    NSMutableArray *moreMenus = [NSMutableArray array];
    [moreMenus addObject:({
        TUIInputMoreCellData *data = [TUIInputMoreCellData new];
        data.image = [UIImage tk_imageNamed:@"more_custom"];
        data.title = NSLocalizedString(@"MoreCustom", nil);
        data;
    })];
    *priority = MoreCellPriority_Nomal;
    return moreMenus;
}

- (void)chatController:(TUIChatController *)chatController onSelectMoreCell:(TUIInputMoreCell *)cell
{
    if ([cell.data.title isEqualToString:NSLocalizedString(@"MoreCustom", nil)]) {
        NSString *text = @"欢迎加入腾讯·云通信大家庭！";
        NSString *link = @"https://cloud.tencent.com/document/product/269/3794";
        NSData *customData = [TCUtil dictionary2JsonData:@{@"version": @(TextLink_Version),@"businessID": TextLink,@"text":text,@"link":link}];
        MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:MsgDirectionOutgoing];
        cellData.text = text;
        cellData.link = link;
        cellData.innerMessage = [V2TIMManager.sharedInstance createCustomMessage:customData
                                                                            desc:text
                                                                       extension:text];
        [chatController sendMessage:cellData];
        
        if ([_conversationData.groupID isEqualToString:@"im_demo_admin"] || [_conversationData.userID isEqualToString:@"im_demo_admin"]) {
            [TCUtil report:Action_Sendmsg2helper actionSub:@"" code:@(0) msg:@"sendmsg2helper"];
        }
        else if ([_conversationData.groupID isEqualToString:@"@TGS#33NKXK5FK"] || [_conversationData.userID isEqualToString:@"@TGS#33NKXK5FK"]) {
            [TCUtil report:Action_Sendmsg2defaultgrp actionSub:@"" code:@(0) msg:@"sendmsg2defaultgrp"];
        }
        [TCUtil report:Action_SendMsg actionSub:Action_Sub_Sendcustom code:@(0) msg:@"sendcustom"];
    }
}

- (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewMessage:(V2TIMMessage *)msg
{
    if (msg.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        NSDictionary *param = [TCUtil jsonData2Dictionary:msg.customElem.data];
        if (param != nil) {
            NSString *businessID = param[@"businessID"];
            if (![businessID isKindOfClass:[NSString class]]) {
                return nil;
            }
            // 判断是不是自定义跳转消息
            if ([businessID isEqualToString:TextLink] || ([(NSString *)param[@"text"] length] > 0 && [(NSString *)param[@"link"] length] > 0)) {
                MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
                cellData.innerMessage = msg;
                cellData.msgID = msg.msgID;
                cellData.text = param[@"text"];
                cellData.link = param[@"link"];
                cellData.avatarUrl = [NSURL URLWithString:msg.faceURL];
                return cellData;
            }
            // 判断是不是群创建自定义消息
            else if ([businessID isEqualToString:GroupCreate] || [param.allKeys containsObject:GroupCreate]) {
                GroupCreateCellData *cellData = [[GroupCreateCellData alloc] initWithDirection:msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
                cellData.content = [NSString stringWithFormat:@"\"%@\"%@",param[@"opUser"],param[@"content"]];
                return cellData;
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
    } else if ([data isKindOfClass:[GroupCreateCellData class]]) {
        GroupCreateCell *groupCell = [[GroupCreateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupCreateCell"];
        [groupCell fillWithData:(GroupCreateCellData *)data];
        return groupCell;
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

- (NSString *)chatController:(TUIChatController *)controller onGetMessageAbstact:(V2TIMMessage *)msg {
    if (msg.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        NSDictionary *param = [TCUtil jsonData2Dictionary:msg.customElem.data];
        if (param != nil) {
            NSString *businessID = param[@"businessID"];
            // 判断是不是自定义跳转消息
            if ([businessID isEqualToString:TextLink] || ([(NSString *)param[@"text"] length] > 0 && [(NSString *)param[@"link"] length] > 0)) {
                return param[@"text"];
            }
            // 判断是不是群创建自定义消息
            else if ([businessID isEqualToString:GroupCreate] || [param.allKeys containsObject:GroupCreate]) {
                return [NSString stringWithFormat:@"\"%@\"%@",param[@"opUser"],param[@"content"]];
            }
        }
    }
    return nil;
}

#if ENABLELIVE
#pragma mark - TUILiveRoomAnchorDelegate
- (void)onRoomCreate:(TRTCLiveRoomInfo *)roomInfo {
    [[TUILiveRoomManager sharedManager] createRoom:SDKAPPID type:@"groupLive" roomID:[NSString stringWithFormat:@"%@", roomInfo.roomId] success:^{
        NSLog(@"----> 业务层创建群直播房间成功: roomId:%@", roomInfo.roomId);
        [TUILiveHeartBeatManager.shareManager startWithType:@"groupLive" roomId:roomInfo.roomId];
    } failed:^(int code, NSString * _Nonnull errorMsg) {
        NSLog(@"----> 业务层创建群直播房间失败，%d, %@", code, errorMsg);
    }];

}

- (void)onRoomDestroy:(TRTCLiveRoomInfo *)roomInfo {
    [[TUILiveRoomManager sharedManager] destroyRoom:SDKAPPID type:@"groupLive" roomID:[NSString stringWithFormat:@"%@", roomInfo.roomId] success:^{
        NSLog(@"----> 业务层销毁群直播房间成功");
        [TUILiveHeartBeatManager.shareManager stop];
    } failed:^(int code, NSString * _Nonnull errorMsg) {
        NSLog(@"----> 业务层销毁群直播房间失败，%d, %@", code, errorMsg);
    }];
}

- (TUIGroupLiveMessageCellData *)groupLiveCellDataWith:(TRTCLiveRoomInfo *)roomInfo roomStatus:(NSInteger)status {
    TUIGroupLiveMessageCellData *cellData = [[TUIGroupLiveMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    cellData.anchorName = roomInfo.ownerName?:@"";
    cellData.roomInfo = @{
        @"roomId":roomInfo.roomId?:@"",
        @"version":@(AVCall_Version),
        @"roomName":roomInfo.roomName?:@"",
        @"roomCover":roomInfo.coverUrl?:@"",
        @"roomType":@"liveRoom",
        @"roomStatus":@(status),
        @"anchorId":roomInfo.ownerId?:@"",
        @"anchorName":roomInfo.ownerName?:@""
    };
    cellData.status = Msg_Status_Init;
    return cellData;
}
#endif
@end
