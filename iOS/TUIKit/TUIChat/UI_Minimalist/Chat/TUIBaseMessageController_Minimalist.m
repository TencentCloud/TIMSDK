//
//  TUIBaseMessageController.m
//  UIKit
//
//  Created by annidyfeng on 2019/7/1.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUIBaseMessageController_Minimalist.h"
#import "TUITextMessageCell_Minimalist.h"
#import <TIMCommon/TUISystemMessageCell.h>
#import "TUIVoiceMessageCell_Minimalist.h"
#import "TUIImageMessageCell_Minimalist.h"
#import "TUIFaceMessageCell_Minimalist.h"
#import "TUIVideoMessageCell_Minimalist.h"
#import "TUIFileMessageCell_Minimalist.h"
#import "TUIJoinGroupMessageCell_Minimalist.h"
#import "TUIMergeMessageCell_Minimalist.h"
#import "TUILinkCell_Minimalist.h"
#import "TUIReplyMessageCell_Minimalist.h"
#import "TUIReplyMessageCellData_Minimalist.h"
#import "TUIReferenceMessageCell_Minimalist.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUIFaceView.h"
#import "TUIMediaView_Minimalist.h"
#import "TUIFileViewController_Minimalist.h"
#import "TUIMergeMessageListController_Minimalist.h"
#import "TUIChatDataProvider_Minimalist.h"
#import "TUIChatConversationModel.h"
#import "TUIChatPopMenu.h"
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TIMConfig.h>
#import <TUICore/TUITool.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import <UIKit/UIWindow.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMessageReadViewController_Minimalist.h"
#import "TUIRepliesDetailViewController_Minimalist.h"
#import "TUIOrderCell_Minimalist.h"
#import "TUIChatPopContextRecentView.h"
#import "TUIChatPopContextController.h"
#import "TUIMessageProgressManager.h"
#import "TUIChatCallingDataProvider.h"
#import <TIMCommon/TIMPopActionProtocol.h>


@interface TUIBaseMessageController_Minimalist () <TUIMessageCellDelegate,
TUIJoinGroupMessageCellDelegate_Minimalist,
TUIMessageBaseDataProviderDataSource,
TUIMessageProgressManagerDelegate,
TIMPopActionProtocol, 
TUINotificationProtocol>

@property (nonatomic, strong) TUIMessageDataProvider_Minimalist *messageDataProvider;
@property (nonatomic, strong) TUIMessageCellData *menuUIMsg;
@property (nonatomic, strong) TUIMessageCellData *reSendUIMsg;
@property (nonatomic, strong) TUIChatConversationModel *conversationData;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL showCheckBox;
@property (nonatomic, assign) BOOL scrollingTriggeredByUser;
@property (nonatomic, assign) BOOL isAutoScrolledToBottom;
@property (nonatomic, strong) TUIChatPopContextController * popAlertController;
@end

@implementation TUIBaseMessageController_Minimalist

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    self.isActive = YES;
    [TUITool addUnsupportNotificationInVC:self];
    [TUIMessageProgressManager.shareManager addDelegate:self];
    
    [TUICore registerEvent:TUICore_TUITranslationNotify subKey:TUICore_TUITranslationNotify_WillForwardTranslationSubKey object:self];
    [TUICore registerEvent:TUICore_TUITranslationNotify subKey:TUICore_TUITranslationNotify_DidChangeTranslationSubKey object:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TUIMessageProgressManager.shareManager removeDelegate:self];
    [TUICore unRegisterEventByObject:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isInVC = YES;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self sendVisibleReadGroupMessages];
    [self limitReadReport];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isInVC = NO;
}

- (void)applicationBecomeActive
{
    self.isActive = YES;
    [self sendVisibleReadGroupMessages];
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
    /**
     * 解决触摸事件没有往下传递，导致手势和 collectionView didselect 冲突的问题
     * Solve the problem that the touch event is not passed down, causing the gesture to conflict with the collectionView didselect
     */
    tap.cancelsTouchesInView = NO ;
    [self.view addGestureRecognizer:tap];
    
    self.tableView.scrollsToTop = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");

    [self.tableView registerClass:[TUITextMessageCell_Minimalist class] forCellReuseIdentifier:TTextMessageCell_ReuseId];
    [self.tableView registerClass:[TUIVoiceMessageCell_Minimalist class] forCellReuseIdentifier:TVoiceMessageCell_ReuseId];
    [self.tableView registerClass:[TUIImageMessageCell_Minimalist class] forCellReuseIdentifier:TImageMessageCell_ReuseId];
    [self.tableView registerClass:[TUISystemMessageCell class] forCellReuseIdentifier:TSystemMessageCell_ReuseId];
    [self.tableView registerClass:[TUIFaceMessageCell_Minimalist class] forCellReuseIdentifier:TFaceMessageCell_ReuseId];
    [self.tableView registerClass:[TUIVideoMessageCell_Minimalist class] forCellReuseIdentifier:TVideoMessageCell_ReuseId];
    [self.tableView registerClass:[TUIFileMessageCell_Minimalist class] forCellReuseIdentifier:TFileMessageCell_ReuseId];
    [self.tableView registerClass:[TUIJoinGroupMessageCell_Minimalist class] forCellReuseIdentifier:TJoinGroupMessageCell_ReuseId];
    [self.tableView registerClass:[TUIMergeMessageCell_Minimalist class] forCellReuseIdentifier:TRelayMessageCell_ReuserId];
    [self.tableView registerClass:[TUIReplyMessageCell_Minimalist class] forCellReuseIdentifier:TReplyMessageCell_ReuseId];
    [self.tableView registerClass:[TUIReferenceMessageCell_Minimalist class] forCellReuseIdentifier:TUIReferenceMessageCell_ReuseId];
    
    NSArray *customMessageInfo = [TUIMessageDataProvider_Minimalist getCustomMessageInfo];
    for (NSDictionary *messageInfo in customMessageInfo) {
        NSString *bussinessID = messageInfo[BussinessID];
        NSString *cellName = messageInfo[TMessageCell_Name];
        Class cls = NSClassFromString(cellName);
        if (cls && bussinessID) {
            [self.tableView registerClass:cls forCellReuseIdentifier:bussinessID];
        }
    }

    self.indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TMessageController_Header_Height)];
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.tableView.tableHeaderView = self.indicatorView;
}

#pragma mark - Data Provider
- (void)setConversation:(TUIChatConversationModel *)conversationData
{
    self.conversationData = conversationData;
    if (!self.messageDataProvider) {
        self.messageDataProvider = [[TUIMessageDataProvider_Minimalist alloc] initWithConversationModel:conversationData];
        self.messageDataProvider.dataSource = self;
    }
    [self loadMessage];
}

