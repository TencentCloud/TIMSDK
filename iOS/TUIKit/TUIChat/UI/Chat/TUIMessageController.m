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
#import "TUIGroupLiveMessageCell.h"
#import "TUILinkCell.h"
#import "TUIReplyMessageCell.h"
#import "TUIReplyMessageCellData.h"
#import "TUIMessageDataProvider.h"
#import "TUIFaceView.h"
#import "TUIMediaView.h"
#import "TUIFileViewController.h"
#import "TUIMergeMessageListController.h"
#import "TUIChatDataProvider.h"
#import "TUIChatConversationModel.h"
#import "TUIMessageDataProvider+Call.h"
#import "TUIMessageDataProvider+Live.h"
#import "TUIChatPopMenu.h"
#import "TUIDefine.h"
#import "TUIConfig.h"
#import "TUITool.h"
#import "TUICore.h"
#import <UIKit/UIWindow.h>

@interface TUIMessageController () <TUIMessageCellDelegate,
TUIJoinGroupMessageCellDelegate,
TUIMessageDataProviderDataSource>

@property (nonatomic, strong) TUIMessageDataProvider *messageDataProvider;
@property (nonatomic, strong) TUIMessageCellData *menuUIMsg;
@property (nonatomic, strong) TUIMessageCellData *reSendUIMsg;
@property (nonatomic, strong) TUIChatConversationModel *conversationData;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL isInVC;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL showCheckBox;
@end

@implementation TUIMessageController

#pragma mark - Life Cycle
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
            [TUIMessageDataProvider markC2CMessageAsRead:userID succ:nil fail:nil];
        }
        NSString *groupID = self.conversationData.groupID;
        if (groupID.length > 0) {
            [TUIMessageDataProvider markGroupMessageAsRead:groupID succ:nil fail:nil];
        }
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    
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
    [self.tableView registerClass:[TUIGroupLiveMessageCell class] forCellReuseIdentifier:TGroupLiveMessageCell_ReuseId];
    [self.tableView registerClass:[TUIReplyMessageCell class] forCellReuseIdentifier:TReplyMessageCell_ReuseId];
    
    // 自定义消息注册 cell
    NSArray *customMessageInfo = [TUIMessageDataProvider getCustomMessageInfo];
    for (NSDictionary *messageInfo in customMessageInfo) {
        NSString *bussinessID = messageInfo[BussinessID];
        NSString *cellName = messageInfo[TMessageCell_Name];
        Class cls = NSClassFromString(cellName);
        if (cls && bussinessID) {
            [self.tableView registerClass:cls forCellReuseIdentifier:bussinessID];
        }
    }

    self.indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TMessageController_Header_Height)];
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.tableView.tableHeaderView = self.indicatorView;
}

- (void)setConversation:(TUIChatConversationModel *)conversationData {
    self.conversationData = conversationData;
    if (!self.messageDataProvider) {
        self.messageDataProvider = [[TUIMessageDataProvider alloc] initWithConversationModel:conversationData];
        self.messageDataProvider.dataSource = self;
    }
    [self loadMessage];
}

- (void)loadMessage
{
    if (self.messageDataProvider.isLoadingData || self.messageDataProvider.isNoMoreMsg) {
        return;
    }
    
    [self.messageDataProvider loadMessageSucceedBlock:^(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TUIMessageCellData *> * _Nonnull newMsgs) {
        if (isNoMoreMsg) {
            self.indicatorView.mm_h = 0;
        }
        if (newMsgs.count != 0) {
            
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
            
            if(isFirstLoad) {   // 第一次加载
                [self scrollToBottom:NO];
            } else {
                CGFloat visibleHeight = 0;
                for (NSInteger i = 0; i < newMsgs.count; ++i) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    visibleHeight += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                }
                if(isNoMoreMsg) {
                    visibleHeight -= TMessageController_Header_Height;
                }
                [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentOffset.y + visibleHeight, self.tableView.frame.size.width, self.tableView.frame.size.height) animated:NO];
            }
        }
        [self.indicatorView stopAnimating];
    } FailBlock:^(int code, NSString *desc) {
        [TUITool makeToastError:code msg:desc];
    }];
}

