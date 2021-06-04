//
//  TUIKitLive.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/10.
//

#import "TUIKitLive.h"
#import "TRTCLiveRoom.h"
#import "TUILiveUserProfile.h"
#import "TUILiveGroupLiveMessageHandle.h"
#import "TUILiveFloatWindow.h"
#import "TUIGroupLiveMessageCell.h"
#import "TUIC2CSignalCell.h"
#import "TUIGroupSignalCell.h"
#import "TIMMessage+DataProvider.h"
#import "NSBundle+TUIKIT.h"

@interface TUILiveUserProfile (private)
+ (void)refreshLoginUserInfoWithUserId:(NSString *)userId callBack:(TUILiveRequestCallback _Nullable)callback;
@end

@interface TUIKitLive ()<TUIChatControllerListener, TUIConversationListControllerListener, TUILiveRoomAnchorDelegate>
@property (nonatomic, assign) int sdkAppId;
@property (nonatomic, assign) BOOL isAttachedTUIKit; /// 如果引入了TUIKit，TUIKit里会给这个变量赋值
@end


@implementation TUIKitLive

+ (instancetype)shareInstance {
    static TUIKitLive *__tuikitlive = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __tuikitlive = [[TUIKitLive alloc] init];
    });
    return __tuikitlive;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.enableVideoCall = YES;
        self.enableAudioCall = YES;
        self.enableGroupLiveEntry = YES;
        [[TUIKitListenerManager sharedInstance] addConversationListControllerListener:self];
        [[TUIKitListenerManager sharedInstance] addChatControllerListener:self];
    }
    return self;
}

- (void)dealloc {
    [[TUIKitListenerManager sharedInstance] removeConversationListControllerListener:self];
    [[TUIKitListenerManager sharedInstance] removeChatControllerListener:self];
}

- (void)setIsAttachedTUIKit:(BOOL)isAttachedTUIKit {
    _isAttachedTUIKit = isAttachedTUIKit;
    if (isAttachedTUIKit) {
        [[TUILiveGroupLiveMessageHandle shareInstance] startObserver];
    } else {
        [[TUILiveGroupLiveMessageHandle shareInstance] stopObserver];
    }
}

- (void)login:(int)sdkAppID userID:(NSString *)userID userSig:(NSString *)userSig callback:(TUILiveRequestCallback)callback {
    self.sdkAppId = sdkAppID;
    TRTCLiveRoomConfig *roomConfig = [[TRTCLiveRoomConfig alloc] initWithAttachedTUIkit:self.isAttachedTUIKit];
    [[TRTCLiveRoom sharedInstance] loginWithSdkAppID:sdkAppID userID:userID userSig:userSig config:roomConfig callback:^(int code, NSString * _Nullable message) {
        if (callback) {
            callback(code, message);
        }
        [TUILiveUserProfile refreshLoginUserInfoWithUserId:userID callBack:nil];
    }];
    [[TUICallManager shareInstance] initWithSdkAppID:sdkAppID userID:userID userSig:userSig];
}

- (void)logout:(TUILiveRequestCallback)callback {
    if ([self isFloatWindwoShow]) {
        [self exitFloatWindow];
    }
    if ([TUIKitLive shareInstance].isAttachedTUIKit) {
        return;
    }
    [[TRTCLiveRoom sharedInstance] logout:^(int code, NSString * _Nullable message) {
        if (code == 0) {
            [TUILiveUserProfile onLogout];
        }
        if (callback) {
            callback(code, message);
        }
    }];
}

- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo {
    [[TUICallManager shareInstance] onReceiveGroupCallAPNs:signalingInfo];
}

- (BOOL)isFloatWindwoShow {
    return [TUILiveFloatWindow sharedInstance].isShowing;
}

- (void)exitFloatWindow {
    if ([TUILiveFloatWindow sharedInstance].isShowing) {
        [[TUILiveFloatWindow sharedInstance] hide];
        [TUILiveFloatWindow sharedInstance].backController = nil; //置为nil会退出房间
    }
}

