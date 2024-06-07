//
//  TUIRepliesDetailViewController.m
//  TUIChat
//
//  Created by wyl on 2022/4/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIRepliesDetailViewController_Minimalist.h"
#import <TIMCommon/TUIMessageCell.h>
#import "TUIChatDataProvider.h"
#import "TUIMenuCellData.h"
#import "TUIMessageDataProvider.h"
#import "TUITextMessageCellData.h"
#import "TUITextMessageCell_Minimalist.h"
#import "TUIChatConfig.h"
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUISystemMessageCell.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIFaceMessageCell_Minimalist.h"
#import "TUIFileMessageCell_Minimalist.h"
#import "TUIFileViewController_Minimalist.h"
#import "TUIImageMessageCell_Minimalist.h"
#import "TUIJoinGroupMessageCell_Minimalist.h"
#import "TUILinkCell_Minimalist.h"
#import "TUIMediaView_Minimalist.h"
#import "TUIMergeMessageCell_Minimalist.h"
#import "TUIMergeMessageListController_Minimalist.h"
#import "TUIReferenceMessageCell_Minimalist.h"
#import "TUIReplyMessageCellData.h"
#import "TUIReplyMessageCell_Minimalist.h"
#import "TUITextMessageCell_Minimalist.h"
#import "TUIVideoMessageCell_Minimalist.h"
#import "TUIVoiceMessageCell_Minimalist.h"
#import "TUIMessageCellConfig_Minimalist.h"

@interface TUIRepliesDetailViewController_Minimalist () <TUIInputControllerDelegate_Minimalist,
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
@property(nonatomic, strong) TUIMessageCellLayout *originCellLayout;
@property TMsgDirection direction;
@property(nonatomic, assign) BOOL showAvatar;
@property(nonatomic, assign) BOOL sameToNextMsgSender;
@property(nonatomic) BOOL isMsgNeedReadReceipt;

// topGestureView subviews
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) TUIMessageCellConfig_Minimalist *messageCellConfig;

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
    [TUICore unRegisterEventByObject:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViews];

    //    [self setupInputViewController];

    [self setnormalTop];

    self.topImgView.hidden = YES;

    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:TIMCommonLocalizableString(Cancel) forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton sizeToFit];
    [self.topGestureView addSubview:_cancelButton];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = [NSString stringWithFormat:@"0 %@", TIMCommonLocalizableString(TUIKitThreadQuote)];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    _titleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");
    [_titleLabel sizeToFit];
    [self.topGestureView addSubview:_titleLabel];

    [self updateSubContainerView];

    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];

    [TUICore registerEvent:TUICore_TUIPluginNotify subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey object:self];
}