- (void)loadMessage
{
    if (self.messageDataProvider.isLoadingData || self.messageDataProvider.isNoMoreMsg) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.messageDataProvider loadMessageSucceedBlock:^(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TUIMessageCellData *> * _Nonnull newMsgs) {
        if (isNoMoreMsg) {
            weakSelf.indicatorView.mm_h = 0;
        }
        if (newMsgs.count != 0) {
            
            [weakSelf.tableView reloadData];
            [weakSelf.tableView layoutIfNeeded];
            
            if(isFirstLoad) {
                [weakSelf scrollToBottom:NO];
            } else {
                CGFloat visibleHeight = 0;
                for (NSInteger i = 0; i < newMsgs.count; ++i) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    visibleHeight += [weakSelf tableView:weakSelf.tableView heightForRowAtIndexPath:indexPath];
                }
                if(isNoMoreMsg) {
                    visibleHeight -= TMessageController_Header_Height;
                }
                [weakSelf.tableView scrollRectToVisible:CGRectMake(0, weakSelf.tableView.contentOffset.y + visibleHeight, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height) animated:NO];
            }
        }
//        [weakSelf.indicatorView stopAnimating];
    } FailBlock:^(int code, NSString *desc) {
        [TUITool makeToastError:code msg:desc];
    }];
}

- (void)clearUImsg {
    [self.messageDataProvider clearUIMsgList];
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
}

- (void)reloadAndScrollToBottomOfMessage:(NSString *)messageID {
    // Dispatch the task to RunLoop to ensure that they are executed after the UITableView refresh is complete.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadCellOfMessage:messageID];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollCellToBottomOfMessage:messageID];
        });
    });
}

- (void)reloadCellOfMessage:(NSString *)messageID {
    NSIndexPath *indexPath = [self indexPathOfMessage:messageID];
    
    // Disable animation when loading to avoid cell jumping.
    if (indexPath == nil) {
        return;
    }
    [UIView performWithoutAnimation:^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)scrollCellToBottomOfMessage:(NSString *)messageID {
    NSIndexPath *indexPath = [self indexPathOfMessage:messageID];
    
    // Scroll the tableView only if the bottom of the cell is invisible.
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    CGRect tableViewRect = self.tableView.bounds;
    BOOL isBottomInvisible = (cellRect.origin.y < CGRectGetMaxY(tableViewRect) && CGRectGetMaxY(cellRect) > CGRectGetMaxY(tableViewRect)) || (cellRect.origin.y >= CGRectGetMaxY(tableViewRect));
    if (isBottomInvisible) {
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
    if (self.isAutoScrolledToBottom) {
        [self scrollToBottom:YES];
    }
}

- (NSIndexPath *)indexPathOfMessage:(NSString *)messageID {
    for (int i = 0; i < self.messageDataProvider.uiMsgs.count; i++) {
        TUIMessageCellData *data = self.messageDataProvider.uiMsgs[i];
        if ([data.innerMessage.msgID isEqualToString:messageID]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

#pragma mark - Event Response
- (void)scrollToBottom:(BOOL)animate
{
    if (self.messageDataProvider.uiMsgs.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageDataProvider.uiMsgs.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animate];
        self.isAutoScrolledToBottom = YES;
    }
}

- (void)didTapViewController
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didTapInMessageController:)]) {
        [self.delegate didTapInMessageController:self];
    }
}

- (void)sendUIMessage:(TUIMessageCellData *)cellData
{
    @weakify(self);
    cellData.innerMessage.needReadReceipt = self.isMsgNeedReadReceipt;
    [self.messageDataProvider sendUIMsg:cellData
                         toConversation:self.conversationData
                          willSendBlock:^(BOOL isReSend, TUIMessageCellData * _Nonnull dateUIMsg) {
        @strongify(self);
        [self scrollToBottom:YES];

        int delay = 1;
        if ([cellData isKindOfClass:[TUIImageMessageCellData_Minimalist class]]) {
            delay = 0;
        }
        
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            if (cellData.status == Msg_Status_Sending) {
                [self changeMsg:cellData status:Msg_Status_Sending_2];
            }
        });
        
    } SuccBlock:^{
        @strongify(self);
        [self reloadUIMessage:cellData];
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
        cellData = [TUIMessageDataProvider_Minimalist getCellData:message];
    }
    if (cellData) {
        [self sendUIMessage:cellData];
    }
}

- (void)reloadUIMessage:(TUIMessageCellData *)msg
{
    // innerMessage maybe changed, reload it
    NSInteger index = [self.messageDataProvider.uiMsgs indexOfObject:msg];
    TUIMessageCellData *newData = [self.messageDataProvider transUIMsgFromIMMsg:@[msg.innerMessage]].lastObject;
    __weak typeof(self) weakSelf = self;
    [self.messageDataProvider preProcessMessage:@[newData] callback:^{
        [weakSelf.messageDataProvider replaceUIMsg:newData atIndex:index];
        [weakSelf.tableView reloadData];
    }];
}

- (void)changeMsg:(TUIMessageCellData *)msg status:(TMsgStatus)status
{
    msg.status = status;
    NSInteger index = [self.messageDataProvider.uiMsgs indexOfObject:msg];
    if ([self.tableView numberOfRowsInSection:0] > index) {
        TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell fillWithData:msg];
    } else {
        NSLog(@"lack of cell");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kTUINotifyMessageStatusChanged" object:nil userInfo:@{
        @"msg": msg,
        @"status": [NSNumber numberWithUnsignedInteger:status],
        @"msgSender": self,
    }];
}

#pragma mark - TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key
               subKey:(NSString *)subKey
               object:(id)anObject
                param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUITranslationNotify]
        && [subKey isEqualToString:TUICore_TUITranslationNotify_DidChangeTranslationSubKey]) {
        // Translation View is shown, hidden or changed.
        TUIMessageCellData *data = param[TUICore_TUITranslationNotify_DidChangeTranslationSubKey_Data];
        [self clearAndReloadCellOfData:data];
   } if ([key isEqualToString:TUICore_TUITranslationNotify]
         && [subKey isEqualToString:TUICore_TUITranslationNotify_WillForwardTranslationSubKey]) {
       // Translation will be forwarded.
       NSString *text = param[TUICore_TUITranslationNotify_WillForwardTranslationSubKey_Text];
       if (self.delegate && [self.delegate respondsToSelector:@selector(messageController:onForwardText:)]) {
           [self.delegate messageController:self onForwardText:text];
       }
   }
}

- (void)clearAndReloadCellOfData:(TUIMessageCellData *)data {
    [data clearCachedCellHeight];
    [self.messageDataProvider removeHeightCacheOfData:data];
    [self reloadAndScrollToBottomOfMessage:data.innerMessage.msgID];
}

