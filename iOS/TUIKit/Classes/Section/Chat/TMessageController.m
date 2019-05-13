//
//  TMessageController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TMessageController.h"
#import "TTextMessageCell.h"
#import "TSystemMessageCell.h"
#import "TVoiceMessageCell.h"
#import "TImageMessageCell.h"
#import "TFaceMessageCell.h"
#import "TVideoMessageCell.h"
#import "TFileMessageCell.h"
#import "TUIKitConfig.h"
#import "TFaceView.h"
#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
#import "TAlertView.h"
@import ImSDK;
@import AVFoundation;

@interface TMessageController () <TIMMessageListener, TMessageCellDelegate, AVAudioPlayerDelegate, TAlertViewDelegate>
@property (nonatomic, strong) TConversationCellData *conv;
@property (nonatomic, strong) NSMutableArray *uiMsgs;
@property (nonatomic, strong) NSMutableArray *heightCache;
@property (nonatomic, strong) TIMMessage *msgForDate;
@property (nonatomic, strong) TIMMessage *msgForGet;
@property (nonatomic, strong) TMessageCellData *menuUIMsg;
@property (nonatomic, strong) TMessageCellData *reSendUIMsg;
@property (nonatomic, strong) UIActivityIndicatorView *headerView;
@property (nonatomic, assign) BOOL isScrollBottom;
@property (nonatomic, assign) BOOL isLoadingMsg;
@property (nonatomic, assign) BOOL noMoreMsg;
@property (nonatomic, strong) AVAudioPlayer *voicePlayer;
@end

@implementation TMessageController

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
    TIMConversation *conv = [[TIMManager sharedInstance]
                             getConversation:(TIMConversationType)_conv.convType
                             receiver:_conv.convId];
    [conv setReadMessage:nil succ:^{
        NSLog(@"");
    } fail:^(int code, NSString *msg) {
        NSLog(@"");
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
    
    _headerView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TMessageController_Header_Height)];
    _headerView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.tableView.tableHeaderView = _headerView;
    
    _heightCache = [NSMutableArray array];
    _uiMsgs = [[NSMutableArray alloc] init];
}

- (void)setConversation:(TConversationCellData *)conversation
{
    _conv = conversation;
    [self loadMessage];
}

