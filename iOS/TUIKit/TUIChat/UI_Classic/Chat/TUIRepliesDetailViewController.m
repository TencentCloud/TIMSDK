//
//  TUIRepliesDetailViewController.m
//  TUIChat
//
//  Created by wyl on 2022/4/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIRepliesDetailViewController.h"
#import <TIMCommon/TUIMessageCell.h>
#import "TUIChatDataProvider.h"
#import "TUIMessageDataProvider.h"
#import "TUITextMessageCell.h"
#import "TUITextMessageCellData.h"
#import "TUIChatConfig.h"

#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUISystemMessageCell.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIFaceMessageCell.h"
#import "TUIFileMessageCell.h"
#import "TUIFileViewController.h"
#import "TUIImageMessageCell.h"
#import "TUIJoinGroupMessageCell.h"
#import "TUILinkCell.h"
#import "TUIMediaView.h"
#import "TUIMergeMessageCell.h"
#import "TUIMergeMessageListController.h"
#import "TUIMessageDataProvider.h"
#import "TUIReferenceMessageCell.h"
#import "TUIReplyMessageCell.h"
#import "TUIReplyMessageCellData.h"
#import "TUITextMessageCell.h"
#import "TUIVideoMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "TUIMessageCellConfig.h"

@interface TUIRepliesDetailViewController () <TUIInputControllerDelegate,
                                              UITableViewDelegate,
                                              UITableViewDataSource,
                                              TUIMessageBaseDataProviderDataSource,
                                              TUIMessageCellDelegate,
                                              TUINotificationProtocol,
                                              V2TIMAdvancedMsgListener>

@property(nonatomic, strong) TUIMessageCellData *cellData;
@property(nonatomic, strong) TUIMessageDataProvider *msgDataProvider;

@property(nonatomic, strong) UIView *headerView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray<V2TIMMessage *> *imMsgs;
@property(nonatomic, strong) NSMutableArray<TUIMessageCellData *> *uiMsgs;
@property(nonatomic, assign) BOOL responseKeyboard;
@property(nonatomic, strong) TUIChatConversationModel *conversationData;
@property(nonatomic, strong) TUIMessageCellConfig *messageCellConfig;

@property(nonatomic, strong) TUIMessageCellLayout *originCellLayout;
@property TMsgDirection direction;
@property(nonatomic, assign) BOOL showName;
@property(nonatomic, assign) BOOL showMessageTime;
@property(nonatomic) BOOL isMsgNeedReadReceipt;

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

    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];

    [TUICore registerEvent:TUICore_TUIPluginNotify
                    subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey
                    object:self];
}
- (void)viewWillAppear:(BOOL)animated {
    [self updateRootMsg];

    [self applyData];

    [self updateTableViewConstraint];

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
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (self.inputController.status == Input_Status_Input || self.inputController.status == Input_Status_Input_Keyboard) {
        CGPoint offset = self.tableView.contentOffset;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
          __strong typeof(weakSelf) strongSelf = weakSelf;
          strongSelf.responseKeyboard = YES;
          [UIApplication.sharedApplication.keyWindow endEditing:YES];
          [strongSelf inputController:strongSelf.inputController didChangeHeight:CGRectGetMaxY(strongSelf.inputController.inputBar.frame) + Bottom_SafeHeight];
          [strongSelf.tableView setContentOffset:offset];
        });
    }
}

- (void)dealloc {
    NSLog(@"%s dealloc", __FUNCTION__);
    [TUICore unRegisterEventByObject:self];
}

- (void)applyData {
    NSArray *messageModifyReplies = self.cellData.messageModifyReplies;
    NSMutableArray *msgIDArray = [NSMutableArray array];
    if (messageModifyReplies.count > 0) {
        for (NSDictionary *dic in messageModifyReplies) {
            if (dic) {
                NSString *messageID = dic[@"messageID"];
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

    __weak typeof(self) weakSelf = self;
    [TUIChatDataProvider findMessages:msgIDArray
                             callback:^(BOOL succ, NSString *_Nonnull error_message, NSArray *_Nonnull msgs) {
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                               if (succ) {
                                   if (msgs.count > 0) {
                                       strongSelf.imMsgs = msgs;
                                       strongSelf.uiMsgs = [self transUIMsgFromIMMsg:msgs];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                         if (strongSelf.uiMsgs.count != 0) {
                                             [strongSelf.tableView reloadData];
                                             [strongSelf.tableView layoutIfNeeded];
                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 
                                                                          (int64_t)(0.1 * NSEC_PER_SEC)),
                                                            dispatch_get_main_queue(), ^{
                                                 [strongSelf scrollToBottom:NO];
                                             });
                                         }
                                       });
                                   }
                               }
                             }];
}

