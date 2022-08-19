//
//  TUIMessageDataProvider+Live.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/10.
//

#import "TUIMessageDataProvider+Live.h"
#import "TUIGroupLiveMessageCell.h"
#import "TUITextMessageCell.h"
#import "TUISystemMessageCell.h"
#import "TUIDefine.h"

@implementation TUIMessageDataProvider (Live)

+ (BOOL)isLiveMessage:(V2TIMMessage *)message {
    if (message.customElem.data) {
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
        //[params[@"version"] integerValue] == Version &&
        if ([params isKindOfClass:NSDictionary.class] && [params[@"businessID"] isKindOfClass:NSString.class] && [params[@"businessID"] isEqualToString:@"group_live"]) {
            return YES;
        }
    }
    
    NSString *content = [self getLiveSignalingContentWithMessage:message];
    if (content.length > 0) {
        return YES;
    }
    return NO;
}

+ (TUIMessageCellData *)getLiveCellData:(V2TIMMessage *)message {
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    //[params[@"version"] integerValue] == Version &&
    if ([params isKindOfClass:NSDictionary.class] && [params[@"businessID"] isKindOfClass:NSString.class] && [params[@"businessID"] isEqualToString:@"group_live"]) {
        TMsgDirection direction = message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
        TUIGroupLiveMessageCellData *cellData = [[TUIGroupLiveMessageCellData alloc] initWithDirection:direction];
        cellData.anchorName = params[@"anchorName"];
        cellData.roomInfo = params;
        cellData.status = Msg_Status_Succ;
        cellData.reuseId = TGroupLiveMessageCell_ReuseId;
        return cellData;
    }
    
    NSString *content = [self getLiveSignalingContentWithMessage:message];
    if (content.length > 0) {
        TMsgDirection direction = message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming;
        TUISystemMessageCellData *cellData = [[TUISystemMessageCellData alloc] initWithDirection:direction];
        cellData.content = content;
        V2TIMMessage *innerMessage = [V2TIMManager.sharedInstance createTextMessage:content];
        cellData.innerMessage = innerMessage;
        cellData.reuseId = TSystemMessageCell_ReuseId;
        return cellData;
    }
    return nil;
}

+ (NSString *)getLiveMessageDisplayString:(V2TIMMessage *)message {
    if (message.customElem == nil || message.customElem.data == nil) {
        return nil;
    }

    V2TIMSignalingInfo *info = [[V2TIMManager sharedInstance] getSignallingInfo:message];
    if (info != nil) {
        return [self getLiveSignalingContentWithMessage:message];
    }

    NSError *err = nil;
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingMutableContainers error:&err];
    if (param != nil && [param isKindOfClass:[NSDictionary class]]) {
        NSString *businessID = param[@"businessID"];
//        if ([businessID isEqualToString:GroupLive]) {
        if ([businessID isEqualToString:@"group_live"]) {
            // **的直播
            if ([param.allKeys containsObject:@"anchorName"] && [param.allKeys containsObject:@"anchorId"]) {
                NSString *anchorName = param[@"anchorName"];
                if (anchorName.length == 0) {
                    anchorName = param[@"anchorId"];
                }
                NSString *format = TUIKitLocalizableString(TUIKitWhosLiveFormat);
                format = [NSString stringWithFormat:@"[%@]", format];
                return [NSString stringWithFormat:format, anchorName];
            }
        }
    }
    return nil;
}

#pragma mark - Utils
+ (NSString *)getLiveSignalingContentWithMessage:(V2TIMMessage *)message
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

    NSString *liveRoomContent = @"";
    if ([self isLiveRoomSignalingInfo:info infoData:param withCustomContent:&liveRoomContent]) {
        return liveRoomContent;
    }

    return nil;
}

+ (BOOL)isLiveRoomSignalingInfo:(V2TIMSignalingInfo *)info infoData:(NSDictionary *)param withCustomContent:(NSString **)content
{
    *content = @"";
    
    NSString *businessId = [param objectForKey:@"businessID"];
//    if (![businessId isEqualToString:Signal_Business_Live]) {
    if (![businessId isEqualToString:@"av_live"]) {
        return NO;
    }
    
    NSInteger actionCode = [[param objectForKey:@"action"] integerValue];
    switch (actionCode) {
        case 100: *content = TUIKitLocalizableString(TUIKitSignalingLiveRequestForMic); break;
        case 101:
            if (info.actionType == SignalingActionType_Reject_Invite) {
                *content = TUIKitLocalizableString(TUIKitSignalingLiveRequestForMicRejected);
            } else if (info.actionType == SignalingActionType_Accept_Invite) {
                *content = TUIKitLocalizableString(TUIKitSignalingAgreeMicRequest);
            }
            break;
        case 102: *content = TUIKitLocalizableString(TUIKitSignalingCloseLinkMicRequest); break;
        case 103: *content = TUIKitLocalizableString(TUIKitSignalingCloseLinkMic); break;
        case 200:
            if (info.actionType == SignalingActionType_Invite) {
                *content = TUIKitLocalizableString(TUIKitSignalingRequestForPK);
            }
            break;
        case 201:
            if (info.actionType == SignalingActionType_Reject_Invite) {
                *content = TUIKitLocalizableString(TUIKitSignalingRequestForPKRejected);
            } else if (info.actionType == SignalingActionType_Accept_Invite) {
                *content = TUIKitLocalizableString(TUIKitSignalingRequestForPKAgree);
            }
            break;
        case 202: *content = TUIKitLocalizableString(TUIKitSignalingPKExit); break;
        default:
            *content = TUIKitLocalizableString(TUIKitSignalingUnrecognlize);
            break;
    }
    return YES;
}

@end