#pragma mark - TUIMessageProgressManagerDelegate
- (void)onMessageSendingResultChanged:(TUIMessageSendingResultType)type messageID:(NSString *)msgID
{
    // async
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (TUIMessageCellData *cellData in weakSelf.messageDataProvider.uiMsgs) {
            if ([cellData.msgID isEqual:msgID]) {
                [weakSelf changeMsg:cellData status:(type == TUIMessageSendingResultTypeSucc) ? Msg_Status_Succ: Msg_Status_Fail];
            }
        }
    });
}
#pragma mark - TUIMessageBaseDataProviderDataSource
static NSMutableArray *lastMsgIndexs = nil;
static NSMutableArray *reloadMsgIndexs = nil;
- (void)dataProviderDataSourceWillChange:(TUIMessageDataProvider_Minimalist *)dataProvider
{
    [self.tableView beginUpdates];
    
    if (lastMsgIndexs) {
        [lastMsgIndexs removeAllObjects];
    } else {
        lastMsgIndexs = [NSMutableArray array];
    }
    
    if (reloadMsgIndexs) {
        [reloadMsgIndexs removeAllObjects];
    } else {
        reloadMsgIndexs = [NSMutableArray array];
    }
}
- (void)dataProviderDataSourceChange:(TUIMessageDataProvider_Minimalist *)dataProvider
                            withType:(TUIMessageBaseDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation
{
    // insert or delete or reload current cell
    [reloadMsgIndexs addObject:@(index)];
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:index inSection:0]];
    switch (type) {
        case TUIMessageBaseDataProviderDataSourceChangeTypeInsert:
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation? UITableViewRowAnimationFade:UITableViewRowAnimationNone];
            break;
        case TUIMessageBaseDataProviderDataSourceChangeTypeDelete:
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation? UITableViewRowAnimationFade:UITableViewRowAnimationNone];
            break;
        case TUIMessageBaseDataProviderDataSourceChangeTypeReload:
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation? UITableViewRowAnimationFade:UITableViewRowAnimationNone];
            break;
        default:
            break;
    }
    
    // remove cache index
    if ([lastMsgIndexs containsObject:@(index)]) {
        [lastMsgIndexs removeObject:@(index)];
    }
    
    // reload last cell
    if (index >= 1 && ![reloadMsgIndexs containsObject:@(index - 1)]) {
        [lastMsgIndexs addObject:@(index - 1)];
    }
    
}

- (void)dataProviderDataSourceDidChange:(TUIMessageDataProvider_Minimalist *)dataProvider
{
    for(NSNumber *number in lastMsgIndexs) {
        NSUInteger index = [number unsignedIntValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        if ([self.messageDataProvider removeHeightCache:index]) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    [lastMsgIndexs removeAllObjects];
    [reloadMsgIndexs removeAllObjects];
    
    [self.tableView endUpdates];
}

- (nullable TUIMessageCellData *)dataProvider:(TUIMessageDataProvider_Minimalist *)dataProvider
               CustomCellDataFromNewIMMessage:(V2TIMMessage *)msg
{
    if (![msg.userID isEqualToString:self.conversationData.userID]
        && ![msg.groupID isEqualToString:self.conversationData.groupID]) {
        return nil;
    }
    
    if (msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        return nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(messageController:onNewMessage:)]) {
        TUIMessageCellData *customCellData = [self.delegate messageController:self onNewMessage:msg];
        if (customCellData) {
            customCellData.innerMessage = msg;
            return customCellData;
        }
    }
    return nil;
}

- (void)dataProvider:(TUIMessageDataProvider_Minimalist *)dataProvider
ReceiveReadMsgWithUserID:(NSString *)userId
                Time:(time_t)timestamp
{

    if (userId.length > 0 && [userId isEqualToString:self.conversationData.userID]) {
        for (int i = 0; i < self.messageDataProvider.uiMsgs.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageDataProvider.uiMsgs.count - 1 - i inSection:0];
            TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            /**
             * 通过回调时间戳判定当前的未读状态是否需要改为已读状态
             * Determine whether the current unread needs to be changed to read by the callback timestamp
             */
            time_t msgTime = [cell.messageData.innerMessage.timestamp timeIntervalSince1970];
            if (msgTime <= timestamp
                && ![cell.readReceiptLabel.text isEqualToString:TIMCommonLocalizableString(Read)]) {
                cell.readReceiptLabel.text = TIMCommonLocalizableString(Read);
            }
        }
    }
}

- (void)dataProvider:(TUIMessageDataProvider_Minimalist *)dataProvider
ReceiveReadMsgWithGroupID:(NSString *)groupID
               msgID:(NSString *)msgID
           readCount:(NSUInteger)readCount
         unreadCount:(NSUInteger)unreadCount
{
    if (groupID != nil && ![groupID isEqualToString:self.conversationData.groupID]) {
        return;
    }
    NSInteger row = [self.messageDataProvider getIndexOfMessage:msgID];
    if (row < 0 || row >= self.messageDataProvider.uiMsgs.count) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell updateReadLabelText];
}

- (void)dataProvider:(TUIMessageDataProvider_Minimalist *)dataProvider
     ReceiveNewUIMsg:(TUIMessageCellData *)uiMsg
{
    /**
     * 查看历史消息的时候根据当前 contentOffset 判断是否需要滑动到底部
     * When viewing historical messages, judge whether you need to slide to the bottom according to the current contentOffset
     */
    if (self.tableView.contentSize.height - self.tableView.contentOffset.y < Screen_Height * 1.5) {
        [self scrollToBottom:YES];
        if (self.isInVC && self.isActive) {
            [self.messageDataProvider sendLatestMessageReadReceipt];
        }
    }
    
    [self limitReadReport];
}

- (void)dataProvider:(TUIMessageDataProvider_Minimalist *)dataProvider ReceiveRevokeUIMsg:(TUIMessageCellData *)uiMsg {
    return;
}

- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider
didChangeTranslationData:(TUIMessageCellData *)data {
    [self reloadAndScrollToBottomOfMessage:data.innerMessage.msgID];
}

#pragma mark - Private
- (void)limitReadReport
{
    static uint64_t lastTs = 0;
    uint64_t curTs = [[NSDate date] timeIntervalSince1970];
    /**
     * 超过 1s && 非首次，立即上报已读
     * More than 1s && Not the first time, report immediately
     */
    if (curTs - lastTs >= 1 && lastTs) {
        lastTs = curTs;
        [self readReport];
    } else {
        /**
         * 低于 1s || 首次  延迟 1s 合并上报
         * Less than 1s || First time, delay 1s and merge report
         */
        static BOOL delayReport = NO;
        if (delayReport) {
            return;
        }
        delayReport = YES;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf readReport];
            delayReport = NO;
        });
    }
}

- (void)readReport
{
    if (self.isInVC && self.isActive) {
        NSString *userID = self.conversationData.userID;
        if (userID.length > 0) {
            [TUIMessageDataProvider_Minimalist markC2CMessageAsRead:userID succ:nil fail:nil];
        }
        NSString *groupID = self.conversationData.groupID;
        if (groupID.length > 0) {
            [TUIMessageDataProvider_Minimalist markGroupMessageAsRead:groupID succ:nil fail:nil];
        }

        NSString *conversationID = @"";
        
        if (IS_NOT_EMPTY_NSSTRING(userID)) {
            conversationID = [NSString stringWithFormat:@"c2c_%@", userID];
        }
        
        if (IS_NOT_EMPTY_NSSTRING(groupID)) {
            conversationID = [NSString stringWithFormat:@"group_%@",groupID];
        }
        
        if (IS_NOT_EMPTY_NSSTRING(self.conversationData.conversationID)) {
            conversationID = self.conversationData.conversationID;
        }
        if (conversationID.length > 0) {
            [TUIMessageDataProvider_Minimalist markConversationAsUndead:@[conversationID] enableMark:NO];
        }
        
    }
}

