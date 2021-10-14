/*
 * Module:   TXLivePlayListener @ TXLiteAVSDK
 *
 * Function: 腾讯云直播播放的回调通知
 *
 * Version: <:Version:>
 */

#import <Foundation/Foundation.h>
#import "TXLiveSDKTypeDef.h"

/// @defgroup TXLivePlayListener_ios TXLivePlayListener
/// 腾讯云直播播放的回调通知
/// @{
@protocol TXLivePlayListener <NSObject>

/**
 * 直播事件通知
 * @param EvtID 参见 TXLiveSDKEventDef.h
 * @param param 参见 TXLiveSDKTypeDef.h
 */
- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param;

/**
 * 网络状态通知
 * @param param 参见 TXLiveSDKTypeDef.h
 */
- (void)onNetStatus:(NSDictionary *)param;

@end
/// @}
