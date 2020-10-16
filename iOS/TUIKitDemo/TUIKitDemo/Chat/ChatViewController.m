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
#import "TUIGroupLiveMessageCell.h"
#import "TUserProfileController.h"
#import "TIMFriendshipManager.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "MyCustomCell.h"
#import "TCUtil.h"
#import "THelper.h"
#import "TCConstants.h"
#import "TUILiveRoomAnchorViewController.h"
#import "TUILiveRoomAudienceViewController.h"
#import "TUILiveDefaultGiftAdapterImp.h"
#import "TUIKitLive.h"
#import "V2TIMManager.h"
#import "TUILiveUserProfile.h"
#import "TUILiveRoomManager.h"
#import "TUILiveHeartBeatManager.h"
#import "GenerateTestUserSig.h"
#import "Toast.h"


// MLeaksFinder 会对这个类误报，这里需要关闭一下
@implementation UIImagePickerController (Leak)

- (BOOL)willDealloc {
    return NO;
}

@end

@interface ChatViewController () <TUIChatControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate,
TUILiveRoomAnchorDelegate>
@property (nonatomic, strong) TUIChatController *chat;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _chat = [[TUIChatController alloc] initWithConversation:self.conversationData];
    _chat.delegate = self;
    [self addChildViewController:_chat];
    [self.view addSubview:_chat.view];


    RAC(self, title) = [RACObserve(_conversationData, title) distinctUntilChanged];
    [self checkTitle];

    NSMutableArray *moreMenus = [NSMutableArray arrayWithArray:_chat.moreMenus];
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
                                                 name:TUIKitNotification_TIMRefreshListener_Changed
                                               object:nil];

    //添加未读计数的监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChangeUnReadCount:)
                                                 name:TUIKitNotification_onChangeUnReadCount
                                               object:nil];


}

- (void)checkTitle {
    if (_conversationData.title.length == 0) {
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
    else if ([msgCellData isKindOfClass:[TUIGroupLiveMessageCell class]]) {
        [TCUtil report:Action_SendMsg actionSub:Action_Sub_Sendgrouplive code:@(0) msg:@"sendgrouplive"];
    }
}

- (void)chatController:(TUIChatController *)chatController onSelectMoreCell:(TUIInputMoreCell *)cell
{
    if ([cell.data.title isEqualToString:@"自定义"]) {
        NSString *text = @"欢迎加入腾讯·云通信大家庭！";
        NSString *link = @"https://cloud.tencent.com/document/product/269/3794";
        MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:MsgDirectionOutgoing];
        cellData.text = text;
        cellData.link = link;
        cellData.innerMessage = [[V2TIMManager sharedInstance] createCustomMessage:[TCUtil dictionary2JsonData:@{@"version": @(TextLink_Version),@"businessID": TextLink,@"text":text,@"link":link}]];
        [chatController sendMessage:cellData];
        
        if ([_conversationData.groupID isEqualToString:@"im_demo_admin"] || [_conversationData.userID isEqualToString:@"im_demo_admin"]) {
            [TCUtil report:Action_Sendmsg2helper actionSub:@"" code:@(0) msg:@"sendmsg2helper"];
        }
        else if ([_conversationData.groupID isEqualToString:@"@TGS#33NKXK5FK"] || [_conversationData.userID isEqualToString:@"@TGS#33NKXK5FK"]) {
            [TCUtil report:Action_Sendmsg2defaultgrp actionSub:@"" code:@(0) msg:@"sendmsg2defaultgrp"];
        }
        [TCUtil report:Action_SendMsg actionSub:Action_Sub_Sendcustom code:@(0) msg:@"sendcustom"];
    } else if ([cell.data.title isEqualToString:@"群直播"]) {
        cell.disableDefaultSelectAction = YES;
        NSString *hashStr = [NSString stringWithFormat:@"%@_%@_liveRoom", _conversationData.groupID, [TUILiveUserProfile getLoginUserInfo].userID];
        int roomId = (hashStr.hash & 0x7FFFFFFF);
        TUILiveRoomAnchorViewController *anchorVC = [[TUILiveRoomAnchorViewController alloc] initWithRoomId:roomId];
        [anchorVC enablePK:NO];
        anchorVC.delegate = self;
        [anchorVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:anchorVC animated:YES];
    }
}

