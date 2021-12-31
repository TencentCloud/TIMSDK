//
//  TUIMessageDataProvider+Live.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/10.
//

#import "TUIMessageDataProvider+Call.h"
#import "TUIGroupLiveMessageCell.h"
#import "TUITextMessageCell.h"
#import "TUISystemMessageCell.h"
#import "TUIDefine.h"
#import "TUIDarkModel.h"

@implementation TUIMessageDataProvider (Call)
+ (BOOL)isCallMessage:(V2TIMMessage *)message {
    /// 音视频通话信令文本，比如 “xxx 发起群通话”，“xxx接收群通话” 等
    NSString *content = [self getCallSignalingContentWithMessage:message callTye:nil];
    if (content.length > 0) {
        return YES;
    }
    return NO;
}

+ (BOOL)isCallMessage:(V2TIMMessage *)message callTye:(NSInteger *)callType{
    /// 音视频通话信令文本，比如 “xxx 发起群通话”，“xxx接收群通话” 等
    NSString *content = [self getCallSignalingContentWithMessage:message callTye:callType];
    if (content.length > 0) {
        return YES;
    }
    return NO;
}

+ (TUIMessageCellData *)getCallCellData:(V2TIMMessage *)message{
    NSInteger callType = 0;
    NSString *content = [self getCallSignalingContentWithMessage:message callTye:&callType];
    TMsgDirection direction = message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
    if (message.userID.length > 0) {
        TUITextMessageCellData *cellData = [[TUITextMessageCellData alloc] initWithDirection:direction];
        if (1 == callType) {
            cellData.isAudioCall = YES;
        } else if (2 == callType) {
            cellData.isVideoCall = YES;
        }
        cellData.content = content;
        V2TIMMessage *innerMessage = [V2TIMManager.sharedInstance createTextMessage:content];
        cellData.innerMessage = innerMessage;
        cellData.reuseId = TTextMessageCell_ReuseId;
        return cellData;
    } else {
        TUISystemMessageCellData *cellData = [[TUISystemMessageCellData alloc] initWithDirection:direction];
        cellData.content = content;
        V2TIMMessage *innerMessage = [V2TIMManager.sharedInstance createTextMessage:content];
        cellData.innerMessage = innerMessage;
        cellData.reuseId = TSystemMessageCell_ReuseId;
        return cellData;
    }
    return nil;
}

+ (NSString *)getCallMessageDisplayString:(V2TIMMessage *)message {
    return [self getCallSignalingContentWithMessage:message callTye:nil];
}

#pragma mark - Utils
/// 信令消息对应的自定义文本
+ (NSString *)getCallSignalingContentWithMessage:(V2TIMMessage *)message callTye:(NSInteger *)callType
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
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    // 判断业务类型
    NSArray *allKeys = param.allKeys;
    if (![allKeys containsObject:@"businessID"]) {
        return nil;
    }

    // 判断是否为音视频通话信令
    NSString *callContent = @"";
    if ([self isCallSignalingInfo:message info:info infoData:param withCustomContent:&callContent callTye:callType]) {
        return callContent;
    }
    
    return nil;
}

+ (BOOL)isCallSignalingInfo:(V2TIMMessage *)message info:(V2TIMSignalingInfo *)info infoData:(NSDictionary *)param withCustomContent:(NSString **)content callTye:(NSInteger *)callType
{
    NSMutableString *mutableContent = [NSMutableString string];
    
    NSString *businessId = [param objectForKey:@"businessID"];
//    if (![businessId isEqualToString:Signal_Business_Call]) {
    if (![businessId isEqualToString:@"av_call"]) {
        return NO;
    }
    if (callType) {
        *callType = [[param objectForKey:@"call_type"] integerValue];
    }
    NSString *showName = [TUIMessageDataProvider getShowName:message];
    switch (info.actionType) {
        case SignalingActionType_Invite:
        {
            // 结束通话
//            if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_CALL_END]) {
            if ([param.allKeys containsObject:@"call_end"]) {
                int duration = [param[@"call_end"] intValue];
                [mutableContent appendString:message.groupID.length > 0 ? TUIKitLocalizableString(TUIKitSignalingFinishGroupChat) : [NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingFinishConversationAndTimeFormat),duration / 60,duration % 60]]; // 结束通话，通话时长：%.2d:%.2d
            } else {
            // 发起通话
                if (message.groupID.length > 0) {
                    [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingNewGroupCallFormat),showName]]; // \"%@\" 发起群通话
                } else {
                    [mutableContent appendString:TUIKitLocalizableString(TUIKitSignalingNewCall)];
                }
            }
        }
            break;
        case SignalingActionType_Cancel_Invite:
        {
            // 取消通话
            if (message.groupID.length > 0) {
                [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIkitSignalingCancelGroupCallFormat),showName]]; // \"%@\" 取消群通话
            } else {
                [mutableContent appendString:TUIKitLocalizableString(TUIkitSignalingCancelCall)];
            }
        }
            break;
        case SignalingActionType_Accept_Invite:
        {
            // 接受通话
            if (message.groupID.length > 0) {
                [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingHangonCallFormat),showName]]; // \"%@\" 已接听
            } else {
                [mutableContent appendString:TUIKitLocalizableString(TUIkitSignalingHangonCall)]; // 已接听
            }
        }
            break;
        case SignalingActionType_Reject_Invite:
        {
            // 拒绝通话
            if (message.groupID.length > 0) {
//                if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_LINE_BUSY]) {
                if ([param.allKeys containsObject:@"line_busy"]) {
                    [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingBusyFormat),showName]]; // \"%@\" 忙线
                } else {
                    [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingDeclineFormat),showName]]; // \"%@\" 拒绝通话
                }
            } else {
//                if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_LINE_BUSY]) {
                if ([param.allKeys containsObject:@"line_busy"]) {
                    [mutableContent appendString:TUIKitLocalizableString(TUIKitSignalingCallBusy)]; // 对方忙线
                } else {
                    [mutableContent appendString:TUIKitLocalizableString(TUIkitSignalingDecline)]; // 拒绝通话
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
            [mutableContent appendString:TUIKitLocalizableString(TUIKitSignalingNoResponse)]; // 无应答
        }
            break;
        default:
        {
            [mutableContent appendString:TUIKitLocalizableString(TUIkitSignalingUnrecognlize)]; // 不能识别的通话指令
        }
            break;
    }
    *content = mutableContent;
    return YES;
}
@end
