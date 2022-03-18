//
//  TUICallingConstants.m
//  TUICalling
//
//  Created by noah on 2021/12/28.
//

#import "TUICallingConstants.h"

static int _component = TC_TUICALLING_COMPONENT;

@implementation TUICallingConstants

NSString *const SIGNALING_EXTRA_KEY_VERSION = @"version";       // 协议版本信息
NSString *const SIGNALING_EXTRA_KEY_BUSINESSID = @"businessID"; // 业务场景，可以是calling，Karaoke等
NSString *const SIGNALING_EXTRA_KEY_PLATFORM = @"platform";     // 平台，iOS,Android,Web,Windows，flutter
NSString *const SIGNALING_EXTRA_KEY_EXTINFO = @"extInfo";       // 扩展字段，备用
NSString *const SIGNALING_EXTRA_KEY_DATA = @"data";             // 携带的指令信息字段
NSString *const SIGNALING_EXTRA_KEY_ROOMID = @"room_id";        // 房间号
NSString *const SIGNALING_EXTRA_KEY_CMD = @"cmd";               // 指令
NSString *const SIGNALING_EXTRA_KEY_CMDINFO = @"cmdInfo";       // 指令信息 （可选）
NSString *const SIGNALING_EXTRA_KEY_MESSAGE = @"message";       // 携带的提示信息，用于UI显示（可选）
NSString *const SIGNALING_EXTRA_KEY_USERIDS = @"userIDs";       // 携带的所有多人通话成员IDs

//  兼容ver4老字段
NSString *const SIGNALING_EXTRA_KEY_CALL_TYPE = @"call_type";
NSString *const SIGNALING_EXTRA_KEY_ROOM_ID = @"room_id";
NSString *const SIGNALING_EXTRA_KEY_LINE_BUSY = @"line_busy";
NSString *const SIGNALING_EXTRA_KEY_CALL_END = @"call_end";
NSString *const SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL = @"switch_to_audio_call";

NSString *const SIGNALING_BUSINESSID = @"av_call";              // 业务场景固定Calling
NSString *const SIGNALING_PLATFORM = @"iOS";                    // 平台固定iOS

NSString *const SIGNALING_CMD_VIDEOCALL = @"videoCall";         // 视频通话
NSString *const SIGNALING_CMD_AUDIOCALL = @"audioCall";         // 语音通话
NSString *const SIGNALING_CMD_HANGUP = @"hangup";               // 挂断电话
NSString *const SIGNALING_CMD_SWITCHTOVOICECALL = @"switchToAudio";        // 视频通话切换为语音通话

NSString *const SIGNALING_MESSAGE_LINEBUSY = @"lineBusy";       // 拒绝忙线

NSString *const SIGNALING_CUSTOM_CALL_ACTION = @"call_action";
NSString *const SIGNALING_CUSTOM_CALLID = @"callid";
NSString *const SIGNALING_CUSTOM_USER = @"user";

// onCallEvent常用类型定义
NSString *const EVENT_CALL_HANG_UP = @"Hangup";
NSString *const EVENT_CALL_LINE_BUSY = @"LineBusy";
NSString *const EVENT_CALL_CNACEL = @"Cancel";
NSString *const EVENT_CALL_TIMEOUT = @"Timeout";
NSString *const EVENT_CALL_NO_RESP = @"NoResp";
NSString *const EVENT_CALL_SUCCEED = @"Succeed";
NSString *const EVENT_CALL_START = @"Start";
NSString *const EVENT_CALL_DECLINE = @"Decline";

NSString *const CALLING_BELL_KEY = @"CallingBell";

// 如果头像为空的默认头像
NSString *const DEFAULT_AVATETR = @"https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png";

+ (int)component {
    return _component;
}

+ (void)setComponent:(int)component {
    _component = component;
}

@end
