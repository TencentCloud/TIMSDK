//
//  TUIMessageController.m
//  UIKit
//
//  Created by annidyfeng on 2019/7/1.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIMessageController.h"
#import "TUITextMessageCell.h"
#import "TUISystemMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "TUIImageMessageCell.h"
#import "TUIFaceMessageCell.h"
#import "TUIVideoMessageCell.h"
#import "TUIFileMessageCell.h"
#import "TUIJoinGroupMessageCell.h"
#import "TUIMergeMessageCell.h"
#import "TUIKitConfig.h"
#import "TUIFaceView.h"
#import "TUIKit.h"
#import "TUIConversationCellData.h"
#import "TIMMessage+DataProvider.h"
#import "TUIImageViewController.h"
#import "TUIVideoViewController.h"
#import "TUIFileViewController.h"
#import "NSString+TUICommon.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMMessage+DataProvider.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "UIColor+TUIDarkMode.h"
#import "NSBundle+TUIKIT.h"
#import "TUIMergeMessageListController.h"


#define MAX_MESSAGE_SEP_DLAY (5 * 60)

@interface TUIMessageController () <TMessageCellDelegate>
@property (nonatomic, strong) V2TIMMessage *msgForGet;
@property (nonatomic, strong) TUIMessageCellData *menuUIMsg;
@property (nonatomic, strong) TUIMessageCellData *reSendUIMsg;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL isScrollBottom;
@property (nonatomic, assign) BOOL isLoadingMsg;
@property (nonatomic, assign) BOOL isInVC;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL showCheckBox;
@end

@implementation TUIMessageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    self.isActive = YES;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isInVC = YES;
    [self readedReport];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.isInVC = NO;
    [self readedReport];
    [super viewWillDisappear:animated];
}

- (void)readedReport
{
    if (self.isInVC && self.isActive) {
        NSString *userID = self.conversationData.userID;
        if (userID.length > 0) {
            [[V2TIMManager sharedInstance] markC2CMessageAsRead:userID succ:^{
                
            } fail:^(int code, NSString *msg) {
                
            }];
        }
        NSString *groupID = self.conversationData.groupID;
        if (groupID.length > 0) {
            [[V2TIMManager sharedInstance] markGroupMessageAsRead:groupID succ:^{
                
            } fail:^(int code, NSString *msg) {
                
            }];
        }
    }
}

- (void)limitReadReport {
    static uint64_t lastTs = 0;
    uint64_t curTs = [[NSDate date] timeIntervalSince1970];
    // 超过 1s && 非首次 立即上报已读
    if (curTs - lastTs >= 1 && lastTs) {
        lastTs = curTs;
        [self readedReport];
    } else {
        // 低于 1s || 首次  延迟 1s 合并上报
        static BOOL delayReport = NO;
        if (delayReport) {
            return;
        }
        delayReport = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self readedReport];
            delayReport = NO;
        });
    }
}

- (void)applicationBecomeActive
{
    self.isActive = YES;
    [self readedReport];
}

- (void)applicationEnterBackground
{
    self.isActive = NO;
}

- (void)setupViews
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageStatusChanged:) name:TUIKitNotification_onMessageStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewMessage:) name:TUIKitNotification_TIMMessageListener object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRevokeMessage:) name:TUIKitNotification_TIMMessageRevokeListener object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecvMessageReceipts:) name:TUIKitNotification_onRecvMessageReceipts object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecvMessageModified:) name:TUIKitNotification_TIMMessageModifiedListener object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapViewController)];
    [self.view addGestureRecognizer:tap];
    
    self.tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 0;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

    [self.tableView registerClass:[TUITextMessageCell class] forCellReuseIdentifier:TTextMessageCell_ReuseId];
    [self.tableView registerClass:[TUIVoiceMessageCell class] forCellReuseIdentifier:TVoiceMessageCell_ReuseId];
    [self.tableView registerClass:[TUIImageMessageCell class] forCellReuseIdentifier:TImageMessageCell_ReuseId];
    [self.tableView registerClass:[TUISystemMessageCell class] forCellReuseIdentifier:TSystemMessageCell_ReuseId];
    [self.tableView registerClass:[TUIFaceMessageCell class] forCellReuseIdentifier:TFaceMessageCell_ReuseId];
    [self.tableView registerClass:[TUIVideoMessageCell class] forCellReuseIdentifier:TVideoMessageCell_ReuseId];
    [self.tableView registerClass:[TUIFileMessageCell class] forCellReuseIdentifier:TFileMessageCell_ReuseId];
    [self.tableView registerClass:[TUIJoinGroupMessageCell class] forCellReuseIdentifier:TJoinGroupMessageCell_ReuseId];
    [self.tableView registerClass:[TUIMergeMessageCell class] forCellReuseIdentifier:TRelayMessageCell_ReuserId];


    _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TMessageController_Header_Height)];
    _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.tableView.tableHeaderView = _indicatorView;

    _heightCache = [NSMutableArray array];
    _uiMsgs = [[NSMutableArray alloc] init];
    _firstLoad = YES;
}