/**
 * 接收方需发送可见消息已读回执的时机：
 * 1、messageVC 可见时。在 [self viewDidAppear:] 中获得通知。
 * 2、代码调用 [self scrollToBottom:] 后 scrollView 自动跳转到底部停止时（例如点击右下角 "x 条新消息" tips）。在 [UIScrollViewDelegate scrollViewDidEndScrollingAnimation:] 中获得通知。
 *    + 注意需要借助 scrollView 的状态来准确判断 scrollView 是否真的停止了滑动。
 * 3、用户连续地拖拽 scrollView 滑动查看消息时。在 [UIScrollViewDelegate scrollViewDidScroll:] 中得到通知。
 *    + 注意此处要判断 scrollView 的滑动是否由用户手势触发（而不是自动代码触发）。因此借助 self.scrollingTriggeredByUser 标志位来区分。
 *    + self.scrollingTriggeredByUser 的更新逻辑：
 *      - 用户手指触碰到屏幕并且开始拖拽时（scrollViewWillBeginDragging:）置 YES；
 *      - 用户手指以一定的加速度拖拽后离开屏幕，屏幕自动停止滑动时（scrollViewDidEndDecelerating:）置 NO；
 *      - 用户手指滑动后不施加加速度，直接抬起手指时（scrollViewDidEndDragging:）置 NO。
 * 4、用户停留在最新消息界面，此时收到了新消息时。在 [self dataProvider:ReceiveNewUIMsg:] 中得到通知。
 *
 * When the receiver sends a visible message read receipt:
 * 1. The time when messageVC is visible.  You will be notified when [self viewDidAppear:] is invoked
 * 2. The time when scrollview scrolled to bottom by called [self scrollToBottom:] (For example, click the "x new message" tips in the lower right corner). You will be notified when  [UIScrollViewDelegate scrollViewDidEndScrollingAnimation:]  is invoked.
 *   + Note that you need to use the state of the scrollView to accurately determine whether the scrollView has really stopped sliding.
 * 3. The time when the user drags the scrollView continuously to view the message. You will be notified when [UIScrollViewDelegate scrollViewDidScroll:]  is invoked.
 *   + Note here to determine whether the scrolling of the scrollView is triggered by user gestures (rather than automatic code triggers). So use the self.scrollingTriggeredByUser flag to distinguish.
 *   + The update logic of self.scrollingTriggeredByUser is as follows:
 *     - Set YES when the user's finger touches the screen and starts to drag (scrollViewWillBeginDragging:);
 *     - When the user's finger drags at a certain acceleration and leaves the screen, when the screen automatically stops sliding (scrollViewDidEndDecelerating:), set to NO;
 *     - No acceleration is applied after the user's finger slides, and when the user lifts the finger directly (scrollViewDidEndDragging:), set NO.
 * 4. When the user stays in the latest message interface and receives a new message at this time. Get notified in [self dataProvider:ReceiveNewUIMsg:] .
 */
- (void)sendVisibleReadGroupMessages {
    if (self.isInVC && self.isActive) {
        NSRange range = [self calcVisibleCellRange];
        [self.messageDataProvider sendMessageReadReceiptAtIndexes:[self transferIndexFromRange:range]];
    }
}

- (NSRange)calcVisibleCellRange
{
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    if (indexPaths.count == 0) {
        return NSMakeRange(0, 0);
    }
    NSIndexPath *topmost = indexPaths.firstObject;
    NSIndexPath *downmost = indexPaths.lastObject;
    return NSMakeRange(topmost.row, downmost.row - topmost.row + 1);
}

- (NSArray *)transferIndexFromRange:(NSRange)range
{
    NSMutableArray *index = [NSMutableArray array];
    NSInteger start = range.location;
    for (int i = 0; i < range.length; i++) {
        [index addObject:@(start + i)];
    }
    return index;
}

- (void)hideKeyboardIfNeeded
{
    [self.view endEditing:YES];
    [TUITool.applicationKeywindow endEditing:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageDataProvider.uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messageDataProvider getCellDataHeightAtIndex:indexPath.row Width:Screen_Width];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.messageDataProvider respondsToSelector:@selector(getEstimatedHeightForRowAtIndex:)]) {
        return [self.messageDataProvider getEstimatedHeightForRowAtIndex:indexPath.row];
    }
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUIMessageCellData *data = self.messageDataProvider.uiMsgs[indexPath.row];
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
        NSAssert(NO, @"Unknow cell");
        return nil;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    cell.delegate = self;
    [cell fillWithData:data];
    [cell notifyBottomContainerReadyOfData:nil];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUIMessageCell *uiMsg = (TUIMessageCell *)cell;
    if ([uiMsg isKindOfClass:TUIMessageCell.class]
        && [self.delegate respondsToSelector:@selector(messageController:willDisplayCell:withData:)]) {
        [self.delegate messageController:self willDisplayCell:uiMsg withData:uiMsg.messageData];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.messageDataProvider.uiMsgs.count) {
        TUITextMessageCellData_Minimalist *cellData = (TUITextMessageCellData_Minimalist *)self.messageDataProvider.uiMsgs[indexPath.row];
        if ([cellData isKindOfClass:TUITextMessageCellData_Minimalist.class]) {
            if ((cellData.isAudioCall || cellData.isVideoCall) && cellData.showUnreadPoint) {
                cellData.innerMessage.localCustomInt = 1;
                cellData.showUnreadPoint = NO;
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollingTriggeredByUser) {
        // only if the scrollView is dragged by user's finger to scroll, we need to send read receipts.
        [self sendVisibleReadGroupMessages];
        self.isAutoScrolledToBottom = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.scrollingTriggeredByUser = YES;
    [self didTapViewController];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self isScrollViewEndDragging:scrollView])
    {
        // user presses on the scrolling scrollView and forces it to stop scrolling immediately.
        self.scrollingTriggeredByUser = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self isScrollViewEndDecelerating:scrollView]) {
        // user drags the scrollView with a certain acceleration and makes a flick gesture, and scrollView will stop scrolling after decelerating.
        self.scrollingTriggeredByUser = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self isScrollViewEndDecelerating:scrollView]) {
        // UIScrollView automatically stops scrolling, for example triggered after calling scrollToBottom
        [self sendVisibleReadGroupMessages];
    }
}

- (BOOL)isScrollViewEndDecelerating:(UIScrollView *)scrollView
{
    return scrollView.tracking == 0 && scrollView.dragging == 0 && scrollView.decelerating == 0;
}

