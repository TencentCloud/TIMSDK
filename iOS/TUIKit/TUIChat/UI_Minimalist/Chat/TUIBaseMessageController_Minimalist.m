//
//  TUIBaseMessageController.m
//  UIKit
//
//  Created by annidyfeng on 2019/7/1.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUIBaseMessageController_Minimalist.h"
#import <TIMCommon/TIMConfig.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TIMPopActionProtocol.h>
#import <TIMCommon/TUISystemMessageCell.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUITool.h>
#import <UIKit/UIWindow.h>
#import "TUIChatCallingDataProvider.h"
#import "TUIChatConversationModel.h"
#import "TUIChatDataProvider.h"
#import "TUIChatPopContextController.h"
#import "TUIChatPopMenu.h"
#import "TUIFaceMessageCell_Minimalist.h"
#import "TUIFaceView.h"
#import "TUIFileMessageCell_Minimalist.h"
#import "TUIFileViewController_Minimalist.h"
#import "TUIImageMessageCell_Minimalist.h"
#import "TUIJoinGroupMessageCell_Minimalist.h"
#import "TUILinkCell_Minimalist.h"
#import "TUIMediaView_Minimalist.h"
#import "TUIMergeMessageCell_Minimalist.h"
#import "TUIMergeMessageListController_Minimalist.h"
#import "TUIMessageDataProvider.h"
#import "TUIMessageProgressManager.h"
#import "TUIMessageReadViewController_Minimalist.h"
#import "TUIOrderCell_Minimalist.h"
#import "TUIReferenceMessageCell_Minimalist.h"
#import "TUIRepliesDetailViewController_Minimalist.h"
#import "TUIReplyMessageCellData.h"
#import "TUIReplyMessageCell_Minimalist.h"
#import "TUITextMessageCell_Minimalist.h"
#import "TUIVideoMessageCell_Minimalist.h"
#import "TUIVoiceMessageCell_Minimalist.h"
#import "TUIMessageCellConfig_Minimalist.h"
#import "TUIVoiceMessageCell_Minimalist.h"
#import "TUIChatbotMessagePlaceholderCellData.h"
#import "TUIAIPlaceholderTypingMessageManager.h"

typedef NSString * CellDataClassName;
typedef Class<TUIMessageCellProtocol> CellClass;
typedef NSString * MessageID;
typedef NSNumber * HeightNumber;

@interface TUIBaseMessageController_Minimalist () <TUIMessageCellDelegate,
                                                   TUIJoinGroupMessageCellDelegate_Minimalist,
                                                   TUIMessageProgressManagerDelegate,
                                                   TUIMessageDataProviderDataSource,
                                                   TIMPopActionProtocol,
                                                   TUINotificationProtocol>

@property(nonatomic, strong) TUIMessageDataProvider *messageDataProvider;
@property(nonatomic, strong) TUIMessageCellData *menuUIMsg;
@property(nonatomic, strong) TUIMessageCellData *reSendUIMsg;
@property(nonatomic, strong) TUIChatConversationModel *conversationData;
@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property(nonatomic, assign) BOOL isActive;
@property(nonatomic, assign) BOOL showCheckBox;
@property(nonatomic, assign) BOOL scrollingTriggeredByUser;
@property(nonatomic, assign) BOOL isAutoScrolledToBottom;
@property(nonatomic, assign) BOOL hasCoverPage;
@property(nonatomic, strong) TUIChatPopContextController *popAlertController;
@property(nonatomic, strong) TUIMessageCellConfig_Minimalist *messageCellConfig;
@end

@implementation TUIBaseMessageController_Minimalist
+ (void)initialize {
    [TUIMessageDataProvider setDataSourceClass:self];
}

+ (void)asyncGetDisplayString:(NSArray<V2TIMMessage *> *)messageList callback:(void(^)(NSDictionary<NSString *, NSString *> *))callback {
  [TUIMessageDataProvider asyncGetDisplayString:messageList callback:callback];
}

+ (nullable NSString *)getDisplayString:(V2TIMMessage *)message {
    return [TUIMessageDataProvider getDisplayString:message];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self registerEvents];
    self.isActive = YES;
    [TUITool addUnsupportNotificationInVC:self];
    [TUIMessageProgressManager.shareManager addDelegate:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TUIMessageProgressManager.shareManager removeDelegate:self];
    [TUICore unRegisterEventByObject:self];
}

- (void)viewWillAppear:(BOOL)animated {
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

- (void)applicationBecomeActive {
    self.isActive = YES;
    [self sendVisibleReadGroupMessages];
}

- (void)applicationEnterBackground {
    self.isActive = NO;
}

- (void)setupViews {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapViewController)];
    /**
     * Solve the problem that the touch event is not passed down, causing the gesture to conflict with the collectionView didselect
     */
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    self.tableView.scrollsToTop = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TMessageController_Header_Height)];
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.tableView.tableHeaderView = self.indicatorView;
    if (!self.indicatorView.isAnimating) {
        [self.indicatorView startAnimating];
    }
    [self.messageCellConfig bindTableView:self.tableView];
}

- (void)registerEvents {
    [TUICore registerEvent:TUICore_TUIPluginNotify subKey:TUICore_TUIPluginNotify_WillForwardTextSubKey object:self];
    [TUICore registerEvent:TUICore_TUIPluginNotify subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationBecomeActive)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedSendMessageRequest:) name:TUIChatSendMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedSendMessageWithoutUpdateUIRequest:) name:TUIChatSendMessageWithoutUpdateUINotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedInsertMessageWithoutUpdateUIRequest:) name:TUIChatInsertMessageWithoutUpdateUINotification object:nil];

}

- (TUIMessageCellConfig_Minimalist *)messageCellConfig {
    if (_messageCellConfig == nil) {
        _messageCellConfig = [[TUIMessageCellConfig_Minimalist alloc] init];
    }
    return _messageCellConfig;
}

#pragma mark - Data Provider
- (void)setConversation:(TUIChatConversationModel *)conversationData {
    self.conversationData = conversationData;
    if (!self.messageDataProvider) {
        self.messageDataProvider = [[TUIMessageDataProvider alloc] initWithConversationModel:conversationData];
        self.messageDataProvider.dataSource = self;
        self.messageDataProvider.mergeAdjacentMsgsFromTheSameSender = YES;
    }
    [self loadMessage];
    [self loadGroupInfo];
}

- (void)restoreAITypingMessageIfNeeded {
    TUIMessageCellData * lastObj = self.messageDataProvider.uiMsgs.lastObject;
    NSString *conversationID = self.conversationData.conversationID;
    if ([[TUIAIPlaceholderTypingMessageManager sharedInstance] hasAIPlaceholderTypingMessageForConversation:conversationID]) {
        TUIMessageCellData *existingAIPlaceHolderMessage = [[TUIAIPlaceholderTypingMessageManager sharedInstance] getAIPlaceholderTypingMessageForConversation:conversationID];
        if (existingAIPlaceHolderMessage) {
            BOOL lastObjisTUIChatbotMessageCellData = [lastObj isKindOfClass:NSClassFromString(@"TUIChatbotMessageCellData")];
            BOOL isSuccess = lastObj.status != Msg_Status_Fail;
            if (!lastObjisTUIChatbotMessageCellData && isSuccess) {
                // Add the existing AI typing message to current message list
                [self sendPlaceHolderUIMessage:existingAIPlaceHolderMessage];
            }
            else {
                [[TUIAIPlaceholderTypingMessageManager sharedInstance] removeAIPlaceholderTypingMessageForConversation:conversationID];
            }
            
        }
    }
}

- (void)loadMessage {
    if (self.messageDataProvider.isLoadingData || self.messageDataProvider.isNoMoreMsg) {
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self.messageDataProvider
        loadMessageSucceedBlock:^(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TUIMessageCellData *> *_Nonnull newMsgs) {
          if (isNoMoreMsg) {
              weakSelf.indicatorView.mm_h = 0;
          }
          if (newMsgs.count != 0) {
              [weakSelf.tableView reloadData];
              [weakSelf.tableView layoutIfNeeded];

              if (isFirstLoad) {
                  [weakSelf scrollToBottom:NO];
              } else {
                  CGFloat visibleHeight = 0;
                  for (NSInteger i = 0; i < newMsgs.count; ++i) {
                      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                      visibleHeight += [weakSelf tableView:weakSelf.tableView heightForRowAtIndexPath:indexPath];
                  }
                  if (isNoMoreMsg) {
                      visibleHeight -= TMessageController_Header_Height;
                  }
                  [weakSelf.tableView scrollRectToVisible:CGRectMake(0, weakSelf.tableView.contentOffset.y + visibleHeight, weakSelf.tableView.frame.size.width,
                                                                     weakSelf.tableView.frame.size.height)
                                                 animated:NO];
              }
          }
          //        [weakSelf.indicatorView stopAnimating];
        }
        FailBlock:^(int code, NSString *desc) {
          [TUITool makeToastError:code msg:desc];
        }];
}