- (void)setConversation:(TUIConversationCellData *)conversationData
{
    self.conversationData = conversationData;
    [self loadMessage];
}

- (void)loadMessage
{
    if(_isLoadingMsg || _noMoreMsg){
        return;
    }
    _isLoadingMsg = YES;
    int msgCount = 20;

    @weakify(self)
    if (self.conversationData.userID.length > 0) {
        [[V2TIMManager sharedInstance] getC2CHistoryMessageList:self.conversationData.userID count:msgCount lastMsg:self.msgForGet succ:^(NSArray<V2TIMMessage *> *msgs) {
            @strongify(self)
            [self getMessages:msgs msgCount:msgCount];
        } fail:^(int code, NSString *msg) {
            @strongify(self)
            self.isLoadingMsg = NO;
            [THelper makeToastError:code msg:msg];
        }];
    }
    if (self.conversationData.groupID.length > 0) {
        [[V2TIMManager sharedInstance] getGroupHistoryMessageList:self.conversationData.groupID count:msgCount lastMsg:self.msgForGet succ:^(NSArray<V2TIMMessage *> *msgs) {
            @strongify(self)
            [self getMessages:msgs msgCount:msgCount];
        } fail:^(int code, NSString *msg) {
            @strongify(self)
            self.isLoadingMsg = NO;
            [THelper makeToastError:code msg:msg];
        }];
    }
}

- (void)getMessages:(NSArray *)msgs msgCount:(int)msgCount
{
    if(msgs.count != 0){
        self.msgForGet = msgs[msgs.count - 1];
    }
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:msgs];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(msgs.count < msgCount){
            self.noMoreMsg = YES;
            self.indicatorView.mm_h = 0;
        }
        if(uiMsgs.count != 0){
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
            [self.uiMsgs insertObjects:uiMsgs atIndexes:indexSet];
            [self.heightCache removeAllObjects];
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
            if(!self.firstLoad){
                CGFloat visibleHeight = 0;
                for (NSInteger i = 0; i < uiMsgs.count; ++i) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    visibleHeight += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                }
                if(self.noMoreMsg){
                    visibleHeight -= TMessageController_Header_Height;
                }
                [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentOffset.y + visibleHeight, self.tableView.frame.size.width, self.tableView.frame.size.height) animated:NO];
            }
        }
        self.isLoadingMsg = NO;
        [self.indicatorView stopAnimating];
        self.firstLoad = NO;
    });
}

- (void)onNewMessage:(NSNotification *)notification
{
    V2TIMMessage *msg = notification.object;
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:@[msg]];
    if (uiMsgs.count > 0) {
        //生成需要插入的 index。即行号从 _uiMsgs.count - 1到 _uiMsgs.count + uiMsgs.count +1。 section 恒为 0。
        [self.tableView beginUpdates];
        for (TUIMessageCellData *uiMsg in uiMsgs) {
            [self.uiMsgs addObject:uiMsg];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0]]
            withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
        // 查看历史消息的时候根据当前 contentOffset 判断是否需要滑动到底部
        if (self.tableView.contentSize.height - self.tableView.contentOffset.y < Screen_Height * 1.5) {
            [self scrollToBottom:YES];
        }
        [self limitReadReport];
    }
}

- (void)onRevokeMessage:(NSNotification *)notification
{
    NSString *msgID = notification.object;
    TUIMessageCellData *uiMsg = nil;
    for (uiMsg in _uiMsgs) {
        if ([uiMsg.msgID isEqualToString:msgID]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self revokeMsg:uiMsg];
            });
            break;
        }
    }
}

- (void)onMessageStatusChanged:(NSNotification *)notification
{
    NSString *msgId = notification.object;
    TUIMessageCellData *uiMsg = nil;
    __weak typeof(self) weakSelf = self;
    for (uiMsg in _uiMsgs) {
        if ([uiMsg.msgID isEqualToString:msgId]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger index = [weakSelf.uiMsgs indexOfObject:uiMsg];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });
            break;
        }
    }
}

