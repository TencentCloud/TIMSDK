//
//  TUIMessageController.m
//  UIKit
//
//  Created by annidyfeng on 2019/7/1.
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
#import "NSString+Common.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
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
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL isScrollBottom;
@property (nonatomic, assign) BOOL isLoadingMsg;
@property (nonatomic, assign) BOOL noMoreMsg;
@property (nonatomic, assign) BOOL firstLoad;
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

    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TMessageController_Header_Height)];
    _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.tableView.tableHeaderView = _indicatorView;
    
    _heightCache = [NSMutableArray array];
    _uiMsgs = [[NSMutableArray alloc] init];
    _firstLoad = YES;
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
    int msgCount = 20;
    
    @weakify(self)
    [self.conversationDataProviderService getMessage:self.conv count:msgCount last:_msgForGet succ:^(NSArray *msgs) {
        @strongify(self)
        if(msgs.count != 0){
            self.msgForGet = msgs[msgs.count - 1];
        }
        NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:msgs];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(msgs.count < msgCount){
                self.noMoreMsg = YES;
                self.indicatorView.mm_h = 0;
            }
            if(uiMsgs.count != 0){
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
                [self.uiMsgs insertObjects:uiMsgs atIndexes:indexSet];
                [self.heightCache removeAllObjects];
                [self.tableView reloadData];
                [self.tableView layoutIfNeeded];
                if(!self.firstLoad){
                    CGFloat visibleHeight = 0;
                    for (NSInteger i = 0; i < uiMsgs.count; ++i) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        visibleHeight += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                    }
                    if(self.noMoreMsg){
                        visibleHeight -= TMessageController_Header_Height;
                    }
                    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentOffset.y + visibleHeight, self.tableView.frame.size.width, self.tableView.frame.size.height) animated:NO];
                }
            }
            self.isLoadingMsg = NO;
            [self.indicatorView stopAnimating];
            self.firstLoad = NO;
        });
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        self.isLoadingMsg = NO;
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)onNewMessage:(NSNotification *)notification
{
    NSArray *msgs = notification.object;
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:msgs];
    if (uiMsgs.count > 0) {
        [_uiMsgs addObjectsFromArray:uiMsgs];
        [self.tableView reloadData];
        [self scrollToBottom:YES];
    }
}

