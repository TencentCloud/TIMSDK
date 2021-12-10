//
//  TUIMergeMessageListController.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//

#import "TUIMergeMessageListController.h"
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
#import "TUIImageViewController.h"
#import "TUIVideoViewController.h"
#import "TUIFileViewController.h"
#import "TUIMessageDataProvider.h"
#import "TUIDefine.h"
#import "TUIReplyMessageCellData.h"

#define STR(x) @#x

@interface TUIMergeMessageListController () <TUIMessageCellDelegate>
@property (nonatomic, strong) NSMutableArray<TUIMessageCellData *> *uiMsgs;
@property (nonatomic, strong) NSMutableDictionary *stylesCache;
@property (nonatomic, strong) TUIMessageDataProvider *msgDataProvider;
@end

@implementation TUIMergeMessageListController

- (void)viewDidLoad {
    [super viewDidLoad];
    _uiMsgs = [[NSMutableArray alloc] init];
    [self loadMessages];
    [self setupViews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self updateCellStyle:YES];
    if (self.willCloseCallback) {
        self.willCloseCallback();
    }
}

- (void)updateCellStyle:(BOOL)recover
{
    if (recover) {
        // 恢复全局设置
        [TUIBubbleMessageCellData setOutgoingBubble:self.stylesCache[STR(outgoingBubble)]];
        [TUIBubbleMessageCellData setIncommingBubble:self.stylesCache[STR(incomingBubble)]];
        TUIMessageCellLayout.incommingTextMessageLayout.bubbleInsets = UIEdgeInsetsFromString(self.stylesCache[STR(incomingTextBubbleInsets)]);
        TUIMessageCellLayout.incommingMessageLayout.avatarInsets = UIEdgeInsetsFromString(self.stylesCache[STR(incomingAvatarInsets)]);
        TUIMessageCellLayout.incommingTextMessageLayout.avatarInsets = UIEdgeInsetsFromString(self.stylesCache[STR(incomingAvatarInsets)]);
        TUIMessageCellLayout.incommingVoiceMessageLayout.avatarInsets = UIEdgeInsetsFromString(self.stylesCache[STR(incomingAvatarInsets)]);
        TUIMessageCellLayout.incommingMessageLayout.messageInsets = UIEdgeInsetsFromString(self.stylesCache[STR(incommingMessageInsets)]);
        [TUITextMessageCellData setOutgoingTextColor:self.stylesCache[STR(outgoingTextColor)]];
        [TUITextMessageCellData setIncommingTextColor:self.stylesCache[STR(incomingTextColor)]];
        return;
    }
    
    // 修改聊天记录界面
    UIImage *outgoingBubble = [TUIBubbleMessageCellData outgoingBubble];
    [TUIBubbleMessageCellData setOutgoingBubble:[UIImage new]];
    [self.stylesCache setObject:outgoingBubble?:[UIImage new] forKey:STR(outgoingBubble)];
    
    UIImage *incomingBubble = [TUIBubbleMessageCellData incommingBubble];
    [TUIBubbleMessageCellData setIncommingBubble:[self bubbleImage]];
    [self.stylesCache setObject:incomingBubble?:[UIImage new] forKey:STR(incomingBubble)];
    
    UIEdgeInsets incomingTextBubbleInsets = TUIMessageCellLayout.incommingTextMessageLayout.bubbleInsets;
    [TUIMessageCellLayout incommingTextMessageLayout].bubbleInsets = UIEdgeInsetsMake(5, 8, 0, 10);
    [self.stylesCache setObject:NSStringFromUIEdgeInsets(incomingTextBubbleInsets)?:@"" forKey:STR(incomingTextBubbleInsets)];
    
    UIEdgeInsets incomingAvatarInsets = TUIMessageCellLayout.incommingTextMessageLayout.avatarInsets;
    TUIMessageCellLayout.incommingMessageLayout.avatarInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    TUIMessageCellLayout.incommingTextMessageLayout.avatarInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    TUIMessageCellLayout.incommingVoiceMessageLayout.avatarInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    [self.stylesCache setObject:NSStringFromUIEdgeInsets(incomingAvatarInsets) forKey:STR(incomingAvatarInsets)];
    
    UIEdgeInsets incommingMessageInsets = TUIMessageCellLayout.incommingMessageLayout.messageInsets;
    TUIMessageCellLayout.incommingMessageLayout.messageInsets = UIEdgeInsetsMake(5, 5, 0, 0);
    [self.stylesCache setObject:NSStringFromUIEdgeInsets(incommingMessageInsets) forKey:STR(incommingMessageInsets)];
    
    UIColor *outgoingTextColor = [TUITextMessageCellData outgoingTextColor];
    [TUITextMessageCellData setOutgoingTextColor:[UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]]];
    [self.stylesCache setObject:outgoingTextColor forKey:STR(outgoingTextColor)];
    
    UIColor *incomingTextColor = [TUITextMessageCellData incommingTextColor];
    [TUITextMessageCellData setIncommingTextColor:[UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]]];
    [self.stylesCache setObject:incomingTextColor forKey:STR(incomingTextColor)];
    
}