- (void)didRecvMessageModified:(NSNotification *)notification
{
    V2TIMMessage *imMsg = notification.object;
    if (imMsg == nil || ![imMsg isKindOfClass:V2TIMMessage.class]) {
        return;
    }
    
    TUIMessageCellData *msg = nil;
    for (msg in _uiMsgs) {
        if ([msg.msgID isEqualToString:imMsg.msgID]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self revokeMsg:msg];
            });
            break;
        }
    }
    if (msg == nil) {
        return;
    }
    
    NSInteger index = [_uiMsgs indexOfObject:msg];
    if (index == NSNotFound) {
        return;
    }
    
    // 取 lastObject, 过滤掉内部生成的 dateMsg
    TUIMessageCellData *replacedCellData = [self transUIMsgFromIMMsg:@[imMsg]].lastObject;
    if (replacedCellData == nil) {
        return;
    }
    
    [_uiMsgs removeObject:msg];
    if (index < self.heightCache.count) {
        [self.heightCache replaceObjectAtIndex:index withObject:@(0)];
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [_uiMsgs insertObject:replacedCellData atIndex:index];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs
{
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = msgs.count - 1; k >= 0; --k) {
        V2TIMMessage *msg = msgs[k];
        if (![msg.userID isEqualToString:self.conversationData.userID] && ![msg.groupID isEqualToString:self.conversationData.groupID]) {
            continue;
        }
        // 时间信息
        TUISystemMessageCellData *dateMsg = [self transSystemMsgFromDate:msg.timestamp];
        
        // 撤回的消息
        if(msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED){
            TUISystemMessageCellData *revoke = [msg revokeCellData];
            if(revoke) {
                if (dateMsg) {
                    _msgForDate = msg;
                    [uiMsgs addObject:dateMsg];
                }
                [uiMsgs addObject:revoke];
            }
            continue;
        }
        // 外部自定义的消息
        if ([self.delegate respondsToSelector:@selector(messageController:onNewMessage:)]) {
            TUIMessageCellData *data = [self.delegate messageController:self onNewMessage:msg];
            if (data) {
                
                data.innerMessage = msg;
                data.msgID = msg.msgID;
                data.direction = msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
                data.identifier = msg.sender;
                data.name = data.identifier;
                if (msg.nameCard.length > 0) {
                    data.name = msg.nameCard;
                } else if (msg.friendRemark.length > 0) {
                    data.name = msg.friendRemark;
                } else if (msg.nickName.length > 0){
                    data.name = msg.nickName;
                }
                data.avatarUrl = [NSURL URLWithString:msg.faceURL];
                switch (msg.status) {
                    case V2TIM_MSG_STATUS_SEND_SUCC:
                        data.status = Msg_Status_Succ;
                        break;
                    case V2TIM_MSG_STATUS_SEND_FAIL:
                        data.status = Msg_Status_Fail;
                        break;
                    case V2TIM_MSG_STATUS_SENDING:
                        data.status = Msg_Status_Sending_2;
                        break;
                    default:
                        break;
                }
                
                if (dateMsg) {
                    _msgForDate = msg;
                    [uiMsgs addObject:dateMsg];
                }
                [uiMsgs addObject:data];
                continue;
            }
        }
        TUIMessageCellData *data = [msg cellData];
        if(msg.groupID.length > 0 && !msg.isSelf
           && ![data isKindOfClass:[TUISystemMessageCellData class]]){
            data.showName = YES;
        }
        if(data) {
            if (dateMsg) {
                _msgForDate = msg;
                [uiMsgs addObject:dateMsg];
            }
            data.innerMessage = msg;
            data.msgID = msg.msgID;
            data.direction = msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
            data.identifier = msg.sender;
            data.name = data.identifier;
            if (msg.nameCard.length > 0) {
                data.name = msg.nameCard;
            } else if (msg.friendRemark.length > 0) {
                data.name = msg.friendRemark;
            } else if (msg.nickName.length > 0){
                data.name = msg.nickName;
            }
            data.avatarUrl = [NSURL URLWithString:msg.faceURL];
            switch (msg.status) {
                case V2TIM_MSG_STATUS_SEND_SUCC:
                    data.status = Msg_Status_Succ;
                    break;
                case V2TIM_MSG_STATUS_SEND_FAIL:
                    data.status = Msg_Status_Fail;
                    break;
                case V2TIM_MSG_STATUS_SENDING:
                    data.status = Msg_Status_Sending_2;
                    break;
                default:
                    break;
            }
            [uiMsgs addObject:data];
        }
    }
    return uiMsgs;
}
#pragma mark - Table view data source

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isScrollBottom == NO) {
        [self scrollToBottom:NO];
        if (indexPath.row == _uiMsgs.count-1) {
            _isScrollBottom = YES;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if(_heightCache.count > indexPath.row){
        height = [_heightCache[indexPath.row] floatValue];
    }
    if (height) {
        return height;
    }
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
    height = [data heightOfWidth:Screen_Width];
    [_heightCache insertObject:[NSNumber numberWithFloat:height] atIndex:indexPath.row];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
    data.showCheckBox = self.showCheckBox && [self supportCheckBox:data];
    TUIMessageCell *cell = nil;
    if ([self.delegate respondsToSelector:@selector(messageController:onShowMessageData:)]) {
        cell = [self.delegate messageController:self onShowMessageData:data];
        if (cell) {
            cell.delegate = self;
            return cell;
        }
    }
    if (!data.reuseId) {
        if([data isKindOfClass:[TUITextMessageCellData class]]) {
            data.reuseId = TTextMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIFaceMessageCellData class]]) {
            data.reuseId = TFaceMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIImageMessageCellData class]]) {
            data.reuseId = TImageMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIVideoMessageCellData class]]) {
            data.reuseId = TVideoMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIVoiceMessageCellData class]]) {
            data.reuseId = TVoiceMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIFileMessageCellData class]]) {
            data.reuseId = TFileMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIJoinGroupMessageCellData class]]){//入群小灰条对应的数据源
            data.reuseId = TJoinGroupMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUISystemMessageCellData class]]) {
            data.reuseId = TSystemMessageCell_ReuseId;
        }
        else if ([data isKindOfClass:[TUIMergeMessageCellData class]]) {
            data.reuseId = TRelayMessageCell_ReuserId;
        }
        else {
            NSAssert(NO, @"无法解析当前cell");
            return nil;
        }
    }
    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    //对于入群小灰条，需要进一步设置其委托。
    if([cell isKindOfClass:[TUIJoinGroupMessageCell class]]){
        TUIJoinGroupMessageCell *joinCell = (TUIJoinGroupMessageCell *)cell;
        joinCell.joinGroupDelegate = self;
        cell = joinCell;
    }
    cell.delegate = self;
    [cell fillWithData:_uiMsgs[indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)scrollToBottom:(BOOL)animate
{
    if (_uiMsgs.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animate];
    }
}

