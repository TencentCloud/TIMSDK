
#import <AVFoundation/AVFoundation.h>

#import "TUIMessageDataProvider_Minimalist.h"
#import "TUIMessageDataProvider_Minimalist+Call.h"
#import "TUIMessageDataProvider_Minimalist+MessageDeal.h"
#import "TUITextMessageCellData_Minimalist.h"
#import "TUISystemMessageCellData.h"
#import "TUIVoiceMessageCellData_Minimalist.h"
#import "TUIImageMessageCellData_Minimalist.h"
#import "TUIVideoMessageCellData_Minimalist.h"
#import "TUIFileMessageCellData_Minimalist.h"
#import "TUIMergeMessageCellData_Minimalist.h"
#import "TUIFaceMessageCellData_Minimalist.h"
#import "TUIJoinGroupMessageCellData_Minimalist.h"
#import "TUIReplyMessageCellData_Minimalist.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUIMessageProgressManager.h"

/**
 * 消息撤回后最大可编辑时间 , default is (2 * 60)
 * The maximum editable time after the message is recalled, default is (2 * 60)
 */
#define MaxReEditMessageDelay 2 * 60

static NSArray *customMessageInfo = nil;

@implementation TUIMessageDataProvider_Minimalist

- (void)preProcessReplyMessageV2:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void(^)(void))callback
{
    if (uiMsgs.count == 0) {
        if (callback) {
            callback();
        }
        return;
    }
    
    @weakify(self)
    dispatch_group_t group = dispatch_group_create();
    for (TUIMessageCellData *cellData in uiMsgs) {
        if (![cellData isKindOfClass:TUIReplyMessageCellData_Minimalist.class]) {
            continue;
        }
        
        TUIReplyMessageCellData_Minimalist *myData = (TUIReplyMessageCellData_Minimalist *)cellData;
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
            // Check time cell which also needed to delete
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
- (void)addUIMsg:(TUIMessageCellData *)cellData {
    [super addUIMsg:cellData];
    [self.class updateUIMsgStatus:cellData uiMsgs:self.uiMsgs];
}

- (void)removeUIMsgList:(NSArray<TUIMessageCellData *> *)cellDatas {
    for (TUIMessageCellData *uiMsg in cellDatas) {
        [self removeUIMsg:uiMsg];
    }
}
- (void)removeUIMsg:(TUIMessageCellData *)cellData {
    NSInteger index = [self.uiMsgs indexOfObject:cellData];
    [super removeUIMsg:cellData];
    if (index >= 1) {
        [self.class updateUIMsgStatus:self.uiMsgs[index - 1] uiMsgs:self.uiMsgs];
    }
}

- (void)insertUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs atIndexes:(NSIndexSet *)indexes {
    [super insertUIMsgs:uiMsgs atIndexes:indexes];
    for (TUIMessageCellData *cellData in uiMsgs) {
        [self.class updateUIMsgStatus:cellData uiMsgs:self.uiMsgs];
    }
}

- (void)addUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs {
    [super addUIMsgs:uiMsgs];
    for (TUIMessageCellData *cellData in uiMsgs) {
        [self.class updateUIMsgStatus:cellData uiMsgs:self.uiMsgs];
    }
}

- (void)replaceUIMsg:(TUIMessageCellData *)cellData atIndex:(NSUInteger)index {
    [super replaceUIMsg:cellData atIndex:index];
    [self.class updateUIMsgStatus:cellData uiMsgs:self.uiMsgs];
}

+ (void)updateUIMsgStatus:(TUIMessageCellData *)cellData uiMsgs:(NSArray *)uiMsgs {
    NSInteger index = [uiMsgs indexOfObject:cellData];
    TUIMessageCellData *data = uiMsgs[index];

    TUIMessageCellData *lastData = nil;
    if (index >= 1) {
        lastData = uiMsgs[index - 1];
        if (![lastData isKindOfClass:[TUISystemMessageCellData class]]) {
            if ([lastData.identifier isEqualToString:data.identifier]) {
                lastData.sameToNextMsgSender = YES;
                lastData.showAvatar = NO;
            } else {
                lastData.sameToNextMsgSender = NO;
                lastData.showAvatar = (lastData.direction == MsgDirectionIncoming ? YES : NO);
            }
        }
    }
    
    TUIMessageCellData *nextData = nil;
    if (index < uiMsgs.count - 1) {
        nextData = uiMsgs[index + 1];
        if ([data.identifier isEqualToString:nextData.identifier]) {
            data.sameToNextMsgSender = YES;
            data.showAvatar = NO;
        } else {
            data.sameToNextMsgSender = NO;
            data.showAvatar = (data.direction == MsgDirectionIncoming ? YES : NO);
        }
    }
    
    if (index == uiMsgs.count - 1) {
        data.showAvatar = (data.direction == MsgDirectionIncoming ? YES : NO);
        data.sameToNextMsgSender = NO;
    }
}

+ (void)load {
    customMessageInfo = @[@{BussinessID : BussinessID_TextLink,
                            TMessageCell_Name : @"TUILinkCell_Minimalist",
                            TMessageCell_Data_Name : @"TUILinkCellData_Minimalist"
                          },
                          @{BussinessID : BussinessID_GroupCreate,
                            TMessageCell_Name : @"TUIGroupCreatedCell_Minimalist",
                            TMessageCell_Data_Name : @"TUIGroupCreatedCellData_Minimalist"
                          },
                          @{BussinessID : BussinessID_Evaluation,
                            TMessageCell_Name : @"TUIEvaluationCell_Minimalist",
                            TMessageCell_Data_Name : @"TUIEvaluationCellData_Minimalist"
                          },
                          @{BussinessID : BussinessID_Order,
                            TMessageCell_Name : @"TUIOrderCell_Minimalist",
                            TMessageCell_Data_Name : @"TUIOrderCellData_Minimalist"
                          },
                          @{BussinessID : BussinessID_Typing,
                            TMessageCell_Name : @"TUIMessageCell",
                            TMessageCell_Data_Name : @"TUITypingStatusCellData"
                          }
    ];
}

+ (NSArray *)getCustomMessageInfo {
    return customMessageInfo;
}

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    if (message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        return [TUIMessageDataProvider_Minimalist getRevokeCellData:message];
    }
    
    TUIMessageCellData *data = nil;
    switch (message.elemType) { 
        case V2TIM_ELEM_TYPE_TEXT:
        {
            data = [TUITextMessageCellData_Minimalist getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_IMAGE:
        {
            data = [TUIImageMessageCellData_Minimalist getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_SOUND:
        {
            data = [TUIVoiceMessageCellData_Minimalist getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_VIDEO:
        {
            data = [TUIVideoMessageCellData_Minimalist getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_FILE:
        {
            data = [TUIFileMessageCellData_Minimalist getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_FACE:
        {
            data = [TUIFaceMessageCellData_Minimalist getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_GROUP_TIPS:
        {
            data = [self getSystemCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_MERGER:
        {
            data = [TUIMergeMessageCellData_Minimalist getCellData:message];
        }
            break;
        case V2TIM_ELEM_TYPE_CUSTOM:
        {
            if ([self isCallMessage:message]) {
                data = [self getCallCellData:message];
            } else if ([self isEvaluationCustomMessage:message]) {
                data = [self getEvalutionCustomCellData:message];
            } else if ([self isOrderCustomMessage:message]) {
                data = [self getOrderCustomCellData:message];
            } else {
                data = [self getNativeCustomCellData:message];
            }
        }
            break;

        default:
            break;
    }

    if (!data) {
        TUITextMessageCellData_Minimalist *cantSupportCellData = [[TUITextMessageCellData_Minimalist alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
        cantSupportCellData.content = TUIKitLocalizableString(TUIKitNotSupportThisMessage);
        data = cantSupportCellData;
        data.reuseId = TTextMessageCell_ReuseId;
    }
    
    /**
     * 判断是否包含「云自定义消息」
     * Determine whether contains cloud custom data
     */
    if (message.cloudCustomData) {
        /**
         * 判断是否包含「回复消息」
         * Determine whether to include "reply-message"
         */
        if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReply]) {
            TUIMessageCellData *replyData = [TUIReplyMessageCellData_Minimalist getCellData:message];
            if (replyData) {
                data = replyData;
            }
        }
        
        /**
         * 判断是否包含「引用消息」
         * Determine whether to include "quote-message"
         */
        if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReference]) {
            TUIMessageCellData *referenceData = [TUIReferenceMessageCellData_Minimalist getCellData:message];
            if (referenceData) {
                data = referenceData;
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
    }
    
    if (data) {
        data.innerMessage = message;
        data.msgID = message.msgID;
        data.direction = message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
        data.identifier = message.sender;
        data.name = [TUIMessageDataProvider_Minimalist getShowName:message];
        data.avatarUrl = [NSURL URLWithString:message.faceURL];

        /**
         * 展示 showName 字段的条件：
         * 1. 当前消息是群消息
         * 2. 当前消息并非自己发送的消息
         * 3. 当前消息不是系统消息
         *
         * Conditions to display the showName field:
         * 1. The current message is a group message
         * 2. The current message is not a message sent by yourself
         * 3. The current message is not a system message
         */
//        if (message.groupID.length > 0 && !message.isSelf
//           && ![data isKindOfClass:[TUISystemMessageCellData class]]) {
//            data.showName = YES;
//        }
        
        /**
         * 更新消息状态
         * Update message status
         */
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
    }
    return data;
}

+ (TUIMessageCellData *)getNativeCustomCellData:(V2TIMMessage *)message {
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
                data.showReadReceipt = NO;
                return data;
            }
        }
    }
    return nil;
}

+ (BOOL)isEvaluationCustomMessage:(V2TIMMessage *)message {
    NSArray *evaluations = @[@"evaluate", @"evaluation"];
    return [evaluations containsObject:[self dataParsedFromWebCustomData:message]];
}

+ (BOOL)isOrderCustomMessage:(V2TIMMessage *)message {
    NSArray *orders = @[@"order"];
    return [orders containsObject:[self dataParsedFromWebCustomData:message]];
}

+ (NSString *)dataParsedFromWebCustomData:(V2TIMMessage *)message {
    NSError *error;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"parse customElem data error: %@", error);
        return nil;
    }
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return data[@"businessID"];
}

+ (TUIMessageCellData *)getEvalutionCustomCellData:(V2TIMMessage *)message {
    return [self getWebCustomCellData:message businessID:BussinessID_Evaluation];
}

+ (TUIMessageCellData *)getOrderCustomCellData:(V2TIMMessage *)message {
    return [self getWebCustomCellData:message businessID:BussinessID_Order];
}

+ (TUIMessageCellData *)getWebCustomCellData:(V2TIMMessage *)message businessID:(NSString *)businessID {
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

+ (TUISystemMessageCellData *)getSystemCellData:(V2TIMMessage *)message {
    V2TIMGroupTipsElem *tip = message.groupTipsElem;
    NSString *opUserName = [self getOpUserName:tip.opMember];
    NSMutableArray<NSString *> *userNameList = [self getUserNameList:tip.memberList];
    NSMutableArray<NSString *> *userIDList = [self getUserIDList:tip.memberList];
    if(tip.type == V2TIM_GROUP_TIPS_TYPE_JOIN || tip.type == V2TIM_GROUP_TIPS_TYPE_INVITE || tip.type == V2TIM_GROUP_TIPS_TYPE_KICKED || tip.type == V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE || tip.type == V2TIM_GROUP_TIPS_TYPE_QUIT){
        TUIJoinGroupMessageCellData_Minimalist *joinGroupData = [[TUIJoinGroupMessageCellData_Minimalist alloc] initWithDirection:MsgDirectionIncoming];
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
        revoke.content = TUIKitLocalizableString(TUIKitMessageTipsYouRecallMessage);
        revoke.innerMessage = message;
        return revoke;
    } else if (message.userID.length > 0){
        revoke.content = TUIKitLocalizableString(TUIkitMessageTipsOthersRecallMessage);
        revoke.innerMessage = message;
        return revoke;
    } else if (message.groupID.length > 0) {
        /**
         * 对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
         * For the name display of group messages, the group business card is displayed first, the nickname has the second priority, and the user ID has the lowest priority.
         */
        NSString *userName = [TUIMessageDataProvider_Minimalist getShowName:message];
        TUIJoinGroupMessageCellData_Minimalist *joinGroupData = [[TUIJoinGroupMessageCellData_Minimalist alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
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

+ (NSString *)getDisplayString:(V2TIMMessage *)message
{
    NSString *str;
    if(message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED){
        str = [self getRevokeDispayString:message];
    } else {
        switch (message.elemType) {
            case V2TIM_ELEM_TYPE_TEXT:
            {
                str = [TUITextMessageCellData_Minimalist getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_IMAGE:
            {
                str = [TUIImageMessageCellData_Minimalist getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_SOUND:
            {
                str = [TUIVoiceMessageCellData_Minimalist getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_VIDEO:
            {
                str = [TUIVideoMessageCellData_Minimalist getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_FILE:
            {
                str = [TUIFileMessageCellData_Minimalist getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_FACE:
            {
                str = [TUIFaceMessageCellData_Minimalist getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_MERGER:
            {
                str = [TUIMergeMessageCellData_Minimalist getDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_GROUP_TIPS:
            {
                str = [self getGroupTipsDisplayString:message];
            }
                break;
            case V2TIM_ELEM_TYPE_CUSTOM:
            {
                if ([self isCallMessage:message]) {
                    str = [self getCallMessageDisplayString:message];
                }
                else {
                    str = [self getCustomDisplayString:message];
                }
                if (!str) {
                    str = TUIKitLocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
                }
            }
                break;
            default:
                break;
        }
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

@end