#pragma mark - TUIMessageDataProviderDataSource
- (void)dataProviderDataSourceWillChange:(TUIMessageDataProvider *)dataProvider {
    [self.tableView beginUpdates];
}
- (void)dataProviderDataSourceChange:(TUIMessageDataProvider *)dataProvider
                            withType:(TUIMessageDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation {
    switch (type) {
        case TUIMessageDataProviderDataSourceChangeTypeInsert:
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:animation? UITableViewRowAnimationFade:UITableViewRowAnimationNone];
            break;
        case TUIMessageDataProviderDataSourceChangeTypeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:animation? UITableViewRowAnimationFade:UITableViewRowAnimationNone];
            break;
        case TUIMessageDataProviderDataSourceChangeTypeReload:
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:animation? UITableViewRowAnimationFade:UITableViewRowAnimationNone];
            break;
        default:
            break;
    }
}
- (void)dataProviderDataSourceDidChange:(TUIMessageDataProvider *)dataProvider {
    [self.tableView endUpdates];
}

- (nullable TUIMessageCellData *)dataProvider:(TUIMessageDataProvider *)dataProvider
               CustomCellDataFromNewIMMessage:(V2TIMMessage *)msg {
    if (![msg.userID isEqualToString:self.conversationData.userID]
        && ![msg.groupID isEqualToString:self.conversationData.groupID]) {
        return nil;
    }
    
    // 撤回消息, 不可自定义
    if (msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        return nil;
    }
    
    // 自定义消息
    if ([self.delegate respondsToSelector:@selector(messageController:onNewMessage:)]) {
        TUIMessageCellData *customCellData = [self.delegate messageController:self onNewMessage:msg];
        if (customCellData) {
            customCellData.innerMessage = msg;
            return customCellData;
        }
    }
    return nil;
}

- (void)dataProvider:(TUIMessageDataProvider *)dataProvider
ReceiveReadMsgWithUserID:(NSString *)userId
                Time:(time_t)timestamp {

    if (userId.length > 0 && [userId isEqualToString:self.conversationData.userID]) {
        //性能优化
        for (int i = 0; i < self.messageDataProvider.uiMsgs.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageDataProvider.uiMsgs.count - 1 - i inSection:0];
            TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            //通过回调时间戳判定当前的未读是否需要改为已读
            time_t msgTime = [cell.messageData.innerMessage.timestamp timeIntervalSince1970];
            if (msgTime <= timestamp
                && ![cell.readReceiptLabel.text isEqualToString:TUIKitLocalizableString(Read)]) {
                cell.readReceiptLabel.text = TUIKitLocalizableString(Read);
            }
        }
    }
}

- (void)dataProvider:(TUIMessageDataProvider *)dataProvider
     ReceiveNewUIMsg:(TUIMessageCellData *)uiMsg {
    // 查看历史消息的时候根据当前 contentOffset 判断是否需要滑动到底部
    if (self.tableView.contentSize.height - self.tableView.contentOffset.y < Screen_Height * 1.5) {
        [self scrollToBottom:YES];
    }
    [self limitReadReport];
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

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageDataProvider.uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messageDataProvider getCellDataHeightAtIndex:indexPath.row Width:Screen_Width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIMessageCellData *data = self.messageDataProvider.uiMsgs[indexPath.row];
    data.showCheckBox = self.showCheckBox && [self supportCheckBox:data];
    TUIMessageCell *cell = nil;
    // 外部自定义消息
    if ([self.delegate respondsToSelector:@selector(messageController:onShowMessageData:)]) {
        cell = [self.delegate messageController:self onShowMessageData:data];
        if (cell) {
            cell.delegate = self;
            return cell;
        }
    }
    
    if (!data.reuseId) {
        NSAssert(NO, @"无法解析当前cell");
        return nil;
    }
    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    cell.delegate = self;
    [cell fillWithData:data];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIMessageCell *uiMsg = (TUIMessageCell *)cell;
    if ([uiMsg isKindOfClass:TUIMessageCell.class]
        && [self.delegate respondsToSelector:@selector(messageController:willDisplayCell:withData:)]) {
        [self.delegate messageController:self willDisplayCell:uiMsg withData:uiMsg.messageData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Event Response
- (void)scrollToBottom:(BOOL)animate
{
    if (self.messageDataProvider.uiMsgs.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageDataProvider.uiMsgs.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animate];
    }
}

- (void)didTapViewController
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didTapInMessageController:)]) {
        [self.delegate didTapInMessageController:self];
    }
}

