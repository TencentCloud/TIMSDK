//
//  TUIMergeMessageListController.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMergeMessageListController.h"
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
#import "TUIMessageDataProvider.h"
#import "TUIMessageSearchDataProvider.h"
#import "TUIReferenceMessageCell.h"
#import "TUIRepliesDetailViewController.h"
#import "TUIReplyMessageCell.h"
#import "TUIReplyMessageCellData.h"
#import "TUITextMessageCell.h"
#import "TUIVideoMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "TUIMessageCellConfig.h"
#import "TUIChatConfig.h"

#define STR(x) @ #x

@interface TUIMergeMessageListController () <TUIMessageCellDelegate, TUIMessageBaseDataProviderDataSource,TUINotificationProtocol>
@property(nonatomic, strong) NSArray<V2TIMMessage *> *imMsgs;
@property(nonatomic, strong) NSMutableArray<TUIMessageCellData *> *uiMsgs;
@property(nonatomic, strong) NSMutableDictionary *stylesCache;
@property(nonatomic, strong) TUIMessageSearchDataProvider *msgDataProvider;

@property(nonatomic, strong) TUIMessageCellConfig *messageCellConfig;

@end

@implementation TUIMergeMessageListController

- (instancetype)init {
    self = [super init];
    if (self) {
        [TUICore registerEvent:TUICore_TUIPluginNotify
                        subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey
                        object:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _uiMsgs = [[NSMutableArray alloc] init];
    [self loadMessages];
    [self setupViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self updateCellStyle:YES];
    if (self.willCloseCallback) {
        self.willCloseCallback();
    }
}

- (void)updateCellStyle:(BOOL)recover {
    if (recover) {
        TUIMessageCellLayout.incommingMessageLayout.avatarInsets = UIEdgeInsetsFromString(self.stylesCache[STR(incomingAvatarInsets)]);
        TUIMessageCellLayout.incommingTextMessageLayout.avatarInsets = UIEdgeInsetsFromString(self.stylesCache[STR(incomingAvatarInsets)]);
        TUIMessageCellLayout.incommingVoiceMessageLayout.avatarInsets = UIEdgeInsetsFromString(self.stylesCache[STR(incomingAvatarInsets)]);
        TUIMessageCellLayout.incommingMessageLayout.messageInsets = UIEdgeInsetsFromString(self.stylesCache[STR(incommingMessageInsets)]);
        [TUITextMessageCell setOutgoingTextColor:self.stylesCache[STR(outgoingTextColor)]];
        [TUITextMessageCell setIncommingTextColor:self.stylesCache[STR(incomingTextColor)]];
        return;
    }

    UIEdgeInsets incomingAvatarInsets = TUIMessageCellLayout.incommingTextMessageLayout.avatarInsets;
    TUIMessageCellLayout.incommingMessageLayout.avatarInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    TUIMessageCellLayout.incommingTextMessageLayout.avatarInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    TUIMessageCellLayout.incommingVoiceMessageLayout.avatarInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    [self.stylesCache setObject:NSStringFromUIEdgeInsets(incomingAvatarInsets) forKey:STR(incomingAvatarInsets)];

    UIEdgeInsets incommingMessageInsets = TUIMessageCellLayout.incommingMessageLayout.messageInsets;
    TUIMessageCellLayout.incommingMessageLayout.messageInsets = UIEdgeInsetsMake(5, 5, 0, 0);
    [self.stylesCache setObject:NSStringFromUIEdgeInsets(incommingMessageInsets) forKey:STR(incommingMessageInsets)];

    UIColor *outgoingTextColor = [TUITextMessageCell outgoingTextColor];
    [TUITextMessageCell setOutgoingTextColor:TUIChatDynamicColor(@"chat_text_message_send_text_color", @"#000000")];
    [self.stylesCache setObject:outgoingTextColor forKey:STR(outgoingTextColor)];

    UIColor *incomingTextColor = [TUITextMessageCell incommingTextColor];
    [TUITextMessageCell setIncommingTextColor:TUIChatDynamicColor(@"chat_text_message_receive_text_color", @"#000000")];
    [self.stylesCache setObject:incomingTextColor forKey:STR(incomingTextColor)];
}

- (void)loadMessages {
    @weakify(self);
    [self.mergerElem
        downloadMergerMessage:^(NSArray<V2TIMMessage *> *msgs) {
          @strongify(self);
          self.imMsgs = msgs;
          [self updateCellStyle:NO];
          [self getMessages:self.imMsgs];
        }
        fail:^(int code, NSString *desc) {
          [self updateCellStyle:NO];
        }];
}

- (void)getMessages:(NSArray *)msgs {
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:msgs];
    @weakify(self);
    [self.msgDataProvider preProcessMessage:uiMsgs
                                   callback:^{
                                     @strongify(self);
                                     @weakify(self);
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                       @strongify(self);
                                       if (uiMsgs.count != 0) {
                                           NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
                                           [self.uiMsgs insertObjects:uiMsgs atIndexes:indexSet];
                                           [self.tableView reloadData];
                                           [self.tableView layoutIfNeeded];
                                       }
                                     });
                                   }];
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs {
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = 0; k < msgs.count; k++) {
        V2TIMMessage *msg = msgs[k];
        if ([self.delegate respondsToSelector:@selector(messageController:onNewMessage:)]) {
            TUIMessageCellData *data = [self.delegate messageController:nil onNewMessage:msg];
            TUIMessageCellLayout *layout = TUIMessageCellLayout.incommingMessageLayout;
            if ([data isKindOfClass:TUITextMessageCellData.class] || [data isKindOfClass:TUIReferenceMessageCellData.class]) {
                layout = TUIMessageCellLayout.incommingTextMessageLayout;
            } else if ([data isKindOfClass:TUIVoiceMessageCellData.class]) {
                layout = TUIMessageCellLayout.incommingVoiceMessageLayout;
            }
            data.cellLayout = layout;
            if (data) {
                data.direction = MsgDirectionIncoming;
                data.showName = YES;
                data.name = data.identifier;
                if (msg.nameCard.length > 0) {
                    data.name = msg.nameCard;
                } else if (msg.nickName.length > 0) {
                    data.name = msg.nickName;
                }
                data.avatarUrl = [NSURL URLWithString:msg.faceURL];
                [uiMsgs addObject:data];
                continue;
            }
        }
        TUIMessageCellData *data = [TUIMessageDataProvider getCellData:msg];
        TUIMessageCellLayout *layout = TUIMessageCellLayout.incommingMessageLayout;

        if ([data isKindOfClass:TUITextMessageCellData.class]) {
            layout = TUIMessageCellLayout.incommingTextMessageLayout;
        } else if ([data isKindOfClass:TUIReplyMessageCellData.class] || [data isKindOfClass:TUIReferenceMessageCellData.class]) {
            layout = TUIMessageCellLayout.incommingTextMessageLayout;
            TUIReferenceMessageCellData *textData = (TUIReferenceMessageCellData *)data;
            textData.textColor = TUIChatDynamicColor(@"chat_text_message_receive_text_color", @"#000000");

        } else if ([data isKindOfClass:TUIVoiceMessageCellData.class]) {
            TUIVoiceMessageCellData *voiceData = (TUIVoiceMessageCellData *)data;
            voiceData.cellLayout = [TUIMessageCellLayout incommingVoiceMessageLayout];
            voiceData.voiceImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"message_voice_receiver_normal")];
            voiceData.voiceAnimationImages =
                [NSArray arrayWithObjects:[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"message_voice_receiver_playing_1")],
                                          [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"message_voice_receiver_playing_2")],
                                          [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"message_voice_receiver_playing_3")], nil];
            voiceData.voiceTop = 10;
            msg.localCustomInt = 1;
            layout = TUIMessageCellLayout.incommingVoiceMessageLayout;
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
    return uiMsgs;
}

