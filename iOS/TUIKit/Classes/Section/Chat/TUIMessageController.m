//
//  TUIMessageController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIMessageController.h"
#import "TUITextMessageCell.h"
#import "TUISystemMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "TUIImageMessageCell.h"
#import "TUIFaceMessageCell.h"
#import "TUIVideoMessageCell.h"
#import "TUIFileMessageCell.h"
#import "TUIKitConfig.h"
#import "TUIFaceView.h"
#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
#import "TUIConversationCellData.h"
#import "TIMMessage+DataProvider.h"
#import "TUIImageViewController.h"
#import "TUIVideoViewController.h"
#import "TUIFileViewController.h"
#import "TUIConversationDataProviderService.h"
@import ImSDK;

#define MAX_MESSAGE_SEP_DLAY (5 * 60)

@interface TUIMessageController () <TIMMessageListener, TMessageCellDelegate>
@property (nonatomic, strong) TIMConversation *conv;
@property (nonatomic, strong) NSMutableArray *uiMsgs;
@property (nonatomic, strong) NSMutableArray *heightCache;
@property (nonatomic, strong) TIMMessage *msgForDate;
@property (nonatomic, strong) TIMMessage *msgForGet;
@property (nonatomic, strong) TUIMessageCellData *menuUIMsg;
@property (nonatomic, strong) TUIMessageCellData *reSendUIMsg;
@property (nonatomic, strong) UIActivityIndicatorView *headerView;
@property (nonatomic, assign) BOOL isScrollBottom;
@property (nonatomic, assign) BOOL isLoadingMsg;
@property (nonatomic, assign) BOOL noMoreMsg;
@property id<TUIConversationDataProviderServiceProtocol> conversationDataProviderService;
@end

@implementation TUIMessageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self readedReport];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self readedReport];
    [super viewWillDisappear:animated];
}

- (void)readedReport
{
    [self.conv setReadMessage:nil succ:nil fail:^(int code, NSString *msg) {
        
    }];
}

- (void)setupViews
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewMessage:) name:TUIKitNotification_TIMMessageListener object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRevokeMessage:) name:TUIKitNotification_TIMMessageRevokeListener object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUploadMessage:) name:TUIKitNotification_TIMUploadProgressListener object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapViewController)];
    [self.view addGestureRecognizer:tap];
    self.tableView.estimatedRowHeight = 0;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = TMessageController_Background_Color;
    
    [self.tableView registerClass:[TUITextMessageCell class] forCellReuseIdentifier:TTextMessageCell_ReuseId];
    [self.tableView registerClass:[TUIVoiceMessageCell class] forCellReuseIdentifier:TVoiceMessageCell_ReuseId];
    [self.tableView registerClass:[TUIImageMessageCell class] forCellReuseIdentifier:TImageMessageCell_ReuseId];
    [self.tableView registerClass:[TUISystemMessageCell class] forCellReuseIdentifier:TSystemMessageCell_ReuseId];
    [self.tableView registerClass:[TUIFaceMessageCell class] forCellReuseIdentifier:TFaceMessageCell_ReuseId];
    [self.tableView registerClass:[TUIVideoMessageCell class] forCellReuseIdentifier:TVideoMessageCell_ReuseId];
    [self.tableView registerClass:[TUIFileMessageCell class] forCellReuseIdentifier:TFileMessageCell_ReuseId];

    
    _headerView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TMessageController_Header_Height)];
    _headerView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.tableView.tableHeaderView = _headerView;
    
    _heightCache = [NSMutableArray array];
    _uiMsgs = [[NSMutableArray alloc] init];
}

- (void)setConversation:(TIMConversation *)conversation
{
    _conv = conversation;
    
    self.conversationDataProviderService = [[TCServiceManager shareInstance] createService:@protocol(TUIConversationDataProviderServiceProtocol)];
    [self loadMessage];
}