- (void)sendUIMessage:(TUIMessageCellData *)cellData {
    @weakify(self);
    [self.messageDataProvider sendUIMsg:cellData
                         toConversation:self.conversationData
                          willSendBlock:^(BOOL isReSend, TUIMessageCellData * _Nonnull dateUIMsg) {
        @strongify(self);
        [self scrollToBottom:YES];

        int delay = 1;
        if ([cellData isKindOfClass:[TUIImageMessageCellData class]]) {
            delay = 0;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (cellData.status == Msg_Status_Sending) {
                [self changeMsg:cellData status:Msg_Status_Sending_2];
            }
        });
        
    } SuccBlock:^{
        @strongify(self);
        [self changeMsg:cellData status:Msg_Status_Succ];
    } FailBlock:^(int code, NSString *desc) {
        @strongify(self)
        [TUITool makeToastError:code msg:desc];
        [self changeMsg:cellData status:Msg_Status_Fail];
    }];
}

- (void)sendMessage:(V2TIMMessage *)message
{
    TUIMessageCellData *cellData = nil;
    if (message.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        cellData = [self.delegate messageController:self onNewMessage:message];
        cellData.innerMessage = message;
    }
    if (!cellData) {
        cellData = [TUIMessageDataProvider getCellData:message];
    }
    if (cellData) {
        [self sendUIMessage:cellData];
    }
}