- (void)loadGroupInfo {
    if (self.conversationData.groupID.length > 0) {
        __weak typeof(self) weakSelf = self;
        [self.messageDataProvider getPinMessageList];
        [self.messageDataProvider loadGroupInfo:^{
            [weakSelf.messageDataProvider getSelfInfoInGroup:^{}];
        }];
        
        self.messageDataProvider.groupRoleChanged = ^(V2TIMGroupMemberRole role) {
            if (weakSelf.groupRoleChanged) {
                weakSelf.groupRoleChanged(role);
            }
        };
        self.messageDataProvider.pinGroupMessageChanged = ^(NSArray * _Nonnull groupPinList) {
            if (weakSelf.pinGroupMessageChanged) {
                weakSelf.pinGroupMessageChanged(groupPinList);
            }
        };
    }
}
- (void)clearUImsg {
    [self.messageDataProvider clearUIMsgList];
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    if (self.indicatorView.isAnimating) {
        [self.indicatorView stopAnimating];
    }
}

- (void)reloadAndScrollToBottomOfMessage:(NSString *)messageID needScroll:(BOOL)isNeedScroll {
    // Dispatch the task to RunLoop to ensure that they are executed after the UITableView refresh is complete.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadCellOfMessage:messageID];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isNeedScroll) {
                [self scrollCellToBottomOfMessage:messageID];
            }
        });
    });
}
- (void)reloadAndScrollToBottomOfMessage:(NSString *)messageID {
    [self reloadAndScrollToBottomOfMessage:messageID needScroll:YES];
}

- (void)reloadCellOfMessage:(NSString *)messageID {
    NSIndexPath *indexPath = [self indexPathOfMessage:messageID];

    // Disable animation when loading to avoid cell jumping.
    if (indexPath == nil) {
        return;
    }
    [UIView performWithoutAnimation:^{
      [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)scrollCellToBottomOfMessage:(NSString *)messageID {
    
    if (self.hasCoverPage) {
        return;
    }
    
    NSIndexPath *indexPath = [self indexPathOfMessage:messageID];

    // Scroll the tableView only if the bottom of the cell is invisible.
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    CGRect tableViewRect = self.tableView.bounds;
    BOOL isBottomInvisible = (cellRect.origin.y < CGRectGetMaxY(tableViewRect) && CGRectGetMaxY(cellRect) > CGRectGetMaxY(tableViewRect)) ||
                             (cellRect.origin.y >= CGRectGetMaxY(tableViewRect));
    if (isBottomInvisible) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
- (void)scrollToBottom:(BOOL)animate {
    if (self.messageDataProvider.uiMsgs.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageDataProvider.uiMsgs.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animate];
        self.isAutoScrolledToBottom = YES;
    }
}

- (void)didTapViewController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapInMessageController:)]) {
        [self.delegate didTapInMessageController:self];
    }
}

- (void)sendPlaceHolderUIMessage:(TUIMessageCellData *)cellData {
    [self.messageDataProvider sendPlaceHolderUIMessage:cellData];
    [self scrollToBottom:YES];
}

- (void)createAITypingMessage {
    // Create AI typing placeholder message using TUIChatbotMessagePlaceholderCellData
    TUIChatbotMessagePlaceholderCellData *aiTypingData = [TUIChatbotMessagePlaceholderCellData createAIPlaceholderCellData];
    
    // Send as placeholder message
    [self sendPlaceHolderUIMessage:aiTypingData];
    
    // Store reference in global manager for later replacement
    NSString *conversationID = self.conversationData.conversationID;
    [[TUIAIPlaceholderTypingMessageManager sharedInstance] setAIPlaceholderTypingMessage:aiTypingData forConversation:conversationID];
    
    // Note: AI typing message will be automatically removed when real AI response is received
    // via onRecvNewMessage in TUIMessageBaseDataProvider
}

- (void)sendUIMessage:(TUIMessageCellData *)cellData {
    @weakify(self);
    cellData.innerMessage.needReadReceipt = self.isMsgNeedReadReceipt;
    [self.messageDataProvider sendUIMsg:cellData
        toConversation:self.conversationData
        willSendBlock:^(BOOL isReSend, TUIMessageCellData *_Nonnull dateUIMsg) {
          @strongify(self);
          if ([cellData isKindOfClass:[TUIVideoMessageCellData class]]||
              [cellData isKindOfClass:[TUIImageMessageCellData class]]) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self scrollToBottom:YES];
              });
          } else {
              [self scrollToBottom:YES];
          }
          [self setUIMessageStatus:cellData status:Msg_Status_Sending_2];
        }
        SuccBlock:^{
          @strongify(self);
          [self reloadUIMessage:cellData];
          [self setUIMessageStatus:cellData status:Msg_Status_Succ];
            NSDictionary *param = @{
            TUICore_TUIChatNotify_SendMessageSubKey_Code : @0,
            TUICore_TUIChatNotify_SendMessageSubKey_Desc : @"",
            TUICore_TUIChatNotify_SendMessageSubKey_Message : cellData.innerMessage
            };
            [TUICore notifyEvent:TUICore_TUIChatNotify subKey:TUICore_TUIChatNotify_SendMessageSubKey object:self param:param];
        }
        FailBlock:^(int code, NSString *desc) {
          @strongify(self);
          [self reloadUIMessage:cellData];
          [self setUIMessageStatus:cellData status:Msg_Status_Fail];
          [self makeSendErrorHud:code desc:desc];
            NSDictionary *param = @{TUICore_TUIChatNotify_SendMessageSubKey_Code : @(code),
                                TUICore_TUIChatNotify_SendMessageSubKey_Desc : desc};
            [TUICore notifyEvent:TUICore_TUIChatNotify subKey:TUICore_TUIChatNotify_SendMessageSubKey object:self param:param];
        }];
}

- (void)setUIMessageStatus:(TUIMessageCellData *)cellData status:(TMsgStatus)status {
    switch (status) {
        case Msg_Status_Init:
        case Msg_Status_Succ:
        case Msg_Status_Fail:
            {
                [self changeMsg:cellData status:status];
            }
            break;
        case Msg_Status_Sending:
        case Msg_Status_Sending_2:
            {
                int delay = 1;
                if ([cellData isKindOfClass:[TUIImageMessageCellData class]] ||
                    [cellData isKindOfClass:[TUIVideoMessageCellData class]]) {
                    delay = 0;
                }
                if (0 == delay) {
                    [self changeMsg:cellData status:Msg_Status_Sending_2];
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (cellData.innerMessage.status == V2TIM_MSG_STATUS_SENDING) {
                            [self changeMsg:cellData status:Msg_Status_Sending_2];
                        }
                    });
                }
            }
            break;
            
        default:
            break;
    }
}

- (void)makeSendErrorHud:(int)code desc:(NSString *)desc  {
    // The text or image msg is sensitive, the cell height may change.
    if (code == 80001 || code == 80004) {
        [self scrollToBottom:YES];
        return;
    }
    
    NSString *errorMsg = @"";
    if (self.isMsgNeedReadReceipt && code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
        errorMsg = [NSString stringWithFormat:@"%@%@", TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceMessageRead),
                                         TUIKitLocalizableString(TUIKitErrorUnsupporInterfaceSuffix)];
    } else {
        errorMsg = [TUITool convertIMError:code msg:desc];
    }
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:errorMsg message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)sendMessage:(V2TIMMessage *)message {
    [self sendMessage:message placeHolderCellData:nil];
}

- (void)sendMessage:(V2TIMMessage *)message placeHolderCellData:(TUIMessageCellData *)placeHolderCellData {
    TUIMessageCellData *cellData = nil;
    if (message.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        cellData = [self.delegate messageController:self onNewMessage:message];
        cellData.innerMessage = message;
    }
    if (!cellData) {
        cellData = [TUIMessageDataProvider getCellData:message];
    }
    if (cellData) {
        cellData.placeHolderCellData = placeHolderCellData;
        [self sendUIMessage:cellData];
    }
}

- (void)reloadUIMessage:(TUIMessageCellData *)msg {
    // innerMessage maybe changed, reload it
    NSInteger index = [self.messageDataProvider.uiMsgs indexOfObject:msg];
    NSMutableArray *newUIMsgs = [self.messageDataProvider transUIMsgFromIMMsg:@[ msg.innerMessage ]];
    if (newUIMsgs.count == 0) {
        return;
    }
    TUIMessageCellData *newUIMsg = newUIMsgs.firstObject;
    @weakify(self)
    [self.messageDataProvider preProcessMessage:@[ newUIMsg ]
                                       callback:^{
        @strongify(self)
        [UIView performWithoutAnimation:^{
            [self.messageDataProvider replaceUIMsg:newUIMsg atIndex:index];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationNone];
        }];
    }];
}

- (void)changeMsg:(TUIMessageCellData *)msg status:(TMsgStatus)status {
    msg.status = status;
    NSInteger index = [self.messageDataProvider.uiMsgs indexOfObject:msg];
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

- (void)onReceivedSendMessageRequest:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) {
        return;
    }
    V2TIMMessage *message = [userInfo objectForKey:TUICore_TUIChatService_SendMessageMethod_MsgKey];
    TUIMessageCellData *cellData = [userInfo objectForKey:TUICore_TUIChatService_SendMessageMethod_PlaceHolderUIMsgKey];
    if (cellData && !message) {
        [self sendPlaceHolderUIMessage:cellData];
    } else if (message) {
        [self sendMessage:message placeHolderCellData:cellData];
    }
}