- (void)loadMessage
{
    if(_isLoadingMsg || _noMoreMsg){
        return;
    }
    _isLoadingMsg = YES;
    TIMConversation *conv = [[TIMManager sharedInstance]
                             getConversation:(TIMConversationType)_conv.convType
                             receiver:_conv.convId];
    __weak typeof(self) ws = self;
    NSInteger msgCount = [[TUIKit sharedInstance] getConfig].msgCountPerRequest;
    [conv getMessage:msgCount last:_msgForGet succ:^(NSArray *msgs) {
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
    TMessageCellData *uiMsg = nil;
    for (uiMsg in _uiMsgs) {
        TIMMessage *imMsg = uiMsg.custom;
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
        TMessageCellData *uiMsg = _uiMsgs[i];
        TIMMessage *imMsg = uiMsg.custom;
        if(imMsg){
            if([imMsg respondsToLocator:[msg locator]]){
                __weak typeof(self) ws = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([uiMsg isKindOfClass:[TImageMessageCellData class]]){
                        TImageMessageCellData *data = (TImageMessageCellData *)uiMsg;
                        data.uploadProgress = progress.intValue;
                        TImageMessageCell *cell = [ws.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                        [cell setData:data];
                    }
                    else if([uiMsg isKindOfClass:[TVideoMessageCellData class]]){
                        TVideoMessageCellData *data = (TVideoMessageCellData *)uiMsg;
                        data.uploadProgress = progress.intValue;
                        TVideoMessageCell *cell = [ws.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                        [cell setData:data];
                    }
                    else if([uiMsg isKindOfClass:[TFileMessageCellData class]]){
                        TFileMessageCellData *data = (TFileMessageCellData *)uiMsg;
                        data.uploadProgress = progress.intValue;
                        TFileMessageCell *cell = [ws.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                        [cell setData:data];
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
        if(![[[msg getConversation] getReceiver] isEqualToString:_conv.convId]){
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
        
        TMessageCellData *dateMsg = [self transSystemMsgFromDate:msg.timestamp];
        if(dateMsg){
            _msgForDate = msg;
            dateMsg.custom = nil;
            [uiMsgs addObject:dateMsg];
        }
        if(msg.status == TIM_MSG_STATUS_LOCAL_REVOKED){
            TSystemMessageCellData *revoke = [[TSystemMessageCellData alloc] init];
            revoke.content = @"你撤回了一条消息";
            revoke.custom = msg;
            [uiMsgs addObject:revoke];
            continue;
        }
        for (int i = 0; i < msg.elemCount; ++i) {
            TIMElem *elem = [msg getElem:i];
            if ([elem isKindOfClass:[TIMSNSSystemElem class]] || [elem isKindOfClass:[TIMProfileSystemElem class]]) {
                //资料关系链消息不往列表里面抛
                continue;
            }
            TMessageCellData *data = nil;
            if([elem isKindOfClass:[TIMTextElem class]]){
                TIMTextElem *text = (TIMTextElem *)elem;
                TTextMessageCellData *textData = [[TTextMessageCellData alloc] init];
                textData.content = text.text;
                data = textData;
            }
            else if([elem isKindOfClass:[TIMFaceElem class]]){
                TIMFaceElem *face = (TIMFaceElem *)elem;
                TFaceMessageCellData *faceData = [[TFaceMessageCellData alloc] init];
                faceData.groupIndex = face.index;
                faceData.faceName = [[NSString alloc] initWithData:face.data encoding:NSUTF8StringEncoding];
                for (TFaceGroup *group in [[TUIKit sharedInstance] getConfig].faceGroups) {
                    if(group.groupIndex == faceData.groupIndex){
                        NSString *path = [group.groupPath stringByAppendingPathComponent:faceData.faceName];
                        faceData.path = path;
                        break;
                    }
                }
                data = faceData;
            }
            else if([elem isKindOfClass:[TIMImageElem class]]){
                TIMImageElem *image = (TIMImageElem *)elem;
                TImageMessageCellData *imageData = [[TImageMessageCellData alloc] init];
                imageData.path = image.path;
                imageData.items = [NSMutableArray array];
                for (TIMImage *item in image.imageList) {
                    TImageItem *itemData = [[TImageItem alloc] init];
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
                TVoiceMessageCellData *soundData = [[TVoiceMessageCellData alloc] init];
                soundData.duration = sound.second;
                soundData.length = sound.dataSize;
                soundData.uuid = sound.uuid;
                
                data = soundData;
            }
            else if([elem isKindOfClass:[TIMVideoElem class]]){
                TIMVideoElem *video = (TIMVideoElem *)elem;
                TVideoMessageCellData *videoData = [[TVideoMessageCellData alloc] init];
                videoData.videoPath = video.videoPath;
                videoData.snapshotPath = video.snapshotPath;
                
                videoData.videoItem = [[TVideoItem alloc] init];
                videoData.videoItem.uuid = video.video.uuid;
                videoData.videoItem.type = video.video.type;
                videoData.videoItem.length = video.video.size;
                videoData.videoItem.duration = video.video.duration;
                
                videoData.snapshotItem = [[TSnapshotItem alloc] init];
                videoData.snapshotItem.uuid = video.snapshot.uuid;
                videoData.snapshotItem.type = video.snapshot.type;
                videoData.snapshotItem.length = video.snapshot.size;
                videoData.snapshotItem.size = CGSizeMake(video.snapshot.width, video.snapshot.height);
                
                data = videoData;
            }
            else if([elem isKindOfClass:[TIMFileElem class]]){
                TIMFileElem *file = (TIMFileElem *)elem;
                TFileMessageCellData *fileData = [[TFileMessageCellData alloc] init];
                fileData.path = file.path;
                fileData.fileName = file.filename;
                fileData.length = file.fileSize;
                fileData.uuid = file.uuid;
                
                data = fileData;
            }
            else if([elem isKindOfClass:[TIMCustomElem class]]){
                TIMCustomElem *custom = (TIMCustomElem *)elem;
                TSystemMessageCellData *systemData = [[TSystemMessageCellData alloc] init];
                systemData.content = custom.ext;
                
                data = systemData;
            }
            if([[msg getConversation] getType] == TIM_GROUP && !msg.isSelf){
                data.showName = YES;
            }
            if(data){
                data.isSelf = msg.isSelf;
                data.head = TUIKitResource(@"default_head");
                //data.name = msg.sender;
                if([[msg getConversation] getType] == TIM_GROUP){
                    data.name = [msg getSenderGroupMemberProfile].nameCard;
                }
                else if([[msg getConversation] getType] == TIM_C2C){
                    TIMUserProfile *profile = [msg getSenderProfile:^(TIMUserProfile *proflie) {
                        //更新 profile
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
                data.custom = msg;
            }
            
            if([elem isKindOfClass:[TIMGroupTipsElem class]]){
                TIMGroupTipsElem *tips = (TIMGroupTipsElem *)elem;
                switch (tips.type) {
                    case TIM_GROUP_TIPS_TYPE_INFO_CHANGE:
                    {
                        for (TIMGroupTipsElemGroupInfo *info in tips.groupChangeList) {
                            TSystemMessageCellData *data = [[TSystemMessageCellData alloc] init];
                            switch (info.type) {
                                case TIM_GROUP_INFO_CHANGE_GROUP_NAME:
                                {
                                    data.content = [NSString stringWithFormat:@"\"%@\"修改群名为\"%@\"", tips.opUser, info.value];
                                }
                                    break;
                                case TIM_GROUP_INFO_CHANGE_GROUP_INTRODUCTION:
                                {
                                    data.content = [NSString stringWithFormat:@"\"%@\"修改群简介为\"%@\"", tips.opUser, info.value];
                                }
                                    break;
                                case TIM_GROUP_INFO_CHANGE_GROUP_NOTIFICATION:
                                {
                                    data.content = [NSString stringWithFormat:@"\"%@\"修改群公告为\"%@\"", tips.opUser, info.value];
                                }
                                    break;
                                case TIM_GROUP_INFO_CHANGE_GROUP_OWNER:
                                {
                                    data.content = [NSString stringWithFormat:@"\"%@\"修改群主为\"%@\"", tips.opUser, info.value];
                                }
                                    break;
                                default:
                                    break;
                            }
                            [uiMsgs addObject:data];
                        }
                    }
                        break;
                    case TIM_GROUP_TIPS_TYPE_KICKED:
                    {
                        TSystemMessageCellData *data = [[TSystemMessageCellData alloc] init];
                        NSString *users = [tips.userList componentsJoinedByString:@"、"];
                        data.content = [NSString stringWithFormat:@"\"%@\"将\"%@\"剔出群组", tips.opUser, users];
                        [uiMsgs addObject:data];
                    }
                        break;
                    case TIM_GROUP_TIPS_TYPE_INVITE:
                    {
                        TSystemMessageCellData *data = [[TSystemMessageCellData alloc] init];
                        NSString *users = [tips.userList componentsJoinedByString:@"、"];
                        data.content = [NSString stringWithFormat:@"\"%@\"邀请\"%@\"加入群组", tips.opUser, users];
                        [uiMsgs addObject:data];
                    }
                        break;
                    default:
                        break;
                }
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
    NSObject *data = _uiMsgs[indexPath.row];
    if([data isKindOfClass:[TTextMessageCellData class]]){
        TTextMessageCellData *text = _uiMsgs[indexPath.row];
        TTextMessageCell *cell = [[TTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TTextMessageCell_ReuseId];
        height = [cell getHeight:text];
    }else if([data isKindOfClass:[TVoiceMessageCellData class]]){
        TVoiceMessageCellData *voice = _uiMsgs[indexPath.row];
        TVoiceMessageCell *cell = [[TVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TVoiceMessageCell_ReuseId];
        height = [cell getHeight:voice];
    }
    else if([data isKindOfClass:[TImageMessageCellData class]]){
        TImageMessageCellData *image = _uiMsgs[indexPath.row];
        TImageMessageCell *cell = [[TImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TImageMessageCell_ReuseId];
        height = [cell getHeight:image];
    }
    else if([data isKindOfClass:[TSystemMessageCellData class]]){
        TSystemMessageCellData *system = _uiMsgs[indexPath.row];
        TSystemMessageCell *cell = [[TSystemMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TSystemMessageCell_ReuseId];
        height = [cell getHeight:system];
    }
    else if([data isKindOfClass:[TFaceMessageCellData class]]){
        TFaceMessageCellData *face = _uiMsgs[indexPath.row];
        TFaceMessageCell *cell = [[TFaceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TFaceMessageCell_ReuseId];
        height = [cell getHeight:face];
    }
    else if([data isKindOfClass:[TVideoMessageCellData class]]){
        TVideoMessageCellData *video = _uiMsgs[indexPath.row];
        TVideoMessageCell *cell = [[TVideoMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TVideoMessageCell_ReuseId];
        height = [cell getHeight:video];
    }
    else if([data isKindOfClass:[TFileMessageCellData class]]){
        TFileMessageCellData *file = _uiMsgs[indexPath.row];
        TFileMessageCell *cell = [[TFileMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TFileMessageCell_ReuseId];
        height = [cell getHeight:file];
    }
    [_heightCache insertObject:[NSNumber numberWithFloat:height] atIndex:indexPath.row];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *data = _uiMsgs[indexPath.row];
    TMessageCell *cell = nil;
    if([data isKindOfClass:[TTextMessageCellData class]]){
        cell = [tableView dequeueReusableCellWithIdentifier:TTextMessageCell_ReuseId];
        if(!cell){
            cell = [[TTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TTextMessageCell_ReuseId];
            cell.delegate = self;
        }
    }
    else if([data isKindOfClass:[TVoiceMessageCellData class]]){
        cell = [tableView dequeueReusableCellWithIdentifier:TVoiceMessageCell_ReuseId];
        if(!cell){
            cell = [[TVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TVoiceMessageCell_ReuseId];
            cell.delegate = self;
        }
    }
    else if([data isKindOfClass:[TImageMessageCellData class]]){
        cell = [tableView dequeueReusableCellWithIdentifier:TImageMessageCell_ReuseId];
        if(!cell){
            cell = [[TImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TImageMessageCell_ReuseId];
            cell.delegate = self;
        }
    }
    else if([data isKindOfClass:[TSystemMessageCellData class]]){
        cell = [tableView dequeueReusableCellWithIdentifier:TSystemMessageCell_ReuseId];
        if(!cell){
            cell = [[TSystemMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TSystemMessageCell_ReuseId];
            cell.delegate = self;
        }
    }
    else if([data isKindOfClass:[TFaceMessageCellData class]]){
        cell = [tableView dequeueReusableCellWithIdentifier:TFaceMessageCell_ReuseId];
        if(!cell){
            cell = [[TFaceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TFaceMessageCell_ReuseId];
            cell.delegate = self;
        }
    }
    else if([data isKindOfClass:[TVideoMessageCellData class]]){
        cell = [tableView dequeueReusableCellWithIdentifier:TVideoMessageCell_ReuseId];
        if(!cell){
            cell = [[TVideoMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TVideoMessageCell_ReuseId];
            cell.delegate = self;
        }
    }
    else if([data isKindOfClass:[TFileMessageCellData class]]){
        cell = [tableView dequeueReusableCellWithIdentifier:TFileMessageCell_ReuseId];
        if(!cell){
            cell = [[TFileMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TFileMessageCell_ReuseId];
            cell.delegate = self;
        }
    }
    [cell setData:_uiMsgs[indexPath.row]];
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

- (void)sendMessage:(TMessageCellData *)msg
{
    
    
    TIMConversation *conv = [[TIMManager sharedInstance]
                             getConversation:(TIMConversationType)_conv.convType
                             receiver:_conv.convId];
    
    [self.tableView beginUpdates];
    TIMMessage *imMsg = nil;
    TMessageCellData *dateMsg = nil;
    if(msg.custom){
        //如果是重发
        msg.status = Msg_Status_Sending;
        imMsg = msg.custom;
        dateMsg = [self transSystemMsgFromDate:[NSDate date]];
        NSInteger row = [_uiMsgs indexOfObject:msg];
        [_heightCache removeObjectAtIndex:row];
        [_uiMsgs removeObjectAtIndex:row];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else{
        //新消息
        imMsg = [self transIMMsgFromUIMsg:msg];
        dateMsg = [self transSystemMsgFromDate:imMsg.timestamp];
    }
    
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
    [conv sendMessage:imMsg succ:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws changeMsg:msg status:Msg_Status_Succ];
        });
    } fail:^(int code, NSString *desc) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws changeMsg:msg status:Msg_Status_Fail];
        });
    }];
    
    int delay = 1;
    if([msg isKindOfClass:[TImageMessageCellData class]]){
        delay = 0;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(msg.status == Msg_Status_Sending){
            [ws changeMsg:msg status:Msg_Status_Sending_2];
        }
    });
}

- (void)changeMsg:(TMessageCellData *)msg status:(TMsgStatus)status
{
    msg.status = status;
    NSInteger index = [_uiMsgs indexOfObject:msg];
    TMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell setData:msg];
}

- (TIMMessage *)transIMMsgFromUIMsg:(TMessageCellData *)data
{
    TIMMessage *msg = [[TIMMessage alloc] init];
    if([data isKindOfClass:[TTextMessageCellData class]]){
        TIMTextElem *imText = [[TIMTextElem alloc] init];
        TTextMessageCellData *text = (TTextMessageCellData *)data;
        imText.text = text.content;
        [msg addElem:imText];
    }
    else if([data isKindOfClass:[TFaceMessageCellData class]]){
        TIMFaceElem *imImage = [[TIMFaceElem alloc] init];
        TFaceMessageCellData *image = (TFaceMessageCellData *)data;
        imImage.index = (int)image.groupIndex;
        imImage.data = [image.faceName dataUsingEncoding:NSUTF8StringEncoding];
        [msg addElem:imImage];
    }
    else if([data isKindOfClass:[TImageMessageCellData class]]){
        TIMImageElem *imImage = [[TIMImageElem alloc] init];
        TImageMessageCellData *uiImage = (TImageMessageCellData *)data;
        imImage.path = uiImage.path;
        [msg addElem:imImage];
    }
    else if([data isKindOfClass:[TVideoMessageCellData class]]){
        TIMVideoElem *imVideo = [[TIMVideoElem alloc] init];
        TVideoMessageCellData *uiVideo = (TVideoMessageCellData *)data;
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
    else if([data isKindOfClass:[TVoiceMessageCellData class]]){
        TIMSoundElem *imSound = [[TIMSoundElem alloc] init];
        TVoiceMessageCellData *uiSound = (TVoiceMessageCellData *)data;
        imSound.path = uiSound.path;
        imSound.second = uiSound.duration;
        imSound.dataSize = uiSound.length;
        [msg addElem:imSound];
    }
    else if([data isKindOfClass:[TFileMessageCellData class]]){
        TIMFileElem *imFile = [[TIMFileElem alloc] init];
        TFileMessageCellData *uiFile = (TFileMessageCellData *)data;
        imFile.path = uiFile.path;
        imFile.fileSize = uiFile.length;
        imFile.filename = uiFile.fileName;
        [msg addElem:imFile];
    }
    data.custom = msg;
    return msg;
    
}
- (TMessageCellData *)transSystemMsgFromDate:(NSDate *)date
{
    if(_msgForDate == nil || [date timeIntervalSinceDate:_msgForDate.timestamp] > 5 * 60){
        TSystemMessageCellData *system = [[TSystemMessageCellData alloc] init];
        system.content = [self getDateDisplayString:date];
        return system;
    }
    return nil;
}

- (NSString *)getDateDisplayString:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:date];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];
    
    NSDateComponents *comp =  [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    
    if (nowCmps.day==myCmps.day) {
        dateFmt.AMSymbol = @"上午";
        dateFmt.PMSymbol = @"下午";
        dateFmt.dateFormat = @"aaa hh:mm";
        
    } else if((nowCmps.day-myCmps.day)==1) {
        dateFmt.AMSymbol = @"上午";
        dateFmt.PMSymbol = @"下午";
        dateFmt.dateFormat = @"昨天 aaahh:mm";
        
    } else {
        dateFmt.AMSymbol = @"上午";
        dateFmt.PMSymbol = @"下午";
        if ((nowCmps.day-myCmps.day) <=7) {
            switch (comp.weekday) {
                case 1:
                    dateFmt.dateFormat = @"星期日 aaahh:mm";
                    break;
                case 2:
                    dateFmt.dateFormat = @"星期一 aaahh:mm";
                    break;
                case 3:
                    dateFmt.dateFormat = @"星期二 aaahh:mm";
                    break;
                case 4:
                    dateFmt.dateFormat = @"星期三 aaahh:mm";
                    break;
                case 5:
                    dateFmt.dateFormat = @"星期四 aaahh:mm";
                    break;
                case 6:
                    dateFmt.dateFormat = @"星期五 aaahh:mm";
                    break;
                case 7:
                    dateFmt.dateFormat = @"星期六 aaahh:mm";
                    break;
                default:
                    break;
            }
        }else {
            dateFmt.dateFormat = @"yyyy年MM月dd日 aaahh:mm";
        }
    }
    return [dateFmt stringFromDate:date];
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
- (void)needReloadMessage:(TMessageCellData *)data
{
    NSInteger index = [_uiMsgs indexOfObject:data];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didSelectMessage:(TMessageCellData *)data
{
    if([data isKindOfClass:[TVoiceMessageCellData class]]){
        TVoiceMessageCellData *voice = (TVoiceMessageCellData *)data;
        [self playVoiceMessage:voice];
    }
    else{
        if(_delegate && [_delegate respondsToSelector:@selector(messageController:didSelectMessages:atIndex:)]){
            NSInteger index = [_uiMsgs indexOfObject:data];
            [_delegate messageController:self didSelectMessages:_uiMsgs atIndex:index];
        }
    }
}

- (void)didLongPressMessage:(TMessageCellData *)data inView:(UIView *)view
{
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(onDelete:)]];
    TIMMessage *imMsg = data.custom;
    if(imMsg){
        if([imMsg isSelf] && [[NSDate date] timeIntervalSinceDate:imMsg.timestamp] < 2 * 60){
            [items addObject:[[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(onRevoke:)]];
        }
    }
    if(imMsg.status == TIM_MSG_STATUS_SEND_FAIL){
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"重发" action:@selector(onReSend:)]];
    }
    
    BOOL isFirstResponder = NO;
    if(_delegate && [_delegate respondsToSelector:@selector(messageController:willShowMenuInView:)]){
        isFirstResponder = [_delegate messageController:self willShowMenuInView:view];
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
    [controller setTargetRect:view.bounds inView:view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [controller setMenuVisible:YES animated:YES];
    });
}

- (void)didReSendMessage:(TMessageCellData *)data
{
    _reSendUIMsg = data;
    TAlertView *alert = [[TAlertView alloc] initWithTitle:@"确定重发此消息吗？"];
    alert.delegate = self;
    [alert showInWindow:self.view.window];
}

#pragma mark - alert view
- (void)didConfirmInAlertView:(TAlertView *)alertView
{
    [self sendMessage:_reSendUIMsg];
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
    TIMMessage *imMsg = _menuUIMsg.custom;
    if(imMsg == nil){
        return;
    }
    if([imMsg remove]){
        [self.tableView beginUpdates];
        NSInteger index = [_uiMsgs indexOfObject:_menuUIMsg];
        [_uiMsgs removeObjectAtIndex:index];
        [_heightCache removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//        if(_uiMsgs.count >= index){
//            TMessageCellData *date = _uiMsgs[index - 1];
//            if([date isKindOfClass:[TSystemMessageCellData class]] && date.custom == nil){
//                //时间cell
//                if(_uiMsgs.count == index){
//                    [_uiMsgs removeObjectAtIndex:index - 1];
//                    [_heightCache removeObjectAtIndex:index - 1];
//                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//                }
//                else{
//
//                }
//            }
//        }
//        else if(_uiMsgs.count > index){
//            
//        }
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
    
    TIMConversation *conv = [[TIMManager sharedInstance]
                             getConversation:(TIMConversationType)_conv.convType
                             receiver:_conv.convId];
    __weak typeof(self) ws = self;
    [conv revokeMessage:_menuUIMsg.custom succ:^{
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

- (void)revokeMsg:(TMessageCellData *)msg
{
    TIMMessage *imMsg = msg.custom;
    if(imMsg == nil){
        return;
    }
    [self.tableView beginUpdates];
    NSInteger index = [_uiMsgs indexOfObject:msg];
    [_uiMsgs removeObject:msg];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    TSystemMessageCellData *data = [[TSystemMessageCellData alloc] init];
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
    
    TImageMessageCellData *uiImage = [[TImageMessageCellData alloc] init];
    uiImage.path = path;
    uiImage.length = data.length;
    uiImage.head = TUIKitResource(@"default_head");
    uiImage.isSelf = YES;
    uiImage.uploadProgress = 0;
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
    
    TVideoMessageCellData *uiVideo = [[TVideoMessageCellData alloc] init];
    uiVideo.snapshotPath = imagePath;
    uiVideo.snapshotItem = [[TSnapshotItem alloc] init];
    UIImage *snapshot = [UIImage imageWithContentsOfFile:imagePath];
    uiVideo.snapshotItem.size = snapshot.size;
    uiVideo.snapshotItem.length = imageData.length;
    uiVideo.videoPath = videoPath;
    uiVideo.videoItem = [[TVideoItem alloc] init];
    uiVideo.videoItem.duration = duration;
    uiVideo.videoItem.length = videoData.length;
    uiVideo.videoItem.type = url.pathExtension;
    uiVideo.head = TUIKitResource(@"default_head");
    uiVideo.isSelf = YES;
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
            TFileMessageCellData *uiFile = [[TFileMessageCellData alloc] init];
            uiFile.path = filePath;
            uiFile.fileName = fileName;
            uiFile.length = (int)fileSize;
            uiFile.head = TUIKitResource(@"default_head");
            uiFile.isSelf = YES;
            uiFile.uploadProgress = 0;
            [ws sendMessage:uiFile];
        }
    }];
    [url stopAccessingSecurityScopedResource];
}

- (void)playVoiceMessage:(TVoiceMessageCellData *)voice
{
    __weak typeof(self) ws = self;
    void (^playBlock)(NSString *path) = ^(NSString *path){
        //update view
        NSInteger row = [ws.uiMsgs indexOfObject:voice];
        [ws.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        //play current
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        NSString *wavPath = [[path stringByDeletingPathExtension] stringByAppendingString:@".wav"];
        [THelper convertAmr:path toWav:wavPath];
        NSURL *url = [NSURL fileURLWithPath:wavPath];
        ws.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [ws.voicePlayer play];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(voice.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSFileManager defaultManager] removeItemAtPath:wavPath error:nil];
            voice.isPlaying = NO;
            NSInteger row = [ws.uiMsgs indexOfObject:voice];
            [ws.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });
    };
    

    //stop play
    if([_voicePlayer isPlaying]){
        [_voicePlayer stop];
    }
    
    //update data
    for (NSInteger index = 0; index < _uiMsgs.count; ++index) {
        if(![_uiMsgs[index] isKindOfClass:[TVoiceMessageCellData class]]){
            continue;
        }
        TVoiceMessageCellData *uiMsg = _uiMsgs[index];
        if(uiMsg == voice){
            uiMsg.isPlaying = !uiMsg.isPlaying;
        }
        else{
            uiMsg.isPlaying = NO;
        }
    }
    
    if(voice.isPlaying){
        BOOL isExist = NO;
        NSString *path = [voice getVoicePath:&isExist];
        if(isExist){
            playBlock(path);
        }
        else{
            [voice downloadVoice:^(NSInteger curSize, NSInteger totalSize) {
            } response:^(int code, NSString *desc, NSString *path) {
                if(code == 0){
                    playBlock(path);
                }
            }];
        }
    }
    else{
        //update view
        NSInteger row = [ws.uiMsgs indexOfObject:voice];
        [ws.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    
}

@end
