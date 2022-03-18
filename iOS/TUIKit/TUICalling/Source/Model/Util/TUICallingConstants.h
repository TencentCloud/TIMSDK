//
//  TUICallingConstants.h
//  TUICalling
//
//  Created by noah on 2021/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static const int TC_TUICALLING_COMPONENT = 3;
static const int TC_TIMCALLING_COMPONENT = 10;
static const int TC_TRTC_FRAMEWORK       = 1;

@interface TUICallingConstants : NSObject

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
extern NSString *const SIGNALING_PLATFORM;

extern NSString *const SIGNALING_CUSTOM_CALL_ACTION;
extern NSString *const SIGNALING_CUSTOM_CALLID;
extern NSString *const SIGNALING_CUSTOM_USER;

// onCallEvent常用类型定义
extern NSString *const EVENT_CALL_HANG_UP;
extern NSString *const EVENT_CALL_LINE_BUSY;
extern NSString *const EVENT_CALL_LINE_BUSY;
extern NSString *const EVENT_CALL_CNACEL;
extern NSString *const EVENT_CALL_TIMEOUT;
extern NSString *const EVENT_CALL_NO_RESP;
extern NSString *const EVENT_CALL_SUCCEED;
extern NSString *const EVENT_CALL_START;
extern NSString *const EVENT_CALL_DECLINE;
extern NSString *const DEFAULT_AVATETR;

extern NSString *const CALLING_BELL_KEY;

@property (class, nonatomic, assign) int component;

@end

NS_ASSUME_NONNULL_END
