//
//  TUIMergeMessageListController.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//

#import "TUIMergeMessageListController.h"
#import "NSBundle+TUIKIT.h"
#import "TUITextMessageCell.h"
#import "TUISystemMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "TUIImageMessageCell.h"
#import "TUIFaceMessageCell.h"
#import "TUIVideoMessageCell.h"
#import "TUIFileMessageCell.h"
#import "TUIJoinGroupMessageCell.h"
#import "TUIMergeMessageCell.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"
#import "TIMMessage+DataProvider.h"
#import "TUIImageViewController.h"
#import "TUIVideoViewController.h"
#import "TUIFileViewController.h"
#import "UIColor+TUIDarkMode.h"

#define STR(x) @#x

@interface TUIMergeMessageListController () <TMessageCellDelegate>
@property (nonatomic, strong) NSMutableArray<TUIMessageCellData *> *uiMsgs;
@property (nonatomic, strong) NSMutableDictionary *stylesCache;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if(uiMsgs.count != 0){
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
            [self.uiMsgs insertObjects:uiMsgs atIndexes:indexSet];
//            [self.heightCache removeAllObjects];
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
        }
    });
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
        TUIMessageCellData *data = [msg cellData];
        // 全部设置为 incomming
        TUIMessageCellLayout *layout = TUIMessageCellLayout.incommingMessageLayout;
        if ([data isKindOfClass:TUITextMessageCellData.class]) {
            layout = TUIMessageCellLayout.incommingTextMessageLayout;
        }else if ([data isKindOfClass:TUIVoiceMessageCellData.class]) {
            TUIVoiceMessageCellData *voiceData = (TUIVoiceMessageCellData *)data;
            voiceData.cellLayout = [TUIMessageCellLayout incommingVoiceMessageLayout];
            voiceData.voiceImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_receiver_normal")];
            voiceData.voiceAnimationImages = [NSArray arrayWithObjects:
                                              [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_receiver_playing_1")],
                                              [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_receiver_playing_2")],
                                              [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_receiver_playing_3")], nil];
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
    self.title = TUILocalizableString(TUIKitRelayChatHistory);
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
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
//    if(_heightCache.count > indexPath.row){
//        return [_heightCache[indexPath.row] floatValue];
//    }
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
    height = [data heightOfWidth:Screen_Width];
//    [_heightCache insertObject:[NSNumber numberWithFloat:height] atIndex:indexPath.row];
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
    if (!data.reuseId) {
        if([data isKindOfClass:[TUITextMessageCellData class]]) {
            data.reuseId = TTextMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIFaceMessageCellData class]]) {
            data.reuseId = TFaceMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIImageMessageCellData class]]) {
            data.reuseId = TImageMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIVideoMessageCellData class]]) {
            data.reuseId = TVideoMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIVoiceMessageCellData class]]) {
            data.reuseId = TVoiceMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIFileMessageCellData class]]) {
            data.reuseId = TFileMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUIJoinGroupMessageCellData class]]){//入群小灰条对应的数据源
            data.reuseId = TJoinGroupMessageCell_ReuseId;
        }
        else if([data isKindOfClass:[TUISystemMessageCellData class]]) {
            data.reuseId = TSystemMessageCell_ReuseId;
        }
        else if ([data isKindOfClass:[TUIMergeMessageCellData class]]) {
            data.reuseId = TRelayMessageCell_ReuserId;
        }
        else {
            NSAssert(NO, @"无法解析当前cell");
            return nil;
        }
    }
    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    cell.delegate = self;
    [cell fillWithData:_uiMsgs[indexPath.row]];

    return cell;
}

#pragma mark - TMessageCellDelegate
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
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:nil onSelectMessageContent:cell];
    }
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
@end