#pragma mark TUIConversationListControllerListener
- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation {
    V2TIMMessage *message = conversation.lastMessage;
    if (message.customElem == nil || message.customElem.data == nil) {
        return nil;
    }
    // 先判断下是不是信令消息（群直播 or 音视频 call）
    V2TIMSignalingInfo *info = [[V2TIMManager sharedInstance] getSignallingInfo:message];
    if (info != nil) {
        return [self getCustomSignalingContentWithMessage:message];
    }
    // 判断是不是群直播自定义消息
    NSError *err = nil;
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingMutableContainers error:&err];
    if (param != nil && [param isKindOfClass:[NSDictionary class]]) {
        NSString *businessID = param[@"businessID"];
        if ([businessID isEqualToString:GroupLive]) {
            // **的直播
            if ([param.allKeys containsObject:@"anchorName"] && [param.allKeys containsObject:@"anchorId"]) {
                NSString *anchorName = param[@"anchorName"];
                if (anchorName.length == 0) {
                    anchorName = param[@"anchorId"];
                }
                NSString *format = TUILocalizableString(TUIKitWhosLiveFormat);
                format = [NSString stringWithFormat:@"[%@]", format];
                return [NSString stringWithFormat:format, anchorName];
            }
        }
    }
    return nil;
}

#pragma mark TUIChatControllerListener

- (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewMessage:(V2TIMMessage *)msg {
    /// 群直播自定义消息
    if (msg.customElem.data) {
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:msg.customElem.data options:NSJSONReadingAllowFragments error:nil];
        //[params[@"version"] integerValue] == Version &&
        if ([params isKindOfClass:NSDictionary.class] && [params[@"businessID"] isKindOfClass:NSString.class] && [params[@"businessID"] isEqualToString:@"group_live"]) {
            TMsgDirection direction = msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
            TUIGroupLiveMessageCellData *cellData = [[TUIGroupLiveMessageCellData alloc] initWithDirection:direction];
            cellData.anchorName = params[@"anchorName"];
            cellData.roomInfo = params;
            cellData.direction = direction;
            cellData.msgID = msg.msgID;
            cellData.identifier = msg.sender;
            cellData.status = Msg_Status_Succ;
            cellData.name = msg.getShowName;
            cellData.avatarUrl = [NSURL URLWithString:msg.faceURL];
            cellData.innerMessage = msg;
            return cellData;
        }
    }
    
    /// 群直播|音视频通话信令消息，比如 “xxx 发起群通话”，“xxx接收群通话” 等
    NSString *content = [self getCustomSignalingContentWithMessage:msg];
    if (content.length > 0) {
        TMsgDirection direction = msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
        if (msg.userID.length > 0) {
            TUIC2CSignalCellData *cellData = [[TUIC2CSignalCellData alloc] initWithDirection:direction];
            cellData.content = content;
            V2TIMMessage *message = [V2TIMManager.sharedInstance createTextMessage:content];
            cellData.innerMessage = message;
            return cellData;
        } else {
            TUIGroupSignalCellData *cellData = [[TUIGroupSignalCellData alloc] initWithDirection:direction];
            cellData.content = content;
            V2TIMMessage *message = [V2TIMManager.sharedInstance createTextMessage:content];
            cellData.innerMessage = message;
            return cellData;
        }
    }
    return nil;
}