- (void)onReceivedSendMessageWithoutUpdateUIRequest:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo == nil) {
        return;
    }
    V2TIMMessage *message = [userInfo objectForKey:TUICore_TUIChatService_SendMessageMethodWithoutUpdateUI_MsgKey];
    if (message == nil) {
        return;
    }
    TUISendMessageAppendParams *param = [TUISendMessageAppendParams new];
    param.isOnlineUserOnly = YES;
    [TUIMessageDataProvider sendMessage:message
                         toConversation:self.conversationData
                           appendParams:param
                               Progress:nil
                              SuccBlock:^{
        NSLog(@"send message without updating UI succeed");
    }
                              FailBlock:^(int code, NSString *desc) {
        NSLog(@"send message without updating UI failed, code: %d, desc: %@", code, desc);
    }];
}
- (void)onReceivedInsertMessageWithoutUpdateUIRequest:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo == nil) {
        return;
    }
    V2TIMMessage *message = [userInfo objectForKey:@"message"];
    BOOL isNeedScrollToBottom = [userInfo objectForKey:@"needScrollToBottom"];
    if (message == nil) {
        return;
    }
    NSMutableArray *newUIMsgs = [self.messageDataProvider transUIMsgFromIMMsg:@[ message ]];
    if (newUIMsgs.count == 0) {
        return;
    }
    
    TUIMessageCellData *newUIMsg = newUIMsgs.firstObject;
    @weakify(self)
    [self.messageDataProvider preProcessMessage:@[ newUIMsg ]
                                       callback:^{
        @strongify(self)
        [UIView performWithoutAnimation:^{
            [self.tableView beginUpdates];
            @autoreleasepool {
                for (TUIMessageCellData *uiMsg in newUIMsgs) {
                    [self.messageDataProvider addUIMsg:uiMsg];
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageDataProvider.uiMsgs.count -1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            [self.tableView endUpdates];
            if (isNeedScrollToBottom) {
               [self scrollToBottom:YES];
            }
        }];
    }];
}
#pragma mark - TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(id)anObject param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIPluginNotify] && [subKey isEqualToString:TUICore_TUIPluginNotify_DidChangePluginViewSubKey]) {
        // Translation View is shown, hidden or changed.
        TUIMessageCellData *data = param[TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data];
        BOOL isAllowScroll2Bottom = YES;
        if ([param[TUICore_TUIPluginNotify_DidChangePluginViewSubKey_isAllowScroll2Bottom] isEqualToString:@"0"] ) {
            isAllowScroll2Bottom = NO ;
            TUIMessageCellData *lasData = [self.messageDataProvider.uiMsgs lastObject];
            BOOL isInBottomPage = (self.tableView.contentSize.height - self.tableView.contentOffset.y
                               <= Screen_Height);
            if ([lasData.msgID isEqualToString:data.msgID]  && isInBottomPage) {
                isAllowScroll2Bottom = YES;
            }
        }
        //only for chatboxcell
        if (self.steamCellFinishedBlock)  {
            if ([param[@"isFinished"] isEqualToString:@"1"]) {
                self.steamCellFinishedBlock(YES,data);
            }
            else {
                self.steamCellFinishedBlock(NO,data);
            }
        }
        [self.messageCellConfig removeHeightCacheOfMessageCellData:data];
        [self reloadAndScrollToBottomOfMessage:data.innerMessage.msgID needScroll:isAllowScroll2Bottom];
    }
    if ([key isEqualToString:TUICore_TUIPluginNotify] && [subKey isEqualToString:TUICore_TUIPluginNotify_WillForwardTextSubKey]) {
        // Translation will be forwarded.
        NSString *text = param[TUICore_TUIPluginNotify_WillForwardTextSubKey_Text];
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageController:onForwardText:)]) {
            [self.delegate messageController:self onForwardText:text];
        }
    }
}

- (void)clearAndReloadCellOfData:(TUIMessageCellData *)data {
    [self.messageCellConfig removeHeightCacheOfMessageCellData:data];
    [self reloadAndScrollToBottomOfMessage:data.innerMessage.msgID];
}

#pragma mark - TUIMessageProgressManagerDelegate
- (void)onMessageSendingResultChanged:(TUIMessageSendingResultType)type messageID:(NSString *)msgID {
    // async
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      for (TUIMessageCellData *cellData in weakSelf.messageDataProvider.uiMsgs) {
          if ([cellData.msgID isEqual:msgID]) {
              [weakSelf changeMsg:cellData status:(type == TUIMessageSendingResultTypeSucc) ? Msg_Status_Succ : Msg_Status_Fail];
          }
      }
    });
}

#pragma mark - TUIMessageBaseDataProviderDataSource
+ (Class)onGetCustomMessageCellDataClass:(NSString *)businessID {
    return [TUIMessageCellConfig_Minimalist getCustomMessageCellDataClass:businessID];
}

static NSMutableArray *lastMsgIndexs = nil;
static NSMutableArray *reloadMsgIndexs = nil;
- (BOOL)isDataSourceConsistent {
    NSInteger dataSourceCount = self.messageDataProvider.uiMsgs.count;
    NSInteger tableViewCount = [self.tableView numberOfRowsInSection:0];

    if (dataSourceCount != tableViewCount) {
        NSLog(@"Data source and UI are inconsistent: Data source count = %ld, Table view count = %ld", (long)dataSourceCount, (long)tableViewCount);
        return NO;
    }
    return YES;
}