- (void)loadMessages
{
    __weak typeof(self) weakSelf = self;
    [self.mergerElem downloadMergerMessage:^(NSArray<V2TIMMessage *> *msgs) {
        [weakSelf updateCellStyle:NO];
        [weakSelf getMessages:msgs];
    } fail:^(int code, NSString *desc) {
        [weakSelf updateCellStyle:NO];
    }];
}

- (void)getMessages:(NSArray *)msgs
{
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:msgs];
    @weakify(self)
    [self.msgDataProvider preProcessReplyMessage:uiMsgs callback:^{
        @strongify(self)
        @weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            if(uiMsgs.count != 0){
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
                [self.uiMsgs insertObjects:uiMsgs atIndexes:indexSet];
                [self.tableView reloadData];
                [self.tableView layoutIfNeeded];
            }
        });
    }];
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs
{
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = 0; k < msgs.count; k++) {
        V2TIMMessage *msg = msgs[k];
        // 外部自定义的消息
        if ([self.delegate respondsToSelector:@selector(messageController:onNewMessage:)]) {
            TUIMessageCellData *data = [self.delegate messageController:nil onNewMessage:msg];
            // 全部设置为 incomming
            TUIMessageCellLayout *layout = TUIMessageCellLayout.incommingMessageLayout;
            if ([data isKindOfClass:TUITextMessageCellData.class]) {
                layout = TUIMessageCellLayout.incommingTextMessageLayout;
            }else if ([data isKindOfClass:TUIVoiceMessageCellData.class]) {
                layout = TUIMessageCellLayout.incommingVoiceMessageLayout;
            }
            data.cellLayout = layout;
            if (data) {
                data.direction = MsgDirectionIncoming;
                data.showName = YES;
                data.name = data.identifier;
                if (msg.nameCard.length > 0) {
                    data.name = msg.nameCard;
                } else if (msg.nickName.length > 0){
                    data.name = msg.nickName;
                }
                data.avatarUrl = [NSURL URLWithString:msg.faceURL];
                [uiMsgs addObject:data];
                continue;
            }
        }
        TUIMessageCellData *data = [TUIMessageDataProvider getCellData:msg];
        // 全部设置为 incomming
        TUIMessageCellLayout *layout = TUIMessageCellLayout.incommingMessageLayout;
        if ([data isKindOfClass:TUITextMessageCellData.class]) {
            layout = TUIMessageCellLayout.incommingTextMessageLayout;
        }else if ([data isKindOfClass:TUIVoiceMessageCellData.class]) {
            TUIVoiceMessageCellData *voiceData = (TUIVoiceMessageCellData *)data;
            voiceData.cellLayout = [TUIMessageCellLayout incommingVoiceMessageLayout];
            voiceData.voiceImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"message_voice_receiver_normal")];
            voiceData.voiceAnimationImages = [NSArray arrayWithObjects:
                                              [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"message_voice_receiver_playing_1")],
                                              [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"message_voice_receiver_playing_2")],
                                              [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"message_voice_receiver_playing_3")], nil];
            voiceData.voiceTop = 10;
            msg.localCustomInt = 1; // 伪造其为 已读
            layout = TUIMessageCellLayout.incommingVoiceMessageLayout;
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

