
#import "TUIMessageController_Minimalist.h"
#import "TUIBaseMessageController_Minimalist+ProtectedAPI.h"
#import "TUIChatSmallTongueView_Minimalist.h"
#import "TUITextMessageCell_Minimalist.h"
#import "TUIReplyMessageCell_Minimalist.h"
#import "TUIReplyMessageCellData_Minimalist.h"
#import "TUIReferenceMessageCell_Minimalist.h"
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMessageSearchDataProvider_Minimalist.h"
#import <TUICore/UIView+TUILayout.h>
#import "ReactiveObjC.h"
#import <TIMCommon/TIMDefine.h>
#import "TUIChatModifyMessageHelper.h"
#import "TUIChatConfig.h"

#define MSG_GET_COUNT 20

@interface  TUIMessageController_Minimalist()<TUIChatSmallTongueViewDelegate_Minimalist>
@property (nonatomic, strong) UIActivityIndicatorView *bottomIndicatorView;
@property (nonatomic, assign) uint64_t locateGroupMessageSeq;
@property (nonatomic, strong) TUIChatSmallTongueView_Minimalist *tongueView;
@property (nonatomic, strong) NSMutableArray *receiveMsgs;
@property (nonatomic, weak) UIImageView *backgroudView;
@end

@implementation TUIMessageController_Minimalist

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bottomIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TMessageController_Header_Height)];
    self.bottomIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.tableView.tableFooterView = self.bottomIndicatorView;
    
    self.tableView.backgroundColor = UIColor.clearColor;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    
    if (self.conversationData.atMsgSeqs.count > 0) {
        TUIChatSmallTongue_Minimalist *tongue = [[TUIChatSmallTongue_Minimalist alloc] init];
        tongue.type = TUIChatSmallTongueType_SomeoneAtMe;
        tongue.atMsgSeqs = [self.conversationData.atMsgSeqs copy];
        [TUIChatSmallTongueManager_Minimalist showTongue:tongue delegate:self];
    }
    self.receiveMsgs = [NSMutableArray array];
}

