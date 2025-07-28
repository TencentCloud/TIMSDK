
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUIMessageController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/UIView+TUILayout.h>
#import "TUIBaseMessageController+ProtectedAPI.h"
#import "TUIChatConfig.h"
#import "TUIChatModifyMessageHelper.h"
#import "TUIChatSmallTongueView.h"
#import "TUIMessageSearchDataProvider.h"
#import "TUIReferenceMessageCell.h"
#import "TUIReplyMessageCell.h"
#import "TUIReplyMessageCellData.h"
#import "TUITextMessageCell.h"

#define MSG_GET_COUNT 20

@interface TUIMessageController () <TUIChatSmallTongueViewDelegate>
@property(nonatomic, strong) UIActivityIndicatorView *bottomIndicatorView;
@property(nonatomic, assign) uint64_t locateGroupMessageSeq;
@property(nonatomic, strong) TUIChatSmallTongueView *tongueView;
@property(nonatomic, strong) NSMutableArray *receiveMsgs;
@property(nonatomic, weak) UIImageView *backgroudView;
@end

@implementation TUIMessageController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.bottomIndicatorView =
        [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TMessageController_Header_Height)];
    self.bottomIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.tableView.tableFooterView = self.bottomIndicatorView;

    self.tableView.backgroundColor = UIColor.clearColor;

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onBottomMarginChanged:) 
                                               name:TUIKitNotification_onMessageVCBottomMarginChanged object:nil];

    self.receiveMsgs = [NSMutableArray array];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.conversationData.atMsgSeqs.count > 0) {
            TUIChatSmallTongue *tongue = [[TUIChatSmallTongue alloc] init];
            tongue.type = TUIChatSmallTongueType_SomeoneAt;
            tongue.parentView = self.view.superview;
            tongue.atTipsStr = self.conversationData.atTipsStr;
            tongue.atMsgSeqs = [self.conversationData.atMsgSeqs copy];
            [TUIChatSmallTongueManager showTongue:tongue delegate:self];
        }
    });
}

- (void)dealloc {
    [TUIChatSmallTongueManager removeTongue];
    [NSNotificationCenter.defaultCenter removeObserver:self];
    NSLog(@"%s dealloc", __FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TUIChatSmallTongueManager hideTongue:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [TUIChatSmallTongueManager hideTongue:YES];
}

#pragma mark - Notification

- (void)keyboardWillShow {
    if (![self messageSearchDataProvider].isNewerNoMoreMsg) {
        [[self messageSearchDataProvider] removeAllSearchData];
        [self.tableView reloadData];
        [self loadMessages:YES];
    }
}

- (void)onBottomMarginChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo.allKeys containsObject:TUIKitNotification_onMessageVCBottomMarginChanged_Margin] &&
        [userInfo[TUIKitNotification_onMessageVCBottomMarginChanged_Margin] isKindOfClass:NSNumber.class]) {
        float margin = [userInfo[TUIKitNotification_onMessageVCBottomMarginChanged_Margin] floatValue];
        [TUIChatSmallTongueManager adaptTongueBottomMargin:margin];
    }
}

#pragma mark - Overrider
- (void)willShowMediaMessage:(TUIMessageCell *)cell {
    [TUIChatSmallTongueManager hideTongue:YES];
}