- (void)dataProviderDataSourceWillChange:(TUIMessageDataProvider *)dataProvider {
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
- (void)dataProviderDataSourceChange:(TUIMessageDataProvider *)dataProvider
                            withType:(TUIMessageBaseDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation {
    // insert or delete or reload current cell
    [reloadMsgIndexs addObject:@(index)];
    NSArray *indexPaths = @[ [NSIndexPath indexPathForRow:index inSection:0] ];
    switch (type) {
        case TUIMessageBaseDataProviderDataSourceChangeTypeInsert:
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
            break;
        case TUIMessageBaseDataProviderDataSourceChangeTypeDelete:
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
            break;
        case TUIMessageBaseDataProviderDataSourceChangeTypeReload:
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
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

- (void)dataProviderDataSourceDidChange:(TUIMessageDataProvider *)dataProvider {
    for (NSNumber *number in lastMsgIndexs) {
        NSUInteger index = [number unsignedIntValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        TUIMessageCellData *cellData = self.messageDataProvider.uiMsgs[indexPath.row];
        [self.messageCellConfig removeHeightCacheOfMessageCellData:cellData];
        [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
    }
    [lastMsgIndexs removeAllObjects];
    [reloadMsgIndexs removeAllObjects];

    [self.tableView endUpdates];
}

- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider onRemoveHeightCache:(TUIMessageCellData *)cellData {
    if (cellData) {
        [self.messageCellConfig removeHeightCacheOfMessageCellData:cellData];
    }
}

- (nullable TUIMessageCellData *)dataProvider:(TUIMessageDataProvider *)dataProvider CustomCellDataFromNewIMMessage:(V2TIMMessage *)msg {
    if (![msg.userID isEqualToString:self.conversationData.userID] && ![msg.groupID isEqualToString:self.conversationData.groupID]) {
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

- (void)dataProvider:(TUIMessageDataProvider *)dataProvider ReceiveReadMsgWithUserID:(NSString *)userId Time:(time_t)timestamp {
    if (userId.length > 0 && [userId isEqualToString:self.conversationData.userID]) {
        for (int i = 0; i < self.messageDataProvider.uiMsgs.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageDataProvider.uiMsgs.count - 1 - i inSection:0];
            TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            /**
             * 
             * Determine whether the current unread needs to be changed to read by the callback timestamp
             */
            time_t msgTime = [cell.messageData.innerMessage.timestamp timeIntervalSince1970];
            if (msgTime <= timestamp && ![cell.readReceiptLabel.text isEqualToString:TIMCommonLocalizableString(Read)]) {
                cell.readReceiptLabel.text = TIMCommonLocalizableString(Read);
            }
        }
    }
}

- (void)dataProvider:(TUIMessageDataProvider *)dataProvider
    ReceiveReadMsgWithGroupID:(NSString *)groupID
                        msgID:(NSString *)msgID
                    readCount:(NSUInteger)readCount
                  unreadCount:(NSUInteger)unreadCount {
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

- (void)dataProvider:(TUIMessageDataProvider *)dataProvider ReceiveNewUIMsg:(TUIMessageCellData *)uiMsg {
    /**
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

- (void)dataProvider:(TUIMessageDataProvider *)dataProvider ReceiveRevokeUIMsg:(TUIMessageCellData *)uiMsg {
    return;
}

- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider didChangeTranslationData:(TUIMessageCellData *)data {
    [self reloadAndScrollToBottomOfMessage:data.innerMessage.msgID];
}

#pragma mark - Private
- (void)limitReadReport {
    static uint64_t lastTs = 0;
    uint64_t curTs = [[NSDate date] timeIntervalSince1970];
    /**
     * More than 1s && Not the first time, report immediately
     */
    if (curTs - lastTs >= 1 && lastTs) {
        lastTs = curTs;
        [self readReport];
    } else {
        /**
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

- (void)readReport {
    if (self.isInVC && self.isActive) {
        NSString *userID = self.conversationData.userID;
        if (userID.length > 0) {
            [TUIMessageDataProvider markC2CMessageAsRead:userID succ:nil fail:nil];
        }
        NSString *groupID = self.conversationData.groupID;
        if (groupID.length > 0) {
            [TUIMessageDataProvider markGroupMessageAsRead:groupID succ:nil fail:nil];
        }

        NSString *conversationID = @"";

        if (IS_NOT_EMPTY_NSSTRING(userID)) {
            conversationID = [NSString stringWithFormat:@"c2c_%@", userID];
        }

        if (IS_NOT_EMPTY_NSSTRING(groupID)) {
            conversationID = [NSString stringWithFormat:@"group_%@", groupID];
        }

        if (IS_NOT_EMPTY_NSSTRING(self.conversationData.conversationID)) {
            conversationID = self.conversationData.conversationID;
        }
        if (conversationID.length > 0) {
            [TUIMessageDataProvider markConversationAsUndead:@[ conversationID ] enableMark:NO];
        }
    }
}

/**
 * When the receiver sends a visible message read receipt:
 * 1. The time when messageVC is visible.  You will be notified when [self viewDidAppear:] is invoked
 * 2. The time when scrollview scrolled to bottom by called [self scrollToBottom:] (For example, click the "x new message" tips in the lower right corner). You
 * will be notified when  [UIScrollViewDelegate scrollViewDidEndScrollingAnimation:]  is invoked.
 *   + Note that you need to use the state of the scrollView to accurately determine whether the scrollView has really stopped sliding.
 * 3. The time when the user drags the scrollView continuously to view the message. You will be notified when [UIScrollViewDelegate scrollViewDidScroll:]  is
 * invoked.
 *   + Note here to determine whether the scrolling of the scrollView is triggered by user gestures (rather than automatic code triggers). So use the
 * self.scrollingTriggeredByUser flag to distinguish.
 *   + The update logic of self.scrollingTriggeredByUser is as follows:
 *     - Set YES when the user's finger touches the screen and starts to drag (scrollViewWillBeginDragging:);
 *     - When the user's finger drags at a certain acceleration and leaves the screen, when the screen automatically stops sliding
 * (scrollViewDidEndDecelerating:), set to NO;
 *     - No acceleration is applied after the user's finger slides, and when the user lifts the finger directly (scrollViewDidEndDragging:), set NO.
 * 4. When the user stays in the latest message interface and receives a new message at this time. Get notified in [self dataProvider:ReceiveNewUIMsg:] .
 */
- (void)sendVisibleReadGroupMessages {
    if (self.isInVC && self.isActive) {
        NSRange range = [self calcVisibleCellRange];
        [self.messageDataProvider sendMessageReadReceiptAtIndexes:[self transferIndexFromRange:range]];
    }
}

- (NSRange)calcVisibleCellRange {
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    if (indexPaths.count == 0) {
        return NSMakeRange(0, 0);
    }
    NSIndexPath *topmost = indexPaths.firstObject;
    NSIndexPath *downmost = indexPaths.lastObject;
    return NSMakeRange(topmost.row, downmost.row - topmost.row + 1);
}

- (NSArray *)transferIndexFromRange:(NSRange)range {
    NSMutableArray *index = [NSMutableArray array];
    NSInteger start = range.location;
    for (int i = 0; i < range.length; i++) {
        [index addObject:@(start + i)];
    }
    return index;
}

- (void)hideKeyboardIfNeeded {
    [self.view endEditing:YES];
    [TUITool.applicationKeywindow endEditing:YES];
}

- (CGFloat)getHeightFromMessageCellData:(TUIMessageCellData *)cellData {
    return [self.messageCellConfig getHeightFromMessageCellData:cellData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageDataProvider.uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messageDataProvider.uiMsgs.count) {
        TUIMessageCellData *cellData = self.messageDataProvider.uiMsgs[indexPath.row];
        return [self.messageCellConfig getHeightFromMessageCellData:cellData];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messageDataProvider.uiMsgs.count) {
        TUIMessageCellData *cellData = self.messageDataProvider.uiMsgs[indexPath.row];
        return [self.messageCellConfig getEstimatedHeightFromMessageCellData:cellData];
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIMessageCell *uiMsg = (TUIMessageCell *)cell;
    if ([uiMsg isKindOfClass:TUIMessageCell.class] && [self.delegate respondsToSelector:@selector(messageController:willDisplayCell:withData:)]) {
        [self.delegate messageController:self willDisplayCell:uiMsg withData:uiMsg.messageData];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messageDataProvider.uiMsgs.count) {
        TUITextMessageCellData *cellData = (TUITextMessageCellData *)self.messageDataProvider.uiMsgs[indexPath.row];
        // Delete after TUICallKit is connected according to the standard process
        if ([cellData isKindOfClass:TUITextMessageCellData.class]) {
            if ((cellData.isAudioCall || cellData.isVideoCall) && cellData.showUnreadPoint) {
                cellData.innerMessage.localCustomInt = 1;
                cellData.showUnreadPoint = NO;
            }
        }
        [TUICore notifyEvent:TUICore_TUIChatNotify
                              subKey:TUICore_TUIChatNotify_MessageDisplayedSubKey
                              object:cellData
                               param:nil];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollingTriggeredByUser) {
        // only if the scrollView is dragged by user's finger to scroll, we need to send read receipts.
        [self sendVisibleReadGroupMessages];
        self.isAutoScrolledToBottom = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.scrollingTriggeredByUser = YES;
    [self didTapViewController];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self isScrollViewEndDragging:scrollView]) {
        // user presses on the scrolling scrollView and forces it to stop scrolling immediately.
        self.scrollingTriggeredByUser = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
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

- (BOOL)isScrollViewEndDecelerating:(UIScrollView *)scrollView {
    return scrollView.tracking == 0 && scrollView.dragging == 0 && scrollView.decelerating == 0;
}

- (BOOL)isScrollViewEndDragging:(UIScrollView *)scrollView {
    return scrollView.tracking == 1 && scrollView.dragging == 0 && scrollView.decelerating == 0;
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
    if (cell.messageData.innerMessage.hasRiskContent) {
        if (![cell isKindOfClass:[TUIReferenceMessageCell_Minimalist class]]) {
            return;
        }
    }
    if (self.showCheckBox && [self supportCheckBox:(TUIMessageCellData *)cell.data]) {
        TUIMessageCellData *data = (TUIMessageCellData *)cell.data;
        data.selected = !data.selected;
        [self.tableView reloadData];
        if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageWhenMultiCheckboxAppear:)]) {
            [self.delegate messageController:self onSelectMessageWhenMultiCheckboxAppear:data];
        }
        return;
    }

    //Hide the keyboard when tapping on the message.
    [self hideKeyboardIfNeeded];

    if ([cell isKindOfClass:[TUITextMessageCell_Minimalist class]]) {
        [self clickTextMessage:(TUITextMessageCell_Minimalist *)cell];
    } else if ([cell isKindOfClass:[TUISystemMessageCell class]]) {
        [self clickSystemMessage:(TUISystemMessageCell *)cell];
    } else if ([cell isKindOfClass:[TUIVoiceMessageCell_Minimalist class]]) {
        [self playVoiceMessage:(TUIVoiceMessageCell_Minimalist *)cell];
    } else if ([cell isKindOfClass:[TUIImageMessageCell_Minimalist class]]) {
        [self showImageMessage:(TUIImageMessageCell_Minimalist *)cell];
    } else if ([cell isKindOfClass:[TUIVideoMessageCell_Minimalist class]]) {
        [self showVideoMessage:(TUIVideoMessageCell_Minimalist *)cell];
    } else if ([cell isKindOfClass:[TUIFileMessageCell_Minimalist class]]) {
        [self showFileMessage:(TUIFileMessageCell_Minimalist *)cell];
    } else if ([cell isKindOfClass:[TUIMergeMessageCell_Minimalist class]]) {
        [self showRelayMessage:(TUIMergeMessageCell_Minimalist *)cell];
    } else if ([cell isKindOfClass:[TUILinkCell_Minimalist class]]) {
        [self showLinkMessage:(TUILinkCell_Minimalist *)cell];
    } else if ([cell isKindOfClass:TUIReplyMessageCell_Minimalist.class]) {
        [self showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell];
    } else if ([cell isKindOfClass:TUIReferenceMessageCell_Minimalist.class]) {
        [self showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell];
    } else if ([cell isKindOfClass:TUIOrderCell_Minimalist.class]) {
        [self showOrderMessage:(TUIOrderCell_Minimalist *)cell];
    }

    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:self onSelectMessageContent:cell];
    }
}
- (void)showContextWindow:(TUIMessageCell *)cell {
    CGRect frame = [UIApplication.sharedApplication.keyWindow convertRect:cell.container.frame fromView:cell];
    TUIChatPopContextController *alertController = [[TUIChatPopContextController alloc] init];
    alertController.alertViewCellData = cell.messageData;
    alertController.originFrame = frame;
    alertController.alertCellClass = cell.class;
    // blur effect
    [alertController setBlurEffectWithView:self.navigationController.view];
    // config
    [self configItems:alertController targetCell:cell];
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    alertController.viewWillShowHandler = ^(TUIMessageCell *_Nonnull alertView) {
      alertView.delegate = weakSelf;
    };

    alertController.dismissComplete = ^{
      if (weakCell) {
          weakCell.container.hidden = NO;
      }
    };
    [self.navigationController presentViewController:alertController animated:NO completion:nil];
    self.popAlertController = alertController;
}

- (void)configItems:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    /**
     * Sort priorities: copy, forward, multiselect, reference, reply, Withdraw, delete
     * The higher the weight, the more prioritized it is:
        Copy - 10000
        Forward - 9000
        Select - 8000
        Quote - 7000
        Reply - 5000
        Recall - 3000
        Details - 2000
        Delete - 1000
     */
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:6];
    [self addNormalItemToItems:items cell:cell alertController:alertController];
    [self addExtraItemToItems:items cell:cell alertController:alertController];
    
    NSMutableArray *sortedArray = [self sortItems:items];
    NSMutableArray *allPageItemsArray = [self pageItems:sortedArray inAlertController:alertController];
    if (allPageItemsArray.count > 0) {
        alertController.items = allPageItemsArray[0];
    }
}

- (void)addNormalItemToItems:(NSMutableArray *)items
                        cell:(TUIMessageCell *)cell
             alertController:(TUIChatPopContextController *)alertController {
    BOOL isPluginCustomMessage = [TUIMessageCellConfig_Minimalist isPluginCustomMessageCellData:cell.messageData];
    if (isPluginCustomMessage) {
        [self addPluginCustomMessageItemToItems:items cell:cell alertController:alertController];
        return;
    }
    [self addNomalMessageItemToItems:items cell:cell alertController:alertController];
}

- (void)addPluginCustomMessageItemToItems:(NSMutableArray *)items
                                     cell:(TUIMessageCell *)cell
                          alertController:(TUIChatPopContextController *)alertController {
    V2TIMMessage *imMsg = cell.messageData.innerMessage;
    // Plugin build-in custom messsages, support actions: multiSelect, reference, reply, delete, recall.
    if ([self isAddMultiSelect:imMsg]) {
        [items addObject:[self setupMultiSelectAction:alertController targetCell:cell]];
    }
    if ([self isAddReply:imMsg]) {
        [items addObject:[self setupReplyAction:alertController targetCell:cell]];
    }
    if ([self isAddQuote:imMsg]) {
        [items addObject:[self setupReferenceAction:alertController targetCell:cell]];
    }
    if ([self isAddDelete]) {
        [items addObject:[self setupDeleteAction:alertController targetCell:cell]];
    }
    if ([self isAddRecall:imMsg]) {
        [items addObject:[self setupRecallAction:alertController targetCell:cell]];
    }
}

- (void)addNomalMessageItemToItems:(NSMutableArray *)items
                                     cell:(TUIMessageCell *)cell
                          alertController:(TUIChatPopContextController *)alertController {
    V2TIMMessage *imMsg = cell.messageData.innerMessage;
    // Normal messages.
    if (imMsg.soundElem) {
        [items addObject:[self setupAudioPlaybackStyleAction:alertController targetCell:cell]];
    }
    if ([self isAddCopy:imMsg data:cell.messageData]) {
        [items addObject:[self setupCopyAction:alertController targetCell:cell]];
    }
    if ([self isAddForward:imMsg]) {
        [items addObject:[self setupForwardAction:alertController targetCell:cell]];
    }
    if ([self isAddMultiSelect:imMsg]) {
        [items addObject:[self setupMultiSelectAction:alertController targetCell:cell]];
    }
    if ([self isAddQuote:imMsg]) {
        [items addObject:[self setupReferenceAction:alertController targetCell:cell]];
    }
    if ([self isAddReply:imMsg]) {
        [items addObject:[self setupReplyAction:alertController targetCell:cell]];
    }
    if ([self isAddRecall:imMsg]) {
        [items addObject:[self setupRecallAction:alertController targetCell:cell]];
    }
    if ([self isAddInfo:imMsg]) {
        [items addObject:[self setupInfoAction:alertController targetCell:cell]];
    }
    if ([self isAddDelete]) {
        [items addObject:[self setupDeleteAction:alertController targetCell:cell]];
    }
    if ([self isAddPin:imMsg]) {
        [items addObject:[self setupGroupPinAction:alertController targetCell:cell]];
    }
}

- (void)handleAIConversationLongPress:(TUIMessageCell *)cell {
    // Check if AI is currently typing, if so, don't allow long press
    if (_delegate && [_delegate respondsToSelector:@selector(isAICurrentlyTyping)] && [_delegate isAICurrentlyTyping]) {
        return;
    }
    
    TUIMessageCellData *data = cell.messageData;
    
    CGRect frame = [UIApplication.sharedApplication.keyWindow convertRect:cell.container.frame fromView:cell];
    TUIChatPopContextController *alertController = [[TUIChatPopContextController alloc] init];
    alertController.alertViewCellData = cell.messageData;
    alertController.originFrame = frame;
    alertController.alertCellClass = cell.class;
    alertController.configRecentView = NO;
    // blur effect
    [alertController setBlurEffectWithView:self.navigationController.view];
    // config
    [self configAIItems:alertController targetCell:cell];
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    alertController.viewWillShowHandler = ^(TUIMessageCell *_Nonnull alertView) {
      alertView.delegate = weakSelf;
    };

    alertController.dismissComplete = ^{
      if (weakCell) {
          weakCell.container.hidden = NO;
      }
    };
    [self.navigationController presentViewController:alertController animated:NO completion:nil];
    self.popAlertController = alertController;
}

- (void)configAIItems:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:6];
    
    V2TIMMessage *imMsg = cell.messageData.innerMessage;

    if ([self isAddCopy:imMsg data:cell.messageData]) {
        [items addObject:[self setupCopyAction:alertController targetCell:cell]];
    }
    if ([self isAddForward:imMsg]) {
        [items addObject:[self setupForwardAction:alertController targetCell:cell]];
    }
    if ([self isAddDelete]) {
        [items addObject:[self setupDeleteAction:alertController targetCell:cell]];
    }
    NSMutableArray *sortedArray = [self sortItems:items];
    NSMutableArray *allPageItemsArray = [self pageItems:sortedArray inAlertController:alertController];
    if (allPageItemsArray.count > 0) {
        alertController.items = allPageItemsArray[0];
    }
}

- (BOOL)isAddDelete {
    return [TUIChatConfig defaultConfig].enablePopMenuDeleteAction;
}

- (BOOL)isAddCopy:(V2TIMMessage *)imMsg data:(TUIMessageCellData *)data {
    BOOL isCopyShown = [TUIChatConfig defaultConfig].enablePopMenuCopyAction;
    BOOL isContentModerated = imMsg.hasRiskContent;
    return isCopyShown && ([data isKindOfClass:[TUITextMessageCellData class]]
                           || [data isKindOfClass:[TUIReferenceMessageCellData class]]
                           || [data isKindOfClass:[TUIReplyMessageCellData class]])
                      && !isContentModerated;
}

- (BOOL)isAddMultiSelect:(V2TIMMessage *)imMsg {
    BOOL isSelectShown = [TUIChatConfig defaultConfig].enablePopMenuSelectAction;
    BOOL isContentModerated = imMsg.hasRiskContent;
    return isSelectShown && !isContentModerated;
}

- (BOOL)isAddReply:(V2TIMMessage *)imMsg {
    BOOL isReplyShown = [TUIChatConfig defaultConfig].enablePopMenuReplyAction;
    BOOL isMsgSentSucceeded = imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC;
    BOOL isContentModerated = imMsg.hasRiskContent;
    return isReplyShown && isMsgSentSucceeded && !isContentModerated;
}

- (BOOL)isAddRecall:(V2TIMMessage *)imMsg {
    BOOL isMyselfMsgSender = [imMsg isSelf];
    BOOL isRecallSupported = [[NSDate date] timeIntervalSinceDate:imMsg.timestamp] < TUIChatConfig.defaultConfig.timeIntervalForMessageRecall;
    BOOL isMsgSentSucceeded = imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC;
    BOOL isRecallShown = [TUIChatConfig defaultConfig].enablePopMenuRecallAction;
    return imMsg && isMyselfMsgSender && isRecallSupported && isMsgSentSucceeded && isRecallShown;
}

- (BOOL)isAddQuote:(V2TIMMessage *)imMsg {
    BOOL isQuoteShown = [TUIChatConfig defaultConfig].enablePopMenuReferenceAction;
    BOOL isMsgSentSucceeded = imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC;
    BOOL isContentModerated = imMsg.hasRiskContent;
    return isQuoteShown && isMsgSentSucceeded && !isContentModerated;
}

- (BOOL)isAddForward:(V2TIMMessage *)imMsg {
    BOOL isForwardShown = [TUIChatConfig defaultConfig].enablePopMenuForwardAction;
    BOOL isMsgSentSucceeded = imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC;
    BOOL isContentModerated = imMsg.hasRiskContent;
    return isForwardShown && isMsgSentSucceeded && !isContentModerated;
}

- (BOOL)isAddPin:(V2TIMMessage *)imMsg {
    BOOL isGroup = (imMsg.groupID.length > 0);
    BOOL isCurrentUserSuperAdmin = [self.messageDataProvider isCurrentUserRoleSuperAdminInGroup];
    BOOL isMsgSentSucceeded = imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC;
    BOOL isPinShown = [TUIChatConfig defaultConfig].enablePopMenuPinAction;
    BOOL isContentModerated = imMsg.hasRiskContent;
    return isGroup && isCurrentUserSuperAdmin && isMsgSentSucceeded && isPinShown && !isContentModerated;
}

- (BOOL)isAddInfo:(V2TIMMessage *)imMsg {
    BOOL isMyselfMsgSender = [imMsg isSelf];
    BOOL isMsgSentSucceeded = imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC;
    BOOL isInfoShown = [TUIChatConfig defaultConfig].enablePopMenuInfoAction;
    return imMsg && isMyselfMsgSender && isMsgSentSucceeded && isInfoShown;
}

- (void)addExtraItemToItems:(NSMutableArray *)items
                       cell:(TUIMessageCell *)cell
            alertController:(TUIChatPopContextController *)alertController {
    NSArray<TUIExtensionInfo *> *infoArray =
        [TUICore getExtensionList:TUICore_TUIChatExtension_PopMenuActionItem_MinimalistExtensionID
                            param:@{TUICore_TUIChatExtension_PopMenuActionItem_TargetVC : self, TUICore_TUIChatExtension_PopMenuActionItem_ClickCell : cell}];

    for (TUIExtensionInfo *info in infoArray) {
        if (info.text && info.icon && info.onClicked) {
            TUIChatPopContextExtionItem *extension = [[TUIChatPopContextExtionItem alloc] 
                                                      initWithTitle:info.text
                                                      markIcon:info.icon
                                                      weight:info.weight
                                                      withActionHandler:^(TUIChatPopContextExtionItem *action) {
                [alertController blurDismissViewControllerAnimated:NO
                                                        completion:^(BOOL finished) { info.onClicked(@{});}];
            }];
            [items addObject:extension];
        }
    }
}

- (NSMutableArray *)sortItems:(NSMutableArray *)items {
    NSArray *sortResultArray = [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      TUIChatPopContextExtionItem *per1 = obj1;
      TUIChatPopContextExtionItem *per2 = obj2;
      return per1.weight > per2.weight ? NSOrderedAscending : NSOrderedDescending;
    }];
    return [NSMutableArray arrayWithArray:sortResultArray];
}

- (NSMutableArray *)pageItems:(NSMutableArray *)items inAlertController:(TUIChatPopContextController *)alertController {
    NSInteger perPageLimitedCount = 4;
    NSMutableArray *allPageItemsArray = [NSMutableArray array];
    NSUInteger itemsRemaining = items.count;
    int j = 0;
    while (itemsRemaining) {
        NSRange range = NSMakeRange(j, MIN(perPageLimitedCount, itemsRemaining));
        NSMutableArray *subLogArr = [NSMutableArray arrayWithArray:[items subarrayWithRange:range]];
        TUIChatPopContextExtionItem *lastItem = [subLogArr lastObject];
        lastItem.needBottomLine = YES;

        [allPageItemsArray addObject:subLogArr];
        itemsRemaining -= range.length;
        j += range.length;
    }

    if (allPageItemsArray.count != 1) {
        // more than one
        NSInteger lastPagedIndex = allPageItemsArray.count - 1;
        for (int pageIndex = 0; pageIndex < allPageItemsArray.count; pageIndex++) {
            NSInteger nextPageIndex = 0;
            if (lastPagedIndex != pageIndex) {
                nextPageIndex = pageIndex + 1;
            } else {
                nextPageIndex = 0;
            }
            TUIChatPopContextExtionItem *moreItem =
                [[TUIChatPopContextExtionItem alloc] initWithTitle:TIMCommonLocalizableString(More)
                                                          markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_more")]
                                                            weight:INT_MAX
                                                 withActionHandler:^(TUIChatPopContextExtionItem *action) {
                                                   NSMutableArray *nextPageItems = allPageItemsArray[nextPageIndex];
                                                   ;
                                                   alertController.items = nextPageItems;
                                                   [alertController updateExtionView];
                                                 }];
            moreItem.titleColor = [UIColor tui_colorWithHex:@"147AFF"];
            NSMutableArray *pageItems = allPageItemsArray[pageIndex];
            [pageItems addObject:moreItem];
        }
    } else {
        // only one
        NSMutableArray<TUIChatPopContextExtionItem *> *items = allPageItemsArray[0];
        TUIChatPopContextExtionItem *lastItem = [items lastObject];
        lastItem.needBottomLine = NO;
    }
    return allPageItemsArray;
}

- (void)onLongPressMessage:(TUIMessageCell *)cell {
    if (TUIChatConfig.defaultConfig.eventConfig.chatEventListener &&
        [TUIChatConfig.defaultConfig.eventConfig.chatEventListener respondsToSelector:@selector(onMessageLongClicked:messageCellData:)]) {
        BOOL result = [TUIChatConfig.defaultConfig.eventConfig.chatEventListener onMessageLongClicked:cell messageCellData:cell.messageData];
        if (result) {
            return;
        }
    }
    TUIMessageCellData *data = cell.messageData;
    if ([data isKindOfClass:[TUISystemMessageCellData class]]) {
        return;
    }
    self.menuUIMsg = data;
    // Check if this is an AI conversation and handle separately
    if ([self.conversationData isAIConversation]) {
        [self handleAIConversationLongPress:cell];
        return;
    }
    [self showContextWindow:cell];
}

- (void)onLongSelectMessageAvatar:(TUIMessageCell *)cell {
    if (TUIChatConfig.defaultConfig.eventConfig.chatEventListener &&
        [TUIChatConfig.defaultConfig.eventConfig.chatEventListener respondsToSelector:@selector(onUserIconLongClicked:messageCellData:)]) {
        BOOL result = [TUIChatConfig.defaultConfig.eventConfig.chatEventListener onUserIconLongClicked:cell messageCellData:cell.messageData];
        if (result) {
            return;
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onLongSelectMessageAvatar:)]) {
        [_delegate messageController:self onLongSelectMessageAvatar:cell];
    }
}

- (void)onRetryMessage:(TUIMessageCell *)cell {
    _reSendUIMsg = cell.messageData;
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitTipsConfirmResendMessage)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Re_send)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *_Nonnull action) {
                                                       [weakSelf sendUIMessage:weakSelf.reSendUIMsg];
                                                     }]];
    [alert tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel)
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction *_Nonnull action){

                                                     }]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)onSelectMessageAvatar:(TUIMessageCell *)cell {
    if (TUIChatConfig.defaultConfig.eventConfig.chatEventListener &&
        [TUIChatConfig.defaultConfig.eventConfig.chatEventListener respondsToSelector:@selector(onUserIconClicked:messageCellData:)]) {
       BOOL result = [TUIChatConfig.defaultConfig.eventConfig.chatEventListener onUserIconClicked:cell messageCellData:cell.messageData];
        if (result) {
            return;
        }
    }
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageAvatar:)]) {
        [self.delegate messageController:self onSelectMessageAvatar:cell];
    }
}