- (BOOL)isScrollViewEndDragging:(UIScrollView *)scrollView
{
    return scrollView.tracking == 1 && scrollView.dragging == 0 && scrollView.decelerating == 0;
}

#pragma mark - TUIMessageCellDelegate

- (void)onSelectMessage:(TUIMessageCell *)cell
{
    if (self.showCheckBox) {
        TUIMessageCellData *data = (TUIMessageCellData *)cell.data;
        data.selected = !data.selected;
        [self.tableView reloadData];
        if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageWhenMultiCheckboxAppear:)]) {
            [self.delegate messageController:self onSelectMessageWhenMultiCheckboxAppear:data];
        }
        return;
    }
    
    if ([cell isKindOfClass:[TUITextMessageCell_Minimalist class]]) {
        [self clickTextMessage:(TUITextMessageCell_Minimalist *)cell];
    }
    else if ([cell isKindOfClass:[TUISystemMessageCell class]]) {
        [self clickSystemMessage:(TUISystemMessageCell *)cell];
    }
    else if ([cell isKindOfClass:[TUIVoiceMessageCell_Minimalist class]]) {
        [self playVoiceMessage:(TUIVoiceMessageCell_Minimalist *)cell];
    }
    else if ([cell isKindOfClass:[TUIImageMessageCell_Minimalist class]]) {
        [self showImageMessage:(TUIImageMessageCell_Minimalist *)cell];
    }
    else if ([cell isKindOfClass:[TUIVideoMessageCell_Minimalist class]]) {
        [self showVideoMessage:(TUIVideoMessageCell_Minimalist *)cell];
    }
    else if ([cell isKindOfClass:[TUIFileMessageCell_Minimalist class]]) {
        [self showFileMessage:(TUIFileMessageCell_Minimalist *)cell];
    }
    else if ([cell isKindOfClass:[TUIMergeMessageCell_Minimalist class]]) {
        [self showRelayMessage:(TUIMergeMessageCell_Minimalist *)cell];
    }
    else if ([cell isKindOfClass:[TUILinkCell_Minimalist class]]) {
        [self showLinkMessage:(TUILinkCell_Minimalist *)cell];
    }
    else if ([cell isKindOfClass:TUIReplyMessageCell_Minimalist.class]) {
        [self showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell];
    }
    else if ([cell isKindOfClass:TUIReferenceMessageCell_Minimalist.class]) {
        [self showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell];
    }
    else if ([cell isKindOfClass:TUIOrderCell_Minimalist.class]) {
        [self showOrderMessage:(TUIOrderCell_Minimalist *)cell];
    }

    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:self onSelectMessageContent:cell];
    }
}

- (void)tryShowGuidance {
    
    BOOL hasShow = [NSUserDefaults.standardUserDefaults boolForKey:@"chat_reply_guide_showKey"];
    if (hasShow) {
        return;
    }
    else {
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"chat_reply_guide_showKey"];
        [NSUserDefaults.standardUserDefaults synchronize];
    }

    TUICSToastStyle * style = [[TUICSToastStyle alloc] initWithDefaultStyle];
    style.backgroundColor = [UIColor clearColor];
    style.maxWidthPercentage = 1;
    style.maxHeightPercentage = 1;
    style.fadeDuration = 0;
    style.verticalPadding = 0;
    style.horizontalPadding = 0;
    style.imageSize = CGSizeMake(Screen_Width , Screen_Height);
    style.activitySize = CGSizeMake(Screen_Width , Screen_Height);
    style.imageContentMode = UIViewContentModeScaleAspectFill;
    
    
    [[UIApplication sharedApplication].keyWindow makeToast:@"" duration:[[NSDate distantFuture] timeIntervalSince1970] position:TUICSToastPositionCenter title:@"" image:TUIChatCommonBundleImage(@"chat_reference_guide")
                                                     style:style completion:^(BOOL didTap) {
    }];
    
    [[UIApplication sharedApplication].keyWindow makeToast:@"" duration:[[NSDate distantFuture] timeIntervalSince1970] position:TUICSToastPositionCenter title:@"" image:TUIChatCommonBundleImage(@"chat_reply_guide")
                                                     style:style completion:^(BOOL didTap) {
    }];

}

- (void)showContextWindow:(TUIMessageCell *)cell {
    CGRect frame = [UIApplication.sharedApplication.keyWindow convertRect:cell.container.frame fromView:cell];
    TUIChatPopContextController * alertController = [[TUIChatPopContextController alloc] init];
    alertController.alertViewCellData = cell.messageData;
    alertController.originFrame = frame;
    alertController.alertCellClass = cell.class;
    // blur effect
    [alertController setBlurEffectWithView:self.navigationController.view];
    // config
    [self configItems:alertController targetCell:cell];
    __weak typeof(cell)weakCell = cell;
    __weak typeof(self)weakSelf = self;
    alertController.viewWillShowHandler = ^(TUIMessageCell * _Nonnull alertView) {
        alertView.delegate  = weakSelf;
    };

    alertController.dismissComplete = ^{
        if (weakCell) {
            weakCell.container.hidden = NO;
        }
    };
    [self.navigationController presentViewController:alertController animated:NO completion:nil];
    self.popAlertController = alertController;
}