- (void)didCloseMediaMessage:(TUIMessageCell *)cell {
    [TUIChatSmallTongueManager hideTongue:NO];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    if (scrollView.contentOffset.y <= TMessageController_Header_Height
        && (scrollView.isTracking || scrollView.isDecelerating)
        && ![self messageSearchDataProvider].isOlderNoMoreMsg
        && !self.indicatorView.isAnimating) {
        // Display pull-to-refresh icon
        [self.indicatorView startAnimating];
    } else if ([self isScrollToBottomIndicatorViewY:scrollView]) {
        if ((scrollView.isTracking || scrollView.isDecelerating) 
            && ![self messageSearchDataProvider].isNewerNoMoreMsg
            && !self.bottomIndicatorView.isAnimating) {
            // Display pull-to-refresh icon
            [self.bottomIndicatorView startAnimating];
        }
        /**
         * Remove the "back to the latest position", "xxx new message" bottom-banner-tips
         */
        if (self.isInVC) {
            [TUIChatSmallTongueManager removeTongue:TUIChatSmallTongueType_ScrollToBoom];
            [TUIChatSmallTongueManager removeTongue:TUIChatSmallTongueType_ReceiveNewMsg];
        }
    } else if (self.isInVC && 0 == self.receiveMsgs.count 
               && self.tableView.contentSize.height - self.tableView.contentOffset.y >= Screen_Height * 2.0) {
        CGPoint point = [scrollView.panGestureRecognizer translationInView:scrollView];
        /**
         * When swiping, add a "back to last position" bottom-banner-tips
         */
        if (point.y > 0) {
            TUIChatSmallTongue *tongue = [[TUIChatSmallTongue alloc] init];
            tongue.type = TUIChatSmallTongueType_ScrollToBoom;
            tongue.parentView = self.view.superview;
            [TUIChatSmallTongueManager showTongue:tongue delegate:self];
        }
    } else if (self.isInVC && self.tableView.contentSize.height - self.tableView.contentOffset.y >= 20) {
        /**
         * Remove the "someone @ me" bottom-banner-tips
         */
        [TUIChatSmallTongueManager removeTongue:TUIChatSmallTongueType_SomeoneAt];
    } else {
        if (self.indicatorView.isAnimating) {
            [self.indicatorView stopAnimating];
        }
        if (self.bottomIndicatorView.isAnimating) {
            [self.bottomIndicatorView stopAnimating];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [super scrollViewDidEndDecelerating:scrollView];
    if (scrollView.contentOffset.y <= TMessageController_Header_Height && ![self messageSearchDataProvider].isOlderNoMoreMsg) {
        /**
         * Pull old news
         */
        [self loadMessages:YES];
    } else if ([self isScrollToBottomIndicatorViewY:scrollView] && ![self messageSearchDataProvider].isNewerNoMoreMsg) {
        /**
         * Load latese message
         */
        [self loadMessages:NO];
    }
}

- (BOOL)isScrollToBottomIndicatorViewY:(UIScrollView *)scrollView {
    /**
     * +2 pixels when scrolling to critical point
     */
    return (scrollView.contentOffset.y + self.tableView.mm_h + 2) > (scrollView.contentSize.height - self.indicatorView.mm_h);
}

#pragma mark - Getters & Setters
- (void)setConversation:(TUIChatConversationModel *)conversationData {
    self.conversationData = conversationData;
    self.messageDataProvider = [[TUIMessageSearchDataProvider alloc] initWithConversationModel:self.conversationData];
    self.messageDataProvider.dataSource = self;
    if (self.locateMessage) {
        [self loadAndScrollToLocateMessages:NO isHighlight:YES];
    } else {
        [[self messageSearchDataProvider] removeAllSearchData];
        [self loadMessages:YES];
    }
    [self loadGroupInfo];
}

#pragma mark - Private Methods
- (TUIMessageSearchDataProvider *)messageSearchDataProvider {
    return (TUIMessageSearchDataProvider *)self.messageDataProvider;
}

- (void)loadAndScrollToLocateMessages:(BOOL)scrollToBoom isHighlight:(BOOL)isHighlight{
    if (!self.locateMessage && self.locateGroupMessageSeq == 0) {
        return;
    }
    @weakify(self);
    [[self messageSearchDataProvider]
        loadMessageWithSearchMsg:self.locateMessage
                    SearchMsgSeq:self.locateGroupMessageSeq
                ConversationInfo:self.conversationData
     SucceedBlock:^(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, NSArray<TUIMessageCellData *> *_Nonnull newMsgs) {
        @strongify(self);
        [self.indicatorView stopAnimating];
        [self.bottomIndicatorView stopAnimating];
        self.indicatorView.mm_h = 0;
        self.bottomIndicatorView.mm_h = 0;
        
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToLocateMessage:scrollToBoom];
            if (isHighlight) {
                [self highlightKeyword];
            }
        });
    }
    FailBlock:^(int code, NSString *desc){}];
}