/// 更新发送的状态
- (void)changeMsg:(TUIMessageCellData *)msg status:(TMsgStatus)status
{
    msg.status = status;
    NSInteger index = [self.messageDataProvider.uiMsgs indexOfObject:msg];
    if ([self.tableView numberOfRowsInSection:0] > index) {
        TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell fillWithData:msg];
    } else {
        NSLog(@"缺少cell");
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 下拉转圈
    if (!self.messageDataProvider.isNoMoreMsg
       && scrollView.contentOffset.y <= TMessageController_Header_Height) {
        if(!self.indicatorView.isAnimating){
            [self.indicatorView startAnimating];
        }
    }
    else {
        if(self.indicatorView.isAnimating){
            [self.indicatorView stopAnimating];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= TMessageController_Header_Height) {
        [self loadMessage];
    }
}

#pragma mark - TUIMessageCellDelegate

- (void)onSelectMessage:(TUIMessageCell *)cell
{
    if (self.showCheckBox) {
        // 如果是多选
        TUIMessageCellData *data = (TUIMessageCellData *)cell.data;
        data.selected = !data.selected;
        [self.tableView reloadData];
        return;
    }
    
    if ([cell isKindOfClass:[TUITextMessageCell class]]) {
        [self clickTextMessage:(TUITextMessageCell *)cell];
    }
    else if ([cell isKindOfClass:[TUISystemMessageCell class]]) {
        [self clickSystemMessage:(TUISystemMessageCell *)cell];
    }
    else if ([cell isKindOfClass:[TUIVoiceMessageCell class]]) {
        [self playVoiceMessage:(TUIVoiceMessageCell *)cell];
    }
    else if ([cell isKindOfClass:[TUIImageMessageCell class]]) {
        [self showImageMessage:(TUIImageMessageCell *)cell];
    }
    else if ([cell isKindOfClass:[TUIVideoMessageCell class]]) {
        [self showVideoMessage:(TUIVideoMessageCell *)cell];
    }
    else if ([cell isKindOfClass:[TUIFileMessageCell class]]) {
        [self showFileMessage:(TUIFileMessageCell *)cell];
    }
    else if ([cell isKindOfClass:[TUIMergeMessageCell class]]) {
        [self showRelayMessage:(TUIMergeMessageCell *)cell];
    }
    else if ([cell isKindOfClass:[TUIGroupLiveMessageCell class]]) {
        [self showLiveMessage:(TUIGroupLiveMessageCell *)cell];
    }
    else if ([cell isKindOfClass:[TUILinkCell class]]) {
        [self showLinkMessage:(TUILinkCell *)cell];
    }
    else if ([cell isKindOfClass:TUIReplyMessageCell.class]) {
        [self showReplyMessage:(TUIReplyMessageCell *)cell];
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

    self.menuUIMsg = data;
    
    __weak typeof(self) weakSelf = self;
    TUIChatPopMenu *menu = [[TUIChatPopMenu alloc] init];
    if ([data isKindOfClass:[TUITextMessageCellData class]] || [data isKindOfClass:TUIReplyMessageCellData.class]) {
        [menu addAction:[[TUIChatPopMenuAction alloc] initWithTitle:TUIKitLocalizableString(Copy) image:[UIImage d_imageNamed:@"icon_copy" bundle:TUIChatBundle] callback:^{
            [weakSelf onCopyMsg:nil];
        }]];
    }
    
    [menu addAction:[[TUIChatPopMenuAction alloc] initWithTitle:TUIKitLocalizableString(Delete) image:[UIImage d_imageNamed:@"icon_delete" bundle:TUIChatBundle] callback:^{
        [weakSelf onDelete:nil];
    }]];
    
    V2TIMMessage *imMsg = data.innerMessage;
    if(imMsg){
        if([imMsg isSelf] && [[NSDate date] timeIntervalSinceDate:imMsg.timestamp] < 2 * 60 && (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC)){
            [menu addAction:[[TUIChatPopMenuAction alloc] initWithTitle:TUIKitLocalizableString(Revoke) image:[UIImage d_imageNamed:@"icon_recall" bundle:TUIChatBundle] callback:^{
                [weakSelf onRevoke:nil];
            }]];
        }
    }

    [menu addAction:[[TUIChatPopMenuAction alloc] initWithTitle:TUIKitLocalizableString(Multiple) image:[UIImage d_imageNamed:@"icon_multi" bundle:TUIChatBundle] callback:^{
        [weakSelf onMulitSelect:nil];
    }]];
    
    if (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC) {
        [menu addAction:[[TUIChatPopMenuAction alloc] initWithTitle:TUIKitLocalizableString(Forward) image:[UIImage d_imageNamed:@"icon_forward" bundle:TUIChatBundle] callback:^{
            [weakSelf onForward:nil];
        }]];
        [menu addAction:[[TUIChatPopMenuAction alloc] initWithTitle:TUIKitLocalizableString(Reply) image:[UIImage d_imageNamed:@"icon_quote" bundle:TUIChatBundle] callback:^{
            [weakSelf onReply:nil];
        }]];
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
    
    CGRect frame = [UIApplication.sharedApplication.keyWindow convertRect:cell.container.frame fromView:cell];
    [menu setArrawPosition:CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y - 5)
              adjustHeight:frame.size.height + 5];
    [menu showInView:self.tableView];
}

- (void)onLongSelectMessageAvatar:(TUIMessageCell *)cell {
    if(_delegate && [_delegate respondsToSelector:@selector(messageController:onLongSelectMessageAvatar:)]){
        [_delegate messageController:self onLongSelectMessageAvatar:cell];
    }
}

- (void)onRetryMessage:(TUIMessageCell *)cell
{
    _reSendUIMsg = cell.messageData;
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TUIKitLocalizableString(TUIKitTipsConfirmResendMessage) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Re-send) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf sendUIMessage:weakSelf.reSendUIMsg];
    }]] ;
    [alert addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

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
        action == @selector(onForward:) ||
        action == @selector(onReply:)){
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
    @weakify(self)
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:TUIKitLocalizableString(ConfirmDeleteMessage) preferredStyle:UIAlertControllerStyleActionSheet];
    [vc addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Delete) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        [self.messageDataProvider deleteUIMsgs:@[self.menuUIMsg] SuccBlock:nil FailBlock:^(int code, NSString *desc) {
            NSLog(@"remove msg failed!");
            NSAssert(NO, desc);
        }];
    }]];
    [vc addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:vc animated:YES completion:nil];
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
    NSString *content = @"";
    if ([_menuUIMsg isKindOfClass:[TUITextMessageCellData class]]) {
        TUITextMessageCellData *txtMsg = (TUITextMessageCellData *)_menuUIMsg;
        content = txtMsg.content;
    } else if ([_menuUIMsg isKindOfClass:TUIReplyMessageCellData.class]) {
        TUIReplyMessageCellData *replyMsg = (TUIReplyMessageCellData *)_menuUIMsg;
        content = replyMsg.content;
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = content;
    [TUITool makeToast:TUIKitLocalizableString(Copied)];
}