- (void)setupViews {
    self.title = TIMCommonLocalizableString(TUIKitRelayChatHistory);
    self.tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 0;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    [self.messageCellConfig bindTableView:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static CGFloat screenWidth = 0;
    if (screenWidth == 0) {
        screenWidth = Screen_Width;
    }
    if (indexPath.row < _uiMsgs.count) {
        TUIMessageCellData *cellData = _uiMsgs[indexPath.row];
        CGFloat height = [self.messageCellConfig getHeightFromMessageCellData:cellData];
        return height;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
    data.showMessageTime = YES;
    data.showCheckBox = NO;
    TUIMessageCell *cell = nil;
    if ([self.delegate respondsToSelector:@selector(messageController:onShowMessageData:)]) {
        cell = [self.delegate messageController:nil onShowMessageData:data];
        if (cell) {
            cell.delegate = self;
            return cell;
        }
    }
    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    cell.delegate = self;
    [cell fillWithData:_uiMsgs[indexPath.row]];
    return cell;
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
    if ([cell isKindOfClass:[TUIReplyMessageCell class]]) {
        [self showReplyMessage:(TUIReplyMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIReferenceMessageCell class]]) {
        [self showReplyMessage:(TUIReplyMessageCell *)cell];
    }

    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:nil onSelectMessageContent:cell];
    }
}