- (void)scrollToLocateMessage:(BOOL)scrollToBoom {
    /**
     * First find the coordinate offset of locateMsg
     */
    CGFloat offsetY = 0;
    NSInteger index = 0;
    for (TUIMessageCellData *uiMsg in [self messageSearchDataProvider].uiMsgs) {
        if ([self isLocateMessage:uiMsg]) {
            break;
        }
        offsetY += [self getHeightFromMessageCellData:uiMsg];
        index++;
    }

    /**
     * 
     * The locateMsg not found
     */
    if (index == [self messageSearchDataProvider].uiMsgs.count) {
        return;
    }

    /**
     *  tableview 
     * Offset half the height of the tableview
     */
    offsetY -= self.tableView.frame.size.height / 2.0;
    if (offsetY <= TMessageController_Header_Height) {
        offsetY = TMessageController_Header_Height + 0.1;
    }

    if (offsetY > TMessageController_Header_Height) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:YES];
    }
}

- (void)highlightKeyword {
    TUIMessageCellData *cellData = nil;
    for (TUIMessageCellData *tmp in [self messageSearchDataProvider].uiMsgs) {
        if ([self isLocateMessage:tmp]) {
            cellData = tmp;
            break;
        }
    }
    if (cellData == nil || cellData.innerMessage.elemType == V2TIM_ELEM_TYPE_GROUP_TIPS) {
        return;
    }

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
      @strongify(self);
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self messageDataProvider].uiMsgs indexOfObject:cellData] inSection:0];
      cellData.highlightKeyword = self.hightlightKeyword.length ? self.hightlightKeyword : @"hightlight";
      TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
      [cell fillWithData:cellData];
      @weakify(self);
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self messageDataProvider].uiMsgs indexOfObject:cellData] inSection:0];
        cellData.highlightKeyword = nil;
        TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell fillWithData:cellData];
      });
    });
}

- (BOOL)isLocateMessage:(TUIMessageCellData *)uiMsg {
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

- (void)loadMessages:(BOOL)order {
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
    [[self messageSearchDataProvider]
        loadMessageWithIsRequestOlderMsg:order
                        ConversationInfo:self.conversationData
                            SucceedBlock:^(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, BOOL isFirstLoad, NSArray<TUIMessageCellData *> *_Nonnull newUIMsgs) {
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
                              [newUIMsgs enumerateObjectsWithOptions:NSEnumerationReverse
                                                          usingBlock:^(TUIMessageCellData *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                                            if (obj.direction == MsgDirectionIncoming) {
                                                                self.C2CIncomingLastMsg = obj.innerMessage;
                                                                *stop = YES;
                                                            }
                                                          }];

                              if (isFirstLoad) {
                                  [self scrollToBottom:NO];
                                  [self restoreAITypingMessageIfNeeded];
                              } else {
                                  if (order) {
                                      NSInteger index = 0;
                                      if (newUIMsgs.count > 0) {
                                          index = newUIMsgs.count - 1;
                                      }
                                      if (self.messageDataProvider.uiMsgs.count > 0) {
                                          [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                                                atScrollPosition:UITableViewScrollPositionTop
                                                                        animated:NO];
                                      }
                                  }
                              }
                            }
                               FailBlock:^(int code, NSString *desc){

                               }];
}

- (void)showReplyMessage:(TUIReplyMessageCell *)cell {
    NSString *originMsgID = @"";
    NSString *msgAbstract = @"";
    if ([cell isKindOfClass:TUIReplyMessageCell.class]) {
        TUIReplyMessageCell *acell = (TUIReplyMessageCell *)cell;
        TUIReplyMessageCellData *cellData = acell.replyData;
        originMsgID = cellData.messageRootID;
        msgAbstract = cellData.msgAbstract;
    } else if ([cell isKindOfClass:TUIReferenceMessageCell.class]) {
        TUIReferenceMessageCell *acell = (TUIReferenceMessageCell *)cell;
        TUIReferenceMessageCellData *cellData = acell.referenceData;
        originMsgID = cellData.originMsgID;
        msgAbstract = cellData.msgAbstract;
    }

    @weakify(self);
    [(TUIMessageSearchDataProvider *)self.messageDataProvider
        findMessages:@[ originMsgID ?: @"" ]
            callback:^(BOOL success, NSString *_Nonnull desc, NSArray<V2TIMMessage *> *_Nonnull msgs) {
              @strongify(self);
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

              BOOL hasRiskContent = message.hasRiskContent;
           
              if ([cell isKindOfClass:TUIReplyMessageCell.class]) {
                  if (hasRiskContent) {
                      return;
                  }
                  [self jumpDetailPageByMessage:message];
              } else if ([cell isKindOfClass:TUIReferenceMessageCell.class]) {
                  [self locateAssignMessage:message matchKeyWord:msgAbstract];
              }
            }];
}

- (void)jumpDetailPageByMessage:(V2TIMMessage *)message {
    NSMutableArray *uiMsgs = [self.messageDataProvider transUIMsgFromIMMsg:@[ message ]];
    if (uiMsgs.count == 0) {
        return;
    }
    [self.messageDataProvider preProcessMessage:uiMsgs
                                       callback:^{
                                         for (TUIMessageCellData *cellData in uiMsgs) {
                                             if ([cellData.innerMessage.msgID isEqual:message.msgID]) {
                                                 [self onJumpToRepliesDetailPage:cellData];
                                                 return;
                                             }
                                         }
                                       }];
}

- (void)locateAssignMessage:(V2TIMMessage *)message matchKeyWord:(NSString *)keyword {
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
        [self scrollToLocateMessage:NO];
        [self highlightKeyword];
        return;
    }

    TUIMessageSearchDataProvider *provider = (TUIMessageSearchDataProvider *)self.messageDataProvider;
    provider.isNewerNoMoreMsg = NO;
    provider.isOlderNoMoreMsg = NO;
    [self loadAndScrollToLocateMessages:NO isHighlight:YES];
}