- (void)didTapViewController
{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapInMessageController:)]){
        [_delegate didTapInMessageController:self];
    }
}

- (void)sendMessage:(TUIMessageCellData *)msg
{
    [self.tableView beginUpdates];
    V2TIMMessage *imMsg = msg.innerMessage;
    TUIMessageCellData *dateMsg = nil;
    if (msg.status == Msg_Status_Init)
    {
        //新消息
        if (!imMsg) {
            imMsg = [self transIMMsgFromUIMsg:msg];
        }
        dateMsg = [self transSystemMsgFromDate:imMsg.timestamp];

    } else if (imMsg) {
        //重发
        dateMsg = [self transSystemMsgFromDate:[NSDate date]];
        NSInteger row = [_uiMsgs indexOfObject:msg];
        [_heightCache removeObjectAtIndex:row];
        [_uiMsgs removeObjectAtIndex:row];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView endUpdates];
        NSLog(@"Unknown message state");
        return;
    }
    @weakify(self)

    imMsg.isExcludedFromUnreadCount = [TUIKit sharedInstance].config.isExcludedFromUnreadCount;
    imMsg.isExcludedFromLastMessage = [TUIKit sharedInstance].config.isExcludedFromLastMessage;
    
    // 设置离线推送
    V2TIMOfflinePushInfo *pushInfo = [[V2TIMOfflinePushInfo alloc] init];
    BOOL isGroup = self.conversationData.groupID.length > 0;
    NSString *senderId = isGroup ? (self.conversationData.groupID) : (TUIKit.sharedInstance.userID);
    senderId = senderId?:@"";
    NSString *nickName = isGroup ? (self.conversationData.title) : (TUIKit.sharedInstance.nickName?:TUIKit.sharedInstance.userID);
    nickName = nickName ?: @"";
    NSDictionary *ext = @{
        @"entity": @{
                @"action": @1,
                @"content": imMsg.getDisplayString?:@"",
                @"sender": senderId,
                @"nickname": nickName,
                @"faceUrl": TUIKit.sharedInstance.faceUrl?:@"",
                @"chatType": isGroup?@(V2TIM_GROUP):@(V2TIM_C2C)
        }
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:ext options:NSJSONWritingPrettyPrinted error:nil];
    pushInfo.ext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    pushInfo.AndroidOPPOChannelID = @"tuikit";
    NSString *msgID = [[V2TIMManager sharedInstance] sendMessage:imMsg
                                                        receiver:self.conversationData.userID
                                                         groupID:self.conversationData.groupID
                                                        priority:V2TIM_PRIORITY_NORMAL
                                                  onlineUserOnly:NO
                                                 offlinePushInfo:pushInfo
                                                        progress:^(uint32_t progress) {
        @strongify(self)
        for (TUIMessageCellData *uiMsg in self.uiMsgs) {
            if ([uiMsg.innerMessage.msgID isEqualToString:imMsg.msgID]) {
                if([uiMsg isKindOfClass:[TUIImageMessageCellData class]]){
                    TUIImageMessageCellData *data = (TUIImageMessageCellData *)uiMsg;
                    data.uploadProgress = progress;
                }
                else if([uiMsg isKindOfClass:[TUIVideoMessageCellData class]]){
                    TUIVideoMessageCellData *data = (TUIVideoMessageCellData *)uiMsg;
                    data.uploadProgress = progress;
                }
                else if([uiMsg isKindOfClass:[TUIFileMessageCellData class]]){
                    TUIFileMessageCellData *data = (TUIFileMessageCellData *)uiMsg;
                    data.uploadProgress = progress;
                }
            }
        }
    } succ:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeMsg:msg status:Msg_Status_Succ];
        });
    } fail:^(int code, NSString *desc) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [THelper makeToastError:code msg:desc];
            [self changeMsg:msg status:Msg_Status_Fail];
        });
    }];
    
    // 展示 UI 界面
    msg.status = Msg_Status_Sending;
    msg.name = [msg.innerMessage getShowName];
    msg.avatarUrl = [NSURL URLWithString:[msg.innerMessage faceURL]];
    msg.msgID = msgID;
    if(dateMsg){
        _msgForDate = imMsg;
        [_uiMsgs addObject:dateMsg];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    [_uiMsgs addObject:msg];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self scrollToBottom:YES];

    int delay = 1;
    if([msg isKindOfClass:[TUIImageMessageCellData class]]){
        delay = 0;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if(msg.status == Msg_Status_Sending){
            [self changeMsg:msg status:Msg_Status_Sending_2];
        }
    });
}

