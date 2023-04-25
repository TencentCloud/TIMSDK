
#import <AVFoundation/AVFoundation.h>

#import "TUIMessageDataProvider.h"
#import "TUIMessageDataProvider+MessageDeal.h"
#import "TUITextMessageCellData.h"
#import <TIMCommon/TUISystemMessageCellData.h>
#import "TUIVoiceMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUIFaceMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIFileMessageCellData.h"
#import "TUIMergeMessageCellData.h"
#import "TUIFaceMessageCellData.h"
#import "TUIJoinGroupMessageCellData.h"
#import "TUIReplyMessageCellData.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUIMessageProgressManager.h"
#import "TUIChatCallingDataProvider.h"

/**
 * 消息撤回后最大可编辑时间 , default is (2 * 60)
 * The maximum editable time after the message is recalled, default is (2 * 60)
 */
#define MaxReEditMessageDelay 2 * 60

static NSMutableArray *customMessageInfo = nil;

static NSMutableArray *pluginCustomMessageInfo = nil;

@implementation TUIMessageDataProvider

#pragma mark - Custom Message Configuration
// *************************************************************************
//                      自定义消息配置
//                      Custom Message Configuration
// *************************************************************************
+ (void)load {
    customMessageInfo = [NSMutableArray arrayWithArray:@[@{BussinessID : BussinessID_TextLink,
                                                           TMessageCell_Name : @"TUILinkCell",
                                                           TMessageCell_Data_Name : @"TUILinkCellData"
                                                         },
                                                         @{BussinessID : BussinessID_GroupCreate,
                                                           TMessageCell_Name : @"TUIGroupCreatedCell",
                                                           TMessageCell_Data_Name : @"TUIGroupCreatedCellData"
                                                         },
                                                         @{BussinessID : BussinessID_Evaluation,
                                                           TMessageCell_Name : @"TUIEvaluationCell",
                                                           TMessageCell_Data_Name : @"TUIEvaluationCellData"
                                                         },
                                                         @{BussinessID : BussinessID_Order,
                                                           TMessageCell_Name : @"TUIOrderCell",
                                                           TMessageCell_Data_Name : @"TUIOrderCellData"
                                                         },
                                                         @{BussinessID : BussinessID_Typing,
                                                           TMessageCell_Name : @"TUIMessageCell",
                                                           TMessageCell_Data_Name : @"TUITypingStatusCellData"
                                                         },
                                                       ]];
    
    pluginCustomMessageInfo = [NSMutableArray array];
    
}

+ (NSMutableArray *)getCustomMessageInfo {
    return customMessageInfo;
}

+ (NSMutableArray *)getPluginCustomMessageInfo {
    return pluginCustomMessageInfo;
}