- (void)updateTableViewConstraint {
    CGFloat textViewHeight = TUIChatConfig.defaultConfig.enableMainPageInputBar? TTextView_Height:0;
    CGFloat height = textViewHeight + Bottom_SafeHeight;
    CGRect msgFrame = self.tableView.frame;
    msgFrame.size.height = self.view.frame.size.height - height;
    self.tableView.frame = msgFrame;
}

- (void)setupViews {
    self.title = TIMCommonLocalizableString(TUIKitRepliesDetailTitle);
    self.view.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");
    self.tableView.scrollsToTop = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    [self.messageCellConfig bindTableView:self.tableView];
}

- (void)setupInputViewController {
    _inputController = [[TUIInputController alloc] init];
    _inputController.delegate = self;
    _inputController.view.frame =
        CGRectMake(0, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight, self.view.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    _inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _inputController.inputBar.isFromReplyPage = YES;
    [self addChildViewController:_inputController];
    [self.view addSubview:_inputController.view];
    TUIFaceGroup *group = TIMConfig.defaultConfig.faceGroups[0];
    [_inputController.faceSegementScrollView setItems:(id) @[ group ] delegate:(id)_inputController];
    TUIMenuCellData *data = [[TUIMenuCellData alloc] init];
    data.path = group.menuPath;
    data.isSelected = YES;
    [_inputController.menuView setData:(id) @[ data ]];
    _inputController.view.hidden = !TUIChatConfig.defaultConfig.enableMainPageInputBar;
    CGFloat margin = 0;
    CGFloat padding = 10;
    _inputController.inputBar.inputTextView.frame =
        CGRectMake(margin, _inputController.inputBar.inputTextView.frame.origin.y,
                   _inputController.inputBar.frame.size.width - _inputController.inputBar.faceButton.frame.size.width - margin * 2 - padding,
                   _inputController.inputBar.inputTextView.frame.size.height);

    _inputController.inputBar.faceButton.frame =
        CGRectMake(_inputController.inputBar.frame.size.width - _inputController.inputBar.faceButton.frame.size.width - margin,
                   _inputController.inputBar.faceButton.frame.origin.y, _inputController.inputBar.faceButton.frame.size.width,
                   _inputController.inputBar.faceButton.frame.size.height);

    if (_inputController.inputBar.micButton) {
        _inputController.inputBar.micButton.alpha = 0;
    }
    if (_inputController.inputBar.moreButton) {
        _inputController.inputBar.moreButton.alpha = 0;
    }
    [_inputController.inputBar defaultLayout];
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
    }
    if ([data isKindOfClass:TUIReferenceMessageCellData.class]) {
        layout = TUIMessageCellLayout.incommingTextMessageLayout;
    }
    if ([data isKindOfClass:TUIVoiceMessageCellData.class]) {
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

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs {
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = 0; k < msgs.count; k++) {
        V2TIMMessage *msg = msgs[k];
        TUIMessageCellData *data = [TUITextMessageCellData getCellData:msg];
        TUIMessageCellLayout *layout = TUIMessageCellLayout.incommingMessageLayout;
        if ([data isKindOfClass:TUITextMessageCellData.class]) {
            layout = TUIMessageCellLayout.incommingTextMessageLayout;
        }
        data.cellLayout = layout;
        data.direction = MsgDirectionIncoming;
        data.showName = YES;
        if (data) {
            data.innerMessage = msg;
            data.msgID = msg.msgID;
            data.identifier = msg.sender;
            data.name = data.identifier;
            if (msg.nameCard.length > 0) {
                data.name = msg.nameCard;
            } else if (msg.nickName.length > 0) {
                data.name = msg.nickName;
            }
            data.avatarUrl = [NSURL URLWithString:msg.faceURL];
            [uiMsgs addObject:data];
        }
    }

    NSArray *sortedArray = [uiMsgs sortedArrayUsingComparator:^NSComparisonResult(TUIMessageCellData *obj1, TUIMessageCellData *obj2) {
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
        CGRect rect = self.view.bounds;
        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
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
    return nil;
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
        line.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
        return line;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return _uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self.messageCellConfig getHeightFromMessageCellData:self.cellData];
    } else {
        if (indexPath.row < self.uiMsgs.count) {
            TUIMessageCellData *cellData = self.uiMsgs[indexPath.row];
            return [self.messageCellConfig getHeightFromMessageCellData:cellData];
        } else {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TUIMessageCell *cell = nil;
        TUIMessageCellData *data = self.cellData;
        cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
        cell.delegate = self;
        [cell fillWithData:data];
        [cell notifyBottomContainerReadyOfData:nil];
        return cell;
    }
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
    data.showMessageTime = YES;
    data.showCheckBox = NO;
    TUIMessageCell *cell = nil;

    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    [cell fillWithData:_uiMsgs[indexPath.row]];
    cell.delegate = self;
    [cell notifyBottomContainerReadyOfData:nil];
    if ([cell isKindOfClass:TUIBubbleMessageCell.class]) {
        TUIBubbleMessageCell *bubbleCell = (TUIBubbleMessageCell *)cell;
        if (bubbleCell.bubbleView) {
            bubbleCell.bubbleView.image = nil;
        }
    }
    return cell;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.inputController reset];
}
#pragma mark - TUIInputControllerDelegate

- (void)inputController:(TUIInputController *)inputController didChangeHeight:(CGFloat)height {
    if (!self.responseKeyboard) {
        return;
    }

    if (self.inputController.replyData == nil) {
        [self onRelyMessage:self.cellData];
    }
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       CGRect msgFrame = self.tableView.frame;
                       msgFrame.size.height = self.view.frame.size.height - height;
                       self.tableView.frame = msgFrame;

                       CGRect inputFrame = self.inputController.view.frame;
                       inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
                       inputFrame.size.height = height;
                       self.inputController.view.frame = inputFrame;

                       [self scrollToBottom:NO];
                     }
                     completion:nil];
}