- (void)changeMsg:(TUIMessageCellData *)msg status:(TMsgStatus)status
{
    msg.status = status;
    NSInteger index = [_uiMsgs indexOfObject:msg];
    if ([self.tableView numberOfRowsInSection:0] > index) {
        TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell fillWithData:msg];
    } else {
        NSLog(@"缺少cell");
    }
}

- (V2TIMMessage *)transIMMsgFromUIMsg:(TUIMessageCellData *)data
{
    V2TIMMessage *msg = nil;
    if([data isKindOfClass:[TUITextMessageCellData class]]){
        TUITextMessageCellData *text = (TUITextMessageCellData *)data;
        if (text.atUserList.count > 0) {
            msg = [[V2TIMManager sharedInstance] createTextAtMessage:text.content atUserList:text.atUserList];
        } else {
            msg = [[V2TIMManager sharedInstance] createTextMessage:text.content];
        }
    }
    else if([data isKindOfClass:[TUIFaceMessageCellData class]]){
        TUIFaceMessageCellData *image = (TUIFaceMessageCellData *)data;
        msg = [[V2TIMManager sharedInstance] createFaceMessage:(int)image.groupIndex data:[image.faceName dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else if([data isKindOfClass:[TUIImageMessageCellData class]]){
        TUIImageMessageCellData *uiImage = (TUIImageMessageCellData *)data;
        msg = [[V2TIMManager sharedInstance] createImageMessage:uiImage.path];
    }
    else if([data isKindOfClass:[TUIVideoMessageCellData class]]){
        TUIVideoMessageCellData *uiVideo = (TUIVideoMessageCellData *)data;
        msg = [[V2TIMManager sharedInstance] createVideoMessage:uiVideo.videoPath type:uiVideo.videoItem.type duration:(int)uiVideo.videoItem.duration snapshotPath:uiVideo.snapshotPath];
    }
    else if([data isKindOfClass:[TUIVoiceMessageCellData class]]){
        TUIVoiceMessageCellData *uiSound = (TUIVoiceMessageCellData *)data;
        msg = [[V2TIMManager sharedInstance] createSoundMessage:uiSound.path duration:uiSound.duration];
    }
    else if([data isKindOfClass:[TUIFileMessageCellData class]]){
        TUIFileMessageCellData *uiFile = (TUIFileMessageCellData *)data;
        msg = [[V2TIMManager sharedInstance] createFileMessage:uiFile.path fileName:uiFile.fileName];
    }
    data.innerMessage = msg;
    return msg;

}
- (TUISystemMessageCellData *)transSystemMsgFromDate:(NSDate *)date
{
    if(_msgForDate == nil || fabs([date timeIntervalSinceDate:_msgForDate.timestamp]) > MAX_MESSAGE_SEP_DLAY){
        TUISystemMessageCellData *system = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
        system.content = [date tk_messageString];
        system.reuseId = TSystemMessageCell_ReuseId;
        return system;
    }
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!_noMoreMsg && scrollView.contentOffset.y <= TMessageController_Header_Height){
        if(!_indicatorView.isAnimating){
            [_indicatorView startAnimating];
        }
    }
    else{
        if(_indicatorView.isAnimating){
            [_indicatorView stopAnimating];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y <= TMessageController_Header_Height){
        [self loadMessage];
    }
}

#pragma mark - message cell delegate

- (void)onSelectMessage:(TUIMessageCell *)cell
{
    if (self.showCheckBox) {
        // 如果是多选
        TUIMessageCellData *data = (TUIMessageCellData *)cell.data;
        data.selected = !data.selected;
        [self.tableView reloadData];
        return;
    }
    
    if([cell isKindOfClass:[TUIVoiceMessageCell class]]){
        [self playVoiceMessage:(TUIVoiceMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIImageMessageCell class]]) {
        [self showImageMessage:(TUIImageMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIVideoMessageCell class]]) {
        [self showVideoMessage:(TUIVideoMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIFileMessageCell class]]) {
        [self showFileMessage:(TUIFileMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIMergeMessageCell class]]) {
        [self showRelayMessage:(TUIMergeMessageCell *)cell];
    }
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:self onSelectMessageContent:cell];
    }
}

- (void)onLongPressMessage:(TUIMessageCell *)cell
{
    TUIMessageCellData *data = cell.messageData;
    if ([data isKindOfClass:[TUISystemMessageCellData class]])
        return; // 系统消息不响应

    NSMutableArray *items = [NSMutableArray array];
    if ([data isKindOfClass:[TUITextMessageCellData class]]) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:TUILocalizableString(Copy) action:@selector(onCopyMsg:)]];
    }

    [items addObject:[[UIMenuItem alloc] initWithTitle:TUILocalizableString(Delete) action:@selector(onDelete:)]];
    V2TIMMessage *imMsg = data.innerMessage;
    if(imMsg){
        if([imMsg isSelf] && [[NSDate date] timeIntervalSinceDate:imMsg.timestamp] < 2 * 60 && (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC)){
            [items addObject:[[UIMenuItem alloc] initWithTitle:TUILocalizableString(Revoke) action:@selector(onRevoke:)]];
        }
    }
    if(imMsg.status == V2TIM_MSG_STATUS_SEND_FAIL){
        [items addObject:[[UIMenuItem alloc] initWithTitle:TUILocalizableString(Resend) action:@selector(onReSend:)]];
    }

    [items addObject:[[UIMenuItem alloc] initWithTitle:TUILocalizableString(Multiple) action:@selector(onMulitSelect:)]];
    if (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:TUILocalizableString(Forward) action:@selector(onRelay:)]];
    }

    BOOL isFirstResponder = NO;
    if(_delegate && [_delegate respondsToSelector:@selector(messageController:willShowMenuInCell:)]){
        isFirstResponder = [_delegate messageController:self willShowMenuInCell:cell];
    }
    if(isFirstResponder){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    else{
        [self becomeFirstResponder];
    }
    UIMenuController *controller = [UIMenuController sharedMenuController];
    controller.menuItems = items;
    _menuUIMsg = data;
    [controller setTargetRect:cell.container.bounds inView:cell.container];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [controller setMenuVisible:YES animated:YES];
    });
}