+ (BOOL)judgeCurrentDataPluginMsg:(TUIMessageCellData *)data {
    NSMutableArray *pluginCustomMessageInfo = [TUIMessageDataProvider getPluginCustomMessageInfo];
    NSMutableArray * currentCustomMessageBussinessIDArray = [NSMutableArray array];
    for (NSDictionary *messageInfo in pluginCustomMessageInfo) {
        NSString *bussinessID = messageInfo[BussinessID];
        if (bussinessID) {
            [currentCustomMessageBussinessIDArray addObject:bussinessID];
        }
    }
    if([currentCustomMessageBussinessIDArray containsObject:data.reuseId]){
        return YES;
    }
    return NO;
}
#pragma mark - Differentiated internal Message cell appearance configuration
// *************************************************************************
//            差异化的内置消息 Cell 外观配置
//            Differentiated internal Message cell appearance configuration
// *************************************************************************
+ (TUIMessageCellData * __nullable)getCellData:(V2TIMMessage *)message {
    TUIMessageCellData *data = nil;
    
    // 1 Parse cell data
    // 1.1 Parse cell data from message status
    if (message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        data = [TUIMessageDataProvider getRevokeCellData:message];
    }
    
    // 1.2 Parse cell data from message custom data
    if (data == nil) {
        
        if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReply]) {
            /**
             * 判断是否包含「回复消息」
             * Determine whether to include "reply-message"
             */
            data = [TUIReplyMessageCellData getCellData:message];
        } else if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReference]) {
            /**
             * 判断是否包含「引用消息」
             * Determine whether to include "quote-message"
             */
            data = [TUIReferenceMessageCellData getCellData:message];
        }
    }
    
    // 1.3 Parse cell data from message element type
    if (data == nil) {
        switch (message.elemType) {
            case V2TIM_ELEM_TYPE_TEXT: {
                data = [TUITextMessageCellData getCellData:message];
            }
                break;
            case V2TIM_ELEM_TYPE_IMAGE: {
                data = [TUIImageMessageCellData getCellData:message];
            }
                break;
            case V2TIM_ELEM_TYPE_SOUND: {
                data = [TUIVoiceMessageCellData getCellData:message];
            }
                break;
            case V2TIM_ELEM_TYPE_VIDEO: {
                data = [TUIVideoMessageCellData getCellData:message];
            }
                break;
            case V2TIM_ELEM_TYPE_FILE: {
                data = [TUIFileMessageCellData getCellData:message];
            }
                break;
            case V2TIM_ELEM_TYPE_FACE: {
                data = [TUIFaceMessageCellData getCellData:message];
            }
                break;
            case V2TIM_ELEM_TYPE_GROUP_TIPS: {
                data = [self getSystemCellData:message];
            }
                break;
            case V2TIM_ELEM_TYPE_MERGER: {
                data = [TUIMergeMessageCellData getCellData:message];
            }
                break;
            case V2TIM_ELEM_TYPE_CUSTOM: {
                id<TUIChatCallingInfoProtocol> callingInfo = nil;
                if ([self.callingDataProvider isCallingMessage:message callingInfo:&callingInfo]) {
                    // Voice-video-call message
                    if (callingInfo) {
                        // Supported voice-video-call message
                        if (callingInfo.excludeFromHistory) {
                            // This message will be ignore in chat page
                            data = nil;
                        } else {
                            data = [self getCallingCellData:callingInfo];
                            if (data == nil) {
                                data = [self getUnsupportedCellData:message];
                            }
                        }
                    } else {
                        // Unsupported voice-video-call message
                        data = [self getUnsupportedCellData:message];
                    }
                } else {
                    // Others custom message
                    data = [self getCustomMessage:message];
                    if (data == nil) {
                        data = [self getUnsupportedCellData:message];
                    }
                }
            }
                break;
            default:
                data = [self getUnsupportedCellData:message];
                break;
        }
    }
    
    // 2 Fill in property if needed
    if (data) {
        data.innerMessage = message;
        data.msgID = message.msgID;
        data.identifier = message.sender;
        data.name = [TUIMessageDataProvider getShowName:message];
        data.avatarUrl = [NSURL URLWithString:message.faceURL];
        if (message.groupID.length > 0 && !message.isSelf
           && ![data isKindOfClass:[TUISystemMessageCellData class]]) {
            data.showName = YES;
        }
        switch (message.status) {
            case V2TIM_MSG_STATUS_SEND_SUCC:
                data.status = Msg_Status_Succ;
                break;
            case V2TIM_MSG_STATUS_SEND_FAIL:
                data.status = Msg_Status_Fail;
                break;
            case V2TIM_MSG_STATUS_SENDING:
                data.status = Msg_Status_Sending_2;
                break;
            default:
                break;
        }
        
        /**
         * 更新消息的上传/下载进度
         * Update progress of message uploading/downloading
         */
        {
            NSInteger progress = [TUIMessageProgressManager.shareManager progressForMessage:message.msgID];
            if ([data conformsToProtocol:@protocol(TUIMessageCellDataFileUploadProtocol)]) {
                ((id<TUIMessageCellDataFileUploadProtocol>)data).uploadProgress = progress;
            }
            if ([data conformsToProtocol:@protocol(TUIMessageCellDataFileDownloadProtocol)]) {
                ((id<TUIMessageCellDataFileDownloadProtocol>)data).downladProgress = progress;
                ((id<TUIMessageCellDataFileDownloadProtocol>)data).isDownloading = (progress != 0) && (progress != 100);
            }
        }
        
        /**
         * 判断是否包含「消息响应」
         * Determine whether to include "react-message"
         */
        if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReact]) {
            [message doThingsInContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReact callback:^(BOOL isContains, id obj) {
                if (isContains) {
                    if(obj && [obj isKindOfClass:NSDictionary.class]) {
                        NSDictionary * dic =  (NSDictionary *)obj;
                        if ([dic isKindOfClass:NSDictionary.class]) {
                            data.messageModifyReacts = dic.copy;
                        }
                    }
                }
            }];
            
        }
        
        /**
         * 判断是否包含「消息回复数」
         * Determine whether to include "replies-message"
         */
        if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReplies]) {
            [message doThingsInContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReplies callback:^(BOOL isContains, id obj) {
                if (isContains) {
                    data.showMessageModifyReplies = YES;
                    if(obj && [obj isKindOfClass:NSDictionary.class]) {
                        NSDictionary * dic =  (NSDictionary *)obj;
                        NSString * typeStr =  [TUICloudCustomDataTypeCenter convertType2String:TUICloudCustomDataType_MessageReplies];
                        NSDictionary *messageReplies = [dic valueForKey:typeStr];
                        NSArray *repliesArr = [messageReplies valueForKey:@"replies"];
                        if ([repliesArr isKindOfClass:NSArray.class]) {
                            data.messageModifyReplies = repliesArr.copy;
                        }
                    }
                }
            }];
        }
    } else {
        NSLog(@"current message will be ignored in chat page, msg:%@", message);
    }
    
    return data;
}

