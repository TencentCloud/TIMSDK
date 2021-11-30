//
//  TRTCSignalFactory.h
//  TUICalling
//
//  Created by adams on 2021/6/17.
//

#import <Foundation/Foundation.h>
#import "TRTCCallingUtils.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const SIGNALING_EXTRA_KEY_VERSION;
extern NSString *const SIGNALING_EXTRA_KEY_BUSINESSID;
extern NSString *const SIGNALING_EXTRA_KEY_PLATFORM;
extern NSString *const SIGNALING_EXTRA_KEY_EXTINFO;
extern NSString *const SIGNALING_EXTRA_KEY_DATA;
extern NSString *const SIGNALING_EXTRA_KEY_ROOMID;
extern NSString *const SIGNALING_EXTRA_KEY_CMD;
extern NSString *const SIGNALING_EXTRA_KEY_MESSAGE;
extern NSString *const SIGNALING_EXTRA_KEY_CMDINFO;
extern NSString *const SIGNALING_EXTRA_KEY_USERIDS;

//  兼容ver4老字段
extern NSString *const SIGNALING_EXTRA_KEY_CALL_TYPE;
extern NSString *const SIGNALING_EXTRA_KEY_ROOM_ID;
extern NSString *const SIGNALING_EXTRA_KEY_LINE_BUSY;
extern NSString *const SIGNALING_EXTRA_KEY_CALL_END;
extern NSString *const SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL;

extern NSString *const SIGNALING_CMD_VIDEOCALL;
extern NSString *const SIGNALING_CMD_AUDIOCALL;
extern NSString *const SIGNALING_CMD_HANGUP;
extern NSString *const SIGNALING_CMD_SWITCHTOVOICECALL;
extern NSString *const SIGNALING_MESSAGE_LINEBUSY;
extern NSString *const SIGNALING_BUSINESSID;

@interface TRTCSignalFactory : NSObject

+ (NSMutableDictionary *)packagingSignalingWithExtInfo:(NSString *)extInfo roomID:(NSUInteger)roomID cmd:(NSString *)cmd cmdInfo:(NSString *)cmdInfo message:(NSString *)message callType:(CallType)callType;

+ (NSMutableDictionary *)packagingSignalingWithExtInfo:(NSString *)extInfo roomID:(NSUInteger)roomID cmd:(NSString *)cmd cmdInfo:(NSString *)cmdInfo userIds:(NSArray *)userIds message:(NSString *)message callType:(CallType)callType;

+ (NSDictionary *)getDataDictionary: (NSDictionary *)signaling;

+ (CallType)convertCmdToCallType:(NSString *)cmd;

+ (NSDictionary *)convertOldSignalingToNewSignaling:(NSDictionary *)oldSignalingDictionary;

@end

NS_ASSUME_NONNULL_END