- (void)onRetryMessage:(TUIMessageCell *)cell
{
    _reSendUIMsg = cell.messageData;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TUILocalizableString(TUIKitTipsConfirmResendMessage) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Re-send) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendMessage:self.reSendUIMsg];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Cancel) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)onSelectMessageAvatar:(TUIMessageCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageAvatar:)]) {
        [self.delegate messageController:self onSelectMessageAvatar:cell];
    }
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(onDelete:) ||
        action == @selector(onRevoke:) ||
        action == @selector(onReSend:) ||
        action == @selector(onCopyMsg:) ||
        action == @selector(onMulitSelect:) ||
        action == @selector(onRelay:)){
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)onDelete:(id)sender
{
    V2TIMMessage *imMsg = _menuUIMsg.innerMessage;
    if(imMsg == nil){
        return;
    }
    NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
    [msgList addObject:imMsg];
    @weakify(self)
    [[V2TIMManager sharedInstance] deleteMessages:msgList succ:^{
        @strongify(self)
        [self.tableView beginUpdates];
        NSInteger index = [self.uiMsgs indexOfObject:self.menuUIMsg];
        [self.uiMsgs removeObjectAtIndex:index];
        [self.heightCache removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

        [self.tableView endUpdates];;
    } fail:^(int code, NSString *msg) {
        NSLog(@"remove msg failed!");
    }];
}

- (void)menuDidHide:(NSNotification*)notification
{
    if(_delegate && [_delegate respondsToSelector:@selector(didHideMenuInMessageController:)]){
        [_delegate didHideMenuInMessageController:self];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)onCopyMsg:(id)sender
{
    if ([_menuUIMsg isKindOfClass:[TUITextMessageCellData class]]) {
        TUITextMessageCellData *txtMsg = (TUITextMessageCellData *)_menuUIMsg;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = txtMsg.content;
    }
}

- (void)onRevoke:(id)sender
{
    @weakify(self)
    [[V2TIMManager sharedInstance] revokeMessage:_menuUIMsg.innerMessage succ:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self revokeMsg:self.menuUIMsg];
        });
    } fail:^(int code, NSString *msg) {
        NSLog(@"revoke msg failed");
    }];
}