- (void)dealloc
{
    [TUIChatSmallTongueManager_Minimalist removeTongue];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [TUIChatSmallTongueManager_Minimalist hideTongue:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [TUIChatSmallTongueManager_Minimalist hideTongue:YES];
}

#pragma mark - Notification

- (void)keyboardWillShow
{
    if (![self messageSearchDataProvider].isNewerNoMoreMsg) {
        [[self messageSearchDataProvider] removeAllSearchData];
        [self.tableView reloadData];
        [self loadMessages:YES];
    }
}

#pragma mark - Overrider
- (void)willShowMediaMessage:(TUIMessageCell *)cell
{
    [TUIChatSmallTongueManager_Minimalist hideTongue:YES];
}

- (void)didCloseMediaMessage:(TUIMessageCell *)cell
{
    [TUIChatSmallTongueManager_Minimalist hideTongue:NO];
}

- (void)onDelete:(TUIMessageCell *)cell
{
    TUIMessageCellData *cellData = cell.messageData;
    @weakify(self)
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:TIMCommonLocalizableString(ConfirmDeleteMessage) preferredStyle:UIAlertControllerStyleActionSheet];
    [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Delete) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        [self.messageDataProvider deleteUIMsgs:@[cellData] SuccBlock:^{
            [self updateAtMeTongue:cellData];
        } FailBlock:^(int code, NSString *desc) {
            NSLog(@"remove msg failed!");
            NSAssert(NO, desc);
        }];
    }]];
    [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)updateAtMeTongue:(TUIMessageCellData *)deleteCellData {
    uint64_t deleteSeq = deleteCellData.innerMessage.seq;
    if ([self.conversationData.atMsgSeqs containsObject:@(deleteSeq)]) {
        [self.conversationData.atMsgSeqs removeObject:@(deleteSeq)];
        if (self.conversationData.atMsgSeqs.count > 0) {
            TUIChatSmallTongue_Minimalist *tongue = [[TUIChatSmallTongue_Minimalist alloc] init];
            tongue.type = TUIChatSmallTongueType_SomeoneAtMe;
            tongue.atMsgSeqs = [self.conversationData.atMsgSeqs copy];
            [TUIChatSmallTongueManager_Minimalist showTongue:tongue delegate:self];
        } else {
            [TUIChatSmallTongueManager_Minimalist removeTongue:TUIChatSmallTongueType_SomeoneAtMe];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    if (scrollView.contentOffset.y <= TMessageController_Header_Height
       && ![self messageSearchDataProvider].isOlderNoMoreMsg) {
        /**
         * 显示下拉刷新
         * Display pull-to-refresh icon
         */
        if (!self.indicatorView.isAnimating) {
            [self.indicatorView startAnimating];
        }
    }
    else if ([self isScrollToBottomIndicatorViewY:scrollView]) {
        if (![self messageSearchDataProvider].isNewerNoMoreMsg) {
            /**
             * 显示上拉加载
             * Display pull-up-loading icon
             */
            if (!self.bottomIndicatorView.isAnimating) {
                [self.bottomIndicatorView startAnimating];
            }
        }
        /**
         * 去掉 "回到最新位置", "xxx条新消息" 小舌头
         * Remove the "back to the latest position", "xxx new message" bottom-banner-tips
         */
        if (self.isInVC) {
            [TUIChatSmallTongueManager_Minimalist removeTongue:TUIChatSmallTongueType_ScrollToBoom];
            [TUIChatSmallTongueManager_Minimalist removeTongue:TUIChatSmallTongueType_ReceiveNewMsg];
        }
    }
    else if (self.isInVC && 0 == self.receiveMsgs.count && self.tableView.contentSize.height - self.tableView.contentOffset.y >= Screen_Height * 2.0) {
        CGPoint point = [scrollView.panGestureRecognizer translationInView:scrollView];
        /**
         * 下滑的时候，添加 "回到最新位置" 小舌头
         * When swiping, add a "back to last position" bottom-banner-tips
         */
        if (point.y > 0) {
            TUIChatSmallTongue_Minimalist *tongue = [[TUIChatSmallTongue_Minimalist alloc] init];
            tongue.type = TUIChatSmallTongueType_ScrollToBoom;
            [TUIChatSmallTongueManager_Minimalist showTongue:tongue delegate:self];
        }
    }
    else if (self.isInVC && self.tableView.contentSize.height - self.tableView.contentOffset.y >= 20) {
        /**
         * 去掉 "有人 @ 我" 小舌头
         * Remove the "someone @ me" bottom-banner-tips
         */
        [TUIChatSmallTongueManager_Minimalist removeTongue:TUIChatSmallTongueType_SomeoneAtMe];
    }
    else {
        if (self.indicatorView.isAnimating) {
            [self.indicatorView stopAnimating];
        }
        if (self.bottomIndicatorView.isAnimating) {
            [self.bottomIndicatorView stopAnimating];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [super scrollViewDidEndDecelerating:scrollView];
    if (scrollView.contentOffset.y <= TMessageController_Header_Height
       && ![self messageSearchDataProvider].isOlderNoMoreMsg) {
        /**
         * 拉取旧消息
         * Pull old news
         */
        [self loadMessages:YES];
    }
    else if ([self isScrollToBottomIndicatorViewY:scrollView]
             && ![self messageSearchDataProvider].isNewerNoMoreMsg
             ) {
        /**
         * 加载新的消息
         * Load latese message
         */
        [self loadMessages:NO];
    }
}

- (BOOL)isScrollToBottomIndicatorViewY:(UIScrollView *)scrollView
{
    /**
     * 滚到临界点,再 + 2 像素
     * +2 pixels when scrolling to critical point
     */
    return (scrollView.contentOffset.y + self.tableView.mm_h + 2) > (scrollView.contentSize.height - self.indicatorView.mm_h);
}

#pragma mark - Getters & Setters
- (void)setConversation:(TUIChatConversationModel *)conversationData
{
    self.conversationData = conversationData;
    self.messageDataProvider = [[TUIMessageSearchDataProvider_Minimalist alloc] initWithConversationModel:self.conversationData];
    self.messageDataProvider.dataSource = self;
    if (self.locateMessage) {
        [self loadLocateMessages:NO];
    } else {
        [[self messageSearchDataProvider] removeAllSearchData];
        [self loadMessages:YES];
    }
}

#pragma mark - Private Methods
- (TUIMessageSearchDataProvider_Minimalist *)messageSearchDataProvider
{
    return (TUIMessageSearchDataProvider_Minimalist *)self.messageDataProvider;
}

- (void)loadLocateMessages:(BOOL)firstLoad
{
    if (!self.locateMessage) {
        return;
    }
    @weakify(self);
    [[self messageSearchDataProvider] loadMessageWithSearchMsg:self.locateMessage
                                                  SearchMsgSeq:self.locateGroupMessageSeq
                                              ConversationInfo:self.conversationData
                                                  SucceedBlock:^(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, NSArray<TUIMessageCellData *> * _Nonnull newMsgs) {
        [self.indicatorView stopAnimating];
        self.indicatorView.mm_h = 0;
        self.bottomIndicatorView.mm_h = 0;
        [self.tableView reloadData];
        if (!firstLoad) {
            /**
             * 在消息回复等跳转场景中，先将 tableview 滚动到最底部，再结合 scrollLocateMessage 来实现滚动定位效果
             * In jump scenarios such as message reply, first scroll the tableview to the bottom, and then combine scrollLocateMessage to achieve scroll positioning effect
             */
            
            NSInteger count = self.messageDataProvider.uiMsgs.count;
            if (count > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count - 1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:NO];
            }
        }
        [self.tableView layoutIfNeeded];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self scrollLocateMessage:firstLoad];
            [self highlightKeyword];
        });
        
    } FailBlock:^(int code, NSString *desc) {
    }];
}