- (void)setupViews
{
    self.title = TUIKitLocalizableString(TUIKitRelayChatHistory);
    self.tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 0;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
    CGFloat height = [data heightOfWidth:Screen_Width];
    return height;
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
    if ([cell isKindOfClass:[TUIReplyMessageCell class]]) {
        [self showReplyMessage:(TUIReplyMessageCell *)cell];
    }
    
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:nil onSelectMessageContent:cell];
    }
}

- (void)showReplyMessage:(TUIReplyMessageCell *)cell
{
    TUIReplyMessageCellData *cellData = cell.replyData;
    V2TIMMessage *message = cellData.originMessage;
    if (message == nil) {
        [TUITool makeToast:@"原始消息不存在，无法跳转"];
        return;
    }
    
    // 当前消息已经处于加载状态
    BOOL memoryExist = NO;
    for (TUIMessageCellData *cellData in self.uiMsgs) {
        if ([cellData.innerMessage.msgID isEqual:message.msgID]) {
            memoryExist = YES;
            break;
        }
    }
    if (memoryExist == NO) {
        [TUITool makeToast:@"原始消息不存在，无法跳转"];
        return;
    }
    
    // 滚动
    [self scrollLocateMessage:message];
    // 高亮
    [self highlightKeyword:cellData.msgAbstract locateMessage:message];
}

- (void)scrollLocateMessage:(V2TIMMessage *)locateMessage
{
    // 先找到 locateMsg 的坐标偏移
    CGFloat offsetY = 0;
    for (TUIMessageCellData *uiMsg in self.uiMsgs) {
        if ([uiMsg.innerMessage.msgID isEqualToString:locateMessage.msgID]) {
            break;
        }
        offsetY += [uiMsg heightOfWidth:Screen_Width];
    }
    
    // 再偏移半个 tableview 的高度
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

- (void)highlightKeyword:(NSString *)keyword locateMessage:(V2TIMMessage *)locateMessage
{
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
    
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.uiMsgs indexOfObject:cellData] inSection:0];
        cellData.highlightKeyword = keyword;
        TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell fillWithData:cellData];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.uiMsgs indexOfObject:cellData] inSection:0];
        cellData.highlightKeyword = nil;
        TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell fillWithData:cellData];
    });
}

- (void)showImageMessage:(TUIImageMessageCell *)cell
{
    TUIImageViewController *image = [[TUIImageViewController alloc] init];
    image.data = [cell imageData];
    [self.navigationController pushViewController:image animated:YES];
}

- (void)playVoiceMessage:(TUIVoiceMessageCell *)cell
{
    for (NSInteger index = 0; index < _uiMsgs.count; ++index) {
        if(![_uiMsgs[index] isKindOfClass:[TUIVoiceMessageCellData class]]){
            continue;
        }
        TUIVoiceMessageCellData *uiMsg = (TUIVoiceMessageCellData *)_uiMsgs[index];
        if(uiMsg == cell.voiceData){
            [uiMsg playVoiceMessage];
            cell.voiceReadPoint.hidden = YES;
        }
        else{
            [uiMsg stopVoiceMessage];
        }
    }
}

- (void)showVideoMessage:(TUIVideoMessageCell *)cell
{
    TUIVideoViewController *video = [[TUIVideoViewController alloc] init];
    video.data = [cell videoData];
    [self.navigationController pushViewController:video animated:YES];
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

- (NSMutableDictionary *)stylesCache
{
    if (_stylesCache == nil) {
        _stylesCache = [NSMutableDictionary dictionary];
    }
    return _stylesCache;
}

// 生成一张透明的气泡图片撑开内容，确保语音消息可被点击
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

- (TUIMessageDataProvider *)msgDataProvider
{
    if (_msgDataProvider == nil) {
        _msgDataProvider = [[TUIMessageDataProvider alloc] init];
    }
    return _msgDataProvider;
}

@end