- (void)configItems:(TUIChatPopContextController*) alertController
         targetCell:(TUIMessageCell *)cell {

    TUIMessageCellData *data = cell.messageData;
    V2TIMMessage *imMsg = data.innerMessage;
    NSMutableArray *pluginCustomMessageInfo = [TUIMessageDataProvider_Minimalist getPluginCustomMessageInfo];
    BOOL isPluginCustomMessage = NO ;
    for (NSDictionary *messageInfo in pluginCustomMessageInfo) {
        NSString *bussinessID = messageInfo[BussinessID];
        if (bussinessID) {
            if([data.reuseId isEqualToString:bussinessID]) {
                isPluginCustomMessage = YES;
                break;
            }
        }
    }
    BOOL isChatNoramlMessageOrCustomMessage = !isPluginCustomMessage ;

    /**
     * 排序优先级:  复制(1)、转发(2)、多选(3)、引用(4)、回复(5)、翻译(6)、撤回(7)、详情(8)、删除(9)
     * Sort priorities: copy, forward, multiselect, reference, reply, Withdraw, delete
     * 权重越大越靠前weight:  复制 10000  转发 9000 多选 8000 引用 7000 回复 5000 翻译 4000 撤回3000 详情 2000  删除 1000
     * The higher the weight, the more prioritized it is:
        Copy - 10000
        Forward - 9000
        Multiple Choice - 8000
        Quote - 7000
        Reply - 5000
        Withdraw - 3000
        Details - 2000
        Delete - 1000
     */
    NSMutableArray *Items = [NSMutableArray arrayWithCapacity:6];

    __weak typeof(self) weakSelf = self;
    
    TUIChatPopContextExtionItem *copyItem = [self setupCopyAction:alertController targetCell:cell];

    TUIChatPopContextExtionItem *forwardItem = [self setupForwardAction:alertController targetCell:cell];
    
    TUIChatPopContextExtionItem *multiSelectItem = [self setupMultiSelectAction:alertController targetCell:cell];
    
    TUIChatPopContextExtionItem *referenceItem = [self setupReferenceAction:alertController targetCell:cell];

    TUIChatPopContextExtionItem *replyItem = [self setupReplyAction:alertController targetCell:cell];
    
    TUIChatPopContextExtionItem *revocationItem = [self setupRevocationAction:alertController targetCell:cell];

    TUIChatPopContextExtionItem *infoItem = [self setupInfoAction:alertController targetCell:cell];

    TUIChatPopContextExtionItem *deleteItem = [self setupDeleteAction:alertController targetCell:cell];
    
    if (isChatNoramlMessageOrCustomMessage) {
        if ([data isKindOfClass:[TUITextMessageCellData_Minimalist class]] || [data isKindOfClass:TUIReferenceMessageCellData_Minimalist.class]) {
            [Items addObject:copyItem];
        }
        if (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC) {
            [Items addObject:forwardItem];
        }
        [Items addObject:multiSelectItem];
        if (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC) {
            [Items addObject:referenceItem];
        }
        if (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC) {
            [Items addObject:replyItem];
        }
        if(imMsg){
            if([imMsg isSelf] &&
               [[NSDate date] timeIntervalSinceDate:imMsg.timestamp] < TUIChatConfig.defaultConfig.timeIntervalForMessageRecall &&
               (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC)){
                [Items addObject:revocationItem];
            }
        }
        if(imMsg){
            if([imMsg isSelf] && (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC)){
                [Items addObject:infoItem];
            }
        }
        [Items addObject:deleteItem];

    }
    else {
        //common
        //多选（multiSelectItem） 引用（referenceItem） 回复（replyItem） 删除(deleteItem) 撤回(revocationItem)
        [Items addObject:multiSelectItem];
        
        if ([TUIChatConfig defaultConfig].enablePopMenuReplyAction && (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC)){
            [Items addObject:replyItem];
        }
        if ([TUIChatConfig defaultConfig].enablePopMenuReferenceAction && (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC)) {
            [Items addObject:referenceItem];
        }
        [Items addObject:deleteItem];

        if(imMsg){
            if([imMsg isSelf] &&
               [[NSDate date] timeIntervalSinceDate:imMsg.timestamp] < TUIChatConfig.defaultConfig.timeIntervalForMessageRecall && 
               (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC)){
                [Items addObject:revocationItem];
            }
        }
    }
    
    //extra
    NSArray<TUIExtensionInfo *> *infoArray = [TUICore getExtensionList:TUICore_TUIChatExtension_PopMenuActionItem_MinimalistExtensionID param:@{
        TUICore_TUIChatExtension_PopMenuActionItem_TargetVC:self,
        TUICore_TUIChatExtension_PopMenuActionItem_ClickCell:cell
    }];
    
    for (TUIExtensionInfo *info in infoArray) {
        if (info.text && info.icon && info.onClicked) {
            TUIChatPopContextExtionItem *extension = [[TUIChatPopContextExtionItem alloc] initWithTitle: info.text markIcon:info.icon weight:info.weight withActionHandler:^(TUIChatPopContextExtionItem *action){
                [alertController blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {
                    info.onClicked(@{});
                }];
            }];
            [Items addObject:extension];
        }
    }
    
    //Sory by weight
    NSArray *sortResultArray = [Items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TUIChatPopContextExtionItem *per1 = obj1;
        TUIChatPopContextExtionItem *per2 = obj2;
        return per1.weight > per2.weight ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSMutableArray *filterArray = [NSMutableArray arrayWithArray:sortResultArray];
    
    __weak typeof(alertController) weakVC = alertController;
    alertController.reactClickCallback = ^(NSString * _Nonnull faceName) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        [weakVC blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {
            if(strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(messageController:modifyMessage:reactEmoji:)]){
                [strongSelf.delegate messageController:strongSelf modifyMessage:cell.messageData reactEmoji:faceName];
            }
        }];
    };

    //Paging
    NSInteger perPageLimitedCount = 4;
    NSMutableArray *allPageItemsArray = [NSMutableArray array];
    NSUInteger itemsRemaining = filterArray.count;
    int j = 0;
    while(itemsRemaining) {
        NSRange range = NSMakeRange(j, MIN(perPageLimitedCount, itemsRemaining));
        NSMutableArray *subLogArr =[NSMutableArray arrayWithArray:[filterArray subarrayWithRange:range]];
        TUIChatPopContextExtionItem * lastItem = [subLogArr lastObject];
        lastItem.needBottomLine = YES;
        
        [allPageItemsArray addObject:subLogArr];
        itemsRemaining-=range.length;
        j+=range.length;
    }
    
    if (allPageItemsArray.count != 1) {
        //more than one
        NSInteger lastPagedIndex = allPageItemsArray.count - 1 ;
        for (int pageIndex = 0 ; pageIndex<allPageItemsArray.count ; pageIndex++) {
            NSInteger nextPageIndex = 0;
            if (lastPagedIndex != pageIndex) {
                nextPageIndex = pageIndex + 1;
            }
            else {
                nextPageIndex = 0;
            }
            TUIChatPopContextExtionItem *moreItem = [[TUIChatPopContextExtionItem alloc] initWithTitle: TIMCommonLocalizableString(More) markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_more")] weight:INT_MAX withActionHandler:^(TUIChatPopContextExtionItem *action){
                NSMutableArray *nextPageItems = allPageItemsArray[nextPageIndex];;
                alertController.Items  = nextPageItems;
                [alertController updateExtionView];
            }];
            moreItem.titleColor = [UIColor tui_colorWithHex:@"147AFF"];
            NSMutableArray *pageItems = allPageItemsArray[pageIndex];
            [pageItems addObject:moreItem];
        }
    }
    else {
        //only one
        NSMutableArray<TUIChatPopContextExtionItem *> *Items  = allPageItemsArray[0];
        TUIChatPopContextExtionItem * lastItem = [Items lastObject];
        lastItem.needBottomLine = NO;
    }
    
    //Entrance
    alertController.Items = allPageItemsArray[0];

    
}
- (void)onLongPressMessage:(TUIMessageCell *)cell
{
    TUIMessageCellData *data = cell.messageData;
    if ([data isKindOfClass:[TUISystemMessageCellData class]]) {
        return;
    }
    self.menuUIMsg = data;
    [self showContextWindow:cell];
}

- (void)onLongSelectMessageAvatar:(TUIMessageCell *)cell
{
    if(_delegate && [_delegate respondsToSelector:@selector(messageController:onLongSelectMessageAvatar:)]){
        [_delegate messageController:self onLongSelectMessageAvatar:cell];
    }
}

