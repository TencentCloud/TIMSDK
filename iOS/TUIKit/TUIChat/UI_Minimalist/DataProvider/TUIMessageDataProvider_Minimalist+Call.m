//
//  TUIMessageDataProvider+Live.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/10.
//

#import "TUIMessageDataProvider_Minimalist+Call.h"
#import "TUITextMessageCell_Minimalist.h"
#import "TUISystemMessageCell.h"
#import "TUIDefine.h"
#import "TUIDarkModel.h"

@implementation TUIMessageDataProvider_Minimalist (Call)
+ (BOOL)isCallMessage:(V2TIMMessage *)message {
    /**
     * 音视频通话信令文本，比如 “xxx 发起群通话”，“xxx接收群通话” 等
     * Audio-video-call signaling text, such as "xxx initiates a group call", "xxx receives a group call", etc.
     */
    NSString *content = [self getCallSignalingContentWithMessage:message callTye:nil];
    if (content.length > 0) {
        return YES;
    }
    return NO;
}

+ (BOOL)isCallMessage:(V2TIMMessage *)message callTye:(NSInteger *)callType{
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
        TUITextMessageCellData_Minimalist *cellData = [[TUITextMessageCellData_Minimalist alloc] initWithDirection:direction];
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
+ (NSString *)getCallSignalingContentWithMessage:(V2TIMMessage *)message callTye:(NSInteger *)callType
{
    V2TIMSignalingInfo *info = [[V2TIMManager sharedInstance] getSignallingInfo:message];
    if (!info) {
        return nil;
    }
    NSError *err = nil;
    NSDictionary *param = nil;
    if (info.data != nil) {
        param = [NSJSONSerialization JSONObjectWithData:[info.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    }
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSArray *allKeys = param.allKeys;
    if (![allKeys containsObject:@"businessID"]) {
        return nil;
    }
    
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
    if (![businessId isEqualToString:@"av_call"]) {
        return NO;
    }
    if (callType) {
        *callType = [[param objectForKey:@"call_type"] integerValue];
    }
    NSString *showName = [TUIMessageDataProvider_Minimalist getShowName:message];
    switch (info.actionType) {
        case SignalingActionType_Invite:
        {
            if ([param.allKeys containsObject:@"data"]) {
                // newer version for calling
                NSDictionary *callData = [param objectForKey:@"data"];
                if (![callData isKindOfClass:NSDictionary.class]) {
                    NSLog(@"error instructure of the calling proto");
                    return NO;
                }
                if (![callData.allKeys containsObject:@"cmd"]) {
                    NSLog(@"error instructure of the calling proto");
                    return NO;
                }
                
                NSString *cmd = [callData objectForKey:@"cmd"];
                if ([cmd isEqualToString:@"switchToAudio"]) {
                    // switch to audio call
                    [mutableContent appendString:TUIKitLocalizableString(TUIKitSignalingSwitchToAudio)];
                } else if ([cmd isEqualToString:@"hangup"]) {
                    // hang up
                    NSInteger duration = 0;
                    if ([param.allKeys containsObject:@"call_end"]) {
                        duration = [param[@"call_end"] intValue];
                    }
                    [mutableContent appendString:message.groupID.length > 0 ? TUIKitLocalizableString(TUIKitSignalingFinishGroupChat) : [NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingFinishConversationAndTimeFormat),duration / 60,duration % 60]];
                } else if ([cmd isEqualToString:@"videoCall"] ||
                           [cmd isEqualToString:@"audioCall"]) {
                    // launch call
                    if (callType) {
                        *callType = [cmd isEqualToString:@"audioCall"] ? 1 : 2;
                    }
                    if (message.groupID.length > 0) {
                        [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingNewGroupCallFormat),showName]];
                    } else {
                        [mutableContent appendString:TUIKitLocalizableString(TUIKitSignalingNewCall)];
                    }
                } else {
                    // other's unsupported invitation
                    [mutableContent appendString:TUIKitLocalizableString(TUIKitSignalingUnsupportedCalling)];
                }
                
            } else {
                // Compatible with older versions
                if (callType) {
                    *callType = [[param objectForKey:@"call_type"] integerValue];
                }
                
                if ([param.allKeys containsObject:@"call_end"]) {
                    // finish call
                    int duration = [param[@"call_end"] intValue];
                    [mutableContent appendString:message.groupID.length > 0 ? TUIKitLocalizableString(TUIKitSignalingFinishGroupChat) : [NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingFinishConversationAndTimeFormat),duration / 60,duration % 60]];
                } else {
                    // launch call
                    if (message.groupID.length > 0) {
                        [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingNewGroupCallFormat),showName]];
                    } else {
                        [mutableContent appendString:TUIKitLocalizableString(TUIKitSignalingNewCall)];
                    }
                }
            }
        }
            break;
        case SignalingActionType_Cancel_Invite:
        {
            if (message.groupID.length > 0) {
                [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIkitSignalingCancelGroupCallFormat),showName]];
            } else {
                [mutableContent appendString:TUIKitLocalizableString(TUIkitSignalingCancelCall)];
            }
        }
            break;
        case SignalingActionType_Accept_Invite:
        {
            if ([param.allKeys containsObject:@"data"]) {
                // newer version for accepting calling
                NSDictionary *callData = [param objectForKey:@"data"];
                if (![callData isKindOfClass:NSDictionary.class]) {
                    NSLog(@"error instructure of the calling proto");
                    return NO;
                }
                if (![callData.allKeys containsObject:@"cmd"]) {
                    NSLog(@"error instructure of the calling proto");
                    return NO;
                }
                
                NSString *cmd = [callData objectForKey:@"cmd"];
                if ([cmd isEqualToString:@"switchToAudio"]) {
                    // comfirm switch to audio call
                    if (callType) {
                        *callType = 2;
                    }
                    [mutableContent appendString:TUIKitLocalizableString(TUIKitSignalingComfirmSwitchToAudio)];
                } else {
                    // accept for calling
                    if (message.groupID.length > 0) {
                        [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingHangonCallFormat),showName]];
                    } else {
                        [mutableContent appendString:TUIKitLocalizableString(TUIkitSignalingHangonCall)];
                    }
                }
                
            } else {
                // Compatible with older versions
                if (message.groupID.length > 0) {
                    [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingHangonCallFormat),showName]];
                } else {
                    [mutableContent appendString:TUIKitLocalizableString(TUIkitSignalingHangonCall)];
                }
            }
        }
            break;
        case SignalingActionType_Reject_Invite:
        {
            if (message.groupID.length > 0) {
//                if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_LINE_BUSY]) {
                if ([param.allKeys containsObject:@"line_busy"]) {
                    [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingBusyFormat),showName]];
                } else {
                    [mutableContent appendString:[NSString stringWithFormat:TUIKitLocalizableString(TUIKitSignalingDeclineFormat),showName]];
                }
            } else {
//                if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_LINE_BUSY]) {
                if ([param.allKeys containsObject:@"line_busy"]) {
                    [mutableContent appendString:TUIKitLocalizableString(TUIKitSignalingCallBusy)];
                } else {
                    [mutableContent appendString:TUIKitLocalizableString(TUIkitSignalingDecline)];
                }
            }
        }
            break;
        case SignalingActionType_Invite_Timeout:
        {
            if (message.groupID.length > 0) {
                for (NSString *invitee in info.inviteeList) {
                    [mutableContent appendString:@"\""];
                    [mutableContent appendString:invitee];
                    [mutableContent appendString:@"\"、"];
                }
                [mutableContent replaceCharactersInRange:NSMakeRange(mutableContent.length - 1, 1) withString:@" "];
            }
            [mutableContent appendString:TUIKitLocalizableString(TUIKitSignalingNoResponse)];
        }
            break;
        default:
        {
            [mutableContent appendString:TUIKitLocalizableString(TUIkitSignalingUnrecognlize)];
        }
            break;
    }
    *content = mutableContent;
    return YES;
}
@end
