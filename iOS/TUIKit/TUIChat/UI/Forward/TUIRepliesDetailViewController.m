//
//  TUIRepliesDetailViewController.m
//  TUIChat
//
//  Created by wyl on 2022/4/27.
//

#import "TUIRepliesDetailViewController.h"
#import "TUIMessageDataProvider.h"
#import "TUIChatDataProvider.h"
#import "TUITextMessageCellData.h"
#import "TUIMessageCell.h"
#import "TUITextMessageCell.h"

#import "TUIGlobalization.h"
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
#import "TUILinkCell.h"
#import "TUIReplyMessageCell.h"
#import "TUIDarkModel.h"
#import "TUIFileViewController.h"
#import "TUIMessageDataProvider.h"
#import "TUIMediaView.h"
#import "TUIDefine.h"
#import "TUIReplyMessageCellData.h"
#import "TUIReferenceMessageCell.h"
#import "TUIThemeManager.h"
#import "TUIMergeMessageListController.h"


@interface TUIRepliesDetailViewController ()<TInputControllerDelegate,UITableViewDelegate,UITableViewDataSource,TUIMessageDataProviderDataSource,TUIMessageCellDelegate>
@property (nonatomic, strong) TUIMessageCellData *cellData;
@property (nonatomic, strong) TUIMessageDataProvider *msgDataProvider;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<V2TIMMessage *> *imMsgs;
@property (nonatomic, strong) NSMutableArray<TUIMessageCellData *> *uiMsgs;
@property (nonatomic, assign) BOOL responseKeyboard;
@property (nonatomic, strong) TUIChatConversationModel *conversationData;

@property(nonatomic, strong) TUIMessageCellLayout *originCellLayout;
@property TMsgDirection direction;
@property (nonatomic, assign) BOOL showName;
@property (nonatomic, assign) BOOL showMessageTime;
@property (nonatomic) BOOL isMsgNeedReadReceipt;

@end