- (void)loadMessage
{
    if(_isLoadingMsg || _noMoreMsg){
        return;
    }
    _isLoadingMsg = YES;

    __weak typeof(self) ws = self;
    int msgCount = 20;
    
    
    [self.conversationDataProviderService getMessage:self.conv count:msgCount last:_msgForGet succ:^(NSArray *msgs) {
        if(msgs.count != 0){
            ws.msgForGet = msgs[msgs.count - 1];
        }
        NSMutableArray *uiMsgs = [ws transUIMsgFromIMMsg:msgs];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(msgs.count < msgCount){
                ws.noMoreMsg = YES;
                CGRect frame = ws.headerView.frame;
                frame.size.height = 0;
                ws.headerView.frame = frame;
            }
            if(uiMsgs.count != 0){
                BOOL firstLoad = YES;
                if(ws.uiMsgs.count != 0){
                    firstLoad = NO;
                }
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
                [ws.uiMsgs insertObjects:uiMsgs atIndexes:indexSet];
                [ws.heightCache removeAllObjects];
                [ws.tableView reloadData];
                [ws.tableView layoutIfNeeded];
                if(!firstLoad){
                    CGFloat visibleHeight = 0;
                    for (NSInteger i = 0; i < uiMsgs.count; ++i) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        visibleHeight += [ws tableView:ws.tableView heightForRowAtIndexPath:indexPath];
                    }
                    if(ws.noMoreMsg){
                        visibleHeight -= TMessageController_Header_Height;
                    }
                    [ws.tableView scrollRectToVisible:CGRectMake(0, ws.tableView.contentOffset.y + visibleHeight, ws.tableView.frame.size.width, ws.tableView.frame.size.height) animated:NO];
                }
            }
            ws.isLoadingMsg = NO;
            [ws.headerView stopAnimating];
        });
    } fail:^(int code, NSString *msg) {
        ws.isLoadingMsg = NO;
        NSLog(@"");
    }];
}

- (void)onNewMessage:(NSNotification *)notification
{
    NSArray *msgs = notification.object;
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:msgs];
    [_uiMsgs addObjectsFromArray:uiMsgs];
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.tableView reloadData];
        [ws scrollToBottom:YES];
    });
}

- (void)onRevokeMessage:(NSNotification *)notification
{
    TIMMessageLocator *locator = notification.object;
    TUIMessageCellData *uiMsg = nil;
    for (uiMsg in _uiMsgs) {
        TIMMessage *imMsg = uiMsg.innerMessage;
        if(imMsg){
            if([imMsg respondsToLocator:locator]){
                __weak typeof(self) ws = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ws revokeMsg:uiMsg];
                });
                break;
            }
        }
    }
}