- (TUIMessageCell *)chatController:(TUIChatController *)controller onShowMessageData:(TUIMessageCellData *)cellData {
    if ([cellData isKindOfClass:[TUIC2CSignalCellData class]]) {
        TUIC2CSignalCell *callCell = [[TUIC2CSignalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"C2CSignalCell"];
        [callCell fillWithData:(TUIC2CSignalCellData *)cellData];
        return callCell;
    } else if ([cellData isKindOfClass:[TUIGroupSignalCell class]]) {
        TUIGroupSignalCell *callCell = [[TUIGroupSignalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupSignalCell"];
        [callCell fillWithData:(TUIGroupSignalCellData *)cellData];
        return callCell;
    } else if ([cellData isKindOfClass:[TUIGroupLiveMessageCellData class]]) {
        TUIGroupLiveMessageCell *liveCell = [[TUIGroupLiveMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupLiveMessageCell"];
        [liveCell fillWithData:(TUIGroupLiveMessageCellData *)cellData];
        return liveCell;
    }
    return nil;
}

- (NSArray <TUIInputMoreCellData *> *)chatController:(TUIChatController *)chatController onRegisterMoreCell:(MoreCellPriority *)priority {
    NSMutableArray *moreMenus = [NSMutableArray array];
    // 开启视频通话
    if (self.enableVideoCall) {
        TUIInputMoreCellData *videoCall = [[TUIInputMoreCellData alloc] init];
        videoCall.title = TUILocalizableString(TUIKitMoreVideoCall);
        videoCall.image = [UIImage tk_imageNamed:@"more_video_call"];
        [moreMenus addObject:videoCall];
    }
    
    // 开启语音通话
    if (self.enableAudioCall) {
        TUIInputMoreCellData *audioCall = [[TUIInputMoreCellData alloc] init];
        audioCall.title = TUILocalizableString(TUIKitMoreVoiceCall);
        audioCall.image = [UIImage tk_imageNamed:@"more_voice_call"];
        [moreMenus addObject:audioCall];
    }
    
    // 开启群直播
    if (self.enableGroupLiveEntry && chatController.conversationData.groupID.length > 0) {
        TUIInputMoreCellData *groupLive = [[TUIInputMoreCellData alloc] init];
        groupLive.title = TUILocalizableString(TUIKitMoreGroupLive);
        groupLive.image = [UIImage tk_imageNamed:@"more_group_live"];
        [moreMenus addObject:groupLive];
    }
    
    if (moreMenus.count == 0) {
        return nil;
    } else {
        *priority = MoreCellPriority_High;
        return moreMenus;
    }
}

- (void)chatController:(TUIChatController *)chatController onSelectMoreCell:(TUIInputMoreCell *)cell {
    NSString *serviceID = nil;
    if ([cell.title.text isEqualToString:TUILocalizableString(TUIKitMoreVideoCall)]) {
        serviceID = ServiceIDForVideoCall;
    } else if ([cell.title.text isEqualToString:TUILocalizableString(TUIKitMoreVoiceCall)]) {
        serviceID = ServiceIDForAudioCall;
    } else if ([cell.title.text isEqualToString:TUILocalizableString(TUIKitMoreGroupLive)]) {
        serviceID = ServiceIDForGroupLive;
    } else {
        return;
    }
    
    // 广播 menu 点击事件，注册 service 服务的模块处理对应事件
    NSDictionary *param = @{@"serviceID"   : serviceID ? : @"",
                            @"groupID"     : chatController.conversationData.groupID ? : @"",
                            @"userID"      : chatController.conversationData.userID ? : @"",
                            @"msgSender"   : chatController};
    // 对于群直播，需要监听群创建销毁的状态，这里把当前对象传出去
    [[NSNotificationCenter defaultCenter] postNotificationName:MenusServiceAction
                                                        object:self
                                                        userInfo:param];
}

- (void)chatController:(TUIChatController *)controller onSelectMessageContent:(TUIMessageCell *)cell {
    if ([cell isKindOfClass:[TUIGroupLiveMessageCell class]]) {
        TUIGroupLiveMessageCellData *celldata = [(TUIGroupLiveMessageCell *)cell customData];
        NSDictionary *roomInfo = celldata.roomInfo;
        [[NSNotificationCenter defaultCenter] postNotificationName:GroupLiveOnSelectMessage object:nil userInfo:@{
            @"roomInfo": roomInfo,
            @"groupID": celldata.innerMessage.groupID?:@"",
            @"msgSender": controller,
        }];
    }
}

- (NSString *)chatController:(TUIChatController *)controller onGetMessageAbstact:(V2TIMMessage *)msg {
    /// 群直播自定义消息
    if (msg.customElem.data) {
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:msg.customElem.data options:NSJSONReadingAllowFragments error:nil];
        //[params[@"version"] integerValue] == Version &&
        if ([params isKindOfClass:NSDictionary.class] && [params[@"businessID"] isKindOfClass:NSString.class] && [params[@"businessID"] isEqualToString:@"group_live"]) {
            NSString *name = params[@"anchorName"];
            if (name.length > 0) {
                name = [NSString stringWithFormat:TUILocalizableString(TUIKitWhosLiveFormat), name];
            } else {
                name = [NSString stringWithFormat:TUILocalizableString(TUIKitWhosLiveFormat), params[@"anchorId"]];
            }
            NSString *roomStatus = [params[@"roomStatus"] boolValue]?TUILocalizableString(Living):TUILocalizableString(Live-finished);
            return [NSString stringWithFormat:@"%@:%@",name, roomStatus];
        }
    }
    
    /// 群直播|音视频通话信令消息，比如 “xxx 发起群通话”，“xxx接收群通话” 等
    NSString *content = [self getCustomSignalingContentWithMessage:msg];
    if (content.length > 0) {
        return content;
    }
    return nil;
}

#pragma mark TUILiveRoomAnchorDelegate

- (void)onRoomCreate:(TRTCLiveRoomInfo *)roomInfo {
    if (self.groupLiveDelegate && [self.groupLiveDelegate respondsToSelector:@selector(onRoomCreate:)]) {
        [self.groupLiveDelegate onRoomCreate:roomInfo];
    }
}

- (void)onRoomDestroy:(TRTCLiveRoomInfo *)roomInfo {
    if (self.groupLiveDelegate && [self.groupLiveDelegate respondsToSelector:@selector(onRoomDestroy:)]) {
        [self.groupLiveDelegate onRoomDestroy:roomInfo];
    }
}

- (void)getPKRoomIDList:(TUILiveOnRoomListCallback _Nullable)callback {
    if (self.groupLiveDelegate && [self.groupLiveDelegate respondsToSelector:@selector(getPKRoomIDList:)]) {
        [self.groupLiveDelegate getPKRoomIDList:callback];
    }
}

- (void)onRoomError:(TRTCLiveRoomInfo *)roomInfo errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage {
    if (self.groupLiveDelegate && [self.groupLiveDelegate respondsToSelector:@selector(onRoomError:errorCode:errorMessage:)]) {
        [self.groupLiveDelegate onRoomError:roomInfo errorCode:errorCode errorMessage:errorMessage];
    }
}

#pragma mark Utils
/// 信令消息对应的自定义文本
- (NSString *)getCustomSignalingContentWithMessage:(V2TIMMessage *)message
{
    V2TIMSignalingInfo *info = [[V2TIMManager sharedInstance] getSignallingInfo:message];
    if (!info) {
        return nil;
    }
    // 解析透传的data字段
    NSError *err = nil;
    NSDictionary *param = nil;
    if (info.data != nil) {
        param = [NSJSONSerialization JSONObjectWithData:[info.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    }
    
    // 判断业务类型
    NSArray *allKeys = param.allKeys;
    if (![allKeys containsObject:@"businessID"]) {
        return nil;
    }
    
    // 判断是否为TRTC的信令
    NSString *liveRoomContent = @"";
    if ([self isLiveRoomSignalingInfo:info infoData:param withCustomContent:&liveRoomContent]) {
        return liveRoomContent;
    }

    // 判断是否为音视频通话信令
    NSString *callContent = @"";
    if ([self isCallSignalingInfo:message info:info infoData:param withCustomContent:&callContent]) {
        return callContent;
    }
    
    return nil;
}

// 直播间自定义信令文本
- (BOOL)isLiveRoomSignalingInfo:(V2TIMSignalingInfo *)info infoData:(NSDictionary *)param withCustomContent:(NSString **)content
{
    *content = @"";
    
    NSString *businessId = [param objectForKey:@"businessID"];
    if (![businessId isEqualToString:Signal_Business_Live]) {
        return NO;
    }
    
    NSInteger actionCode = [[param objectForKey:@"action"] integerValue];
    switch (actionCode) {
        case 100: *content = TUILocalizableString(TUIKitSignalingLiveRequestForMic); break;
        case 101:
            if (info.actionType == SignalingActionType_Reject_Invite) {
                *content = TUILocalizableString(TUIKitSignalingLiveRequestForMicRejected);
            } else if (info.actionType == SignalingActionType_Accept_Invite) {
                *content = TUILocalizableString(TUIKitSignalingAgreeMicRequest);
            }
            break;
        case 102: *content = TUILocalizableString(TUIKitSignalingCloseLinkMicRequest); break;
        case 103: *content = TUILocalizableString(TUIKitSignalingCloseLinkMic); break;
        case 200:
            if (info.actionType == SignalingActionType_Invite) {
                *content = TUILocalizableString(TUIKitSignalingRequestForPK);
            }
            break;
        case 201:
            if (info.actionType == SignalingActionType_Reject_Invite) {
                *content = TUILocalizableString(TUIKitSignalingRequestForPKRejected);
            } else if (info.actionType == SignalingActionType_Accept_Invite) {
                *content = TUILocalizableString(TUIKitSignalingRequestForPKAgree);
            }
            break;
        case 202: *content = TUILocalizableString(TUIKitSignalingPKExit); break;
        default:
            *content = TUILocalizableString(TUIKitSignalingUnrecognlize);
            break;
    }
    return YES;
}

- (BOOL)isCallSignalingInfo:(V2TIMMessage *)message info:(V2TIMSignalingInfo *)info infoData:(NSDictionary *)param withCustomContent:(NSString **)content
{
    NSMutableString *mutableContent = [NSMutableString string];
    
    NSString *businessId = [param objectForKey:@"businessID"];
    if (![businessId isEqualToString:Signal_Business_Call]) {
        return NO;
    }
    
    switch (info.actionType) {
        case SignalingActionType_Invite:
        {
            // 结束通话
            if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_CALL_END]) {
                int duration = [param[SIGNALING_EXTRA_KEY_CALL_END] intValue];
                [mutableContent appendString:message.groupID.length > 0 ? TUILocalizableString(TUIKitSignalingFinishGroupChat) : [NSString stringWithFormat:TUILocalizableString(TUIKitSignalingFinishConversationAndTimeFormat),duration / 60,duration % 60]]; // 结束通话，通话时长：%.2d:%.2d
            } else {
            // 发起通话
                if (message.groupID.length > 0) {
                    [mutableContent appendString:[NSString stringWithFormat:TUILocalizableString(TUIKitSignalingNewGroupCallFormat),message.getShowName]]; // \"%@\" 发起群通话
                } else {
                    [mutableContent appendString:TUILocalizableString(TUIKitSignalingNewCall)];
                }
            }
        }
            break;
        case SignalingActionType_Cancel_Invite:
        {
            // 取消通话
            if (message.groupID.length > 0) {
                [mutableContent appendString:[NSString stringWithFormat:TUILocalizableString(TUIkitSignalingCancelGroupCallFormat),message.getShowName]]; // \"%@\" 取消群通话
            } else {
                [mutableContent appendString:TUILocalizableString(TUIkitSignalingCancelCall)];
            }
        }
            break;
        case SignalingActionType_Accept_Invite:
        {
            // 接受通话
            if (message.groupID.length > 0) {
                [mutableContent appendString:[NSString stringWithFormat:TUILocalizableString(TUIKitSignalingHangonCallFormat),message.getShowName]]; // \"%@\" 已接听
            } else {
                [mutableContent appendString:TUILocalizableString(TUIkitSignalingHangonCall)]; // 已接听
            }
        }
            break;
        case SignalingActionType_Reject_Invite:
        {
            // 拒绝通话
            if (message.groupID.length > 0) {
                if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_LINE_BUSY]) {
                    [mutableContent appendString:[NSString stringWithFormat:TUILocalizableString(TUIKitSignalingBusyFormat),message.getShowName]]; // \"%@\" 忙线
                } else {
                    [mutableContent appendString:[NSString stringWithFormat:TUILocalizableString(TUIKitSignalingDeclineFormat),message.getShowName]]; // \"%@\" 拒绝通话
                }
            } else {
                if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_LINE_BUSY]) {
                    [mutableContent appendString:TUILocalizableString(TUIKitSignalingCallBusy)]; // 对方忙线
                } else {
                    [mutableContent appendString:TUILocalizableString(TUIkitSignalingDecline)]; // 拒绝通话
                }
            }
        }
            break;
        case SignalingActionType_Invite_Timeout:
        {
            // 通话超时
            if (message.groupID.length > 0) {
                for (NSString *invitee in info.inviteeList) {
                    [mutableContent appendString:@"\""];
                    [mutableContent appendString:invitee];
                    [mutableContent appendString:@"\"、"];
                }
                [mutableContent replaceCharactersInRange:NSMakeRange(mutableContent.length - 1, 1) withString:@" "];
            }
            [mutableContent appendString:TUILocalizableString(TUIKitSignalingNoResponse)]; // 无应答
        }
            break;
        default:
        {
            [mutableContent appendString:TUILocalizableString(TUIkitSignalingUnrecognlize)]; // 不能识别的通话指令
        }
            break;
    }
    *content = mutableContent;
    return YES;
}

@end