- (void)onJumpToRepliesDetailPage:(TUIMessageCellData *)data {
    TUIMessageCellData *copyData = [TUIMessageDataProvider getCellData:data.innerMessage];
    if (!copyData) {
        return;
    }
    @weakify(self);
    [self.messageDataProvider preProcessMessage:@[ copyData ]
                                       callback:^{
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                           @strongify(self);
                                           TUIMessageCell *cell = [[TUIMessageCell alloc] init];
                                           [cell fillWithData:copyData];
                                           TUIRepliesDetailViewController_Minimalist *repliesDetailVC =
                                               [[TUIRepliesDetailViewController_Minimalist alloc] initWithCellData:copyData
                                                                                                  conversationData:self.conversationData];
                                           repliesDetailVC.delegate = self.delegate;
                                           repliesDetailVC.modalPresentationStyle = UIModalPresentationCustom;

                                           [self.navigationController presentViewController:repliesDetailVC animated:YES completion:nil];
                                           self.hasCoverPage = YES;
                                           repliesDetailVC.parentPageDataProvider = self.messageDataProvider;
                                           @weakify(self);
                                           repliesDetailVC.willCloseCallback = ^() {
                                             @strongify(self);
                                             self.hasCoverPage = NO;
                                             [self.tableView reloadData];
                                           };
                                         });
                                       }];
}