@implementation TUIRepliesDetailViewController
- (instancetype)initWithCellData:(TUIMessageCellData *)data conversationData:(TUIChatConversationModel *)conversationData {
    self = [super init];
    self.cellData = data;
    [self setConversation:conversationData];
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    
    [self setupInputViewController];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [self updateRootMsg];

    [self applyData];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.responseKeyboard = YES;
    self.isMsgNeedReadReceipt = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.responseKeyboard = NO;
    [self revertRootMsg];
    if (self.willCloseCallback) {
        self.willCloseCallback();
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.inputController.status == Input_Status_Input ||
        self.inputController.status == Input_Status_Input_Keyboard) {
        // 在后台默默关闭键盘 + 调整 tableview 的尺寸为全屏
        CGPoint offset = self.tableView.contentOffset;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.responseKeyboard = YES;
            [UIApplication.sharedApplication.keyWindow endEditing:YES];
            [strongSelf inputController:strongSelf.inputController didChangeHeight:CGRectGetMaxY(strongSelf.inputController.inputBar.frame) + Bottom_SafeHeight];
            [strongSelf.tableView setContentOffset:offset];
        });
    }
}
- (void)applyData {
    /*
     {
     messageAbstract = "1-1";
     messageID = "144115263641742148-1652172672-3557886729";
     messageSender = 1008611;
     messageSequence = 103;
     messageTime = 1652172673;
     messageType = 1;
     version = 1;
 }
     */
    NSArray * messageModifyReplies = self.cellData.messageModifyReplies;
    NSMutableArray * msgIDArray =  [NSMutableArray array];
//    if (IS_NOT_EMPTY_NSSTRING(self.cellData.msgID)) {
//        [msgIDArray addObject:self.cellData.msgID];
//    }
    if (messageModifyReplies.count >0) {
        for (NSDictionary * dic in messageModifyReplies) {
            if (dic) {
                NSString * messageID = dic[@"messageID"];
                if (IS_NOT_EMPTY_NSSTRING(messageID)) {
                    [msgIDArray addObject:messageID];
                }
            }
        }
    }
    __weak typeof(self)weakSelf = self;
    [TUIChatDataProvider findMessages:msgIDArray callback:^(BOOL succ, NSString * _Nonnull error_message, NSArray * _Nonnull msgs) {
        __strong typeof(weakSelf)strongSelf = weakSelf;

        if (succ) {
            if (msgs.count >0) {
                strongSelf.imMsgs = msgs;
                strongSelf.uiMsgs = [self transUIMsgFromIMMsg:msgs];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(strongSelf.uiMsgs.count != 0){
                        [strongSelf.tableView reloadData];
                        [strongSelf.tableView layoutIfNeeded];
                        [strongSelf scrollToBottom:YES];
                    }
                });
            }
        }
    }];
}
- (void)setupViews
{
    self.title = TUIKitLocalizableString(TUIKitRepliesDetailTitle);

    self.tableView.scrollsToTop = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");;
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
    [self.tableView registerClass:[TUIReferenceMessageCell class] forCellReuseIdentifier:TUIReferenceMessageCell_ReuseId];
    
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
    
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
}
- (void)setupInputViewController {
    _inputController = [[TUIInputController alloc] init];
    _inputController.delegate = self;
    _inputController.view.frame = CGRectMake(0, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight, self.view.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    _inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addChildViewController:_inputController];
    [self.view addSubview:_inputController.view];
    TUIFaceGroup *group = TUIConfig.defaultConfig.faceGroups[0];
    [_inputController.faceView setData:(id)@[group]];
    TUIMenuCellData *data = [[TUIMenuCellData alloc] init];
    data.path = group.menuPath;
    data.isSelected = YES;
    [_inputController.menuView setData:(id)@[data]];
    
    CGFloat margin = 20;
    CGFloat padding = 10;
    _inputController.inputBar.inputTextView.frame = CGRectMake(margin, _inputController.inputBar.inputTextView.frame.origin.y, _inputController.inputBar.frame.size.width - _inputController.inputBar.faceButton.frame.size.width - margin *2  - padding, _inputController.inputBar.inputTextView.frame.size.height);
    
    _inputController.inputBar.faceButton.frame = CGRectMake(_inputController.inputBar.frame.size.width - _inputController.inputBar.faceButton.frame.size.width - margin, _inputController.inputBar.faceButton.frame.origin.y, _inputController.inputBar.faceButton.frame.size.width , _inputController.inputBar.faceButton.frame.size.height);
    
    if (_inputController.inputBar.micButton) {
        [_inputController.inputBar.micButton removeFromSuperview];
    }
    if (_inputController.inputBar.moreButton) {
        [_inputController.inputBar.moreButton removeFromSuperview];
    }
}

- (void)updateRootMsg {
    self.originCellLayout = self.cellData.cellLayout;
    self.direction = self.cellData.direction;
    self.showName = self.cellData.showName;
    self.showMessageTime = self.cellData.showMessageTime;
    
    TUIMessageCellData *data = self.cellData;
    TUIMessageCellLayout *layout = TUIMessageCellLayout.incommingMessageLayout;
    if ([data isKindOfClass:TUITextMessageCellData.class]) {
        layout = TUIMessageCellLayout.incommingTextMessageLayout;
        TUITextMessageCellData * textData = (TUITextMessageCellData *)data;
        textData.textColor = [TUITextMessageCellData incommingTextColor];
        textData.textFont = [TUITextMessageCellData incommingTextFont];
    }
    if( [data isKindOfClass:TUIReferenceMessageCellData.class]) {
        layout = TUIMessageCellLayout.incommingTextMessageLayout;
        TUIReferenceMessageCellData * textData = (TUIReferenceMessageCellData *)data;
        textData.textColor = [TUITextMessageCellData incommingTextColor];
    }
    if ([data isKindOfClass:TUIVoiceMessageCellData.class] ) {
        layout = [TUIMessageCellLayout incommingVoiceMessageLayout];
    }
    self.cellData.cellLayout = layout;
    self.cellData.direction = MsgDirectionIncoming;
    self.cellData.showName = YES;
    self.cellData.showMessageModifyReplies = NO;
    self.cellData.showMessageTime = YES;
    
}
- (void)revertRootMsg {
    self.cellData.cellLayout = self.originCellLayout;
    self.cellData.direction = self.direction;
    self.cellData.showName = self.showName;
    self.cellData.showMessageModifyReplies = YES;
    self.cellData.showMessageTime = self.showMessageTime;
}


- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs
{
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = 0; k < msgs.count; k++) {
        V2TIMMessage *msg = msgs[k];
        TUIMessageCellData *data = [TUITextMessageCellData getCellData:msg];
        // 全部设置为 incomming
        TUIMessageCellLayout *layout = TUIMessageCellLayout.incommingMessageLayout;
        if ([data isKindOfClass:TUITextMessageCellData.class]) {
            layout = TUIMessageCellLayout.incommingTextMessageLayout;
            TUITextMessageCellData * textData = (TUITextMessageCellData *)data;
            textData.textColor = [TUITextMessageCellData incommingTextColor];
            textData.textFont = [TUITextMessageCellData incommingTextFont];
        }
        data.cellLayout = layout;
        data.direction = MsgDirectionIncoming;
        data.showName = YES;
        if(data) {
            data.innerMessage = msg;
            data.msgID = msg.msgID;
            data.identifier = msg.sender;
            data.name = data.identifier;
            if (msg.nameCard.length > 0) {
                data.name = msg.nameCard;
            } else if (msg.nickName.length > 0){
                data.name = msg.nickName;
            }
            data.avatarUrl = [NSURL URLWithString:msg.faceURL];
            [uiMsgs addObject:data];
        }
    }
    return uiMsgs;
}


#pragma mark - tableView

- (UITableView *)tableView {
    if (!_tableView) {
        CGRect rect = self.view.bounds;
        if (![UINavigationBar appearance].isTranslucent && [[[UIDevice currentDevice] systemVersion] doubleValue]<15.0) {
            rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - TabBar_Height - NavBar_Height  - TTextView_Height);
        }
        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 20;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
    return  nil;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 0.5;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 0.5)];
        line.backgroundColor = TUICoreDynamicColor(@"separator_color", @"#DBDBDB");
        return line;
    }
    return nil;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return _uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self.cellData heightOfWidth:Screen_Width];
    }
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
    CGFloat height = [data heightOfWidth:Screen_Width];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        TUIMessageCell *cell = nil;
        TUIMessageCellData *data = self.cellData;
        cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
        cell.delegate = self;
        [cell fillWithData:data];
        return cell;
    }
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
    data.showMessageTime = YES;
    data.showCheckBox = NO;
    TUIMessageCell *cell = nil;

    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    [cell fillWithData:_uiMsgs[indexPath.row]];
    cell.delegate = self;
    if ([cell isKindOfClass:TUIBubbleMessageCell.class]) {
        TUIBubbleMessageCell * bubbleCell = (TUIBubbleMessageCell *)cell;
        if (bubbleCell.bubbleView) {
            bubbleCell.bubbleView.image = nil;
        }
    }
    return cell;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.inputController reset];
}
#pragma mark - TInputControllerDelegate

- (void)inputController:(TUIInputController *)inputController didChangeHeight:(CGFloat)height
{
    if (!self.responseKeyboard) {
        return;
    }
    //目标celldata
    if (self.inputController.replyData ==  nil) {
        [self onRelyMessage:self.cellData];
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect msgFrame = self.tableView.frame;
        msgFrame.size.height = self.view.frame.size.height - height;
        self.tableView.frame = msgFrame;

        CGRect inputFrame = self.inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        self.inputController.view.frame = inputFrame;

                
        [self scrollToBottom:NO];
    } completion:nil];
}