- (void)onRevoke:(id)sender
{
    [self.messageDataProvider revokeUIMsg:self.menuUIMsg SuccBlock:nil FailBlock:^(int code, NSString *desc) {
        NSAssert(NO, desc);
    }];
}

- (void)onReSend:(id)sender
{
    [self sendUIMessage:_menuUIMsg];
}

- (void)onMulitSelect:(id)sender
{
    // 显示多选框
    [self enableMultiSelectedMode:YES];
    
    // 默认选中当前点击的cell
    self.menuUIMsg.selected = YES;
    [self.tableView beginUpdates];
    NSInteger index = [self.messageDataProvider.uiMsgs indexOfObject:self.menuUIMsg];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onSelectMessageMenu:withData:)]) {
        [_delegate messageController:self onSelectMessageMenu:0 withData:_menuUIMsg];
    }
}

- (void)onForward:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onSelectMessageMenu:withData:)]) {
        [_delegate messageController:self onSelectMessageMenu:1 withData:_menuUIMsg];
    }
}

- (void)onReply:(id)sender
{
    // 消息回复
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onRelyMessage:)]) {
        [_delegate messageController:self onRelyMessage:self.menuUIMsg];
    }
}

// 是否支持多选
- (BOOL)supportCheckBox:(TUIMessageCellData *)data
{
    // TODO: 应该通过接口来判断, 不应该写死
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
    // TODO: 应该通过接口来判断, 不应该写死
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
        for (TUIMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
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
    for (TUIMessageCellData *data in self.messageDataProvider.uiMsgs) {
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
    [self.messageDataProvider deleteUIMsgs:uiMsgs SuccBlock:nil FailBlock:^(int code, NSString *desc) {
        NSLog(@"deleteMessages failed!");
        NSAssert(NO, desc);
    }];
}

- (void)clickTextMessage:(TUITextMessageCell *)cell
{
    V2TIMMessage *message = cell.messageData.innerMessage;
    if (0 == message.userID.length) {
        return;
    }
    NSInteger callType = 0;
    NSDictionary *param = nil;
    if ([TUIMessageDataProvider isCallMessage:message callTye:&callType]) {
        if (1 == callType) {
            param = @{
                TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey : @[message.userID],
                TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey : @"0"
            };
        } else if (2 == callType) {
            param = @{
                TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey : @[message.userID],
                TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey : @"1"
            };
        }
        if (param) {
            [TUICore callService:TUICore_TUICallingService
                          method:TUICore_TUICallingService_ShowCallingViewMethod
                           param:param];
        }
    }
}

- (void)clickSystemMessage:(TUISystemMessageCell *)cell
{
    TUISystemMessageCellData *data = (TUISystemMessageCellData *)cell.messageData;
    if (data.supportReEdit) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageController:onReEditMessage:)]) {
            [self.delegate messageController:self onReEditMessage:cell.messageData];
        }
    }
}

- (void)playVoiceMessage:(TUIVoiceMessageCell *)cell
{
    for (TUIMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
        if(![cellData isKindOfClass:[TUIVoiceMessageCellData class]]){
            continue;
        }
        TUIVoiceMessageCellData *voiceMsg = (TUIVoiceMessageCellData *)cellData;
        if (voiceMsg == cell.voiceData) {
            [voiceMsg playVoiceMessage];
            cell.voiceReadPoint.hidden = YES;
        } else {
            [voiceMsg stopVoiceMessage];
        }
    }
}

- (void)showImageMessage:(TUIImageMessageCell *)cell
{
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView *mediaView = [[TUIMediaView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)showVideoMessage:(TUIVideoMessageCell *)cell
{
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView *mediaView = [[TUIMediaView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
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

- (void)showLinkMessage:(TUILinkCell *)cell {
    TUILinkCellData *cellData = cell.customData;
    if (cellData.link) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cellData.link]];
    }
}

- (void)showReplyMessage:(TUIReplyMessageCell *)cell
{
}

- (void)showLiveMessage:(TUIGroupLiveMessageCell *)cell {
    TUIGroupLiveMessageCellData *celldata = cell.customData;
    NSDictionary *roomInfo = celldata.roomInfo;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kTUINotifyGroupLiveOnSelectMessage" object:nil userInfo:@{
        @"roomInfo": roomInfo,
        @"groupID": celldata.innerMessage.groupID?:@"",
        @"msgSender": self,
    }];
}


@end