- (void)onReSend:(id)sender
{
    [self sendMessage:_menuUIMsg];
}

- (void)onMulitSelect:(id)sender
{
    // 显示多选框
    [self enableMultiSelectedMode:YES];
    
    // 默认选中当前点击的cell
    self.menuUIMsg.selected = YES;
    [self.tableView beginUpdates];
    NSInteger index = [self.uiMsgs indexOfObject:self.menuUIMsg];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onSelectMessageMenu:withData:)]) {
        [_delegate messageController:self onSelectMessageMenu:0 withData:_menuUIMsg];
    }
}

- (void)onRelay:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onSelectMessageMenu:withData:)]) {
        [_delegate messageController:self onSelectMessageMenu:1 withData:_menuUIMsg];
    }
}

// 是否支持多选
- (BOOL)supportCheckBox:(TUIMessageCellData *)data
{
    // 过滤掉不支持多选
    if ([data isKindOfClass:TUISystemMessageCellData.class]) {
        return NO;
    }
    // 默认都支持多选
    return YES;
}

// 是否支持转发
- (BOOL)supportRelay:(TUIMessageCellData *)data
{
    // 过滤掉不支持转发
    if ([data isKindOfClass: TUIVoiceMessageCellData.class]) {
        return NO;
    }
    // 默认都支持转发
    return YES;
}

- (void)enableMultiSelectedMode:(BOOL)enable
{
    self.showCheckBox = enable;
    if (!enable) {
        for (TUIMessageCellData *cellData in self.uiMsgs) {
            cellData.selected = NO;
        }
    }
    [self.tableView reloadData];
}

- (NSArray<TUIMessageCellData *> *)multiSelectedResult:(TUIMultiResultOption)option
{
    NSMutableArray *arrayM = [NSMutableArray array];
    if (!self.showCheckBox) {
        return [NSArray arrayWithArray:arrayM];
    }
    BOOL filterUnsupported = option & TUIMultiResultOptionFiterUnsupportRelay;
    for (TUIMessageCellData *data in self.uiMsgs) {
        if (data.selected) {
            if (filterUnsupported && ![self supportRelay:data]) {
                // 过滤掉不支持转发
                continue;
            }
            [arrayM addObject:data];
        }
    }
    return [NSArray arrayWithArray:arrayM];
}

- (void)deleteMessages:(NSArray<TUIMessageCellData *> *)uiMsgs
{
    NSMutableArray *uiMsgList = [NSMutableArray array];
    NSMutableArray *msgList = [NSMutableArray array];
    for (TUIMessageCellData *uiMsg in uiMsgs) {
        if ([self.uiMsgs containsObject:uiMsg]) {
            [uiMsgList addObject:uiMsg];
            [msgList addObject:uiMsg.innerMessage];
        }
    }
    
    if (msgList.count == 0) {
        return;
    }
    
    @weakify(self)
    [[V2TIMManager sharedInstance] deleteMessages:msgList succ:^{
        @strongify(self)
        for (TUIMessageCellData *uiMsg in uiMsgList) {
            [self.tableView beginUpdates];
            NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
            [self.uiMsgs removeObjectAtIndex:index];
            [self.heightCache removeObjectAtIndex:index];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];;
        }
    } fail:^(int code, NSString *msg) {
        NSLog(@"remove msg failed!");
    }];
}

