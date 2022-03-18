//
//  TRTCSignalFactory.m
//  TUICalling
//
//  Created by adams on 2021/6/17.
//

#import "TRTCSignalFactory.h"
#import "TRTCCallingHeader.h"
#import "TUICallingConstants.h"

static const NSUInteger SIGNALING_VERSION = 4;                  // 信令版本号

@implementation TRTCSignalFactory

+ (NSMutableDictionary *)packagingSignalingWithExtInfo:(NSString *)extInfo
                                                roomID:(NSUInteger)roomID
                                                   cmd:(NSString *)cmd
                                               cmdInfo:(NSString *)cmdInfo
                                               message:(NSString *)message
                                              callType:(CallType)callType {
    return [[self class] packagingSignalingWithExtInfo:extInfo roomID:roomID cmd:cmd cmdInfo:cmdInfo userIds:@[] message:message callType:callType];
}

+ (NSMutableDictionary *)packagingSignalingWithExtInfo:(NSString *)extInfo
                                                roomID:(NSUInteger)roomID
                                                   cmd:(NSString *)cmd
                                               cmdInfo:(NSString *)cmdInfo
                                               userIds:(NSArray *)userIds
                                               message:(NSString *)message
                                              callType:(CallType)callType {
    NSMutableDictionary *signalingDictionary = [@{SIGNALING_EXTRA_KEY_VERSION:@(SIGNALING_VERSION),
                                                  SIGNALING_EXTRA_KEY_BUSINESSID:SIGNALING_BUSINESSID,
                                                  SIGNALING_EXTRA_KEY_PLATFORM:SIGNALING_PLATFORM,
                                                  SIGNALING_EXTRA_KEY_EXTINFO:extInfo,
                                                  SIGNALING_EXTRA_KEY_CALL_TYPE:@(callType),
                                                  SIGNALING_EXTRA_KEY_DATA:@{SIGNALING_EXTRA_KEY_ROOMID:@(roomID),
                                                                             SIGNALING_EXTRA_KEY_CMD:cmd,
                                                                             SIGNALING_EXTRA_KEY_USERIDS:userIds,
                                                                             SIGNALING_EXTRA_KEY_CMDINFO:cmdInfo,
                                                                             SIGNALING_EXTRA_KEY_MESSAGE:message}} mutableCopy];
    return signalingDictionary;
}

+ (NSDictionary *)getDataDictionary: (NSDictionary *)signaling {
    NSDictionary *dataDictionary = signaling[SIGNALING_EXTRA_KEY_DATA];
    return dataDictionary;
}

+ (CallType)convertCmdToCallType:(NSString *)cmd {
    if ([cmd isEqualToString:SIGNALING_CMD_AUDIOCALL]) {
        return CallType_Audio;
    } else if ([cmd isEqualToString:SIGNALING_CMD_VIDEOCALL]) {
        return CallType_Video;
    }
    return CallType_Unknown;
}

+ (NSDictionary *)convertOldSignalingToNewSignaling:(NSDictionary *)oldSignalingDictionary {
    NSMutableDictionary *signalingDictionary = [NSMutableDictionary dictionaryWithDictionary:oldSignalingDictionary];
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    if ([oldSignalingDictionary.allKeys containsObject:SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL]) {
        [dataDictionary setValue:SIGNALING_CMD_SWITCHTOVOICECALL forKey:SIGNALING_EXTRA_KEY_CMD];
    }
    else if ([oldSignalingDictionary.allKeys containsObject:SIGNALING_EXTRA_KEY_CALL_END]) {
        [dataDictionary setValue:SIGNALING_CMD_HANGUP forKey:SIGNALING_EXTRA_KEY_CMD];
    }
    else if ([oldSignalingDictionary.allKeys containsObject:SIGNALING_EXTRA_KEY_CALL_TYPE]) {
        CallType callType = [signalingDictionary[SIGNALING_EXTRA_KEY_CALL_TYPE] integerValue];
        switch (callType) {
            case CallType_Video:
                [dataDictionary setValue:SIGNALING_CMD_VIDEOCALL forKey:SIGNALING_EXTRA_KEY_CMD];
                break;
            case CallType_Audio:
                [dataDictionary setValue:SIGNALING_CMD_AUDIOCALL forKey:SIGNALING_EXTRA_KEY_CMD];
                break;
            default:
                break;
        }
    }
    
    if ([oldSignalingDictionary.allKeys containsObject:SIGNALING_EXTRA_KEY_BUSINESSID]) {
        [signalingDictionary setValue:oldSignalingDictionary[SIGNALING_EXTRA_KEY_BUSINESSID] forKey:SIGNALING_EXTRA_KEY_BUSINESSID];
    } else {
        NSString *cmd = dataDictionary[SIGNALING_EXTRA_KEY_CMD];
        if ([cmd isEqualToString:SIGNALING_CMD_SWITCHTOVOICECALL] ||
            [cmd isEqualToString:SIGNALING_CMD_HANGUP] ||
            [cmd isEqualToString:SIGNALING_CMD_VIDEOCALL] ||
            [cmd isEqualToString:SIGNALING_CMD_AUDIOCALL]) {
            [signalingDictionary setValue:SIGNALING_BUSINESSID forKey:SIGNALING_EXTRA_KEY_BUSINESSID];
        }
    }
    
    if ([oldSignalingDictionary.allKeys containsObject:SIGNALING_EXTRA_KEY_LINE_BUSY]) {
        [dataDictionary setValue:SIGNALING_MESSAGE_LINEBUSY forKey:SIGNALING_EXTRA_KEY_MESSAGE];
    }
    
    if ([oldSignalingDictionary.allKeys containsObject:SIGNALING_EXTRA_KEY_ROOM_ID]) {
        [dataDictionary setValue:@([signalingDictionary[SIGNALING_EXTRA_KEY_ROOM_ID] integerValue]) forKey:SIGNALING_EXTRA_KEY_ROOMID];
    }
    
    [signalingDictionary setValue:dataDictionary forKey:SIGNALING_EXTRA_KEY_DATA];
    
    NSLog(@"%@",signalingDictionary);
    return signalingDictionary;
}

@end
