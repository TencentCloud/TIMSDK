//
//  TUIRepliesDetailViewController.m
//  TUIChat
//
//  Created by wyl on 2022/4/27.
//

#import "TUIRepliesDetailViewController_Minimalist.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUIChatDataProvider_Minimalist.h"
#import "TUITextMessageCellData_Minimalist.h"
#import "TUIMessageCell.h"
#import "TUITextMessageCell_Minimalist.h"
#import "TUIMenuCellData_Minimalist.h"

#import "TUITextMessageCell_Minimalist.h"
#import "TUISystemMessageCell.h"
#import "TUIVoiceMessageCell_Minimalist.h"
#import "TUIImageMessageCell_Minimalist.h"
#import "TUIFaceMessageCell_Minimalist.h"
#import "TUIVideoMessageCell_Minimalist.h"
#import "TUIFileMessageCell_Minimalist.h"
#import "TUIJoinGroupMessageCell_Minimalist.h"
#import "TUIMergeMessageCell_Minimalist.h"
#import "TUILinkCell_Minimalist.h"
#import "TUIReplyMessageCell_Minimalist.h"
#import "TUIFileViewController_Minimalist.h"
#import "TUIReplyMessageCellData_Minimalist.h"
#import "TUIReferenceMessageCell_Minimalist.h"
#import "TUIMergeMessageListController_Minimalist.h"
#import "TUIMediaView_Minimalist.h"
#import "TUIGlobalization.h"
#import "TUIDefine.h"
#import "TUIDarkModel.h"
#import "TUIThemeManager.h"


@interface TUIRepliesDetailViewController_Minimalist ()<TUIInputControllerDelegate_Minimalist,UITableViewDelegate,UITableViewDataSource,TUIMessageBaseDataProviderDataSource,TUIMessageCellDelegate>

@property (nonatomic, strong) TUIMessageCellData *cellData;
@property (nonatomic, strong) TUIMessageDataProvider_Minimalist *msgDataProvider;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<V2TIMMessage *> *imMsgs;
@property (nonatomic, strong) NSMutableArray<TUIMessageCellData *> *uiMsgs;
@property (nonatomic, assign) BOOL responseKeyboard;
@property (nonatomic, strong) TUIChatConversationModel *conversationData;
@property(nonatomic, strong) TUIMessageCellLayout *originCellLayout;
@property TMsgDirection direction;
@property (nonatomic, assign) BOOL showAvatar;
@property (nonatomic, assign) BOOL sameToNextMsgSender;
@property (nonatomic) BOOL isMsgNeedReadReceipt;

//topGestureView subviews
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TUIRepliesDetailViewController_Minimalist
- (instancetype)initWithCellData:(TUIMessageCellData *)data conversationData:(TUIChatConversationModel *)conversationData {
    self = [super init];
    self.cellData = data;
    self.showAvatar = data.showAvatar;
    self.sameToNextMsgSender = data.sameToNextMsgSender;
    self.cellData.showAvatar = YES;
    self.cellData.sameToNextMsgSender = NO;
    [self setConversation:conversationData];
    return self;
}

- (void)dealloc {
    self.cellData.showAvatar = self.showAvatar;
    self.cellData.sameToNextMsgSender = self.sameToNextMsgSender;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    
//    [self setupInputViewController];

    [self setnormalTop];
    
    self.topImgView.hidden = YES;
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:TUIKitLocalizableString(Cancel) forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton sizeToFit];
    [self.topGestureView addSubview:_cancelButton];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text =  [NSString stringWithFormat:@"0 %@",TUIKitLocalizableString(TUIKitThreadQuote)];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    _titleLabel.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");
    [_titleLabel sizeToFit];
    [self.topGestureView addSubview:_titleLabel];

    [self updateSubContainerView];
}