- (void)revokeMsg:(TUIMessageCellData *)msg
{
    V2TIMMessage *imMsg = msg.innerMessage;
    if(imMsg == nil){
        return;
    }
    NSInteger index = [_uiMsgs indexOfObject:msg];
    if (index == NSNotFound)
        return;
    [_uiMsgs removeObject:msg];
    if (index < self.heightCache.count) {
        [self.heightCache replaceObjectAtIndex:index withObject:@(0)];
    }

    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    TUISystemMessageCellData *data = [imMsg revokeCellData];
    [_uiMsgs insertObject:data atIndex:index];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)playVoiceMessage:(TUIVoiceMessageCell *)cell
{
    for (NSInteger index = 0; index < _uiMsgs.count; ++index) {
        if(![_uiMsgs[index] isKindOfClass:[TUIVoiceMessageCellData class]]){
            continue;
        }
        TUIVoiceMessageCellData *uiMsg = _uiMsgs[index];
        if(uiMsg == cell.voiceData){
            [uiMsg playVoiceMessage];
            cell.voiceReadPoint.hidden = YES;
        }
        else{
            [uiMsg stopVoiceMessage];
        }
    }
}

- (void)showImageMessage:(TUIImageMessageCell *)cell
{
    TUIImageViewController *image = [[TUIImageViewController alloc] init];
    image.data = [cell imageData];
    [self.navigationController pushViewController:image animated:YES];
}

- (void)showVideoMessage:(TUIVideoMessageCell *)cell
{
    TUIVideoViewController *video = [[TUIVideoViewController alloc] init];
    video.data = [cell videoData];
    [self.navigationController pushViewController:video animated:YES];
}

- (void)showFileMessage:(TUIFileMessageCell *)cell
{
    TUIFileViewController *file = [[TUIFileViewController alloc] init];
    file.data = [cell fileData];
    [self.navigationController pushViewController:file animated:YES];
}

- (void)showRelayMessage:(TUIMergeMessageCell *)cell
{
    TUIMergeMessageListController *relayVc = [[TUIMergeMessageListController alloc] init];
    relayVc.delegate = self.delegate;
    relayVc.mergerElem = cell.relayData.mergerElem;
    __weak typeof(self) weakSelf = self;
    relayVc.willCloseCallback = ^(){
        // 刷新下，主要是更新下全局的UI
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:relayVc animated:YES];
}

- (void)didTapOnRestNameLabel:(TUIJoinGroupMessageCell *)cell withIndex:(NSInteger)index{
    [self jumpToProfileController:cell.joinData.userIDList[index]];
}
- (void)jumpToProfileController:(NSString *)memberId{
    //此处实现点击入群的姓名 Label 后，跳转到对应的消息界面。此处的跳转逻辑和点击头像的跳转逻辑相同。
    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendsInfo:@[memberId] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
        V2TIMFriendInfoResult *result = resultList.firstObject;
        id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
        if ([vc isKindOfClass:[UIViewController class]]) {
            vc.friendProfile = result.friendInfo;
            [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
            return;
        }
    } fail:^(int code, NSString *msg) {
        NSLog(@"拉取好友资料失败");
    }];

    [[V2TIMManager sharedInstance] getUsersInfo:@[memberId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        @strongify(self)
        V2TIMUserFullInfo *userFullInfo = infoList.firstObject;
        id<TUIUserProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
        if (userFullInfo && [vc isKindOfClass:[UIViewController class]]) {
            vc.userFullInfo = userFullInfo;
            vc.actionType = PCA_ADD_FRIEND;
            [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

//已读回执
- (void) didRecvMessageReceipts:(NSNotification *)noti{
    NSArray *receiptsArray = noti.object;
    if(!receiptsArray.count){
        NSLog(@"Receipt Data Error");
        return;
    }
    V2TIMMessageReceipt *receipt = receiptsArray[0];
    time_t receiptTime = receipt.timestamp;
    if(receipt.userID.length > 0 && [receipt.userID isEqualToString:self.conversationData.userID]){
        //性能优化
        for(int i = 0;i < _uiMsgs.count;i++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_uiMsgs.count - 1 - i inSection:0];
            TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            //通过回调时间戳判定当前的未读是否需要改为已读
            time_t msgTime = [cell.messageData.innerMessage.timestamp timeIntervalSince1970];
            if(msgTime <= receiptTime && ![cell.readReceiptLabel.text isEqualToString:TUILocalizableString(Read)]) {
                cell.readReceiptLabel.text = TUILocalizableString(Read);
            }
        }
    }
}

@end