- (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewMessage:(V2TIMMessage *)msg
{
    if (msg.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        NSDictionary *param = [TCUtil jsonData2Dictionary:msg.customElem.data];
        if (param != nil) {
            NSInteger version = [param[@"version"] integerValue];
            NSString *businessID = param[@"businessID"];
            NSString *text = param[@"text"];
            NSString *link = param[@"link"];
            if (text.length == 0 || link.length == 0) {
                return nil;
            }
            if ([businessID isEqualToString:TextLink]) {
                if (version <= TextLink_Version) {
                    MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
                    cellData.innerMessage = msg;
                    cellData.msgID = msg.msgID;
                    cellData.text = param[@"text"];
                    cellData.link = param[@"link"];
                    cellData.avatarUrl = [NSURL URLWithString:msg.faceURL];
                    return cellData;
                }
            } else {
                // 兼容下老版本
                MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
                cellData.innerMessage = msg;
                cellData.msgID = msg.msgID;
                cellData.text = param[@"text"];
                cellData.link = param[@"link"];
                cellData.avatarUrl = [NSURL URLWithString:msg.faceURL];
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
    } else if ([cell isKindOfClass:[TUIGroupLiveMessageCell class]]) {
        cell.disableDefaultSelectAction = YES;
        NSLog(@"群直播消息");
        TUIGroupLiveMessageCellData *celldata = [(TUIGroupLiveMessageCell *)cell customData];
        NSDictionary *roomInfo = celldata.roomInfo;
        NSString *anchorId = roomInfo[@"anchorId"];
        if (roomInfo[@"roomId"] && anchorId.length > 0) {
            if ([anchorId isEqual:[TUILiveUserProfile getLoginUserInfo].userID]) {
                NSString *hashStr = [NSString stringWithFormat:@"%@_%@_liveRoom", _conversationData.groupID, [TUILiveUserProfile getLoginUserInfo].userID];
                int roomId = (hashStr.hash & 0x7FFFFFFF);
                TUILiveRoomAnchorViewController *anchorVC = [[TUILiveRoomAnchorViewController alloc] initWithRoomId:roomId];
                [anchorVC enablePK:NO];
                anchorVC.delegate = self;
                [anchorVC setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:anchorVC animated:YES];
            } else {
                
                // 检查群直播是否结束
                __weak typeof(self) weakSelf = self;
                [self checkGroupLiveOnline:[NSString stringWithFormat:@"%@", roomInfo[@"roomId"]] completion:^(BOOL online) {
                    if (!online) {
                        [self.view makeToast:@"直播已结束"];
                        return;
                    }
                    TUILiveRoomAudienceViewController *audienceVC = [[TUILiveRoomAudienceViewController alloc] initWithRoomId:[roomInfo[@"roomId"] intValue] anchorId:anchorId useCdn:NO cdnUrl:@""];
                    [weakSelf.navigationController pushViewController:audienceVC animated:YES];
                }];
            }
        }
    }
}

- (void) onChangeUnReadCount:(NSNotification *)notifi{
    NSMutableArray *convList = (NSMutableArray *)notifi.object;
    int unReadCount = 0;
    for (V2TIMConversation *conv in convList) {
        // 忽略当前会话的未读数
        if (![conv.conversationID isEqual:self.conversationData.conversationID]) {
            unReadCount += conv.unreadCount;
        }
    }
    [_unRead setNum:unReadCount];
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

#pragma mark - 群直播相关
- (void)checkGroupLiveOnline:(NSString *)roomId completion:(void(^)(BOOL online))completion
{
    [TUILiveRoomManager.sharedManager getRoomList:SDKAPPID type:@"groupLive" success:^(NSArray<NSString *> * _Nonnull roomIds) {
        if (completion) {
            completion([roomIds containsObject:roomId]);
        }
    } failed:^(int code, NSString * _Nonnull errorMsg) {
        if (completion) {
            completion(NO);
        }
    }];
}



#pragma mark - TUILiveRoomAnchorDelegate
- (void)onRoomCreate:(TRTCLiveRoomInfo *)roomInfo {
    TUIGroupLiveMessageCellData *cellData = [self groupLiveCellDataWith:roomInfo roomStatus:1];
    [self sendMessage:cellData];
    
    [[TUILiveRoomManager sharedManager] createRoom:SDKAPPID type:@"groupLive" roomID:[NSString stringWithFormat:@"%@", roomInfo.roomId] success:^{
        NSLog(@"----> 业务层创建群直播房间成功: roomId:%@", roomInfo.roomId);
        [TUILiveHeartBeatManager.shareManager startWithType:@"groupLive" roomId:roomInfo.roomId];
    } failed:^(int code, NSString * _Nonnull errorMsg) {
        NSLog(@"----> 业务层创建群直播房间失败，%d, %@", code, errorMsg);
    }];

}

- (void)onRoomDestroy:(TRTCLiveRoomInfo *)roomInfo {
    TUIGroupLiveMessageCellData *cellData = [self groupLiveCellDataWith:roomInfo roomStatus:0];
    [self sendMessage:cellData];
    
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

@end