- (void)inputController:(TUIInputController *)inputController didSendMessage:(V2TIMMessage *)msg {
    [self sendMessage:msg];
}

- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell
{
    cell.disableDefaultSelectAction = NO;
    
    if (cell.disableDefaultSelectAction) {
        return;
    }

}


- (void)sendMessage:(V2TIMMessage *)message
{
    TUIMessageCellData *cellData = nil;
    if (!cellData) {
        cellData = [TUIMessageDataProvider getCellData:message];
    }
    if (cellData) {
        cellData.innerMessage.needReadReceipt = self.isMsgNeedReadReceipt;
        [self sendUIMessage:cellData];
    }
}

- (void)sendUIMessage:(TUIMessageCellData *)cellData {
    @weakify(self);
    [self.parentPageDataProvider sendUIMsg:cellData
                         toConversation:self.conversationData
                          willSendBlock:^(BOOL isReSend, TUIMessageCellData * _Nonnull dateUIMsg) {
        @strongify(self);
        
        int delay = 1;
        if ([cellData isKindOfClass:[TUIImageMessageCellData class]]) {
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
        [self changeMsg:cellData status:Msg_Status_Succ];
        [self scrollToBottom:YES];
    } FailBlock:^(int code, NSString *desc) {
        @strongify(self)
        [TUITool makeToastError:code msg:desc];
        [self changeMsg:cellData status:Msg_Status_Fail];
    }];
}

- (void)scrollToBottom:(BOOL)animated{
    if (self.uiMsgs.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.uiMsgs.count - 1 inSection:1]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }

}

- (void)changeMsg:(TUIMessageCellData *)msg status:(TMsgStatus)status
{
    msg.status = status;
    NSInteger index = [self.uiMsgs indexOfObject:msg];
    if ([self.tableView numberOfRowsInSection:0] > index) {
        TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell fillWithData:msg];
    } else {
        NSLog(@"缺少cell");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kTUINotifyMessageStatusChanged" object:nil userInfo:@{
        @"msg": msg,
        @"status": [NSNumber numberWithUnsignedInteger:status],
        @"msgSender": self,
    }];
}


#pragma mark - 消息回复


- (void)onRelyMessage:(nonnull TUIMessageCellData *)data
{
    NSString *desc = @"";
    desc = [self replyReferenceMessageDesc:data];
    
    TUIReplyPreviewData *replyData = [[TUIReplyPreviewData alloc] init];
    replyData.msgID = data.msgID;
    replyData.msgAbstract = desc;
    replyData.sender = data.name;
    replyData.type = (NSInteger)data.innerMessage.elemType;
    replyData.originMessage = data.innerMessage;
    self.inputController.replyData = replyData;
}
- (NSString *)replyReferenceMessageDesc:(TUIMessageCellData *)data {
    NSString *desc = @"";
    if (data.innerMessage.elemType == V2TIM_ELEM_TYPE_FILE) {
        desc = data.innerMessage.fileElem.filename;
    } else if (data.innerMessage.elemType == V2TIM_ELEM_TYPE_MERGER) {
        desc = data.innerMessage.mergerElem.title;
    } else if (data.innerMessage.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        desc = [TUIMessageDataProvider getDisplayString:data.innerMessage];
    } else if (data.innerMessage.elemType == V2TIM_ELEM_TYPE_TEXT) {
        desc = data.innerMessage.textElem.text;
    }
    return desc;
}