- (void)inputController:(TUIInputController *)inputController didSendMessage:(V2TIMMessage *)msg {
    [self sendMessage:msg];
}

- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell {
    cell.disableDefaultSelectAction = NO;

    if (cell.disableDefaultSelectAction) {
        return;
    }
}

- (void)sendMessage:(V2TIMMessage *)message {
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
        willSendBlock:^(BOOL isReSend, TUIMessageCellData *_Nonnull dateUIMsg) {
          @strongify(self);

          int delay = 1;
          if ([cellData isKindOfClass:[TUIImageMessageCellData class]]) {
              delay = 0;
          }

          @weakify(self);
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            if (cellData.status == Msg_Status_Sending) {
                [self changeMsg:cellData status:Msg_Status_Sending_2];
            }
          });
        }
        SuccBlock:^{
          @strongify(self);
          [self changeMsg:cellData status:Msg_Status_Succ];
          [self scrollToBottom:YES];
        }
        FailBlock:^(int code, NSString *desc) {
          @strongify(self);
          [TUITool makeToastError:code msg:desc];
          [self changeMsg:cellData status:Msg_Status_Fail];
        }];
}

- (void)scrollToBottom:(BOOL)animated {
    if (self.uiMsgs.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.uiMsgs.count - 1 inSection:1]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

- (void)changeMsg:(TUIMessageCellData *)msg status:(TMsgStatus)status {
    msg.status = status;
    NSInteger index = [self.uiMsgs indexOfObject:msg];
    if ([self.tableView numberOfRowsInSection:0] > index) {
        TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell fillWithData:msg];
    } else {
        NSLog(@"lack of cell");
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kTUINotifyMessageStatusChanged"
                                                        object:nil
                                                      userInfo:@{
                                                          @"msg" : msg,
                                                          @"status" : [NSNumber numberWithUnsignedInteger:status],
                                                          @"msgSender" : self,
                                                      }];
}

#pragma mark - Message reply