- (void)scrollToLocateMessage:(V2TIMMessage *)locateMessage matchKeyword:(NSString *)msgAbstract {
    CGFloat offsetY = 0;
    NSInteger index = 0;
    for (TUIMessageCellData *uiMsg in self.uiMsgs) {
        if ([uiMsg.innerMessage.msgID isEqualToString:locateMessage.msgID]) {
            break;
        }
        offsetY += [uiMsg heightOfWidth:Screen_Width];
        index++;
    }

    if (index == self.uiMsgs.count) {
        return;
    }
    
    offsetY -= self.tableView.frame.size.height / 2.0;
    if (offsetY <= TMessageController_Header_Height) {
        offsetY = TMessageController_Header_Height + 0.1;
    }

    if (offsetY > TMessageController_Header_Height) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:YES];
    }
    
    [self highlightKeyword:msgAbstract locateMessage:locateMessage];
}

- (void)highlightKeyword:(NSString *)keyword locateMessage:(V2TIMMessage *)locateMessage {
    TUIMessageCellData *cellData = nil;
    for (TUIMessageCellData *tmp in self.uiMsgs) {
        if ([tmp.msgID isEqualToString:locateMessage.msgID]) {
            cellData = tmp;
            break;
        }
    }
    if (cellData == nil) {
        return;
    }

    CGFloat time = 0.5;
    UITableViewRowAnimation animation = UITableViewRowAnimationFade;
    if ([cellData isKindOfClass:TUITextMessageCellData.class]) {
        time = 2;
        animation = UITableViewRowAnimationNone;
    }

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
      @strongify(self);
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.uiMsgs indexOfObject:cellData] inSection:0];
      cellData.highlightKeyword = keyword;
      TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
      [cell fillWithData:cellData];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      @strongify(self);
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.uiMsgs indexOfObject:cellData] inSection:0];
      cellData.highlightKeyword = nil;
      TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
      [cell fillWithData:cellData];
    });
}
- (void)showReplyMessage:(TUIReplyMessageCell *)cell {
    [UIApplication.sharedApplication.keyWindow endEditing:YES];
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

    
    TUIMessageCellData *originMemoryMessageData = nil;
    for (TUIMessageCellData *uiMsg in self.uiMsgs) {
        if ([uiMsg.innerMessage.msgID isEqualToString:originMsgID]) {
            originMemoryMessageData = uiMsg;
            break;
        }
    }
    
    if (originMemoryMessageData && [cell isKindOfClass:TUIReplyMessageCell.class]) {
        [self onJumpToRepliesDetailPage:originMemoryMessageData];
    }
    else {
        [(TUIMessageSearchDataProvider *)self.msgDataProvider
            findMessages:@[ originMsgID ?: @"" ]
                callback:^(BOOL success, NSString *_Nonnull desc, NSArray<V2TIMMessage *> *_Nonnull msgs) {
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

                  if ([cell isKindOfClass:TUIReplyMessageCell.class]) {
                      [self jumpDetailPageByMessage:message];
                  } else if ([cell isKindOfClass:TUIReferenceMessageCell.class]) {
                      [self scrollToLocateMessage:message matchKeyword:msgAbstract];
                  }
                }];
    }

}