- (void)findMessages:(NSArray<NSString *> *)msgIDs callback:(void (^)(BOOL success, NSString *desc, NSArray<V2TIMMessage *> *messages))callback {
    TUIMessageSearchDataProvider *provider = (TUIMessageSearchDataProvider *)self.messageDataProvider;
    if (provider) {
        [provider findMessages:msgIDs callback:callback];
    }
}

#pragma mark - TUIMessageBaseDataProviderDataSource
- (void)dataProvider:(TUIMessageDataProvider *)dataProvider ReceiveNewUIMsg:(TUIMessageCellData *)uiMsg {
    [super dataProvider:dataProvider ReceiveNewUIMsg:uiMsg];
    /**
     * When viewing historical messages, if you scroll more than two screens, after receiving a new message, add a "xxx new message" bottom-banner-tips
     */
    if (self.tableView.contentSize.height - self.tableView.contentOffset.y >= Screen_Height * 2.0) {
        [self.receiveMsgs addObject:uiMsg];
        TUIChatSmallTongue *tongue = [[TUIChatSmallTongue alloc] init];
        tongue.type = TUIChatSmallTongueType_ReceiveNewMsg;
        tongue.parentView = self.view.superview;
        tongue.unreadMsgCount = self.receiveMsgs.count;
        [TUIChatSmallTongueManager showTongue:tongue delegate:self];
    }

    if (self.isInVC) {
        self.C2CIncomingLastMsg = uiMsg.innerMessage;
    }
}