- (void)onUploadMessage:(NSNotification *)notification
{
    NSDictionary *dic = notification.object;
    TIMMessage *msg = [dic objectForKey:@"message"];
    NSNumber *progress = [dic objectForKey:@"progress"];
    for (NSInteger i = 0; i < _uiMsgs.count; ++i) {
        TUIMessageCellData *uiMsg = _uiMsgs[i];
        TIMMessage *imMsg = uiMsg.innerMessage;
        if(imMsg){
            if([imMsg respondsToLocator:[msg locator]]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([uiMsg isKindOfClass:[TUIImageMessageCellData class]]){
                        TUIImageMessageCellData *data = (TUIImageMessageCellData *)uiMsg;
                        data.uploadProgress = progress.intValue;
                    }
                    else if([uiMsg isKindOfClass:[TUIVideoMessageCellData class]]){
                        TUIVideoMessageCellData *data = (TUIVideoMessageCellData *)uiMsg;
                        data.uploadProgress = progress.intValue;
                    }
                    else if([uiMsg isKindOfClass:[TUIFileMessageCellData class]]){
                        TUIFileMessageCellData *data = (TUIFileMessageCellData *)uiMsg;
                        data.uploadProgress = progress.intValue;
                    }
                });
            }
        }
    }
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs
{
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = msgs.count - 1; k >= 0; --k) {
        TIMMessage *msg = msgs[k];
        if(![[[msg getConversation] getReceiver] isEqualToString:[_conv getReceiver]]){
            continue;
        }
        if(msg.status == TIM_MSG_STATUS_HAS_DELETED){
            continue;
        }
        
        //判断有没要展示的 elem
        bool hasShowElem = false;
        for (int i = 0; i < msg.elemCount; ++i) {
            TIMElem *elem = [msg getElem:i];
            if ([elem isKindOfClass:[TIMSNSSystemElem class]] || [elem isKindOfClass:[TIMProfileSystemElem class]]) {
                //资料关系链消息不往列表里面抛
                continue;
            }
            hasShowElem =true;
        }
        if (!hasShowElem) {
            continue;
        }
        
        TUISystemMessageCellData *dateMsg = [self transSystemMsgFromDate:msg.timestamp];
        if (dateMsg) {
            _msgForDate = msg;
            [uiMsgs addObject:dateMsg];
        }
        if(msg.status == TIM_MSG_STATUS_LOCAL_REVOKED){
            TUISystemMessageCellData *revoke = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            revoke.content = @"你撤回了一条消息";
            revoke.innerMessage = msg;
            [uiMsgs addObject:revoke];
            continue;
        }
        if ([self.delegate respondsToSelector:@selector(messageController:onNewMessage:)]) {
            TUIMessageCellData *data = [self.delegate messageController:self onNewMessage:msg];
            if (data) {
                [uiMsgs addObject:data];
                continue;
            }
        }
        for (int i = 0; i < msg.elemCount; ++i) {
            TIMElem *elem = [msg getElem:i];
            if ([elem isKindOfClass:[TIMSNSSystemElem class]] || [elem isKindOfClass:[TIMProfileSystemElem class]]) {
                //资料关系链消息不往列表里面抛
                continue;
            }
            TUIMessageCellData *data = nil;
            if([elem isKindOfClass:[TIMTextElem class]]){
                TIMTextElem *text = (TIMTextElem *)elem;
                TUITextMessageCellData *textData = [[TUITextMessageCellData alloc] initWithDirection:(msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                textData.content = text.text;
                data = textData;
            }
            else if([elem isKindOfClass:[TIMFaceElem class]]){
                TIMFaceElem *face = (TIMFaceElem *)elem;
                TUIFaceMessageCellData *faceData = [[TUIFaceMessageCellData alloc] initWithDirection:(msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                faceData.groupIndex = face.index;
                faceData.faceName = [[NSString alloc] initWithData:face.data encoding:NSUTF8StringEncoding];
                for (TFaceGroup *group in [TUIKit sharedInstance].config.faceGroups) {
                    if(group.groupIndex == faceData.groupIndex){
                        NSString *path = [group.groupPath stringByAppendingPathComponent:faceData.faceName];
                        faceData.path = path;
                        break;
                    }
                }
                faceData.reuseId = TFaceMessageCell_ReuseId;
                data = faceData;
            }
            else if([elem isKindOfClass:[TIMImageElem class]]){
                TIMImageElem *image = (TIMImageElem *)elem;
                TUIImageMessageCellData *imageData = [[TUIImageMessageCellData alloc] initWithDirection:(msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                imageData.path = image.path;
                imageData.items = [NSMutableArray array];
                for (TIMImage *item in image.imageList) {
                    TUIImageItem *itemData = [[TUIImageItem alloc] init];
                    itemData.uuid = item.uuid;
                    itemData.size = CGSizeMake(item.width, item.height);
                    itemData.url = item.url;
                    if(item.type == TIM_IMAGE_TYPE_THUMB){
                        itemData.type = TImage_Type_Thumb;
                    }
                    else if(item.type == TIM_IMAGE_TYPE_LARGE){
                        itemData.type = TImage_Type_Large;
                    }
                    else if(item.type == TIM_IMAGE_TYPE_ORIGIN){
                        itemData.type = TImage_Type_Origin;
                    }
                    [imageData.items addObject:itemData];
                }
                data = imageData;
            }
            else if([elem isKindOfClass:[TIMSoundElem class]]){
                TIMSoundElem *sound = (TIMSoundElem *)elem;
                TUIVoiceMessageCellData *soundData = [[TUIVoiceMessageCellData alloc] initWithDirection:(msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                soundData.duration = sound.second;
                soundData.length = sound.dataSize;
                soundData.uuid = sound.uuid;
                data = soundData;
            }
            else if([elem isKindOfClass:[TIMVideoElem class]]){
                TIMVideoElem *video = (TIMVideoElem *)elem;
                TUIVideoMessageCellData *videoData = [[TUIVideoMessageCellData alloc] initWithDirection:(msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                videoData.videoPath = video.videoPath;
                videoData.snapshotPath = video.snapshotPath;
                
                videoData.videoItem = [[TUIVideoItem alloc] init];
                videoData.videoItem.uuid = video.video.uuid;
                videoData.videoItem.type = video.video.type;
                videoData.videoItem.length = video.video.size;
                videoData.videoItem.duration = video.video.duration;
                
                videoData.snapshotItem = [[TUISnapshotItem alloc] init];
                videoData.snapshotItem.uuid = video.snapshot.uuid;
                videoData.snapshotItem.type = video.snapshot.type;
                videoData.snapshotItem.length = video.snapshot.size;
                videoData.snapshotItem.size = CGSizeMake(video.snapshot.width, video.snapshot.height);
                
                data = videoData;
            }
            else if([elem isKindOfClass:[TIMFileElem class]]){
                TIMFileElem *file = (TIMFileElem *)elem;
                TUIFileMessageCellData *fileData = [[TUIFileMessageCellData alloc] initWithDirection:(msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                fileData.path = file.path;
                fileData.fileName = file.filename;
                fileData.length = file.fileSize;
                fileData.uuid = file.uuid;

                data = fileData;
            }
#if 0
            if([elem isKindOfClass:[TIMCustomElem class]]){
                TIMCustomElem *custom = (TIMCustomElem *)elem;
                TUISystemMessageCellData *systemData = [[TUISystemMessageCellData alloc] initWithDirection:(msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                systemData.content = custom.ext;
                if (systemData.content.length > 0)
                    data = systemData;
            }
#endif
            if([[msg getConversation] getType] == TIM_GROUP && !msg.isSelf){
                data.showName = YES;
            }
            if(data){
                data.direction = msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
                //data.name = msg.sender;
                if([[msg getConversation] getType] == TIM_GROUP){
                    data.name = [msg getSenderGroupMemberProfile].nameCard;
                }
                else if([[msg getConversation] getType] == TIM_C2C){
                    TIMUserProfile *profile = [msg getSenderProfile:^(TIMUserProfile *proflie) {
                        //更新 profile
                        if (proflie) {
                            data.name = proflie.nickname;
                        }
                    }];
                    data.name = profile.nickname;
                }
                if(data.name.length == 0){
                    data.name = msg.sender;
                }
                if(msg.status == TIM_MSG_STATUS_SEND_SUCC){
                    data.status = Msg_Status_Succ;
                    [uiMsgs addObject:data];
                }
                else if(msg.status == TIM_MSG_STATUS_SEND_FAIL){
                    data.status = Msg_Status_Fail;
                    [uiMsgs addObject:data];
                }
                data.innerMessage = msg;
            }
            
            if([elem isKindOfClass:[TIMGroupTipsElem class]]){
                TUISystemMessageCellData *sysdata = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
                sysdata.content = [msg getDisplayString];

                [uiMsgs addObject:sysdata];
                data = sysdata;
            }
        }
    }
    return uiMsgs;
}
#pragma mark - Table view data source

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isScrollBottom == NO) {
        [self scrollToBottom:NO];
        if (indexPath.row == _uiMsgs.count-1) {
            _isScrollBottom = YES;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if(_heightCache.count > indexPath.row){
        return [_heightCache[indexPath.row] floatValue];
    }
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
    height = [data heightOfWidth:Screen_Width];
    [_heightCache insertObject:[NSNumber numberWithFloat:height] atIndex:indexPath.row];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIMessageCellData *data = _uiMsgs[indexPath.row];
    TUIMessageCell *cell = nil;
    if ([self.delegate respondsToSelector:@selector(messageController:onShowMessageData:)]) {
        cell = [self.delegate messageController:self onShowMessageData:data];
        if (cell) {
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
        } else if([data isKindOfClass:[TUISystemMessageCellData class]]) {
            data.reuseId = TSystemMessageCell_ReuseId;
        } else {
            return nil;
        }
    }
    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    cell.delegate = self;
    [cell fillWithData:_uiMsgs[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)scrollToBottom:(BOOL)animate
{
    if (_uiMsgs.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animate];
    }
}

- (void)didTapViewController
{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapInMessageController:)]){
        [_delegate didTapInMessageController:self];
    }
}

- (void)sendMessage:(TUIMessageCellData *)msg
{
    [self.tableView beginUpdates];
    TIMMessage *imMsg = msg.innerMessage;
    TUIMessageCellData *dateMsg = nil;
    if (msg.status == Msg_Status_Init)
    {
        //新消息
        if (!imMsg) {
            imMsg = [self transIMMsgFromUIMsg:msg];
        }
        dateMsg = [self transSystemMsgFromDate:imMsg.timestamp];
        
    } else if (imMsg) {
        //重发
        dateMsg = [self transSystemMsgFromDate:[NSDate date]];
        NSInteger row = [_uiMsgs indexOfObject:msg];
        [_heightCache removeObjectAtIndex:row];
        [_uiMsgs removeObjectAtIndex:row];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    } else {
        NSLog(@"Unknown message state");
        return;
    }
    msg.status = Msg_Status_Sending;
    if(dateMsg){
        _msgForDate = imMsg;
        [_uiMsgs addObject:dateMsg];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    [_uiMsgs addObject:msg];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self scrollToBottom:YES];
    
    __weak typeof(self) ws = self;
    [self.conv sendMessage:imMsg succ:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws changeMsg:msg status:Msg_Status_Succ];
        });
    } fail:^(int code, NSString *desc) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws changeMsg:msg status:Msg_Status_Fail];
        });
    }];
    
    int delay = 1;
    if([msg isKindOfClass:[TUIImageMessageCellData class]]){
        delay = 0;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(msg.status == Msg_Status_Sending){
            [ws changeMsg:msg status:Msg_Status_Sending_2];
        }
    });
}

- (void)changeMsg:(TUIMessageCellData *)msg status:(TMsgStatus)status
{
    msg.status = status;
    NSInteger index = [_uiMsgs indexOfObject:msg];
    TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell fillWithData:msg];
}

- (TIMMessage *)transIMMsgFromUIMsg:(TUIMessageCellData *)data
{
    TIMMessage *msg = [[TIMMessage alloc] init];
    if([data isKindOfClass:[TUITextMessageCellData class]]){
        TIMTextElem *imText = [[TIMTextElem alloc] init];
        TUITextMessageCellData *text = (TUITextMessageCellData *)data;
        imText.text = text.content;
        [msg addElem:imText];
    }
    else if([data isKindOfClass:[TUIFaceMessageCellData class]]){
        TIMFaceElem *imImage = [[TIMFaceElem alloc] init];
        TUIFaceMessageCellData *image = (TUIFaceMessageCellData *)data;
        imImage.index = (int)image.groupIndex;
        imImage.data = [image.faceName dataUsingEncoding:NSUTF8StringEncoding];
        [msg addElem:imImage];
    }
    else if([data isKindOfClass:[TUIImageMessageCellData class]]){
        TIMImageElem *imImage = [[TIMImageElem alloc] init];
        TUIImageMessageCellData *uiImage = (TUIImageMessageCellData *)data;
        imImage.path = uiImage.path;
        [msg addElem:imImage];
    }
    else if([data isKindOfClass:[TUIVideoMessageCellData class]]){
        TIMVideoElem *imVideo = [[TIMVideoElem alloc] init];
        TUIVideoMessageCellData *uiVideo = (TUIVideoMessageCellData *)data;
        imVideo.videoPath = uiVideo.videoPath;
        imVideo.snapshotPath = uiVideo.snapshotPath;
        imVideo.snapshot = [[TIMSnapshot alloc] init];
        imVideo.snapshot.width = uiVideo.snapshotItem.size.width;
        imVideo.snapshot.height = uiVideo.snapshotItem.size.height;
        imVideo.video = [[TIMVideo alloc] init];
        imVideo.video.duration = (int)uiVideo.videoItem.duration;
        imVideo.video.type = uiVideo.videoItem.type;
        [msg addElem:imVideo];
    }
    else if([data isKindOfClass:[TUIVoiceMessageCellData class]]){
        TIMSoundElem *imSound = [[TIMSoundElem alloc] init];
        TUIVoiceMessageCellData *uiSound = (TUIVoiceMessageCellData *)data;
        imSound.path = uiSound.path;
        imSound.second = uiSound.duration;
        imSound.dataSize = uiSound.length;
        [msg addElem:imSound];
    }
    else if([data isKindOfClass:[TUIFileMessageCellData class]]){
        TIMFileElem *imFile = [[TIMFileElem alloc] init];
        TUIFileMessageCellData *uiFile = (TUIFileMessageCellData *)data;
        imFile.path = uiFile.path;
        imFile.fileSize = uiFile.length;
        imFile.filename = uiFile.fileName;
        [msg addElem:imFile];
    }
    data.innerMessage = msg;
    return msg;
    
}
- (TUISystemMessageCellData *)transSystemMsgFromDate:(NSDate *)date
{
    if(_msgForDate == nil || fabs([date timeIntervalSinceDate:_msgForDate.timestamp]) > MAX_MESSAGE_SEP_DLAY){
        TUISystemMessageCellData *system = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
        system.content = [date tk_messageString];
        system.reuseId = TSystemMessageCell_ReuseId;
        return system;
    }
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!_noMoreMsg && scrollView.contentOffset.y <= TMessageController_Header_Height){
        if(!_headerView.isAnimating){
            [_headerView startAnimating];
        }
    }
    else{
        if(_headerView.isAnimating){
            [_headerView stopAnimating];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y <= TMessageController_Header_Height){
        [self loadMessage];
    }
}

#pragma mark - message cell delegate

- (void)onSelectMessage:(TUIMessageCell *)cell
{
    if([cell isKindOfClass:[TUIVoiceMessageCell class]]){
        [self playVoiceMessage:(TUIVoiceMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIImageMessageCell class]]) {
        [self showImageMessage:(TUIImageMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIVideoMessageCell class]]) {
        [self showVideoMessage:(TUIVideoMessageCell *)cell];
    }
    if ([cell isKindOfClass:[TUIFileMessageCell class]]) {
        [self showFileMessage:(TUIFileMessageCell *)cell];
    }
}

- (void)onLongPressMessage:(TUIMessageCell *)cell
{
    TUIMessageCellData *data = cell.messageData;
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(onDelete:)]];
    TIMMessage *imMsg = data.innerMessage;
    if(imMsg){
        if([imMsg isSelf] && [[NSDate date] timeIntervalSinceDate:imMsg.timestamp] < 2 * 60){
            [items addObject:[[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(onRevoke:)]];
        }
    }
    if(imMsg.status == TIM_MSG_STATUS_SEND_FAIL){
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"重发" action:@selector(onReSend:)]];
    }
    
    BOOL isFirstResponder = NO;
    if(_delegate && [_delegate respondsToSelector:@selector(messageController:willShowMenuInCell:)]){
        isFirstResponder = [_delegate messageController:self willShowMenuInCell:cell];
    }
    if(isFirstResponder){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    else{
        [self becomeFirstResponder];
    }
    UIMenuController *controller = [UIMenuController sharedMenuController];
    controller.menuItems = items;
    _menuUIMsg = data;
    [controller setTargetRect:cell.container.bounds inView:cell.container];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [controller setMenuVisible:YES animated:YES];
    });
}