- (void)updateSubContainerView {
    //    [super updateSubContainerView];
    self.topGestureView.frame = CGRectMake(0, 0, self.containerView.frame.size.width, kScale390(60));
    self.cancelButton.frame =
        CGRectMake(kScale390(15), (self.topGestureView.bounds.size.height - kScale390(22)) * 0.5, self.cancelButton.frame.size.width, kScale390(22));
    self.titleLabel.frame = CGRectMake((self.topGestureView.bounds.size.width - self.titleLabel.frame.size.width) * 0.5, self.cancelButton.frame.origin.y,
                                       self.titleLabel.frame.size.width, kScale390(22));

    self.tableView.frame = CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width,
                                      self.containerView.frame.size.height - self.topGestureView.frame.size.height);
    if (isRTL()) {
        [self.cancelButton resetFrameToFitRTL];
    }
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
    self.titleLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)msgIDArray.count, TIMCommonLocalizableString(TUIKitThreadQuote)];
    [self.titleLabel sizeToFit];
    __weak typeof(self) weakSelf = self;
    [TUIChatDataProvider findMessages:msgIDArray
                                        callback:^(BOOL succ, NSString *_Nonnull error_message, NSArray *_Nonnull msgs) {
                                          __strong typeof(weakSelf) strongSelf = weakSelf;
                                          if (succ) {
                                              if (msgs.count > 0) {
                                                  strongSelf.imMsgs = msgs;
                                                  strongSelf.uiMsgs = [self transUIMsgFromIMMsg:msgs];
                                                  for (TUIMessageCellData *data in strongSelf.uiMsgs) {
                                                      [TUIMessageDataProvider updateUIMsgStatus:data uiMsgs:strongSelf.uiMsgs];
                                                  }
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
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    self.tableView.scrollsToTop = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    [self.messageCellConfig bindTableView:self.tableView];
}

- (void)setupInputViewController {
    _inputController = [[TUIInputController_Minimalist alloc] init];
    _inputController.delegate = self;
    _inputController.view.frame = CGRectMake(0, self.containerView.frame.size.height - TTextView_Height - Bottom_SafeHeight,
                                             self.containerView.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    _inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addChildViewController:_inputController];
    [self.containerView addSubview:_inputController.view];
    TUIFaceGroup *group = TIMConfig.defaultConfig.faceGroups[0];
    [_inputController.faceSegementScrollView setItems:(id) @[ group ] delegate:(id)_inputController];
    TUIMenuCellData *data = [[TUIMenuCellData alloc] init];
    data.path = group.menuPath;
    data.isSelected = YES;
    [_inputController.menuView setData:(id) @[ data ]];

    CGFloat margin = 20;
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
    self.cellData.showMessageModifyReplies = NO;
}
- (void)revertRootMsg {
    self.cellData.cellLayout = self.originCellLayout;
    self.cellData.direction = self.direction;
    self.cellData.showMessageModifyReplies = YES;
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
        data.direction = MsgDirectionIncoming;
        data.cellLayout = layout;
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
        CGRect rect = CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width,
                                 self.containerView.frame.size.height - self.topGestureView.frame.size.height);

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
    data.showCheckBox = NO;
    TUIMessageCell *cell = nil;

    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    [cell fillWithData:_uiMsgs[indexPath.row]];
    [cell notifyBottomContainerReadyOfData:nil];
    cell.delegate = self;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.inputController reset];
}

#pragma mark - TUIInputControllerDelegate

- (void)inputController:(TUIInputController_Minimalist *)inputController didChangeHeight:(CGFloat)height {
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

- (void)inputController:(TUIInputController_Minimalist *)inputController didSendMessage:(V2TIMMessage *)msg {
    [self sendMessage:msg];
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

- (void)onCancel:(id)btn {
    [self dismissViewControllerAnimated:YES completion:nil];
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
- (void)dataProviderDataSourceWillChange:(TUIMessageBaseDataProvider *)dataProvider {
}
- (void)dataProviderDataSourceChange:(TUIMessageBaseDataProvider *)dataProvider
                            withType:(TUIMessageBaseDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation {
}
- (void)dataProviderDataSourceDidChange:(TUIMessageBaseDataProvider *)dataProvider {
    // update by applyData
}


- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider onRemoveHeightCache:(TUIMessageCellData *)cellData {
    if (cellData) {
        [self.messageCellConfig removeHeightCacheOfMessageCellData:cellData];
    }
}

#pragma mark - action

- (void)showImageMessage:(TUIImageMessageCell_Minimalist *)cell {
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView_Minimalist *mediaView = [[TUIMediaView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:@[ self.cellData.innerMessage ]];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)playVoiceMessage:(TUIVoiceMessageCell_Minimalist *)cell {
    TUIVoiceMessageCellData *uiMsg = (TUIVoiceMessageCellData *)self.cellData;
    if (uiMsg == cell.voiceData) {
        [uiMsg playVoiceMessage];
        cell.voiceReadPoint.hidden = YES;
    } else {
        [uiMsg stopVoiceMessage];
    }
}

- (void)showVideoMessage:(TUIVideoMessageCell_Minimalist *)cell {
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView_Minimalist *mediaView = [[TUIMediaView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:@[ self.cellData.innerMessage ]];
    __weak typeof(self) weakSelf = self;
    mediaView.onClose = ^{
      [weakSelf.tableView reloadData];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)showFileMessage:(TUIFileMessageCell_Minimalist *)cell {
    TUIFileMessageCellData *fileData = cell.fileData;
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
    if ([key isEqualToString:TUICore_TUIPluginNotify] && [subKey isEqualToString:TUICore_TUIPluginNotify_DidChangePluginViewSubKey]) {
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

- (TUIMessageCellConfig_Minimalist *)messageCellConfig {
    if (_messageCellConfig == nil) {
        _messageCellConfig = [[TUIMessageCellConfig_Minimalist alloc] init];
    }
    return _messageCellConfig;
}

@end