- (void)onRelyMessage:(nonnull TUIMessageCellData *)data {
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
- (void)onSelectMessage:(TUIMessageCell *)cell {
    if (TUIChatConfig.defaultConfig.eventConfig.chatEventListener &&
        [TUIChatConfig.defaultConfig.eventConfig.chatEventListener respondsToSelector:@selector(onMessageClicked:messageCellData:)]) {
        BOOL result = [TUIChatConfig.defaultConfig.eventConfig.chatEventListener onMessageClicked:cell messageCellData:cell.messageData];
        if (result) {
            return;
        }
    }
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

#pragma mark - V2TIMAdvancedMsgListener

- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    V2TIMMessage *imMsg = msg;
    if (imMsg == nil || ![imMsg isKindOfClass:V2TIMMessage.class]) {
        return;
    }
    if ([imMsg.msgID isEqualToString:self.cellData.msgID] ) {
        TUIMessageCellData *cellData = [TUIMessageDataProvider getCellData:imMsg];
        self.cellData.messageModifyReplies = cellData.messageModifyReplies;
        [self applyData];
    }

}
- (void)onRecvMessageModified:(V2TIMMessage *)msg {
    V2TIMMessage *imMsg = msg;
    if (imMsg == nil || ![imMsg isKindOfClass:V2TIMMessage.class]) {
        return;
    }
    if ([imMsg.msgID isEqualToString:self.cellData.msgID] ) {
        TUIMessageCellData *cellData = [TUIMessageDataProvider getCellData:imMsg];
        self.cellData.messageModifyReplies = cellData.messageModifyReplies;
        [self applyData];
    }

}

#pragma mark - dataProviderDataChange
- (void)dataProviderDataSourceWillChange:(TUIMessageDataProvider *)dataProvider {
}

- (void)dataProviderDataSourceChange:(TUIMessageDataProvider *)dataProvider
                            withType:(TUIMessageBaseDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation {
}

- (void)dataProviderDataSourceDidChange:(TUIMessageDataProvider *)dataProvider {
    
}

- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider onRemoveHeightCache:(TUIMessageCellData *)cellData {
    if (cellData) {
        [self.messageCellConfig removeHeightCacheOfMessageCellData:cellData];
    }
}

#pragma mark - action

- (void)showImageMessage:(TUIImageMessageCell *)cell {
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView *mediaView = [[TUIMediaView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:@[ self.cellData.innerMessage ]];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)playVoiceMessage:(TUIVoiceMessageCell *)cell {
    TUIVoiceMessageCellData *uiMsg = (TUIVoiceMessageCellData *)self.cellData;
    if (uiMsg == cell.voiceData) {
        [uiMsg playVoiceMessage];
        cell.voiceReadPoint.hidden = YES;
    } else {
        [uiMsg stopVoiceMessage];
    }
}

- (void)showVideoMessage:(TUIVideoMessageCell *)cell {
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView *mediaView = [[TUIMediaView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:@[ self.cellData.innerMessage ]];
    __weak typeof(self) weakSelf = self;
    mediaView.onClose = ^{
      [weakSelf.tableView reloadData];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)showFileMessage:(TUIFileMessageCell *)cell {
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

- (void)setConversation:(TUIChatConversationModel *)conversationData {
    self.conversationData = conversationData;
    if (!self.msgDataProvider) {
        self.msgDataProvider = [[TUIMessageDataProvider alloc] initWithConversationModel:conversationData];
        self.msgDataProvider.dataSource = self;
    }
    [self loadMessage];
}
- (void)loadMessage {
    if (self.msgDataProvider.isLoadingData || self.msgDataProvider.isNoMoreMsg) {
        return;
    }

    [self.msgDataProvider
        loadMessageSucceedBlock:^(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TUIMessageCellData *> *_Nonnull newMsgs) {

        }
        FailBlock:^(int code, NSString *desc) {
          [TUITool makeToastError:code msg:desc];
        }];
}

#pragma mark - TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(id)anObject param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIPluginNotify] &&
        [subKey isEqualToString:TUICore_TUIPluginNotify_DidChangePluginViewSubKey]) {
        TUIMessageCellData *data = param[TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data];
        NSInteger section = 1;
        if ([data.msgID isEqualToString:self.cellData.msgID] ) {
            //root section
            section = 0;
        }
        [self.messageCellConfig removeHeightCacheOfMessageCellData:data];
        [self reloadAndScrollToBottomOfMessage:data.innerMessage.msgID section:section];
    }
}

- (void)reloadAndScrollToBottomOfMessage:(NSString *)messageID section:(NSInteger)section {
    // Dispatch the task to RunLoop to ensure that they are executed after the UITableView refresh is complete.
    dispatch_async(dispatch_get_main_queue(), ^{
      [self reloadCellOfMessage:messageID section:section];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollCellToBottomOfMessage:messageID section:section];
      });
    });
}

- (void)reloadCellOfMessage:(NSString *)messageID section:(NSInteger)section {
    NSIndexPath *indexPath = [self indexPathOfMessage:messageID section:section];

    // Disable animation when loading to avoid cell jumping.
    if (indexPath == nil) {
        return;
    }
    [UIView performWithoutAnimation:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
        });
    }];
}

- (void)scrollCellToBottomOfMessage:(NSString *)messageID section:(NSInteger)section {
    NSIndexPath *indexPath = [self indexPathOfMessage:messageID section:section];

    // Scroll the tableView only if the bottom of the cell is invisible.
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    CGRect tableViewRect = self.tableView.bounds;
    BOOL isBottomInvisible = cellRect.origin.y < CGRectGetMaxY(tableViewRect) && CGRectGetMaxY(cellRect) > CGRectGetMaxY(tableViewRect);
    if (isBottomInvisible) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (NSIndexPath *)indexPathOfMessage:(NSString *)messageID section:(NSInteger)section {
    if (section == 0) {
        return [NSIndexPath indexPathForRow:0 inSection:section];
    } else {
        for (int i = 0; i < self.uiMsgs.count; i++) {
            TUIMessageCellData *data = self.uiMsgs[i];
            if ([data.innerMessage.msgID isEqualToString:messageID]) {
                return [NSIndexPath indexPathForRow:i inSection:section];
            }
        }
    }
    return nil;
}

- (TUIMessageCellConfig *)messageCellConfig {
    if (_messageCellConfig == nil) {
        _messageCellConfig = [[TUIMessageCellConfig alloc] init];
    }
    return _messageCellConfig;
}

@end
