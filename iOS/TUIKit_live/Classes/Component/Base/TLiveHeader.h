//
//  TLiveHeader.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by xiangzhang on 2021/5/24.
//

#ifndef TLiveHeader_h
#define TLiveHeader_h

#define AVCall @"av_call"           // 音视频通话
#define AVCall_Version      4       // 音视频通话业务版本
#define GroupLive @"group_live"     // 群直播

// 群直播消息点击通知
#define GroupLiveOnSelectMessage @"kTUINotifyGroupLiveOnSelectMessage"

// 注册聊天界面 Menus 服务，比如视频通话、音频通话、群直播等
#define MenusServiceAction       @"kTUINotifyMenusServiceAction"
#define ServiceIDForVideoCall    @"kTUINotifyGroupLiveOnSelectVideoCall"
#define ServiceIDForAudioCall    @"kTUINotifyGroupLiveOnSelectAudioCall"
#define ServiceIDForGroupLive    @"kTUINotifyGroupLiveOnSelectGroupLive"

//信令业务类型
#define Signal_Business_ID   @"businessID"
#define Signal_Business_Call @"av_call"  //音视频通话信令
#define Signal_Business_Live @"av_live"  //音视频直播信令

//音视频通话信令类型
#define SIGNALING_EXTRA_KEY_VERSION     @"version"
#define SIGNALING_EXTRA_KEY_CALL_TYPE   @"call_type"
#define SIGNALING_EXTRA_KEY_ROOM_ID     @"room_id"
#define SIGNALING_EXTRA_KEY_LINE_BUSY   @"line_busy"
#define SIGNALING_EXTRA_KEY_CALL_END    @"call_end"

// 来自 TUIKit 的通知
#define TUILive_From_UIKit_TIMUserStatusListener @"TUIKitNotification_TIMUserStatusListener"

#endif /* TLiveHeader_h */