- (void)jumpDetailPageByMessage:(V2TIMMessage *)message {
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:@[ message ]];
    [self.msgDataProvider preProcessMessage:uiMsgs
                                   callback:^{
                                     for (TUIMessageCellData *cellData in uiMsgs) {
                                         if ([cellData.innerMessage.msgID isEqual:message.msgID]) {
                                             [self onJumpToRepliesDetailPage:cellData];
                                             return;
                                         }
                                     }
                                   }];
}

- (void)onJumpToRepliesDetailPage:(TUIMessageCellData *)data {
    TUIRepliesDetailViewController *repliesDetailVC = [[TUIRepliesDetailViewController alloc] initWithCellData:data conversationData:self.conversationData];
    repliesDetailVC.delegate = self.delegate;
    [self.navigationController pushViewController:repliesDetailVC animated:YES];
    repliesDetailVC.parentPageDataProvider = self.parentPageDataProvider;
    __weak typeof(self) weakSelf = self;
    repliesDetailVC.willCloseCallback = ^() {
      [weakSelf.tableView reloadData];
    };
}

- (void)showImageMessage:(TUIImageMessageCell *)cell {
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView *mediaView = [[TUIMediaView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:self.imMsgs];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)playVoiceMessage:(TUIVoiceMessageCell *)cell {
    for (NSInteger index = 0; index < _uiMsgs.count; ++index) {
        if (![_uiMsgs[index] isKindOfClass:[TUIVoiceMessageCellData class]]) {
            continue;
        }
        TUIVoiceMessageCellData *uiMsg = (TUIVoiceMessageCellData *)_uiMsgs[index];
        if (uiMsg == cell.voiceData) {
            [uiMsg playVoiceMessage];
            cell.voiceReadPoint.hidden = YES;
        } else {
            [uiMsg stopVoiceMessage];
        }
    }
}

- (void)showVideoMessage:(TUIVideoMessageCell *)cell {
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView *mediaView = [[TUIMediaView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:self.imMsgs];
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

- (NSMutableDictionary *)stylesCache {
    if (_stylesCache == nil) {
        _stylesCache = [NSMutableDictionary dictionary];
    }
    return _stylesCache;
}

- (UIImage *)bubbleImage {
    CGRect rect = CGRectMake(0, 0, 100, 40);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (TUIMessageSearchDataProvider *)msgDataProvider {
    if (_msgDataProvider == nil) {
        _msgDataProvider = [[TUIMessageSearchDataProvider alloc] init];
        _msgDataProvider.dataSource = self;
    }
    return _msgDataProvider;
}

- (TUIMessageCellConfig *)messageCellConfig {
    if (_messageCellConfig == nil) {
        _messageCellConfig = [[TUIMessageCellConfig alloc] init];
    }
    return _messageCellConfig;
}

#pragma mark - TUIMessageBaseDataProviderDataSource
- (void)dataProviderDataSourceWillChange:(TUIMessageBaseDataProvider *)dataProvider {
    // do nothing
}

- (void)dataProviderDataSourceChange:(TUIMessageBaseDataProvider *)dataProvider
                            withType:(TUIMessageBaseDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation {
    // do nothing
}

- (void)dataProviderDataSourceDidChange:(TUIMessageBaseDataProvider *)dataProvider {
    [self.tableView reloadData];
}

- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider onRemoveHeightCache:(TUIMessageCellData *)cellData {
    if (cellData) {
        [self.messageCellConfig removeHeightCacheOfMessageCellData:cellData];
    }
}

#pragma mark - TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(id)anObject param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIPluginNotify] && [subKey isEqualToString:TUICore_TUIPluginNotify_DidChangePluginViewSubKey]) {
        TUIMessageCellData *data = param[TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data];
        [self.messageCellConfig removeHeightCacheOfMessageCellData:data];
        [self reloadAndScrollToBottomOfMessage:data.innerMessage.msgID section:0];
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
    for (int i = 0; i < self.uiMsgs.count; i++) {
        TUIMessageCellData *data = self.uiMsgs[i];
        if ([data.innerMessage.msgID isEqualToString:messageID]) {
            return [NSIndexPath indexPathForRow:i inSection:section];
        }
    }
    return nil;
}
@end