- (void)scrollLocateMessage:(BOOL)firstLoad
{
    /**
     * 先找到 locateMsg 的坐标偏移
     * First find the coordinate offset of locateMsg
     */
    CGFloat offsetY = 0;
    NSInteger index = 0;
    for (TUIMessageCellData *uiMsg in [self messageSearchDataProvider].uiMsgs) {
        if ([self isLocateMessage:uiMsg]) {
            break;
        }
        offsetY += [uiMsg heightOfWidth:Screen_Width];
        index++;
    }
    
    /**
     * 没有找到定位消息
     * The locateMsg not found
     */
    if (index == [self messageSearchDataProvider].uiMsgs.count) {
        return;
    }
    
    /**
     * 再偏移半个 tableview 的高度
     * Offset half the height of the tableview
     */
    offsetY -= self.tableView.frame.size.height / 2.0;
    if (offsetY <= TMessageController_Header_Height) {
        offsetY = TMessageController_Header_Height + 0.1;
    }

    if (offsetY > TMessageController_Header_Height) {
        if (firstLoad) {
            [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentOffset.y + offsetY, Screen_Width, self.tableView.bounds.size.height) animated:NO];
        } else {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
}

- (void)highlightKeyword
{
    TUIMessageCellData *cellData = nil;
    for (TUIMessageCellData *tmp in [self messageSearchDataProvider].uiMsgs) {
        if ([self isLocateMessage:tmp]) {
            cellData = tmp;
            break;
        }
    }
    if (cellData == nil) {
        return;
    }
    
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self messageDataProvider].uiMsgs indexOfObject:cellData] inSection:0];
        cellData.highlightKeyword = self.hightlightKeyword.length?self.hightlightKeyword:@"hightlight";
        TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell fillWithData:cellData];
        [cell layoutSubviews];
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self messageDataProvider].uiMsgs indexOfObject:cellData] inSection:0];
            cellData.highlightKeyword = nil;
            TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell fillWithData:cellData];
            [cell layoutSubviews];
        });
    });
}

- (BOOL)isLocateMessage:(TUIMessageCellData *)uiMsg
{
    if (self.locateMessage) {
        if ([uiMsg.innerMessage.msgID isEqualToString:self.locateMessage.msgID]) {
            return YES;
        }
    } else {
        if (self.conversationData.groupID.length > 0 && uiMsg.innerMessage && uiMsg.innerMessage.seq == self.locateGroupMessageSeq) {
            return YES;
        }
    }
    return NO;
}

- (void)loadMessages:(BOOL)order
{
    if ([self messageSearchDataProvider].isLoadingData) {
        return;
    }

    if (order && [self messageSearchDataProvider].isOlderNoMoreMsg) {
        [self.indicatorView stopAnimating];
        return;
    }
    if (!order && [self messageSearchDataProvider].isNewerNoMoreMsg) {
        [self.bottomIndicatorView stopAnimating];
        return;
    }
    
    @weakify(self);
    [[self messageSearchDataProvider] loadMessageWithIsRequestOlderMsg:order
                                                      ConversationInfo:self.conversationData
                                                          SucceedBlock:^(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, BOOL isFirstLoad, NSArray<TUIMessageCellData *> * _Nonnull newUIMsgs) {
        @strongify(self);
        
        [self.indicatorView stopAnimating];
        [self.bottomIndicatorView stopAnimating];
        if (isOlderNoMoreMsg) {
            self.indicatorView.mm_h = 0;
        } else {
            self.indicatorView.mm_h = TMessageController_Header_Height;
        }
        if (isNewerNoMoreMsg) {
            self.bottomIndicatorView.mm_h = 0;
        } else {
            self.bottomIndicatorView.mm_h = TMessageController_Header_Height;
        }
                
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        
        [newUIMsgs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TUIMessageCellData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.direction == MsgDirectionIncoming) {
                self.C2CIncomingLastMsg = obj.innerMessage;
                *stop = YES;
            }
            
        }];
        
        if (isFirstLoad) {
            [self scrollToBottom:NO];
        } else {
            if (order) {
                NSInteger index = 0;
                if (newUIMsgs.count > 0) {
                    index = newUIMsgs.count - 1;
                }
                if (self.messageDataProvider.uiMsgs.count > 0) {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            }
        }
        
    } FailBlock:^(int code, NSString *desc) {
        
    }];
}