- (void)onJumpToMessageInfoPage:(TUIMessageCellData *)data selectCell:(TUIMessageCell *)cell {

    TUIMessageCellData *alertViewCellData =  [TUIMessageDataProvider getCellData:cell.messageData.innerMessage];;
    @weakify(self);
    [self.messageDataProvider preProcessMessage:@[alertViewCellData] callback:^{
        @strongify(self);
        TUIMessageReadViewController_Minimalist *readViewController =
            [[TUIMessageReadViewController_Minimalist alloc] initWithCellData:data
                                                                 dataProvider:self.messageDataProvider
                                                        showReadStatusDisable:NO
                                                              c2cReceiverName:self.conversationData.title
                                                            c2cReceiverAvatar:self.conversationData.faceUrl];
        CGRect frame = [UIApplication.sharedApplication.keyWindow convertRect:cell.frame fromView:cell];
        readViewController.originFrame = frame;
        readViewController.alertCellClass = cell.class;
        @weakify(self);
        readViewController.viewWillShowHandler = ^(TUIMessageCell *_Nonnull alertView) {
          alertView.delegate = self;
        };
        readViewController.viewWillDismissHandler = ^(TUIMessageCell * _Nonnull alertView) {
          self.hasCoverPage = NO;
        };
        readViewController.alertViewCellData = alertViewCellData;
        self.hasCoverPage = YES;
        [self.navigationController pushViewController:readViewController animated:YES];
    }];

}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(onDelete:) || action == @selector(onRevoke:) || action == @selector(onReSend:) || action == @selector(onCopyMsg:) ||
        action == @selector(onMulitSelect:) || action == @selector(onForward:) || action == @selector(onReply:)) {
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (void)buildMenuWithBuilder:(id<UIMenuBuilder>)builder API_AVAILABLE(ios(13.0)) {
    if (@available(iOS 16.0, *)) {
        [builder removeMenuForIdentifier:UIMenuLookup];
    }
    [super buildMenuWithBuilder:builder];
}

- (void)menuDidHide:(NSNotification *)notification {
    if (_delegate && [_delegate respondsToSelector:@selector(didHideMenuInMessageController:)]) {
        [_delegate didHideMenuInMessageController:self];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)onCopyMsg:(id)sender {
    NSString *content = @"";
    /**
     * 
     * The text message should be based on the content of the message actually selected by the cursor
     */
    if ([sender isKindOfClass:[TUITextMessageCell_Minimalist class]]) {
        TUITextMessageCell_Minimalist *txtCell = (TUITextMessageCell_Minimalist *)sender;
        content = txtCell.textData.content;
    }
    if ([sender isKindOfClass:TUIReferenceMessageCell_Minimalist.class]) {
        TUIReferenceMessageCell_Minimalist *replyMsgCell = (TUIReferenceMessageCell_Minimalist *)sender;
        TUIReferenceMessageCellData *replyMsg = (TUIReferenceMessageCellData *)replyMsgCell.data;
        content = replyMsg.content;
    }
    if ([sender isKindOfClass:TUIReplyMessageCell_Minimalist.class]) {
        TUIReplyMessageCell_Minimalist *replyMsgCell = (TUIReplyMessageCell_Minimalist *)sender;
        TUIReplyMessageCellData *replyMsg = (TUIReplyMessageCellData *)replyMsgCell.data;
        content = replyMsg.content;
    }
    if (content.length > 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = content;
        [TUITool makeToast:TIMCommonLocalizableString(Copied)];
    }
}

- (void)onRevoke:(id)sender {
    @weakify(self);
    [self.messageDataProvider revokeUIMsg:self.menuUIMsg
        SuccBlock:^{
          @strongify(self);
          if (self.delegate && [self.delegate respondsToSelector:@selector(didHideMenuInMessageController:)]) {
              [self.delegate didHideMenuInMessageController:self];
          }
        }
        FailBlock:^(int code, NSString *desc) {
          NSAssert(NO, desc);
        }];
}

- (void)onReSend:(id)sender {
    [self sendUIMessage:_menuUIMsg];
}

- (void)onMulitSelect:(id)sender {
    [self enableMultiSelectedMode:YES];
    if (self.menuUIMsg.innerMessage.hasRiskContent) {
        if (_delegate && [_delegate respondsToSelector:@selector(messageController:onSelectMessageMenu:withData:)]) {
            [_delegate messageController:self onSelectMessageMenu:0 withData:nil];
        }
        return;
    }
    self.menuUIMsg.selected = YES;
    [self.tableView beginUpdates];
    NSInteger index = [self.messageDataProvider.uiMsgs indexOfObject:self.menuUIMsg];
    [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];

    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onSelectMessageMenu:withData:)]) {
        [_delegate messageController:self onSelectMessageMenu:0 withData:_menuUIMsg];
    }
}