- (void)onRetryMessage:(TUIMessageCell *)cell
{
    _reSendUIMsg = cell.messageData;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定重发此消息吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"重发" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendMessage:self.reSendUIMsg];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(onDelete:) ||
        action == @selector(onRevoke:) ||
        action == @selector(onReSend:)){
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)onDelete:(id)sender
{
    TIMMessage *imMsg = _menuUIMsg.innerMessage;
    if(imMsg == nil){
        return;
    }
    if([imMsg remove]){
        [self.tableView beginUpdates];
        NSInteger index = [_uiMsgs indexOfObject:_menuUIMsg];
        [_uiMsgs removeObjectAtIndex:index];
        [_heightCache removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

        [self.tableView endUpdates];
    }
}

- (void)menuDidHide:(NSNotification*)notification
{
    if(_delegate && [_delegate respondsToSelector:@selector(didHideMenuInMessageController:)]){
        [_delegate didHideMenuInMessageController:self];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)onRevoke:(id)sender
{
    __weak typeof(self) ws = self;
    [self.conv revokeMessage:_menuUIMsg.innerMessage succ:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws revokeMsg:ws.menuUIMsg];
        });
    } fail:^(int code, NSString *msg) {
        NSLog(@"");
    }];
}

- (void)onReSend:(id)sender
{
    [self sendMessage:_menuUIMsg];
}

