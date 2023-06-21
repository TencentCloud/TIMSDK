
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <AVFoundation/AVFoundation.h>

#import <TIMCommon/TUISystemMessageCellData.h>
#import "TUIChatCallingDataProvider.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUIFaceMessageCellData_Minimalist.h"
#import "TUIFileMessageCellData_Minimalist.h"
#import "TUIImageMessageCellData_Minimalist.h"
#import "TUIJoinGroupMessageCellData_Minimalist.h"
#import "TUIMergeMessageCellData_Minimalist.h"
#import "TUIMessageDataProvider_Minimalist+MessageDeal.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUIMessageProgressManager.h"
#import "TUIReplyMessageCellData_Minimalist.h"
#import "TUITextMessageCellData_Minimalist.h"
#import "TUIVideoMessageCellData_Minimalist.h"
#import "TUIVoiceMessageCellData_Minimalist.h"

/**
 * 消息撤回后最大可编辑时间 , default is (2 * 60)
 * The maximum editable time after the message is recalled, default is (2 * 60)
 */
#define MaxReEditMessageDelay 2 * 60

static NSMutableArray *gCustomMessageInfo = nil;
static NSMutableArray *gPluginCustomMessageInfo = nil;

@implementation TUIMessageDataProvider_Minimalist

#pragma mark - Custom Message Configuration
// *************************************************************************
//                      自定义消息配置
//                      Custom Message Configuration
// *************************************************************************
+ (void)load {
    gCustomMessageInfo = [NSMutableArray arrayWithArray:@[
        @{BussinessID : BussinessID_TextLink, TMessageCell_Name : @"TUILinkCell_Minimalist", TMessageCell_Data_Name : @"TUILinkCellData_Minimalist"}, @{
            BussinessID : BussinessID_GroupCreate,
            TMessageCell_Name : @"TUIGroupCreatedCell_Minimalist",
            TMessageCell_Data_Name : @"TUIGroupCreatedCellData_Minimalist"
        },
        @{
            BussinessID : BussinessID_Evaluation,
            TMessageCell_Name : @"TUIEvaluationCell_Minimalist",
            TMessageCell_Data_Name : @"TUIEvaluationCellData_Minimalist"
        },
        @{BussinessID : BussinessID_Order, TMessageCell_Name : @"TUIOrderCell_Minimalist", TMessageCell_Data_Name : @"TUIOrderCellData_Minimalist"},
        @{BussinessID : BussinessID_Typing, TMessageCell_Name : @"TUIMessageCell", TMessageCell_Data_Name : @"TUITypingStatusCellData"}
    ]];
    gPluginCustomMessageInfo = [NSMutableArray array];
}

+ (NSMutableArray *)getCustomMessageInfo {
    return gCustomMessageInfo;
}

+ (NSMutableArray *)getPluginCustomMessageInfo {
    return gPluginCustomMessageInfo;
}