- (void)onRetryMessage:(TUIMessageCell *)cell
{
    _reSendUIMsg = cell.messageData;
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitTipsConfirmResendMessage) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Re-send) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf sendUIMessage:weakSelf.reSendUIMsg];
    }]] ;
    [alert tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)onSelectMessageAvatar:(TUIMessageCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageAvatar:)]) {
        [self.delegate messageController:self onSelectMessageAvatar:cell];
    }
}

- (void)onJumpToRepliesDetailPage:(TUIMessageCellData *)data {
    TUIMessageCellData *copyData = [TUIMessageDataProvider_Minimalist getCellData:data.innerMessage];
    @weakify(self)
    [self.messageDataProvider preProcessMessage:@[copyData] callback:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            TUIMessageCell * cell = [[TUIMessageCell alloc] init];
            [cell fillWithData:copyData];
            TUIRepliesDetailViewController_Minimalist *repliesDetailVC = [[TUIRepliesDetailViewController_Minimalist alloc] initWithCellData:copyData conversationData:self.conversationData];
            repliesDetailVC.delegate = self.delegate;
            repliesDetailVC.modalPresentationStyle = UIModalPresentationCustom;

            [self.navigationController presentViewController:repliesDetailVC animated:YES completion:nil];
            repliesDetailVC.parentPageDataProvider = self.messageDataProvider;
            @weakify(self)
            repliesDetailVC.willCloseCallback = ^(){
                @strongify(self)
                [self.tableView reloadData];
            };
        });
    }];
}


- (void)onEmojiClickCallback:(TUIMessageCellData *)data faceName:(NSString *)faceName {
    if(self.delegate && [self.delegate respondsToSelector:@selector(messageController:modifyMessage:reactEmoji:)]){
        [self.delegate messageController:self modifyMessage:data reactEmoji:faceName];
    }
}

- (void)onJumpToRepliesEmojiPage:(TUIMessageCellData *)data faceList:(NSArray <TUITagsModel *>*)listModel {
    if(self.delegate && [self.delegate respondsToSelector:@selector(messageController:modifyMessage:faceList:)]){
        [self.delegate messageController:self modifyMessage:data faceList:listModel];
    }
}

- (void)onJumpToMessageInfoPage:(TUIMessageCellData *)data selectCell:(TUIMessageCell *)cell {
    TUIMessageReadViewController_Minimalist *readViewController = [[TUIMessageReadViewController_Minimalist alloc] initWithCellData:data dataProvider:self.messageDataProvider showReadStatusDisable:NO c2cReceiverName:self.conversationData.title c2cReceiverAvatar:self.conversationData.faceUrl];
    CGRect frame = [UIApplication.sharedApplication.keyWindow convertRect:cell.frame fromView:cell];
    readViewController.alertViewCellData = data;
    readViewController.originFrame = frame;
    readViewController.alertCellClass = cell.class;
    readViewController.viewWillShowHandler = ^(TUIMessageCell * _Nonnull alertView) {
        alertView.delegate  = self;
    };
    [self.navigationController pushViewController:readViewController animated:YES];
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
- (void)buildMenuWithBuilder:(id<UIMenuBuilder>)builder API_AVAILABLE(ios(13.0))  {
    if (@available(iOS 16.0, *)) {
        [builder removeMenuForIdentifier:UIMenuLookup];
    }
    [super buildMenuWithBuilder:builder];
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
    /**
     * 文本消息要以光标实际选中的消息内容为准
     * The text message should be based on the content of the message actually selected by the cursor
     */
    if ([sender isKindOfClass:[TUITextMessageCell_Minimalist class]]) {
        TUITextMessageCell_Minimalist *txtCell = (TUITextMessageCell_Minimalist *)sender;
        content = txtCell.textView.text;
    }
    if ([sender isKindOfClass:TUIReferenceMessageCell_Minimalist.class]) {
        TUIReferenceMessageCellData_Minimalist *replyMsg = (TUIReferenceMessageCellData_Minimalist *)sender;
        content = replyMsg.content;
    }
    if (content.length > 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = content;
        [TUITool makeToast:TIMCommonLocalizableString(Copied)];
    }
}

- (void)onRevoke:(id)sender
{
    @weakify(self)
    [self.messageDataProvider revokeUIMsg:self.menuUIMsg SuccBlock:^{
        @strongify(self)
        if(self.delegate && [self.delegate respondsToSelector:@selector(didHideMenuInMessageController:)]){
            [self.delegate didHideMenuInMessageController:self];
        }
    }  FailBlock:^(int code, NSString *desc) {
        NSAssert(NO, desc);
    }];
}

- (void)onReSend:(id)sender
{
    [self sendUIMessage:_menuUIMsg];
}

- (void)onMulitSelect:(id)sender
{
    [self enableMultiSelectedMode:YES];
    
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
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onRelyMessage:)]) {
        [_delegate messageController:self onRelyMessage:self.menuUIMsg];
    }
}

- (void)onReference:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onReferenceMessage:)]) {
        [_delegate messageController:self onReferenceMessage:self.menuUIMsg];
    }
}

- (BOOL)supportCheckBox:(TUIMessageCellData *)data
{
    if ([data isKindOfClass:TUISystemMessageCellData.class]) {
        return NO;
    }
    return YES;
}