#pragma mark - TUIMessageCellDelegate
- (void)onSelectMessage:(TUIMessageCell *)cell
{
    if ([cell isKindOfClass:[TUIImageMessageCell class]]) {
        [self showImageMessage:(TUIImageMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIVoiceMessageCell class]]) {
        [self playVoiceMessage:(TUIVoiceMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIVideoMessageCell class]]) {
        [self showVideoMessage:(TUIVideoMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIFileMessageCell class]]) {
        [self showFileMessage:(TUIFileMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIMergeMessageCell class]]) {
        TUIMergeMessageListController *relayVc = [[TUIMergeMessageListController alloc] init];
        relayVc.mergerElem = [(TUIMergeMessageCell *)cell relayData].mergerElem;
        relayVc.delegate = self.delegate;
        [self.navigationController pushViewController:relayVc animated:YES];
    }
    if ([cell isKindOfClass:[TUIGroupLiveMessageCell class]]) {
        [self showLiveMessage:(TUIGroupLiveMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUILinkCell class]]) {
        [self showLinkMessage:(TUILinkCell *)cell];
    }
//    if ([cell isKindOfClass:[TUIReplyMessageCell class]]) {
//        [self showReplyMessage:(TUIReplyMessageCell *)cell];
//    }
//    if ([cell isKindOfClass:[TUIReferenceMessageCell class]]) {
//        [self showReplyMessage:(TUIReplyMessageCell *)cell];
//    }

    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:nil onSelectMessageContent:cell];
    }
}

#pragma mark - dataProviderDataChange
- (void)dataProviderDataSourceWillChange:(TUIMessageDataProvider *)dataProvider {
    
}
- (void)dataProviderDataSourceChange:(TUIMessageDataProvider *)dataProvider
                            withType:(TUIMessageDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation {
    
}
- (void)dataProviderDataSourceDidChange:(TUIMessageDataProvider *)dataProvider {
    for (TUIMessageCellData *cellData in dataProvider.uiMsgs) {
        if ([cellData.innerMessage.msgID isEqual:self.cellData.msgID]) {
            self.cellData.messageModifyReplies = cellData.messageModifyReplies;
            break;
        }
    }
    
    [self applyData];
    
    
   
}


#pragma mark - action

- (void)showImageMessage:(TUIImageMessageCell *)cell
{
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView *mediaView = [[TUIMediaView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:@[self.cellData.innerMessage]];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)playVoiceMessage:(TUIVoiceMessageCell *)cell
{
        TUIVoiceMessageCellData *uiMsg = (TUIVoiceMessageCellData *)self.cellData;
        if(uiMsg == cell.voiceData){
            [uiMsg playVoiceMessage];
            cell.voiceReadPoint.hidden = YES;
        }
        else{
            [uiMsg stopVoiceMessage];
        }
}

- (void)showVideoMessage:(TUIVideoMessageCell *)cell
{
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView *mediaView = [[TUIMediaView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:@[self.cellData.innerMessage]];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)showFileMessage:(TUIFileMessageCell *)cell
{
    TUIFileViewController *file = [[TUIFileViewController alloc] init];
    file.data = [cell fileData];
    [self.navigationController pushViewController:file animated:YES];
}

- (void)showLinkMessage:(TUILinkCell *)cell {
    TUILinkCellData *cellData = cell.customData;
    if (cellData.link) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cellData.link]];
    }
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

- (void)setConversation:(TUIChatConversationModel *)conversationData {
    self.conversationData = conversationData;
    if (!self.msgDataProvider) {
        self.msgDataProvider = [[TUIMessageDataProvider alloc] initWithConversationModel:conversationData];
        self.msgDataProvider.dataSource = self;
    }
    [self loadMessage];
}
- (void)loadMessage
{
    if (self.msgDataProvider.isLoadingData || self.msgDataProvider.isNoMoreMsg) {
        return;
    }
    
    [self.msgDataProvider loadMessageSucceedBlock:^(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TUIMessageCellData *> * _Nonnull newMsgs) {
        
    } FailBlock:^(int code, NSString *desc) {
        [TUITool makeToastError:code msg:desc];
    }];
}
@end