#pragma mark - Differentiated internal Message cell appearance configuration
// *************************************************************************
//            差异化的内置消息 Cell 外观配置
//            Differentiated internal Message cell appearance configuration
// *************************************************************************
+ (TUIMessageCellData *__nullable)getCellData:(V2TIMMessage *)message {
    TUIMessageCellData *data = nil;

    // 1 Parse cell data
    // 1.1 Parse cell data from message status
    if (message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        data = [TUIMessageDataProvider_Minimalist getRevokeCellData:message];
    }

    // 1.2 Parse cell data from message custom data
    if (data == nil) {
        if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReply]) {
            /**
             * 判断是否包含「回复消息」
             * Determine whether to include "reply-message"
             */
            TUIMessageCellData *replyData = [TUIReplyMessageCellData_Minimalist getCellData:message];
            if (replyData) {
                data = replyData;
            }
        } else if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReference]) {
            /**
             * 判断是否包含「引用消息」
             * Determine whether to include "quote-message"
             */
            TUIMessageCellData *referenceData = [TUIReferenceMessageCellData_Minimalist getCellData:message];
            if (referenceData) {
                data = referenceData;
            }
        }
    }

    // 1.3 Parse cell data from message element type
    if (data == nil) {
        switch (message.elemType) {
            case V2TIM_ELEM_TYPE_TEXT: {
                data = [TUITextMessageCellData_Minimalist getCellData:message];
            } break;
            case V2TIM_ELEM_TYPE_IMAGE: {
                data = [TUIImageMessageCellData_Minimalist getCellData:message];
            } break;
            case V2TIM_ELEM_TYPE_SOUND: {
                data = [TUIVoiceMessageCellData_Minimalist getCellData:message];
            } break;
            case V2TIM_ELEM_TYPE_VIDEO: {
                data = [TUIVideoMessageCellData_Minimalist getCellData:message];
            } break;
            case V2TIM_ELEM_TYPE_FILE: {
                data = [TUIFileMessageCellData_Minimalist getCellData:message];
            } break;
            case V2TIM_ELEM_TYPE_FACE: {
                data = [TUIFaceMessageCellData_Minimalist getCellData:message];
            } break;
            case V2TIM_ELEM_TYPE_GROUP_TIPS: {
                data = [self getSystemCellData:message];
            } break;
            case V2TIM_ELEM_TYPE_MERGER: {
                data = [TUIMergeMessageCellData_Minimalist getCellData:message];
            } break;
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
            } break;

            default:
                data = [self getUnsupportedCellData:message];
                break;
        }
    }

    // 2 Fill in property if needed
    if (data) {
        [self fillPropertyToCellData:data ofMessage:message];
    } else {
        NSLog(@"current message will be ignored in chat page, msg:%@", message);
    }

    return data;
}
+ (void)fillPropertyToCellData:(TUIMessageCellData *)data ofMessage:(V2TIMMessage *)message {
    data.innerMessage = message;
    data.msgID = message.msgID;
    data.identifier = message.sender;
    data.name = [TUIMessageDataProvider_Minimalist getShowName:message];
    data.avatarUrl = [NSURL URLWithString:message.faceURL];
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
        NSInteger uploadProgress = [TUIMessageProgressManager.shareManager uploadProgressForMessage:message.msgID];
        NSInteger downloadProgress = [TUIMessageProgressManager.shareManager downloadProgressForMessage:message.msgID];
        if ([data conformsToProtocol:@protocol(TUIMessageCellDataFileUploadProtocol)]) {
            ((id<TUIMessageCellDataFileUploadProtocol>)data).uploadProgress = uploadProgress;
        }
        if ([data conformsToProtocol:@protocol(TUIMessageCellDataFileDownloadProtocol)]) {
            ((id<TUIMessageCellDataFileDownloadProtocol>)data).downladProgress = downloadProgress;
            ((id<TUIMessageCellDataFileDownloadProtocol>)data).isDownloading = (downloadProgress != 0) && (downloadProgress != 100);
        }
    }

    /**
     * 判断是否包含「消息响应」
     * Determine whether to include "react-message"
     */
    if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReact]) {
        [message doThingsInContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReact
                                                callback:^(BOOL isContains, id obj) {
                                                  if (isContains) {
                                                      if (obj && [obj isKindOfClass:NSDictionary.class]) {
                                                          NSDictionary *dic = (NSDictionary *)obj;
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
        [message doThingsInContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReplies
                                                callback:^(BOOL isContains, id obj) {
                                                  if (isContains) {
                                                      data.showMessageModifyReplies = YES;
                                                      if (obj && [obj isKindOfClass:NSDictionary.class]) {
                                                          NSDictionary *dic = (NSDictionary *)obj;
                                                          NSString *typeStr =
                                                              [TUICloudCustomDataTypeCenter convertType2String:TUICloudCustomDataType_MessageReplies];
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
+ (TUIMessageCellData *__nullable)getCustomMessage:(V2TIMMessage *)message {
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
    for (NSDictionary *messageInfo in gCustomMessageInfo) {
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

+ (TUIMessageCellData *)getUnsupportedCellData:(V2TIMMessage *)message {
    TUITextMessageCellData_Minimalist *cellData =
        [[TUITextMessageCellData_Minimalist alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    cellData.content = TIMCommonLocalizableString(TUIKitNotSupportThisMessage);
    cellData.reuseId = TTextMessageCell_ReuseId;
    return cellData;
}

+ (TUISystemMessageCellData *)getSystemCellData:(V2TIMMessage *)message {
    V2TIMGroupTipsElem *tip = message.groupTipsElem;
    NSString *opUserName = [self getOpUserName:tip.opMember];
    NSMutableArray<NSString *> *userNameList = [self getUserNameList:tip.memberList];
    NSMutableArray<NSString *> *userIDList = [self getUserIDList:tip.memberList];
    if (tip.type == V2TIM_GROUP_TIPS_TYPE_JOIN || tip.type == V2TIM_GROUP_TIPS_TYPE_INVITE || tip.type == V2TIM_GROUP_TIPS_TYPE_KICKED ||
        tip.type == V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE || tip.type == V2TIM_GROUP_TIPS_TYPE_QUIT) {
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

+ (TUISystemMessageCellData *)getRevokeCellData:(V2TIMMessage *)message {
    TUISystemMessageCellData *revoke = [[TUISystemMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    revoke.reuseId = TSystemMessageCell_ReuseId;
    if (message.isSelf) {
        if (message.elemType == V2TIM_ELEM_TYPE_TEXT && fabs([[NSDate date] timeIntervalSinceDate:message.timestamp]) < MaxReEditMessageDelay) {
            revoke.supportReEdit = YES;
        }
        revoke.content = TIMCommonLocalizableString(TUIKitMessageTipsYouRecallMessage);
        revoke.innerMessage = message;
        return revoke;
    } else if (message.userID.length > 0) {
        revoke.content = TIMCommonLocalizableString(TUIKitMessageTipsOthersRecallMessage);
        revoke.innerMessage = message;
        return revoke;
    } else if (message.groupID.length > 0) {
        /**
         * 对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
         * For the name display of group messages, the group business card is displayed first, the nickname has the second priority, and the user ID has the
         * lowest priority.
         */
        NSString *userName = [TUIMessageDataProvider_Minimalist getShowName:message];
        TUIJoinGroupMessageCellData_Minimalist *joinGroupData = [[TUIJoinGroupMessageCellData_Minimalist alloc] initWithDirection:MsgDirectionIncoming];
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
    system.content = [self.class convertDateToStr:date];
    system.reuseId = TSystemMessageCell_ReuseId;
    system.type = TUISystemMessageTypeDate;
    return system;
}

static TUIChatCallingDataProvider *gCallingDataProvider;
+ (TUIChatCallingDataProvider *)callingDataProvider {
    if (gCallingDataProvider == nil) {
        gCallingDataProvider = [[TUIChatCallingDataProvider alloc] init];
    }
    return gCallingDataProvider;
}

+ (TUIMessageCellData *)getCallingCellData:(id<TUIChatCallingInfoProtocol>)callingInfo {
    TMsgDirection direction = MsgDirectionIncoming;
    if (callingInfo.direction == TUICallMessageDirectionIncoming) {
        direction = MsgDirectionIncoming;
    } else if (callingInfo.direction == TUICallMessageDirectionOutgoing) {
        direction = MsgDirectionOutgoing;
    }

    if (callingInfo.participantType == TUICallParticipantTypeC2C) {
        TUITextMessageCellData_Minimalist *cellData = [[TUITextMessageCellData_Minimalist alloc] initWithDirection:direction];
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

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    NSString *str;
    if (message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        str = [self getRevokeDispayString:message];
    } else {
        switch (message.elemType) {
            case V2TIM_ELEM_TYPE_TEXT: {
                str = [TUITextMessageCellData_Minimalist getDisplayString:message];
            } break;
            case V2TIM_ELEM_TYPE_IMAGE: {
                str = [TUIImageMessageCellData_Minimalist getDisplayString:message];
            } break;
            case V2TIM_ELEM_TYPE_SOUND: {
                str = [TUIVoiceMessageCellData_Minimalist getDisplayString:message];
            } break;
            case V2TIM_ELEM_TYPE_VIDEO: {
                str = [TUIVideoMessageCellData_Minimalist getDisplayString:message];
            } break;
            case V2TIM_ELEM_TYPE_FILE: {
                str = [TUIFileMessageCellData_Minimalist getDisplayString:message];
            } break;
            case V2TIM_ELEM_TYPE_FACE: {
                str = [TUIFaceMessageCellData_Minimalist getDisplayString:message];
            } break;
            case V2TIM_ELEM_TYPE_MERGER: {
                str = [TUIMergeMessageCellData_Minimalist getDisplayString:message];
            } break;
            case V2TIM_ELEM_TYPE_GROUP_TIPS: {
                str = [self getGroupTipsDisplayString:message];
            } break;
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
            } break;
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

+ (NSString *)getCustomDisplayString:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *businessID = param[BussinessID];
    if (!businessID || ![businessID isKindOfClass:[NSString class]]) {
        return nil;
    }
    for (NSDictionary *messageInfo in gCustomMessageInfo) {
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
    gCallingDataProvider = nil;
}

- (void)preProcessReplyMessageV2:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void (^)(void))callback {
    if (uiMsgs.count == 0) {
        if (callback) {
            callback();
        }
        return;
    }

    @weakify(self);
    dispatch_group_t group = dispatch_group_create();
    for (TUIMessageCellData *cellData in uiMsgs) {
        if (![cellData isKindOfClass:TUIReplyMessageCellData_Minimalist.class]) {
            continue;
        }

        TUIReplyMessageCellData_Minimalist *myData = (TUIReplyMessageCellData_Minimalist *)cellData;
        __weak typeof(myData) weakMyData = myData;
        myData.onFinish = ^{
          @strongify(self);
          [self.dataSource dataProviderDataSourceWillChange:self];
          NSUInteger index = [self.uiMsgs indexOfObject:weakMyData];
          [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageBaseDataProviderDataSourceChangeTypeReload atIndex:index animation:NO];
          [self.dataSource dataProviderDataSourceDidChange:self];
        };
        dispatch_group_enter(group);
        [self loadOriginMessageFromReplyData:myData
                                dealCallback:^{
                                  dispatch_group_leave(group);
                                }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
      if (callback) {
          callback();
      }
    });
}
- (void)deleteUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs SuccBlock:(nullable V2TIMSucc)succ FailBlock:(nullable V2TIMFail)fail {
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
            if (index >= 0 && index < self.uiMsgs.count && [[self.uiMsgs objectAtIndex:index] isKindOfClass:TUISystemMessageCellData.class]) {
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
    [self.class deleteMessages:imMsgList
                          succ:^{
                            @strongify(self);
                            [self.dataSource dataProviderDataSourceWillChange:self];
                            for (TUIMessageCellData *uiMsg in uiMsgList) {
                                NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
                                [self.dataSource dataProviderDataSourceChange:self
                                                                     withType:TUIMessageBaseDataProviderDataSourceChangeTypeDelete
                                                                      atIndex:index
                                                                    animation:YES];
                            }
                            [self removeUIMsgList:uiMsgList];

                            [self.dataSource dataProviderDataSourceDidChange:self];
                            if (succ) {
                                succ();
                            }
                          }
                          fail:fail];
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

+ (NSString *)convertDateToStr:(NSDate *)date {
    if (!date) {
        return nil;
    }

    if ([date isEqualToDate:[NSDate distantPast]]) {
        return @"";
    }

    static NSDateFormatter *dateFmt = nil;
    if (dateFmt == nil) {
        dateFmt = [[NSDateFormatter alloc] init];
    }
    NSString *identifer = [TUIGlobalization tk_localizableLanguageKey];
    dateFmt.locale = [NSLocale localeWithLocaleIdentifier:identifer];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.firstWeekday = 7;
    NSDateComponents *nowComponent = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth
                                                 fromDate:NSDate.new];
    NSDateComponents *dateCompoent = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth
                                                 fromDate:date];

    if (nowComponent.year == dateCompoent.year) {
        // Same year
        if (nowComponent.month == dateCompoent.month) {
            // Same month
            if (nowComponent.weekOfMonth == dateCompoent.weekOfMonth) {
                // Same week
                if (nowComponent.day == dateCompoent.day) {
                    // Same day
                    return TIMCommonLocalizableString(TUIKitDateToday);
                } else {
                    // Not same day
                    dateFmt.dateFormat = @"EEEE";
                }
            } else {
                // Not same weeek
                dateFmt.dateFormat = @"MM/dd";
            }
        } else {
            // Not same month
            dateFmt.dateFormat = @"MM/dd";
        }
    } else {
        // Not same year
        dateFmt.dateFormat = @"yyyy/MM/dd";
    }

    NSString *str = [dateFmt stringFromDate:date];
    return str;
}

@end