- (BOOL)supportRelay:(TUIMessageCellData *)data
{
    if ([data isKindOfClass: TUIVoiceMessageCellData_Minimalist.class]) {
        return NO;
    }
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

- (void)clickTextMessage:(TUITextMessageCell_Minimalist *)cell
{
    V2TIMMessage *message = cell.messageData.innerMessage;
    if (0 == message.userID.length) {
        return;
    }
    [TUIMessageDataProvider_Minimalist.callingDataProvider redialFromMessage:message];
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

- (void)playVoiceMessage:(TUIVoiceMessageCell_Minimalist *)cell
{
    for (TUIMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
        if(![cellData isKindOfClass:[TUIVoiceMessageCellData_Minimalist class]]){
            continue;
        }
        TUIVoiceMessageCellData_Minimalist *voiceMsg = (TUIVoiceMessageCellData_Minimalist *)cellData;
        if (voiceMsg == cell.voiceData) {
            [voiceMsg playVoiceMessage];
            cell.voiceReadPoint.hidden = YES;
        } else {
            [voiceMsg stopVoiceMessage];
        }
    }
}

- (void)showImageMessage:(TUIImageMessageCell_Minimalist *)cell
{
    [self hideKeyboardIfNeeded];
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView_Minimalist *mediaView = [[TUIMediaView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage];
    __weak typeof(self) weakSelf = self;
    mediaView.onClose = ^{
        [weakSelf didCloseMediaMessage:cell];
    };
    [self willShowMediaMessage:cell];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)showVideoMessage:(TUIVideoMessageCell_Minimalist *)cell
{
    [self hideKeyboardIfNeeded];
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView_Minimalist *mediaView = [[TUIMediaView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage];
    __weak typeof(self) weakSelf = self;
    mediaView.onClose = ^{
        [weakSelf didCloseMediaMessage:cell];
    };
    [self willShowMediaMessage:cell];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)showFileMessage:(TUIFileMessageCell_Minimalist *)cell
{
    [self hideKeyboardIfNeeded];
    TUIFileMessageCellData_Minimalist *fileData = cell.fileData;
    if (![fileData isLocalExist]) {
        [fileData downloadFile];
        return;
    }
    
    if(self.popAlertController) {
        [self.popAlertController blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {}];
    }
    
    TUIFileViewController_Minimalist *file = [[TUIFileViewController_Minimalist alloc] init];
    file.data = [cell fileData];
    [self.navigationController pushViewController:file animated:YES];
}

- (void)showRelayMessage:(TUIMergeMessageCell_Minimalist *)cell
{
    if(self.popAlertController) {
        [self.popAlertController blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {}];
    }
    TUIMergeMessageListController_Minimalist *relayVc = [[TUIMergeMessageListController_Minimalist alloc] init];
    relayVc.delegate = self.delegate;
    relayVc.mergerElem = cell.relayData.mergerElem;
    relayVc.conversationData = self.conversationData;
    relayVc.parentPageDataProvider = self.messageDataProvider;
    __weak typeof(self) weakSelf = self;
    relayVc.willCloseCallback = ^(){
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:relayVc animated:YES];
}

- (void)showLinkMessage:(TUILinkCell_Minimalist *)cell
{
    TUILinkCellData_Minimalist *cellData = cell.customData;
    if (cellData.link) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cellData.link]];
    }
}

- (void)showOrderMessage:(TUIOrderCell_Minimalist *)cell
{
    TUIOrderCellData_Minimalist *cellData = cell.customData;
    if (cellData.link) {
        [TUITool openLinkWithURL:[NSURL URLWithString:cellData.link]];
    }
}

- (void)showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell
{
    // subclass override
}

- (void)willShowMediaMessage:(TUIMessageCell *)cell
{
    // subclass override
}

- (void)didCloseMediaMessage:(TUIMessageCell *)cell
{
    // subclass override
}

- (void)onDelete:(TUIMessageCell *)cell
{
    // subclass override
}

#pragma mark - config TUIChatPopContextExtionItems
- (TUIChatPopContextExtionItem *)setupCopyAction:(TUIChatPopContextController*) alertController
    targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(cell);
    @weakify(alertController);
    TUIChatPopContextExtionItem *copyItem = [[TUIChatPopContextExtionItem alloc] initWithTitle: TIMCommonLocalizableString(Copy) markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_copy")] weight:10000 withActionHandler:^(TUIChatPopContextExtionItem *action){
        @strongify(alertController);
        [alertController blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {
            @strongify(self);
            @strongify(cell);
            [self onCopyMsg:cell];
        }];
    }];
    return copyItem;
}

- (TUIChatPopContextExtionItem *)setupForwardAction:(TUIChatPopContextController*) alertController
    targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(alertController);
    TUIChatPopContextExtionItem *forwardItem = [[TUIChatPopContextExtionItem alloc] initWithTitle: TIMCommonLocalizableString(Forward) markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_forward")] weight:9000 withActionHandler:^(TUIChatPopContextExtionItem *action){
        @strongify(alertController);
        [alertController blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {
            @strongify(self);
            [self onForward:nil];
        }];
    }];
    return forwardItem;
}

- (TUIChatPopContextExtionItem *)setupMultiSelectAction:(TUIChatPopContextController*) alertController
                                         targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(alertController);
    TUIChatPopContextExtionItem *multiSelectItem = [[TUIChatPopContextExtionItem alloc] initWithTitle: TIMCommonLocalizableString(MultiSelect) markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_multi")] weight:8000 withActionHandler:^(TUIChatPopContextExtionItem *action){
        @strongify(alertController);
        [alertController blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {
            @strongify(self);
            [self onMulitSelect:nil];
        }];
    }];
    return multiSelectItem;
}

- (TUIChatPopContextExtionItem *)setupReferenceAction:(TUIChatPopContextController*) alertController
                                         targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(alertController);
    TUIChatPopContextExtionItem *referenceItem = [[TUIChatPopContextExtionItem alloc] initWithTitle: TIMCommonLocalizableString(Quote) markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_quote")] weight:7000 withActionHandler:^(TUIChatPopContextExtionItem *action){
        @strongify(alertController);
        [alertController blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {
            @strongify(self);
            [self onReference:nil];
        }];
    }];
    return referenceItem;
}
- (TUIChatPopContextExtionItem *)setupReplyAction:(TUIChatPopContextController*) alertController
                                         targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(alertController);
    TUIChatPopContextExtionItem *replyItem = [[TUIChatPopContextExtionItem alloc] initWithTitle: TIMCommonLocalizableString(Reply) markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_reply")] weight:5000 withActionHandler:^(TUIChatPopContextExtionItem *action){
        @strongify(alertController);
        [alertController blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {
            @strongify(self);
            [self onReply:nil];
        }];
    }];
    return replyItem;
}

- (TUIChatPopContextExtionItem *)setupRevocationAction:(TUIChatPopContextController*) alertController
                                       targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(alertController);
    TUIChatPopContextExtionItem *revocationItem = [[TUIChatPopContextExtionItem alloc] initWithTitle: TIMCommonLocalizableString(Recall) markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_revocation")] weight:3000 withActionHandler:^(TUIChatPopContextExtionItem *action){
        @strongify(alertController);
        [alertController blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {
            @strongify(self);
            [self onRevoke:nil];
        }];
    }];
    return revocationItem;
}
- (TUIChatPopContextExtionItem *)setupInfoAction:(TUIChatPopContextController*) alertController
                                       targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(cell);
    @weakify(alertController);
    TUIChatPopContextExtionItem *infoItem = [[TUIChatPopContextExtionItem alloc] initWithTitle: TIMCommonLocalizableString(Info) markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_info")] weight:2000 withActionHandler:^(TUIChatPopContextExtionItem *action){
        @strongify(alertController);
        [alertController blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {
            @strongify(self);
            @strongify(cell);
            [self onJumpToMessageInfoPage:cell.messageData selectCell:cell];
        }];
    }];

    return infoItem;
}
- (TUIChatPopContextExtionItem *)setupDeleteAction:(TUIChatPopContextController*) alertController
                                       targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(cell);
    @weakify(alertController);
    TUIChatPopContextExtionItem *deleteItem = [[TUIChatPopContextExtionItem alloc] initWithTitle: TIMCommonLocalizableString(Delete) markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_delete")] weight:1000 withActionHandler:^(TUIChatPopContextExtionItem *action){
        @strongify(alertController);
        [alertController blurDismissViewControllerAnimated:NO completion:^(BOOL finished) {
            @strongify(self);
            @strongify(cell);
            [self onDelete:cell];
        }];
    }];
    deleteItem.titleColor = [UIColor tui_colorWithHex:@"FF584C"];
    return deleteItem;
}

@end