- (void)revokeMsg:(TUIMessageCellData *)msg
{
    TIMMessage *imMsg = msg.innerMessage;
    if(imMsg == nil){
        return;
    }
    NSInteger index = [_uiMsgs indexOfObject:msg];
    if (index == NSNotFound)
        return;
    [_uiMsgs removeObject:msg];

    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    TUISystemMessageCellData *data = [[TUISystemMessageCellData alloc] initWithDirection:(imMsg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    if(imMsg.isSelf){
        data.content = @"你撤回了一条消息";
    }
    else{
        data.content = [NSString stringWithFormat:@"\"%@\"撤回了一条消息", imMsg.sender];
    }
    [_uiMsgs insertObject:data atIndex:index];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self scrollToBottom:YES];
}


- (void)sendImageMessage:(UIImage *)image;
{
    NSData *data = UIImagePNGRepresentation(image);
    NSString *path = [TUIKit_Image_Path stringByAppendingString:[THelper genImageName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    
    TUIImageMessageCellData *uiImage = [[TUIImageMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    uiImage.path = path;
    uiImage.length = data.length;
    [self sendMessage:uiImage];
}

- (void)sendVideoMessage:(NSURL *)url
{
    NSData *videoData = [NSData dataWithContentsOfURL:url];
    NSString *videoPath = [NSString stringWithFormat:@"%@%@.%@", TUIKit_Video_Path, [THelper genVideoName:nil], url.pathExtension];
    [[NSFileManager defaultManager] createFileAtPath:videoPath contents:videoData attributes:nil];
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    NSInteger duration = (NSInteger)urlAsset.duration.value / urlAsset.duration.timescale;
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(192, 192);
    NSError *error = nil;
    CMTime actualTime;
    CMTime time = CMTimeMakeWithSeconds(0.0, 10);
    CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imagePath = [TUIKit_Video_Path stringByAppendingString:[THelper genSnapshotName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
    
    TUIVideoMessageCellData *uiVideo = [[TUIVideoMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    uiVideo.snapshotPath = imagePath;
    uiVideo.snapshotItem = [[TUISnapshotItem alloc] init];
    UIImage *snapshot = [UIImage imageWithContentsOfFile:imagePath];
    uiVideo.snapshotItem.size = snapshot.size;
    uiVideo.snapshotItem.length = imageData.length;
    uiVideo.videoPath = videoPath;
    uiVideo.videoItem = [[TUIVideoItem alloc] init];
    uiVideo.videoItem.duration = duration;
    uiVideo.videoItem.length = videoData.length;
    uiVideo.videoItem.type = url.pathExtension;
    uiVideo.uploadProgress = 0;
    [self sendMessage:uiVideo];
}

- (void)sendFileMessage:(NSURL *)url
{
    [url startAccessingSecurityScopedResource];
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] init];
    NSError *error;
    __weak typeof(self) ws = self;
    [coordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        NSString *fileName = [url lastPathComponent];
        NSString *filePath = [TUIKit_File_Path stringByAppendingString:fileName];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileData attributes:nil];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
            TUIFileMessageCellData *uiFile = [[TUIFileMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            uiFile.path = filePath;
            uiFile.fileName = fileName;
            uiFile.length = (int)fileSize;
            uiFile.uploadProgress = 0;
            [ws sendMessage:uiFile];
        }
    }];
    [url stopAccessingSecurityScopedResource];
}

- (void)playVoiceMessage:(TUIVoiceMessageCell *)cell
{
    for (NSInteger index = 0; index < _uiMsgs.count; ++index) {
        if(![_uiMsgs[index] isKindOfClass:[TUIVoiceMessageCellData class]]){
            continue;
        }
        TUIVoiceMessageCellData *uiMsg = _uiMsgs[index];
        if(uiMsg == cell.voiceData){
            [uiMsg playVoiceMessage];
        }
        else{
            [uiMsg stopVoiceMessage];
        }
    }
}

- (void)showImageMessage:(TUIImageMessageCell *)cell
{
    TUIImageViewController *image = [[TUIImageViewController alloc] init];
    image.data = [cell imageData];
    [self presentViewController:image animated:YES completion:nil];
}

- (void)showVideoMessage:(TUIVideoMessageCell *)cell
{
    TUIVideoViewController *video = [[TUIVideoViewController alloc] init];
    video.data = [cell videoData];
    [self presentViewController:video animated:YES completion:nil];
}

- (void)showFileMessage:(TUIFileMessageCell *)cell
{
    TUIFileViewController *file = [[TUIFileViewController alloc] init];
    file.data = [cell fileData];
    [self.navigationController pushViewController:file animated:YES];
}
@end