+ (TUIMessageCellData * __nullable)getCustomMessage:(V2TIMMessage *)message {
    NSError *error;
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"parse customElem data error: %@", error);
        return nil;
    }
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *businessID = param[BussinessID];
    if (!businessID || ![businessID isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    for (NSDictionary *messageInfo in customMessageInfo) {
        if ([businessID isEqualToString:messageInfo[BussinessID]]) {
            NSString *cellDataName = messageInfo[TMessageCell_Data_Name];
            Class cls = NSClassFromString(cellDataName);
            if (cls && [cls respondsToSelector:@selector(getCellData:)]) {
                TUIMessageCellData *data = [cls getCellData:message];
                data.reuseId = businessID;
                return data;
            }
        }
    }
    return nil;
}

+ (TUIMessageCellData *)getUnsupportedCellData:(V2TIMMessage *)message {
    TUITextMessageCellData *cellData = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    cellData.content = TIMCommonLocalizableString(TUIKitNotSupportThisMessage);
    cellData.reuseId = TTextMessageCell_ReuseId;
    return cellData;
}

+ (TUISystemMessageCellData *)getSystemCellData:(V2TIMMessage *)message {
    V2TIMGroupTipsElem *tip = message.groupTipsElem;
    NSString *opUserName = [self getOpUserName:tip.opMember];
    NSMutableArray<NSString *> *userNameList = [self getUserNameList:tip.memberList];
    NSMutableArray<NSString *> *userIDList = [self getUserIDList:tip.memberList];
    if(tip.type == V2TIM_GROUP_TIPS_TYPE_JOIN || tip.type == V2TIM_GROUP_TIPS_TYPE_INVITE || tip.type == V2TIM_GROUP_TIPS_TYPE_KICKED || tip.type == V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE || tip.type == V2TIM_GROUP_TIPS_TYPE_QUIT){
        TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [self getDisplayString:message];
        joinGroupData.opUserName = opUserName;
        joinGroupData.opUserID = tip.opMember.userID;
        joinGroupData.userNameList = userNameList;
        joinGroupData.userIDList = userIDList;
        joinGroupData.reuseId = TJoinGroupMessageCell_ReuseId;
        return joinGroupData;
    } else {
        TUISystemMessageCellData *sysdata = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        sysdata.content = [self getDisplayString:message];
        sysdata.reuseId = TSystemMessageCell_ReuseId;
        if (sysdata.content.length) {
            return sysdata;
        }
    }
    return nil;
}

+ (TUISystemMessageCellData *)getRevokeCellData:(V2TIMMessage *)message{

    TUISystemMessageCellData *revoke = [[TUISystemMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    revoke.reuseId = TSystemMessageCell_ReuseId;
    if(message.isSelf){
        if (message.elemType == V2TIM_ELEM_TYPE_TEXT && fabs([[NSDate date] timeIntervalSinceDate:message.timestamp]) < MaxReEditMessageDelay) {
            revoke.supportReEdit = YES;
        }
        revoke.content = TIMCommonLocalizableString(TUIKitMessageTipsYouRecallMessage);
        revoke.innerMessage = message;
        return revoke;
    } else if (message.userID.length > 0){
        revoke.content = TIMCommonLocalizableString(TUIkitMessageTipsOthersRecallMessage);
        revoke.innerMessage = message;
        return revoke;
    } else if (message.groupID.length > 0) {
        /**
         * 对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
         * For the name display of group messages, the group business card is displayed first, the nickname has the second priority, and the user ID has the lowest priority.
         */
        NSString *userName = [TUIMessageDataProvider getShowName:message];
        TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
        joinGroupData.opUserID = message.sender;
        joinGroupData.opUserName = userName;
        joinGroupData.reuseId = TJoinGroupMessageCell_ReuseId;
        return joinGroupData;
    }
    return nil;
}

+ (nullable TUISystemMessageCellData *)getSystemMsgFromDate:(NSDate *)date {
    TUISystemMessageCellData *system = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    system.content = [TUITool convertDateToStr:date];
    system.reuseId = TSystemMessageCell_ReuseId;
    system.type = TUISystemMessageTypeDate;
    return system;
}

static TUIChatCallingDataProvider *_callingDataProvider;
+ (TUIChatCallingDataProvider *)callingDataProvider {
    if (_callingDataProvider == nil) {
        _callingDataProvider = [[TUIChatCallingDataProvider alloc] init];
    }
    return _callingDataProvider;
}

+ (TUIMessageCellData *)getCallingCellData:(id<TUIChatCallingInfoProtocol>)callingInfo {
    TMsgDirection direction = MsgDirectionIncoming;
    if (callingInfo.direction == TUICallMessageDirectionIncoming) {
        direction = MsgDirectionIncoming;
    } else if (callingInfo.direction == TUICallMessageDirectionOutgoing) {
        direction = MsgDirectionOutgoing;
    }
    
    if (callingInfo.participantType == TUICallParticipantTypeC2C) {
        TUITextMessageCellData *cellData = [[TUITextMessageCellData alloc] initWithDirection:direction];
        if (callingInfo.streamMediaType == TUICallStreamMediaTypeVoice) {
            cellData.isAudioCall = YES;
        } else if (callingInfo.streamMediaType == TUICallStreamMediaTypeVideo) {
            cellData.isVideoCall = YES;
        } else {
            cellData.isAudioCall = NO;
            cellData.isVideoCall = NO;
        }
        cellData.content = callingInfo.content;
        cellData.isCaller = (callingInfo.participantRole == TUICallParticipantRoleCaller);
        cellData.showUnreadPoint = callingInfo.showUnreadPoint;
        cellData.isUseMsgReceiverAvatar = callingInfo.isUseReceiverAvatar;
        cellData.reuseId = TTextMessageCell_ReuseId;
        return cellData;
    } else if (callingInfo.participantType == TUICallParticipantTypeGroup) {
        TUISystemMessageCellData *cellData = [[TUISystemMessageCellData alloc] initWithDirection:direction];
        cellData.content = callingInfo.content;
        cellData.reuseId = TSystemMessageCell_ReuseId;
        return cellData;
    } else {
        return nil;
    }
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message
{
    NSString *str;
    if(message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED){
        str = [self getRevokeDispayString:message];
    } else {
        switch (message.elemType) {
            case V2TIM_ELEM_TYPE_TEXT: {
                str = [TUITextMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_IMAGE: {
                str = [TUIImageMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_SOUND: {
                str = [TUIVoiceMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_VIDEO: {
                str = [TUIVideoMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_FILE: {
                str = [TUIFileMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_FACE: {
                str = [TUIFaceMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_MERGER: {
                str = [TUIMergeMessageCellData getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_GROUP_TIPS: {
                str = [self getGroupTipsDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_CUSTOM: {
                id<TUIChatCallingInfoProtocol> callingInfo = nil;
                if ([self.callingDataProvider isCallingMessage:message callingInfo:&callingInfo]) {
                    // Voice-video-call message
                    if (callingInfo) {
                        // Supported voice-video-call message
                        if (callingInfo.excludeFromHistory) {
                            // This message will be ignore in chat page
                            str = nil;
                        } else {
                            // Get display text
                            str = callingInfo.content ?: TIMCommonLocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
                        }
                    } else {
                        // Unsupported voice-video-call message
                        str = TIMCommonLocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
                    }
                } else {
                    // Others custom message
                    str = [self getCustomDisplayString:message];
                    if (str == nil) {
                        str = TIMCommonLocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
                    }
                }
            }
                break;
            default:
                str = TIMCommonLocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
                break;
        }
    }
    
    if (str == nil) {
        NSLog(@"current message will be ignored in chat page or conversation list page, msg:%@", message);
    }
    return str;
}

+ (NSString *)getCustomDisplayString:(V2TIMMessage *)message{
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *businessID = param[BussinessID];
    if (!businessID || ![businessID isKindOfClass:[NSString class]]) {
        return nil;
    }
    for (NSDictionary *messageInfo in customMessageInfo) {
        if ([businessID isEqualToString:messageInfo[BussinessID]]) {
            NSString *cellDataName = messageInfo[TMessageCell_Data_Name];
            Class cls = NSClassFromString(cellDataName);
            if (cls && [cls respondsToSelector:@selector(getDisplayString:)]) {
                return [cls getDisplayString:message];
            }
        }
    }
    return nil;
}


#pragma mark - Differentiated interaction logic
// *************************************************************************
//                       差异化交互逻辑
//                       Differentiated interaction logic
// *************************************************************************
- (void)dealloc {
    _callingDataProvider = nil;
}

- (void)preProcessReplyMessageV2:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void(^)(void))callback {
    if (uiMsgs.count == 0) {
        if (callback) {
            callback();
        }
        return;
    }
    
    @weakify(self)
    dispatch_group_t group = dispatch_group_create();
    for (TUIMessageCellData *cellData in uiMsgs) {
        if (![cellData isKindOfClass:TUIReplyMessageCellData.class]) {
            continue;
        }
        
        TUIReplyMessageCellData *myData = (TUIReplyMessageCellData *)cellData;
        __weak typeof(myData) weakMyData = myData;
        myData.onFinish = ^{
            @strongify(self)
            [self.dataSource dataProviderDataSourceWillChange:self];
            NSUInteger index = [self.uiMsgs indexOfObject:weakMyData];
            [self.dataSource dataProviderDataSourceChange:self
                                                 withType:TUIMessageBaseDataProviderDataSourceChangeTypeReload
                                                  atIndex:index
                                                animation:NO];
            [self.dataSource dataProviderDataSourceDidChange:self];
        };
        dispatch_group_enter(group);
        [self loadOriginMessageFromReplyData:myData dealCallback:^{
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (callback) {
            callback();
        }
    });
}

- (void)deleteUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs
           SuccBlock:(nullable V2TIMSucc)succ
           FailBlock:(nullable V2TIMFail)fail {
    NSMutableArray *uiMsgList = [NSMutableArray array];
    NSMutableArray *imMsgList = [NSMutableArray array];
    for (TUIMessageCellData *uiMsg in uiMsgs) {
        if ([self.uiMsgs containsObject:uiMsg]) {
            // Check content cell
            [uiMsgList addObject:uiMsg];
            [imMsgList addObject:uiMsg.innerMessage];
            
            // Check time cell which also need to be deleted
            NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
            index--;
            if (index >= 0 && index < self.uiMsgs.count &&
                [[self.uiMsgs objectAtIndex:index] isKindOfClass:TUISystemMessageCellData.class]) {
                TUISystemMessageCellData *systemCellData = (TUISystemMessageCellData *)[self.uiMsgs objectAtIndex:index];
                if (systemCellData.type == TUISystemMessageTypeDate) {
                    [uiMsgList addObject:systemCellData];
                }
            }
        }
    }
    
    if (imMsgList.count == 0) {
        if (fail) {
            fail(ERR_INVALID_PARAMETERS, @"not found uiMsgs");
        }
        return;
    }
    
    @weakify(self);
    [self.class deleteMessages:imMsgList succ:^{
        @strongify(self);
        [self.dataSource dataProviderDataSourceWillChange:self];
        for (TUIMessageCellData *uiMsg in uiMsgList) {
            NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
            [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageBaseDataProviderDataSourceChangeTypeDelete atIndex:index animation:YES];
        }
        [self removeUIMsgList:uiMsgList];
        
        [self.dataSource dataProviderDataSourceDidChange:self];
        if (succ) {
            succ();
        }
    } fail:fail];
}

- (void)removeUIMsgList:(NSArray<TUIMessageCellData *> *)cellDatas {
    for (TUIMessageCellData *uiMsg in cellDatas) {
        [self removeUIMsg:uiMsg];
    }
}

@end