- (void)updateSubContainerView {
//    [super updateSubContainerView];
    self.topGestureView.frame = CGRectMake(0, 0, self.containerView.frame.size.width, kScale390(60));
    self.cancelButton.frame = CGRectMake(kScale390(15), (self.topGestureView.bounds.size.height - kScale390(22))*0.5, self.cancelButton.frame.size.width, kScale390(22));
    self.titleLabel.frame = CGRectMake((self.topGestureView.bounds.size.width - self.titleLabel.frame.size.width) *0.5, self.cancelButton.frame.origin.y, self.titleLabel.frame.size.width, kScale390(22));
    
    self.tableView.frame = CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width, self.containerView.frame.size.height - self.topGestureView.frame.size.height);
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateRootMsg];

    [self applyData];

    [self updateTableViewConstraint];

    [self updateSubContainerView];

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
    NSArray * messageModifyReplies = self.cellData.messageModifyReplies;
    NSMutableArray * msgIDArray =  [NSMutableArray array];
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
    
    // When the only reply is retracted, go back to the previous controller
    if (msgIDArray.count <= 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    self.titleLabel.text =  [NSString stringWithFormat:@"%lu %@",(unsigned long)msgIDArray.count,TUIKitLocalizableString(TUIKitThreadQuote)];
    [self.titleLabel sizeToFit];
    __weak typeof(self)weakSelf = self;
    [TUIChatDataProvider_Minimalist findMessages:msgIDArray callback:^(BOOL succ, NSString * _Nonnull error_message, NSArray * _Nonnull msgs) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (succ) {
            if (msgs.count >0) {
                strongSelf.imMsgs = msgs;
                strongSelf.uiMsgs = [self transUIMsgFromIMMsg:msgs];
                for (TUIMessageCellData *data in strongSelf.uiMsgs) {
                    [TUIMessageDataProvider_Minimalist updateUIMsgStatus:data uiMsgs:strongSelf.uiMsgs];
                }
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

- (void)updateTableViewConstraint {
    CGFloat height = CGRectGetMaxY(self.inputController.inputBar.frame) + Bottom_SafeHeight;
    CGRect msgFrame = self.tableView.frame;
    msgFrame.size.height = self.view.frame.size.height - height;
    self.tableView.frame = msgFrame;
}

- (void)setupViews
{
    self.title = TUIKitLocalizableString(TUIKitRepliesDetailTitle);
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    self.tableView.scrollsToTop = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
    
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
}
- (void)setupInputViewController {
    _inputController = [[TUIInputController_Minimalist alloc] init];
    _inputController.delegate = self;
    _inputController.view.frame = CGRectMake(0, self.containerView.frame.size.height - TTextView_Height - Bottom_SafeHeight, self.containerView.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    _inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addChildViewController:_inputController];
    [self.containerView addSubview:_inputController.view];
    TUIFaceGroup *group = TUIConfig.defaultConfig.faceGroups[0];
    [_inputController.faceView setData:(id)@[group]];
    TUIMenuCellData_Minimalist *data = [[TUIMenuCellData_Minimalist alloc] init];
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
    if (_inputController.inputBar.cameraButton) {
        [_inputController.inputBar.cameraButton removeFromSuperview];
    }
}

- (void)updateRootMsg {
    self.originCellLayout = self.cellData.cellLayout;
    self.direction = self.cellData.direction;
    
    TUIMessageCellData *data = self.cellData;
    TUIMessageCellLayout *layout = TUIMessageCellLayout.incommingMessageLayout;
    if ([data isKindOfClass:TUITextMessageCellData_Minimalist.class]) {
        layout = TUIMessageCellLayout.incommingTextMessageLayout;
        TUITextMessageCellData_Minimalist * textData = (TUITextMessageCellData_Minimalist *)data;
        textData.textColor = [TUITextMessageCellData_Minimalist incommingTextColor];
        textData.textFont = [TUITextMessageCellData_Minimalist incommingTextFont];
    }
    if( [data isKindOfClass:TUIReferenceMessageCellData_Minimalist.class]) {
        layout = TUIMessageCellLayout.incommingTextMessageLayout;
        TUIReferenceMessageCellData_Minimalist * textData = (TUIReferenceMessageCellData_Minimalist *)data;
        textData.textColor = [TUITextMessageCellData_Minimalist incommingTextColor];
    }
    if ([data isKindOfClass:TUIVoiceMessageCellData_Minimalist.class] ) {
        layout = [TUIMessageCellLayout incommingVoiceMessageLayout];
    }
    self.cellData.cellLayout = layout;
    self.cellData.direction = MsgDirectionIncoming;
    self.cellData.showMessageModifyReplies = NO;
}
- (void)revertRootMsg {
    self.cellData.cellLayout = self.originCellLayout;
    self.cellData.direction = self.direction;
    self.cellData.showMessageModifyReplies = YES;
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs
{
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = 0; k < msgs.count; k++) {
        V2TIMMessage *msg = msgs[k];
        TUIMessageCellData *data = [TUITextMessageCellData_Minimalist getCellData:msg];
        TUIMessageCellLayout *layout = TUIMessageCellLayout.incommingMessageLayout;
        if ([data isKindOfClass:TUITextMessageCellData_Minimalist.class]) {
            layout = TUIMessageCellLayout.incommingTextMessageLayout;
            TUITextMessageCellData_Minimalist * textData = (TUITextMessageCellData_Minimalist *)data;
            textData.textColor = [TUITextMessageCellData_Minimalist incommingTextColor];
            textData.textFont = [TUITextMessageCellData_Minimalist incommingTextFont];
        }
        data.direction = MsgDirectionIncoming;
        data.cellLayout = layout;
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
    
    NSArray * sortedArray = [uiMsgs sortedArrayUsingComparator:^NSComparisonResult(TUIMessageCellData *obj1, TUIMessageCellData *obj2) {
        if ([obj1.innerMessage.timestamp timeIntervalSince1970] == [obj2.innerMessage.timestamp timeIntervalSince1970]) {
            return obj1.innerMessage.seq > obj2.innerMessage.seq;
        } else {
            return [obj1.innerMessage.timestamp compare:obj2.innerMessage.timestamp];
        }
    }];
    
    uiMsgs = [NSMutableArray arrayWithArray:sortedArray];
    
    return uiMsgs;
}


#pragma mark - tableView

- (UITableView *)tableView {
    if (!_tableView) {
        CGRect rect = CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width, self.containerView.frame.size.height - self.topGestureView.frame.size.height);

        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        [self.containerView addSubview:_tableView];
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
    data.showCheckBox = NO;
    TUIMessageCell *cell = nil;

    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    [cell fillWithData:_uiMsgs[indexPath.row]];
    cell.delegate = self;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.inputController reset];
}

#pragma mark - TUIInputControllerDelegate

- (void)inputController:(TUIInputController_Minimalist *)inputController didChangeHeight:(CGFloat)height
{
    if (!self.responseKeyboard) {
        return;
    }
    
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


- (void)inputController:(TUIInputController_Minimalist *)inputController didSendMessage:(V2TIMMessage *)msg {
    [self sendMessage:msg];
}

- (void)inputController:(TUIInputController_Minimalist *)inputController didSelectMoreCell:(TUIInputMoreCell_Minimalist *)cell
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
        cellData = [TUIMessageDataProvider_Minimalist getCellData:message];
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

- (void)onCancel:(id)btn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeMsg:(TUIMessageCellData *)msg status:(TMsgStatus)status
{
    msg.status = status;
    NSInteger index = [self.uiMsgs indexOfObject:msg];
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


#pragma mark - Message reply

- (void)onRelyMessage:(nonnull TUIMessageCellData *)data
{
    NSString *desc = @"";
    desc = [self replyReferenceMessageDesc:data];
    
    TUIReplyPreviewData_Minimalist *replyData = [[TUIReplyPreviewData_Minimalist alloc] init];
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
        desc = [TUIMessageDataProvider_Minimalist getDisplayString:data.innerMessage];
    } else if (data.innerMessage.elemType == V2TIM_ELEM_TYPE_TEXT) {
        desc = data.innerMessage.textElem.text;
    }
    return desc;
}

#pragma mark - TUIMessageCellDelegate
- (void)onSelectMessage:(TUIMessageCell *)cell
{
    if ([cell isKindOfClass:[TUIImageMessageCell_Minimalist class]]) {
        [self showImageMessage:(TUIImageMessageCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIVoiceMessageCell_Minimalist class]]) {
        [self playVoiceMessage:(TUIVoiceMessageCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIVideoMessageCell_Minimalist class]]) {
        [self showVideoMessage:(TUIVideoMessageCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIFileMessageCell_Minimalist class]]) {
        [self showFileMessage:(TUIFileMessageCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIMergeMessageCell_Minimalist class]]) {
        TUIMergeMessageListController_Minimalist *relayVc = [[TUIMergeMessageListController_Minimalist alloc] init];
        relayVc.mergerElem = [(TUIMergeMessageCell_Minimalist *)cell relayData].mergerElem;
        relayVc.delegate = self.delegate;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:relayVc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:NO completion:nil];
    }
    if ([cell isKindOfClass:[TUILinkCell_Minimalist class]]) {
        [self showLinkMessage:(TUILinkCell_Minimalist *)cell];
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
- (void)dataProviderDataSourceWillChange:(TUIMessageBaseDataProvider *)dataProvider {
    
}
- (void)dataProviderDataSourceChange:(TUIMessageBaseDataProvider *)dataProvider
                            withType:(TUIMessageBaseDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation {
    
}
- (void)dataProviderDataSourceDidChange:(TUIMessageBaseDataProvider *)dataProvider {
    for (TUIMessageCellData *cellData in dataProvider.uiMsgs) {
        if ([cellData.innerMessage.msgID isEqual:self.cellData.msgID]) {
            self.cellData.messageModifyReplies = cellData.messageModifyReplies;
            break;
        }
    }
    
    [self applyData];
    
    
   
}


#pragma mark - action

- (void)showImageMessage:(TUIImageMessageCell_Minimalist *)cell
{
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView_Minimalist *mediaView = [[TUIMediaView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:@[self.cellData.innerMessage]];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)playVoiceMessage:(TUIVoiceMessageCell_Minimalist *)cell
{
        TUIVoiceMessageCellData_Minimalist *uiMsg = (TUIVoiceMessageCellData_Minimalist *)self.cellData;
        if(uiMsg == cell.voiceData){
            [uiMsg playVoiceMessage];
            cell.voiceReadPoint.hidden = YES;
        }
        else{
            [uiMsg stopVoiceMessage];
        }
}

- (void)showVideoMessage:(TUIVideoMessageCell_Minimalist *)cell
{
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView_Minimalist *mediaView = [[TUIMediaView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:@[self.cellData.innerMessage]];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)showFileMessage:(TUIFileMessageCell_Minimalist *)cell
{
    TUIFileMessageCellData_Minimalist *fileData = cell.fileData;
    if (![fileData isLocalExist]) {
        [fileData downloadFile];
        return;
    }
    

    TUIFileViewController_Minimalist *file = [[TUIFileViewController_Minimalist alloc] init];
    file.data = [cell fileData];
    file.dismissClickCallback = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:file];
    
    [self presentViewController:nav animated:NO completion:nil];
}

- (void)showLinkMessage:(TUILinkCell_Minimalist *)cell {
    TUILinkCellData_Minimalist *cellData = cell.customData;
    if (cellData.link) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cellData.link]];
    }
}

- (void)setConversation:(TUIChatConversationModel *)conversationData {
    self.conversationData = conversationData;
    if (!self.msgDataProvider) {
        self.msgDataProvider = [[TUIMessageDataProvider_Minimalist alloc] initWithConversationModel:conversationData];
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
