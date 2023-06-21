//
//  TUIMergeMessageListController.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMergeMessageListController_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIMessageCellLayout.h>
#import <TIMCommon/TUISystemMessageCell.h>
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
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUIMessageSearchDataProvider_Minimalist.h"
#import "TUIReferenceMessageCell_Minimalist.h"
#import "TUIRepliesDetailViewController_Minimalist.h"
#import "TUIReplyMessageCellData_Minimalist.h"
#import "TUIReplyMessageCell_Minimalist.h"
#import "TUITextMessageCell_Minimalist.h"
#import "TUIVideoMessageCell_Minimalist.h"
#import "TUIVoiceMessageCell_Minimalist.h"

#define STR(x) @ #x

@interface TUIMergeMessageListController_Minimalist () <TUIMessageCellDelegate>
@property(nonatomic, strong) NSArray<V2TIMMessage *> *imMsgs;
@property(nonatomic, strong) NSMutableArray<TUIMessageCellData *> *uiMsgs;
@property(nonatomic, strong) NSMutableDictionary *stylesCache;
@property(nonatomic, strong) TUIMessageSearchDataProvider_Minimalist *msgDataProvider;
@end

@implementation TUIMergeMessageListController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];
    _uiMsgs = [[NSMutableArray alloc] init];
    [self loadMessages];
    [self setupViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.willCloseCallback) {
        self.willCloseCallback();
    }
}

- (void)loadMessages {
    @weakify(self);
    [self.mergerElem
        downloadMergerMessage:^(NSArray<V2TIMMessage *> *msgs) {
          @strongify(self);
          self.imMsgs = msgs;
          [self getMessages:self.imMsgs];
        }
                         fail:^(int code, NSString *desc){
                             // to do
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
            if ([data isKindOfClass:TUITextMessageCellData_Minimalist.class] || [data isKindOfClass:TUIReferenceMessageCellData_Minimalist.class]) {
                layout = TUIMessageCellLayout.incommingTextMessageLayout;
            } else if ([data isKindOfClass:TUIVoiceMessageCellData_Minimalist.class]) {
                layout = TUIMessageCellLayout.incommingVoiceMessageLayout;
            }
            data.cellLayout = layout;
            if (data) {
                data.direction = MsgDirectionIncoming;
                //                data.showName = YES;
                //                data.name = data.identifier;
                //                if (msg.nameCard.length > 0) {
                //                    data.name = msg.nameCard;
                //                } else if (msg.nickName.length > 0){
                //                    data.name = msg.nickName;
                //                }
                data.avatarUrl = [NSURL URLWithString:msg.faceURL];
                [uiMsgs addObject:data];
                continue;
            }
        }
        TUIMessageCellData *data = [TUIMessageDataProvider_Minimalist getCellData:msg];
        TUIMessageCellLayout *layout = TUIMessageCellLayout.incommingMessageLayout;

        if ([data isKindOfClass:TUITextMessageCellData_Minimalist.class]) {
            layout = TUIMessageCellLayout.incommingTextMessageLayout;
            TUITextMessageCellData_Minimalist *textData = (TUITextMessageCellData_Minimalist *)data;
            textData.textColor = TUIChatDynamicColor(@"chat_text_message_receive_text_color", @"#000000");
            textData.textFont = [TUITextMessageCellData_Minimalist incommingTextFont];
        } else if ([data isKindOfClass:TUIReplyMessageCellData_Minimalist.class] || [data isKindOfClass:TUIReferenceMessageCellData_Minimalist.class]) {
            layout = TUIMessageCellLayout.incommingTextMessageLayout;
            TUIReferenceMessageCellData_Minimalist *textData = (TUIReferenceMessageCellData_Minimalist *)data;
            textData.textColor = TUIChatDynamicColor(@"chat_text_message_receive_text_color", @"#000000");

        } else if ([data isKindOfClass:TUIVoiceMessageCellData_Minimalist.class]) {
            TUIVoiceMessageCellData_Minimalist *voiceData = (TUIVoiceMessageCellData_Minimalist *)data;
            voiceData.cellLayout = [TUIMessageCellLayout incommingVoiceMessageLayout];
            voiceData.voiceTop = 10;
            msg.localCustomInt = 1;
            layout = TUIMessageCellLayout.incommingVoiceMessageLayout;
        }
        data.cellLayout = layout;
        data.direction = MsgDirectionIncoming;
        //        data.showName = YES;
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
    for (TUIMessageCellData *cellData in uiMsgs) {
        [TUIMessageDataProvider_Minimalist updateUIMsgStatus:cellData uiMsgs:uiMsgs];
    }
    return uiMsgs;
}

- (void)setupViews {
    self.title = TIMCommonLocalizableString(TUIKitRelayChatHistory);
    self.tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 0;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");
    ;

    UIImage *image = TIMCommonDynamicImage(@"nav_back_img", [UIImage imageNamed:@"ic_back_white"]);
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

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

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES
                             completion:^{
                             }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
    CGFloat height = [data heightOfWidth:Screen_Width];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
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
        [self.navigationController pushViewController:relayVc animated:YES];
    }
    if ([cell isKindOfClass:[TUILinkCell_Minimalist class]]) {
        [self showLinkMessage:(TUILinkCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIReplyMessageCell_Minimalist class]]) {
        [self showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIReferenceMessageCell_Minimalist class]]) {
        [self showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell];
    }

    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:nil onSelectMessageContent:cell];
    }
}