- (void)dataProvider:(TUIMessageDataProvider *)dataProvider ReceiveRevokeUIMsg:(TUIMessageCellData *)uiMsg {
    /**
     * Recalled messages need to be removed from "xxx new messages" bottom-banner-tips
     */
    [super dataProvider:dataProvider ReceiveRevokeUIMsg:uiMsg];
    if ([self.receiveMsgs containsObject:uiMsg]) {
        [self.receiveMsgs removeObject:uiMsg];
        TUIChatSmallTongue *tongue = [[TUIChatSmallTongue alloc] init];
        tongue.type = TUIChatSmallTongueType_ReceiveNewMsg;
        tongue.parentView = self.view.superview;
        tongue.unreadMsgCount = self.receiveMsgs.count;
        if (tongue.unreadMsgCount != 0) {
            [TUIChatSmallTongueManager showTongue:tongue delegate:self];
        } else {
            [TUIChatSmallTongueManager removeTongue:TUIChatSmallTongueType_ReceiveNewMsg];
        }
    }

    /*
     *  When the retracted message is a "reply" type of message, go to the root message to delete the currently retracted message.
     */

    if ([uiMsg isKindOfClass:TUIReplyMessageCellData.class]) {
        TUIReplyMessageCellData *cellData = (TUIReplyMessageCellData *)uiMsg;
        NSString *messageRootID = @"";
        NSString *revokeMsgID = @"";
        messageRootID = cellData.messageRootID;
        revokeMsgID = cellData.msgID;

        [(TUIMessageSearchDataProvider *)self.messageDataProvider
            findMessages:@[ messageRootID ?: @"" ]
                callback:^(BOOL success, NSString *_Nonnull desc, NSArray<V2TIMMessage *> *_Nonnull msgs) {
                  if (success) {
                      V2TIMMessage *message = msgs.firstObject;
                      [[TUIChatModifyMessageHelper defaultHelper] modifyMessage:message revokeMsgID:revokeMsgID];
                  }
                }];
    }
    /*
     The message whose reference is withdrawn should not expose the original message content, so it is necessary to traverse all reference messages and reply messages and replace the original message content with "TIMCommonLocalizableString(TUIKitRepliesOriginMessageRevoke)"
     */
    for (TUIMessageCellData * cellData in self.messageDataProvider.uiMsgs) {
        if ([cellData isKindOfClass:TUIReplyMessageCellData.class]) {
            TUIReplyMessageCellData *replyMessageData = (TUIReplyMessageCellData *)cellData;
            if ([replyMessageData.originMessage.msgID isEqualToString:uiMsg.msgID]) {
                [self.messageDataProvider processQuoteMessage:@[replyMessageData]];
            }
        }
    }
}

#pragma mark - TUIChatSmallTongueViewDelegate
- (void)onChatSmallTongueClick:(TUIChatSmallTongue *)tongue {
    switch (tongue.type) {
        case TUIChatSmallTongueType_ScrollToBoom: {
            @weakify(self)
            [self.messageDataProvider getLastMessage:YES succ:^(V2TIMMessage * _Nonnull message) {
                @strongify(self)
                if (!message) return;
                self.locateMessage = message;
                for (TUIMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
                    if ([self isLocateMessage:cellData]) {
                        [self scrollToLocateMessage:YES];
                        return;
                    }
                }
                [self loadAndScrollToLocateMessages:YES isHighlight:NO];
            } fail:^(int code, NSString *desc) {
                NSLog(@"getLastMessage failed");
            }];
        } break;
        case TUIChatSmallTongueType_ReceiveNewMsg: {
            [TUIChatSmallTongueManager removeTongue:TUIChatSmallTongueType_ReceiveNewMsg];
            TUIMessageCellData *cellData = self.receiveMsgs.firstObject;
            if (cellData) {
                self.locateMessage = cellData.innerMessage;
                [self scrollToLocateMessage:YES];
                [self highlightKeyword];
            }
            [self.receiveMsgs removeAllObjects];
        } break;
        case TUIChatSmallTongueType_SomeoneAt: {
            [TUIChatSmallTongueManager removeTongue:TUIChatSmallTongueType_SomeoneAt];
            [self.conversationData.atMsgSeqs removeAllObjects];
            self.locateGroupMessageSeq = [tongue.atMsgSeqs.firstObject integerValue];
            for (TUIMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
                if ([self isLocateMessage:cellData]) {
                    [self scrollToLocateMessage:YES];
                    [self highlightKeyword];
                    return;
                }
            }
            [self loadAndScrollToLocateMessages:YES isHighlight:YES];
        } break;
        default:
            break;
    }
}

@end