- (void)onForward:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onSelectMessageMenu:withData:)]) {
        [_delegate messageController:self onSelectMessageMenu:1 withData:_menuUIMsg];
    }
}

- (void)onReply:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onRelyMessage:)]) {
        [_delegate messageController:self onRelyMessage:self.menuUIMsg];
    }
}

- (void)onReference:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onReferenceMessage:)]) {
        [_delegate messageController:self onReferenceMessage:self.menuUIMsg];
    }
}

- (BOOL)supportCheckBox:(TUIMessageCellData *)data {
    if ([data isKindOfClass:TUISystemMessageCellData.class]) {
        return NO;
    }
    return YES;
}

- (BOOL)supportRelay:(TUIMessageCellData *)data {
    if ([data isKindOfClass:TUIVoiceMessageCellData.class]) {
        return NO;
    }
    return YES;
}

- (void)enableMultiSelectedMode:(BOOL)enable {
    self.showCheckBox = enable;
    if (!enable) {
        for (TUIMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
            cellData.selected = NO;
        }
    }
    [self.tableView reloadData];
}

- (NSArray<TUIMessageCellData *> *)multiSelectedResult:(TUIMultiResultOption)option {
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

- (void)deleteMessages:(NSArray<TUIMessageCellData *> *)uiMsgs {
    [self.messageDataProvider deleteUIMsgs:uiMsgs
                                 SuccBlock:nil
                                 FailBlock:^(int code, NSString *desc) {
                                   NSLog(@"deleteMessages failed!");
                                   NSAssert(NO, desc);
                                 }];
}

- (void)removeUIMsgList:(NSArray<TUIMessageCellData *> *)uiMsgs {
    [self.messageDataProvider removeUIMsgList:uiMsgs];
}

- (void)clickTextMessage:(TUITextMessageCell_Minimalist *)cell {
    V2TIMMessage *message = cell.messageData.innerMessage;
    if (0 == message.userID.length) {
        return;
    }
    [TUIMessageDataProvider.callingDataProvider redialFromMessage:message];
}
- (void)clickSystemMessage:(TUISystemMessageCell *)cell {
    TUISystemMessageCellData *data = (TUISystemMessageCellData *)cell.messageData;
    if (data.supportReEdit) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageController:onReEditMessage:)]) {
            [self.delegate messageController:self onReEditMessage:cell.messageData];
        }
    }
}

- (void)playVoiceMessage:(TUIVoiceMessageCell_Minimalist *)cell {
    for (TUIMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
        if (![cellData isKindOfClass:[TUIVoiceMessageCellData class]]) {
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

- (void)showImageMessage:(TUIImageMessageCell_Minimalist *)cell {
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

- (void)showVideoMessage:(TUIVideoMessageCell_Minimalist *)cell {
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

- (void)showFileMessage:(TUIFileMessageCell_Minimalist *)cell {
    [self hideKeyboardIfNeeded];
    TUIFileMessageCellData *fileData = cell.fileData;
    if (![fileData isLocalExist]) {
        [fileData downloadFile];
        return;
    }

    if (self.popAlertController) {
        [self.popAlertController blurDismissViewControllerAnimated:NO
                                                        completion:^(BOOL finished){
                                                        }];
    }

    TUIFileViewController_Minimalist *file = [[TUIFileViewController_Minimalist alloc] init];
    file.data = [cell fileData];
    [self.navigationController pushViewController:file animated:YES];
}

- (void)showRelayMessage:(TUIMergeMessageCell_Minimalist *)cell {
    if (self.popAlertController) {
        [self.popAlertController blurDismissViewControllerAnimated:NO
                                                        completion:^(BOOL finished){
                                                        }];
    }
    TUIMergeMessageListController_Minimalist *mergeVc = [[TUIMergeMessageListController_Minimalist alloc] init];
    mergeVc.delegate = self.delegate;
    mergeVc.mergerElem = cell.mergeData.mergerElem;
    mergeVc.conversationData = self.conversationData;
    mergeVc.parentPageDataProvider = self.messageDataProvider;
    __weak typeof(self) weakSelf = self;
    mergeVc.willCloseCallback = ^() {
      [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:mergeVc animated:YES];
}

- (void)showLinkMessage:(TUILinkCell_Minimalist *)cell {
    TUILinkCellData *cellData = cell.customData;
    if (cellData.link) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cellData.link]];
    }
}

- (void)showOrderMessage:(TUIOrderCell_Minimalist *)cell {
    TUIOrderCellData *cellData = cell.customData;
    if (cellData.link) {
        [TUITool openLinkWithURL:[NSURL URLWithString:cellData.link]];
    }
}

- (void)showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell {
    // subclass override
}

- (void)willShowMediaMessage:(TUIMessageCell *)cell {
    // subclass override
}

- (void)didCloseMediaMessage:(TUIMessageCell *)cell {
    // subclass override
}

- (void)onDelete:(TUIMessageCell *)cell {
    // subclass override
}

#pragma mark - config TUIChatPopContextExtionItems
- (TUIChatPopContextExtionItem *)setupCopyAction:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(cell);
    @weakify(alertController);
    TUIChatPopContextExtionItem *copyItem =
        [[TUIChatPopContextExtionItem alloc] initWithTitle:TIMCommonLocalizableString(Copy)
                                                  markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_copy")]
                                                    weight:10000
                                         withActionHandler:^(TUIChatPopContextExtionItem *action) {
                                           @strongify(alertController);
                                           [alertController blurDismissViewControllerAnimated:NO
                                                                                   completion:^(BOOL finished) {
                                                                                     @strongify(self);
                                                                                     @strongify(cell);
                                                                                     [self onCopyMsg:cell];
                                                                                   }];
                                         }];
    return copyItem;
}

- (TUIChatPopContextExtionItem *)setupForwardAction:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(alertController);
    TUIChatPopContextExtionItem *forwardItem =
        [[TUIChatPopContextExtionItem alloc] initWithTitle:TIMCommonLocalizableString(Forward)
                                                  markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_forward")]
                                                    weight:9000
                                         withActionHandler:^(TUIChatPopContextExtionItem *action) {
                                           @strongify(alertController);
                                           [alertController blurDismissViewControllerAnimated:NO
                                                                                   completion:^(BOOL finished) {
                                                                                     @strongify(self);
                                                                                     [self onForward:nil];
                                                                                   }];
                                         }];
    return forwardItem;
}

- (TUIChatPopContextExtionItem *)setupMultiSelectAction:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(alertController);
    TUIChatPopContextExtionItem *multiSelectItem =
        [[TUIChatPopContextExtionItem alloc] initWithTitle:TIMCommonLocalizableString(MultiSelect)
                                                  markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_multi")]
                                                    weight:8000
                                         withActionHandler:^(TUIChatPopContextExtionItem *action) {
                                           @strongify(alertController);
                                           [alertController blurDismissViewControllerAnimated:NO
                                                                                   completion:^(BOOL finished) {
                                                                                     @strongify(self);
                                                                                     [self onMulitSelect:nil];
                                                                                   }];
                                         }];
    return multiSelectItem;
}