- (void)scrollLocateMessage:(V2TIMMessage *)locateMessage {
    CGFloat offsetY = 0;
    for (TUIMessageCellData *uiMsg in self.uiMsgs) {
        if ([uiMsg.innerMessage.msgID isEqualToString:locateMessage.msgID]) {
            break;
        }
        offsetY += [uiMsg heightOfWidth:Screen_Width];
    }

    offsetY -= self.tableView.frame.size.height / 2.0;
    if (offsetY <= TMessageController_Header_Height) {
        offsetY = TMessageController_Header_Height + 0.1;
    }

    if (offsetY > TMessageController_Header_Height) {
        if (self.tableView.contentOffset.y > offsetY) {
            [self.tableView scrollRectToVisible:CGRectMake(0, offsetY, Screen_Width, self.tableView.bounds.size.height) animated:YES];
        }
    }
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
    if ([cellData isKindOfClass:TUITextMessageCellData_Minimalist.class]) {
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
- (void)showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell {
    [UIApplication.sharedApplication.keyWindow endEditing:YES];
    NSString *originMsgID = @"";
    NSString *msgAbstract = @"";
    if ([cell isKindOfClass:TUIReplyMessageCell_Minimalist.class]) {
        TUIReplyMessageCell_Minimalist *acell = (TUIReplyMessageCell_Minimalist *)cell;
        TUIReplyMessageCellData_Minimalist *cellData = acell.replyData;
        originMsgID = cellData.messageRootID;
        msgAbstract = cellData.msgAbstract;
    } else if ([cell isKindOfClass:TUIReferenceMessageCell_Minimalist.class]) {
        TUIReferenceMessageCell_Minimalist *acell = (TUIReferenceMessageCell_Minimalist *)cell;
        TUIReferenceMessageCellData_Minimalist *cellData = acell.referenceData;
        originMsgID = cellData.originMsgID;
        msgAbstract = cellData.msgAbstract;
    }

    [(TUIMessageSearchDataProvider_Minimalist *)self.msgDataProvider
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

              if ([cell isKindOfClass:TUIReplyMessageCell_Minimalist.class]) {
                  [self jumpDetailPageByMessage:message];
              } else if ([cell isKindOfClass:TUIReferenceMessageCell_Minimalist.class]) {
                  [self scrollLocateMessage:message];
              }
            }];
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
    TUIRepliesDetailViewController_Minimalist *repliesDetailVC = [[TUIRepliesDetailViewController_Minimalist alloc] initWithCellData:data
                                                                                                                    conversationData:self.conversationData];
    repliesDetailVC.delegate = self.delegate;
    repliesDetailVC.modalPresentationStyle = UIModalPresentationCustom;
    [self.navigationController presentViewController:repliesDetailVC animated:YES completion:nil];
    repliesDetailVC.parentPageDataProvider = self.parentPageDataProvider;
    __weak typeof(self) weakSelf = self;
    repliesDetailVC.willCloseCallback = ^() {
      [weakSelf.tableView reloadData];
    };
}

- (void)onJumpToRepliesEmojiPage:(TUIMessageCellData *)data {
    // to do
}

- (void)showImageMessage:(TUIImageMessageCell_Minimalist *)cell {
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView_Minimalist *mediaView = [[TUIMediaView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:self.imMsgs];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)playVoiceMessage:(TUIVoiceMessageCell_Minimalist *)cell {
    for (NSInteger index = 0; index < _uiMsgs.count; ++index) {
        if (![_uiMsgs[index] isKindOfClass:[TUIVoiceMessageCellData_Minimalist class]]) {
            continue;
        }
        TUIVoiceMessageCellData_Minimalist *uiMsg = (TUIVoiceMessageCellData_Minimalist *)_uiMsgs[index];
        if (uiMsg == cell.voiceData) {
            [uiMsg playVoiceMessage];
            cell.voiceReadPoint.hidden = YES;
        } else {
            [uiMsg stopVoiceMessage];
        }
    }
}

- (void)showVideoMessage:(TUIVideoMessageCell_Minimalist *)cell {
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView_Minimalist *mediaView = [[TUIMediaView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:self.imMsgs];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)showFileMessage:(TUIFileMessageCell_Minimalist *)cell {
    TUIFileMessageCellData_Minimalist *fileData = cell.fileData;
    if (![fileData isLocalExist]) {
        [fileData downloadFile];
        return;
    }

    TUIFileViewController_Minimalist *file = [[TUIFileViewController_Minimalist alloc] init];
    file.data = [cell fileData];
    [self.navigationController pushViewController:file animated:YES];
}

- (void)showLinkMessage:(TUILinkCell_Minimalist *)cell {
    TUILinkCellData_Minimalist *cellData = cell.customData;
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

- (TUIMessageSearchDataProvider_Minimalist *)msgDataProvider {
    if (_msgDataProvider == nil) {
        _msgDataProvider = [[TUIMessageSearchDataProvider_Minimalist alloc] init];
    }
    return _msgDataProvider;
}

@end