- (void)showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell
{
    [UIApplication.sharedApplication.keyWindow endEditing:YES];
    NSString *  originMsgID = @"";
    NSString *  msgAbstract = @"";
    if ([cell  isKindOfClass:TUIReplyMessageCell_Minimalist.class]) {
        TUIReplyMessageCell_Minimalist * acell = (TUIReplyMessageCell_Minimalist *)cell;
        TUIReplyMessageCellData_Minimalist *cellData = acell.replyData;
        originMsgID = cellData.messageRootID;
        msgAbstract = cellData.msgAbstract;
    }
    else if ([cell isKindOfClass:TUIReferenceMessageCell_Minimalist.class]) {
        TUIReferenceMessageCell_Minimalist * acell = (TUIReferenceMessageCell_Minimalist *)cell;
        TUIReferenceMessageCellData_Minimalist * cellData = acell.referenceData;
        originMsgID = cellData.originMsgID;
        msgAbstract = cellData.msgAbstract;
    }
   
    [(TUIMessageSearchDataProvider_Minimalist *)self.messageDataProvider findMessages:@[originMsgID?:@""] callback:^(BOOL success, NSString * _Nonnull desc, NSArray<V2TIMMessage *> * _Nonnull msgs) {
        if (!success) {
            [TUITool makeToast:TIMCommonLocalizableString(TUIKitReplyMessageNotFoundOriginMessage)];
            return;
        }
        V2TIMMessage *message = msgs.firstObject;
        if (message == nil) {
            [TUITool makeToast:TIMCommonLocalizableString(TUIKitReplyMessageNotFoundOriginMessage)];
            return;
        }
        
        if (message.status == V2TIM_MSG_STATUS_HAS_DELETED || message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
            [TUITool makeToast:TIMCommonLocalizableString(TUIKitReplyMessageNotFoundOriginMessage)];
            return;
        }
        
        if ([cell isKindOfClass:TUIReplyMessageCell_Minimalist.class]) {
            [self jumpDetailPageByMessage:message];
        }
        else if ([cell isKindOfClass:TUIReferenceMessageCell_Minimalist.class]) {
            [self locateAssignMessage:message matchKeyWord:msgAbstract];
        }
    }];
}

- (void)jumpDetailPageByMessage:(V2TIMMessage *)message
{
    NSMutableArray *uiMsgs = [self.messageDataProvider transUIMsgFromIMMsg:@[message]];
    [self.messageDataProvider preProcessMessage:uiMsgs callback:^{
        for (TUIMessageCellData *cellData in uiMsgs) {
            if ([cellData.innerMessage.msgID isEqual:message.msgID]) {
                [self onJumpToRepliesDetailPage:cellData];
                return;
            }
        }
    }];
}


- (void)locateAssignMessage:(V2TIMMessage *)message matchKeyWord:(NSString *)keyword
{
    if (message == nil) {
        return;
    }
    self.locateMessage = message;
    self.hightlightKeyword = keyword;
    
    BOOL memoryExist = NO;
    for (TUIMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
        if ([cellData.innerMessage.msgID isEqual:message.msgID]) {
            memoryExist = YES;
            break;
        }
    }
    if (memoryExist) {
        [self scrollLocateMessage:NO];
        [self highlightKeyword];
        return;
    }
    
    TUIMessageSearchDataProvider_Minimalist *provider = (TUIMessageSearchDataProvider_Minimalist *)self.messageDataProvider;
    provider.isNewerNoMoreMsg = NO;
    provider.isOlderNoMoreMsg = NO;
    [self loadLocateMessages:NO];
}