- (void)onRevokeMessage:(NSNotification *)notification
{
    TIMMessageLocator *locator = notification.object;
    TUIMessageCellData *uiMsg = nil;
    for (uiMsg in _uiMsgs) {
        TIMMessage *imMsg = uiMsg.innerMessage;
        if(imMsg){
            if([imMsg respondsToLocator:locator]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self revokeMsg:uiMsg];
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
            }
        }
    }
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs
{
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = msgs.count - 1; k >= 0; --k) {
        TIMMessage *msg = msgs[k];

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
            if ([elem isKindOfClass:[TIMGroupTipsElem class]]) {
                TIMGroupTipsElem *gt = (TIMGroupTipsElem *)elem;
                if (![[gt group] isEqualToString:[_conv getReceiver]]) {
                    continue;
                }
            } else if ([elem isKindOfClass:[TIMGroupSystemElem class]]) {
                TIMGroupSystemElem *gs = (TIMGroupSystemElem *)elem;
                if (![[gs group] isEqualToString:[_conv getReceiver]]) {
                    continue;
                }
            } else if(![[[msg getConversation] getReceiver] isEqualToString:[_conv getReceiver]]){
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
            TUISystemMessageCellData *revoke = [[TUISystemMessageCellData alloc] initWithDirection:(msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            if(msg.isSelf){
                revoke.content = @"你撤回了一条消息";
            }
            else if (self.conv.getType == TIM_C2C){
                revoke.content = @"对方撤回了一条消息";
            } else {
                revoke.content = [NSString stringWithFormat:@"\"%@\"撤回了一条消息", msg.sender];
            }
            
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
                imageData.path = [image.path safePathString];
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
                videoData.videoPath = [video.videoPath safePathString];
                videoData.snapshotPath = [video.snapshotPath safePathString];
                
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
                fileData.path = [file.path safePathString];
                fileData.fileName = file.filename;
                fileData.length = file.fileSize;
                fileData.uuid = file.uuid;

                data = fileData;
            } else if ([elem isKindOfClass:[TIMCustomElem class]]) {
                TIMCustomElem *custom = (TIMCustomElem *)elem;
                if (custom.data.bytes) {
                    if (strcmp(custom.data.bytes, "group_create") == 0 ||
                        strcmp(custom.data.bytes, "group_delete") == 0 ||
                        strcmp(custom.data.bytes, "group_quit") == 0) {
                        TUISystemMessageCellData *sysdata = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
                        sysdata.content = [msg getDisplayString];
                        
                        data = sysdata;
                    }
                }
            } else {
                TUISystemMessageCellData *sysdata = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
                sysdata.content = [msg getDisplayString];
                if (sysdata.content.length) {
                    data = sysdata;
                }
            }
            if([[msg getConversation] getType] == TIM_GROUP && !msg.isSelf
               && ![data isKindOfClass:[TUISystemMessageCellData class]]){
                data.showName = YES;
            }
            
            if(data) {
                data.direction = msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
                data.identifier = [msg sender];
                
                NSString *nameCard;
                if([[msg getConversation] getType] == TIM_GROUP){
                    nameCard = [msg getSenderGroupMemberProfile].nameCard;
                }
                
                void (^block)(TIMUserProfile *) = ^(TIMUserProfile *profile)  {
                    //更新 profile
                    if (nameCard.length == 0)
                        data.name = [profile showName];
                    if (profile.faceURL)
                        data.avatarUrl = [NSURL URLWithString:[profile faceURL]];
                };
                
                [msg getSenderProfile:block];
                data.name = nameCard.length ? nameCard : msg.sender;
                
                switch (msg.status) {
                    case TIM_MSG_STATUS_SEND_SUCC:
                        data.status = Msg_Status_Succ;
                        break;
                    case TIM_MSG_STATUS_SEND_FAIL:
                        data.status = Msg_Status_Fail;
                        break;
                    case TIM_MSG_STATUS_SENDING:
                        data.status = Msg_Status_Sending_2;
                        break;
                    default:
                        break;
                }
                [uiMsgs addObject:data];
                data.innerMessage = msg;
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
        [self.tableView endUpdates];
        NSLog(@"Unknown message state");
        return;
    }
    TIMUserProfile *selfProfile = [[TIMFriendshipManager sharedInstance] querySelfProfile];
    
    msg.status = Msg_Status_Sending;
    msg.name = [selfProfile showName];
    msg.avatarUrl = [NSURL URLWithString:selfProfile.faceURL];
    
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
        NSLog(@"====== %d",imMsg.status);
        dispatch_async(dispatch_get_main_queue(), ^{
            [THelper makeToastError:code msg:desc];
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
        if(!_indicatorView.isAnimating){
            [_indicatorView startAnimating];
        }
    }
    else{
        if(_indicatorView.isAnimating){
            [_indicatorView stopAnimating];
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
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:self onSelectMessageContent:cell];
    }
}

- (void)onLongPressMessage:(TUIMessageCell *)cell
{
    TUIMessageCellData *data = cell.messageData;
    if ([data isKindOfClass:[TUISystemMessageCellData class]])
        return; // 系统消息不响应
    
    NSMutableArray *items = [NSMutableArray array];
    if ([data isKindOfClass:[TUITextMessageCellData class]]) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(onCopyMsg:)]];
    }
    
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

- (void)onSelectMessageAvatar:(TUIMessageCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageAvatar:)]) {
        [self.delegate messageController:self onSelectMessageAvatar:cell];
    }
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(onDelete:) ||
        action == @selector(onRevoke:) ||
        action == @selector(onReSend:) ||
        action == @selector(onCopyMsg:)){
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

- (void)onCopyMsg:(id)sender
{
    if ([_menuUIMsg isKindOfClass:[TUITextMessageCellData class]]) {
        TUITextMessageCellData *txtMsg = (TUITextMessageCellData *)_menuUIMsg;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = txtMsg.content;
    }
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
    else if (self.conv.getType == TIM_C2C){
        data.content = @"对方撤回了一条消息";
    } else {
        data.content = [NSString stringWithFormat:@"\"%@\"撤回了一条消息", imMsg.sender];
    }
    [_uiMsgs insertObject:data atIndex:index];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self scrollToBottom:YES];
}


- (void)sendImageMessage:(UIImage *)image;
{
    NSData *data = UIImageJPEGRepresentation(image, 0.75);
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
    [self.navigationController pushViewController:image animated:YES];
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
@end
