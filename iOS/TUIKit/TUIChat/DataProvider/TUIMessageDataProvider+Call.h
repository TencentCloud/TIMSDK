//
//  TUIMessageDataProvider+Live.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/10.
//

#import "TUIMessageDataProvider.h"
#import "TUIMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageDataProvider (Call)
/**
 * 判断是否为 "音视频通话" 自定义消息
 * Determine whether it is an "audio-video-call" custom message
 */
+ (BOOL)isCallMessage:(V2TIMMessage *)message;

/**
 * 判断是否为 "音视频通话" 自定义消息，如果是，返回音视频通话类型(callType:1 语音通话；2 视频通话)
 * Determine whether it is an "audio and video call" custom message, if so, return the audio and video call type (callType: 1 voice call; 2 video call)
 */
+ (BOOL)isCallMessage:(V2TIMMessage *)message callTye:(NSInteger *)callType;


+ (TUIMessageCellData *)getCallCellData:(V2TIMMessage *)message;

+ (NSString *)getCallMessageDisplayString:(V2TIMMessage *)message;
@end

NS_ASSUME_NONNULL_END