#pragma mark - TUIMessageBaseDataProviderDataSource
- (void)dataProvider:(TUIMessageDataProvider_Minimalist *)dataProvider
     ReceiveNewUIMsg:(TUIMessageCellData *)uiMsg
{
    [super dataProvider:dataProvider ReceiveNewUIMsg:uiMsg];
    /**
     * 查看历史消息的时候，如果滚动超过两屏，收到新消息后，添加 "xxx条新消息"小舌头
     * When viewing historical messages, if you scroll more than two screens, after receiving a new message, add a "xxx new message" bottom-banner-tips
     */
    if (self.isInVC && self.tableView.contentSize.height - self.tableView.contentOffset.y >= Screen_Height * 2.0) {
        [self.receiveMsgs addObject:uiMsg];
        TUIChatSmallTongue_Minimalist *tongue = [[TUIChatSmallTongue_Minimalist alloc] init];
        tongue.type = TUIChatSmallTongueType_ReceiveNewMsg;
        tongue.unreadMsgCount = self.receiveMsgs.count;
        [TUIChatSmallTongueManager_Minimalist showTongue:tongue delegate:self];
    }
    
    if (self.isInVC) {
        self.C2CIncomingLastMsg = uiMsg.innerMessage;
    }
}

- (void)dataProvider:(TUIMessageDataProvider_Minimalist *)dataProvider
  ReceiveRevokeUIMsg:(TUIMessageCellData *)uiMsg
{
    /**
     * 撤回的消息要从 "xxx条新消息" 移除
     * Recalled messages need to be removed from "xxx new messages" bottom-banner-tips
     */
    [super dataProvider:dataProvider ReceiveRevokeUIMsg:uiMsg];
    if ([self.receiveMsgs containsObject:uiMsg]) {
        [self.receiveMsgs removeObject:uiMsg];
        TUIChatSmallTongue_Minimalist *tongue = [[TUIChatSmallTongue_Minimalist alloc] init];
        tongue.type = TUIChatSmallTongueType_ReceiveNewMsg;
        tongue.unreadMsgCount = self.receiveMsgs.count;
        if (tongue.unreadMsgCount != 0) {
            [TUIChatSmallTongueManager_Minimalist showTongue:tongue delegate:self];
        } else {
            [TUIChatSmallTongueManager_Minimalist removeTongue:TUIChatSmallTongueType_ReceiveNewMsg];
        }
    }
    
    /*
     *  当被撤回的消息是否是 "回复"类型的消息时，去查根消息删除当前被撤回的消息。
     *  When the retracted message is a "reply" type of message, go to the root message to delete the currently retracted message.
     */
    
    if ([uiMsg isKindOfClass:TUIReplyMessageCellData_Minimalist.class]) {
        TUIReplyMessageCellData_Minimalist *cellData = (TUIReplyMessageCellData_Minimalist *)uiMsg;
        NSString *  messageRootID = @"";
        NSString *  revokeMsgID = @"";
        messageRootID = cellData.messageRootID;
        revokeMsgID = cellData.msgID;
        
        [(TUIMessageSearchDataProvider_Minimalist *)self.messageDataProvider findMessages:@[messageRootID?:@""] callback:^(BOOL success, NSString * _Nonnull desc, NSArray<V2TIMMessage *> * _Nonnull msgs) {
            if (success) {
                V2TIMMessage *message = msgs.firstObject;
                [[TUIChatModifyMessageHelper defaultHelper] modifyMessage:message revokeMsgID:revokeMsgID];
            }
            
        }];
    }
}

#pragma mark - TUIChatSmallTongueViewDelegate
- (void)onChatSmallTongueClick:(TUIChatSmallTongue_Minimalist *)tongue
{
    switch (tongue.type) {
        case TUIChatSmallTongueType_ScrollToBoom:
        {
            [self scrollToBottom:YES];
        }
            break;
        case TUIChatSmallTongueType_ReceiveNewMsg:
        {
            [TUIChatSmallTongueManager_Minimalist removeTongue:TUIChatSmallTongueType_ReceiveNewMsg];
            TUIMessageCellData *cellData = self.receiveMsgs.firstObject;
            if (cellData) {
                self.locateMessage = cellData.innerMessage;
                [self scrollLocateMessage:NO];
                [self highlightKeyword];
            }
            [self.receiveMsgs removeAllObjects];
        }
            break;
        case TUIChatSmallTongueType_SomeoneAtMe:
        {
            [TUIChatSmallTongueManager_Minimalist removeTongue:TUIChatSmallTongueType_SomeoneAtMe];
            [self.conversationData.atMsgSeqs removeAllObjects];;
            self.locateGroupMessageSeq = [tongue.atMsgSeqs.firstObject integerValue];
            for (TUIMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
                if ([self isLocateMessage:cellData]) {
                    [self scrollLocateMessage:NO];
                    [self highlightKeyword];
                    return;
                }
            }
            [self loadLocateMessages:NO];
        }
            break;
        default:
            break;
    }
}

@end