- (TUIChatPopContextExtionItem *)setupReferenceAction:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(alertController);
    TUIChatPopContextExtionItem *referenceItem =
        [[TUIChatPopContextExtionItem alloc] initWithTitle:TIMCommonLocalizableString(Quote)
                                                  markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_quote")]
                                                    weight:7000
                                         withActionHandler:^(TUIChatPopContextExtionItem *action) {
                                           @strongify(alertController);
                                           [alertController blurDismissViewControllerAnimated:NO
                                                                                   completion:^(BOOL finished) {
                                                                                     @strongify(self);
                                                                                     [self onReference:nil];
                                                                                   }];
                                         }];
    return referenceItem;
}
- (TUIChatPopContextExtionItem *)setupReplyAction:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(alertController);
    TUIChatPopContextExtionItem *replyItem =
        [[TUIChatPopContextExtionItem alloc] initWithTitle:TIMCommonLocalizableString(Reply)
                                                  markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_reply")]
                                                    weight:5000
                                         withActionHandler:^(TUIChatPopContextExtionItem *action) {
                                           @strongify(alertController);
                                           [alertController blurDismissViewControllerAnimated:NO
                                                                                   completion:^(BOOL finished) {
                                                                                     @strongify(self);
                                                                                     [self onReply:nil];
                                                                                   }];
                                         }];
    return replyItem;
}

- (TUIChatPopContextExtionItem *)setupRecallAction:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(alertController);
    TUIChatPopContextExtionItem *revocationItem =
        [[TUIChatPopContextExtionItem alloc] initWithTitle:TIMCommonLocalizableString(Recall)
                                                  markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_revocation")]
                                                    weight:3000
                                         withActionHandler:^(TUIChatPopContextExtionItem *action) {
                                           @strongify(alertController);
                                           [alertController blurDismissViewControllerAnimated:NO
                                                                                   completion:^(BOOL finished) {
                                                                                     @strongify(self);
                                                                                     [self onRevoke:nil];
                                                                                   }];
                                         }];
    return revocationItem;
}
- (TUIChatPopContextExtionItem *)setupInfoAction:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(cell);
    @weakify(alertController);
    TUIChatPopContextExtionItem *infoItem =
        [[TUIChatPopContextExtionItem alloc] initWithTitle:TIMCommonLocalizableString(Info)
                                                  markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_info")]
                                                    weight:2000
                                         withActionHandler:^(TUIChatPopContextExtionItem *action) {
                                           @strongify(alertController);
                                           [alertController blurDismissViewControllerAnimated:NO
                                                                                   completion:^(BOOL finished) {
                                                                                     @strongify(self);
                                                                                     @strongify(cell);
                                                                                     [self onJumpToMessageInfoPage:cell.messageData selectCell:cell];
                                                                                   }];
                                         }];

    return infoItem;
}
- (TUIChatPopContextExtionItem *)setupDeleteAction:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(cell);
    @weakify(alertController);
    TUIChatPopContextExtionItem *deleteItem =
        [[TUIChatPopContextExtionItem alloc] initWithTitle:TIMCommonLocalizableString(Delete)
                                                  markIcon:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_delete")]
                                                    weight:1000
                                         withActionHandler:^(TUIChatPopContextExtionItem *action) {
                                           @strongify(alertController);
                                           [alertController blurDismissViewControllerAnimated:NO
                                                                                   completion:^(BOOL finished) {
                                                                                     @strongify(self);
                                                                                     @strongify(cell);
                                                                                     [self onDelete:cell];
                                                                                   }];
                                         }];
    deleteItem.titleColor = [UIColor tui_colorWithHex:@"FF584C"];
    return deleteItem;
}

- (TUIChatPopContextExtionItem *)setupAudioPlaybackStyleAction:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    
    
    @weakify(self);
    @weakify(cell);
    @weakify(alertController);
    
    TUIVoiceAudioPlaybackStyle originStyle = [TUIVoiceMessageCellData getAudioplaybackStyle];

    TUIChatPopContextExtionItem *styleActionItem = nil;
    __weak typeof(styleActionItem)  weakStyleActionItem = styleActionItem;

    NSString *title = @"";
    UIImage * img = nil;
    if (originStyle == TUIVoiceAudioPlaybackStyleLoudspeaker) {
        title = TIMCommonLocalizableString(TUIKitAudioPlaybackStyleHandset);
        img   = [UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_loudspeaker")];
    }
    else {
        title = TIMCommonLocalizableString(TUIKitAudioPlaybackStyleLoudspeaker);
        img   = [UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_handset")];
    }
    
    styleActionItem =
        [[TUIChatPopContextExtionItem alloc] initWithTitle:title
                                                  markIcon:img
                                                    weight:11000
                                         withActionHandler:^(TUIChatPopContextExtionItem *action) {
            @strongify(alertController);
            [alertController blurDismissViewControllerAnimated:NO
                                                    completion:^(BOOL finished) {
                                                      if (originStyle == TUIVoiceAudioPlaybackStyleLoudspeaker) {
                                                          // Change To Handset
                                                          weakStyleActionItem.title = TIMCommonLocalizableString(TUIKitAudioPlaybackStyleLoudspeaker);
                                                          [TUITool hideToast];
                                                          [TUITool makeToast:TIMCommonLocalizableString(TUIKitAudioPlaybackStyleChange2Handset) duration:2];
                                                      } else {
                                                          weakStyleActionItem.title = TIMCommonLocalizableString(TUIKitAudioPlaybackStyleHandset);
                                                          [TUITool hideToast];
                                                          [TUITool makeToast:TIMCommonLocalizableString(TUIKitAudioPlaybackStyleChange2Loudspeaker) duration:2];
                                                      }
                                                      [TUIVoiceMessageCellData changeAudioPlaybackStyle];
                                                    }];
        }];
    return styleActionItem;
}
- (BOOL)isCurrentUserRoleSuperAdminInGroup {
    return [self.messageDataProvider isCurrentUserRoleSuperAdminInGroup];
}

- (BOOL)isCurrentMessagePin:(NSString *)msgID {
    return [self.messageDataProvider isCurrentMessagePin:msgID];
}
- (void)unPinGroupMessage:(V2TIMMessage *)innerMessage {
    NSString *groupId =  self.conversationData.groupID;
    BOOL isPinned = [self.messageDataProvider isCurrentMessagePin:innerMessage.msgID];
    BOOL pinOrUnpin = !isPinned;

    [self.messageDataProvider pinGroupMessage:groupId message:innerMessage isPinned:pinOrUnpin succ:^{
        
    } fail:^(int code, NSString *desc) {
        
    }];
}
- (TUIChatPopContextExtionItem *)setupGroupPinAction:(TUIChatPopContextController *)alertController targetCell:(TUIMessageCell *)cell {
    @weakify(self);
    @weakify(cell);
    @weakify(alertController);
    BOOL isPinned = [self.messageDataProvider isCurrentMessagePin:self.menuUIMsg.innerMessage.msgID];
    UIImage* img = isPinned ? [UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_unpin")] :
    [UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_extion_pin")];
    TUIChatPopContextExtionItem *groupPinAction =
        [[TUIChatPopContextExtionItem alloc] initWithTitle:isPinned?
         TIMCommonLocalizableString(TUIKitGroupMessageUnPin) : TIMCommonLocalizableString(TUIKitGroupMessagePin)
                                                  markIcon:img
                                                    weight:900
                                         withActionHandler:^(TUIChatPopContextExtionItem *action) {
                                           @strongify(alertController);
                                           [alertController blurDismissViewControllerAnimated:NO
                                                                                   completion:^(BOOL finished) {
                                                                                     @strongify(self);
                                                                                    [self onGroupPin:nil
                                                                                       currentStatus:isPinned];
                                                                                   }];
                                         }];
    return groupPinAction;
}
- (void)onGroupPin:(id)sender currentStatus:(BOOL)currentStatus {
    NSString *groupId =  self.conversationData.groupID;
    BOOL isPinned = currentStatus;
    BOOL pinOrUnpin = !isPinned;
    
    [self.messageDataProvider pinGroupMessage:groupId message:self.menuUIMsg.innerMessage isPinned:pinOrUnpin succ:^{

    } fail:^(int code, NSString *desc) {
        if (code == 10070) {
            [TUITool makeToast:TIMCommonLocalizableString(TUIKitGroupMessagePinOverLimit)];
        }
        else if (code == 10004) {
            if (pinOrUnpin) {
                [TUITool makeToast:TIMCommonLocalizableString(TUIKitGroupMessagePinRepeatedly)];
            }
            else {
                [TUITool makeToast:TIMCommonLocalizableString(TUIKitGroupMessageUnPinRepeatedly)];
            }
        }
    }];
}
@end
