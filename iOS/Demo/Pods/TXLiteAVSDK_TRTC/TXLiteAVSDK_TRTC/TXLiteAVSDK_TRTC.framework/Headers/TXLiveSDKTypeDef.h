#ifndef __TX_LIVE_SDK_TYPE_DEF_H__
#define __TX_LIVE_SDK_TYPE_DEF_H__

#include "TXLiveSDKEventDef.h"
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
typedef UIView TXView;
typedef UIImage TXImage;
typedef UIEdgeInsets TXEdgeInsets;
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSView TXView;
typedef NSImage TXImage;
typedef NSEdgeInsets TXEdgeInsets;
#endif



/////////////////////////////////////////////////////////////////////////////////
//
//                    【视频相关枚举值定义】
//                   
/////////////////////////////////////////////////////////////////////////////////

/**
 * 1.1 视频分辨率
 * 
 * 在普通模式下，TXLivePusher 只支持三种固定的分辨率，即：360 × 640、540 × 960 以及 720 × 1280。
 * 
 *【如何横屏推流】
 * 如果希望使用 640 × 360、960 × 540、1280 × 720 这样的横屏分辨率，需要设置 TXLivePushConfig 中的 homeOrientation 属性，
 * 并使用 TXLivePusher 中的 setRenderRotation 接口进行画面旋转。
 *
 *【自定义分辨率】
 * 如果希望使用其他分辨率，可以设置 TXLivePushConfig 中的 customModeType 为 CUSTOM_MODE_VIDEO_CAPTURE，
 * 自己采集 SampleBuffer 送给 TXLivePusher 的 sendVideoSampleBuffer 接口。
 *
 *【建议的分辨率】
 * 手机直播场景下最常用的分辨率为 9:16 的竖屏分辨率 540 × 960。
 * 从清晰的角度，540 × 960 比 360 × 640 要清晰，同时跟 720 × 1280 相当。
 * 从性能的角度，540 × 960 可以避免前置摄像头开启 720 × 1280 的采集分辨率，对于美颜开销很大的场景能节省不少的计算量。
 */
typedef NS_ENUM(NSInteger, TX_Enum_Type_VideoResolution) {

    /// 竖屏分辨率，宽高比为 9:16
    VIDEO_RESOLUTION_TYPE_360_640      = 0,   ///< 建议码率 800kbps
    VIDEO_RESOLUTION_TYPE_540_960      = 1,   ///< 建议码率 1200kbps
    VIDEO_RESOLUTION_TYPE_720_1280     = 2,   ///< 建议码率 1800kbps
    VIDEO_RESOLUTION_TYPE_1080_1920    = 30,  ///< 建议码率 3000kbps


    /// 如下均为内建分辨率，为 SDK 内部使用，不支持通过接口进行设置
    VIDEO_RESOLUTION_TYPE_640_360      = 3,   
    VIDEO_RESOLUTION_TYPE_960_540      = 4,   
    VIDEO_RESOLUTION_TYPE_1280_720     = 5,   
    VIDEO_RESOLUTION_TYPE_1920_1080    = 31,

    VIDEO_RESOLUTION_TYPE_320_480      = 6,
    VIDEO_RESOLUTION_TYPE_180_320      = 7,
    VIDEO_RESOLUTION_TYPE_270_480      = 8,
    VIDEO_RESOLUTION_TYPE_320_180      = 9,
    VIDEO_RESOLUTION_TYPE_480_270      = 10,
    
    VIDEO_RESOLUTION_TYPE_240_320      = 11,
    VIDEO_RESOLUTION_TYPE_360_480      = 12,
    VIDEO_RESOLUTION_TYPE_480_640      = 13,
    VIDEO_RESOLUTION_TYPE_320_240      = 14,
    VIDEO_RESOLUTION_TYPE_480_360      = 15,
    VIDEO_RESOLUTION_TYPE_640_480      = 16,
    
    VIDEO_RESOLUTION_TYPE_480_480      = 17,
    VIDEO_RESOLUTION_TYPE_270_270      = 18,
    VIDEO_RESOLUTION_TYPE_160_160      = 19,
};

/**
 * 1.2 画面质量挡位
 *
 * 如果您希望调整直播的编码参数，建议您直接使用 TXLivePusher 提供的 setVideoQuality 接口。
 * 由于视频编码参数中的分辨率，码率和帧率对最终效果都有着复杂的影响，如果您之前没有相关操作经验，不建议直接修改这些编码参数。
 * 我们在 setVideoQuality 接口中提供了如下几个挡位供您选择：
 *
 *  1. 标清：采用 360 × 640 的分辨率，码率调控范围 300kbps - 800kbps，关闭网络自适应时的码率为 800kbps，适合网络较差的直播环境。
 *  2. 高清：采用 540 × 960 的分辨率，码率调控范围 600kbps - 1500kbps，关闭网络自适应时的码率为 1200kbps，常规手机直播的推荐挡位。
 *  3. 超清：采用 720 × 1280 的分辨率，码率调控范围 600kbps - 1800kbps，关闭网络自适应时的码率为 1800kbps，能耗高，但清晰度较标清提升并不明显。
 *  4. 连麦（大主播）：主播从原来的“推流状态”进入“连麦状态”后，可以通过 setVideoQuality 接口调整自 MAIN_PUBLISHER 挡位。
 *  5. 连麦（小主播）：观众从原来的“播放状态”进入“连麦状态”后，可以通过 setVideoQuality 接口调整自 SUB_PUBLISHER 挡位。
 *  6. 视频通话：该选项后续会逐步废弃，如果您希望实现纯视频通话而非直播功能，推荐使用腾讯云 [TRTC](https://cloud.tencent.com/product/trtc) 服务。
 *
 * 【推荐设置】如果您对整个平台的清晰度要求比较高，推荐使用 setVideoQuality(HIGH_DEFINITION, NO, NO) 的组合。
 *             如果您的主播有很多三四线城市的网络适配要求，推荐使用 setVideoQuality(HIGH_DEFINITION, YES, NO) 的组合。
 *  
 * @note 在开启硬件加速后，您可能会发现诸如 368 × 640 或者 544 × 960 这样的“不完美”分辨率。
 *       这是由于部分硬编码器要求像素能被 16 整除所致，属于正常现象，您可以通过播放端的填充模式解决“小黑边”问题。
 */
typedef NS_ENUM(NSInteger, TX_Enum_Type_VideoQuality) {
    VIDEO_QUALITY_STANDARD_DEFINITION       = 1,    ///< 标清：采用 360 × 640 的分辨率   
    VIDEO_QUALITY_HIGH_DEFINITION           = 2,    ///< 高清：采用 540 × 960 的分辨率  
    VIDEO_QUALITY_SUPER_DEFINITION          = 3,    ///< 超清：采用 720 × 1280 的分辨率
    VIDEO_QUALITY_ULTRA_DEFINITION          = 7,    ///< 蓝光：采用 1080 × 1920 的分辨率
    VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER    = 4,    ///< 连麦场景下的大主播使用
    VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER     = 5,    ///< 连麦场景下的小主播（连麦的观众）使用
    VIDEO_QUALITY_REALTIME_VIDEOCHAT        = 6,    ///< 纯视频通话场景使用（已废弃）
};

/**
 * 1.3 画面旋转方向
 */
typedef NS_ENUM(NSInteger, TX_Enum_Type_HomeOrientation) {
    HOME_ORIENTATION_RIGHT     = 0,    ///< HOME 键在右边，横屏模式      
    HOME_ORIENTATION_DOWN      = 1,    ///< HOME 键在下面，手机直播中最常见的竖屏直播模式                  
    HOME_ORIENTATION_LEFT      = 2,    ///< HOME 键在左边，横屏模式                   
    HOME_ORIENTATION_UP        = 3,    ///< HOME 键在上边，竖屏直播（适合小米 MIX2）                     
};

/**
 * 1.4 画面填充模式
 */
typedef NS_ENUM(NSInteger, TX_Enum_Type_RenderMode) {
    
    RENDER_MODE_FILL_SCREEN    = 0,    ///< 图像铺满屏幕，不留黑边，如果图像宽高比不同于屏幕宽高比，部分画面内容会被裁剪掉。
    RENDER_MODE_FILL_EDGE      = 1,    ///< 图像适应屏幕，保持画面完整，但如果图像宽高比不同于屏幕宽高比，会有黑边的存在。
};

/**
 * 1.5 美颜风格
 */
typedef NS_ENUM(NSInteger, TX_Enum_Type_BeautyStyle) {
    BEAUTY_STYLE_SMOOTH        = 0,    ///< 光滑，磨皮程度较高，更适合秀场直播类场景下使用。
    BEAUTY_STYLE_NATURE        = 1,    ///< 自然，磨皮算法会最大限度保留皮肤细节。
    BEAUTY_STYLE_PITU          = 2,    ///< 由上海优图实验室提供的美颜算法，磨皮效果介于光滑和自然之间，比光滑保留更多皮肤细节，比自然磨皮程度更高。
};

/**
 * 1.6 美颜程度，取值范围1 - 9，该枚举值定义了关闭和最大值。
 */
typedef NS_ENUM(NSInteger, TX_Enum_Type_BeautyFilterDepth) {
    BEAUTY_FILTER_DEPTH_CLOSE   = 0,   ///< 关闭美颜
    BEAUTY_FILTER_DEPTH_MAX     = 9,   ///< 最大美颜强度
};


/**
 * 1.6 网络自适应算法，推荐选项：AUTO_ADJUST_LIVEPUSH_STRATEGY
 */
typedef NS_ENUM(NSInteger, TX_Enum_Type_AutoAdjustStrategy) {
    AUTO_ADJUST_NONE                                 = -1,    ///< 非法数值，用于 SDK 内部做合法性检查

    AUTO_ADJUST_LIVEPUSH_STRATEGY                    =  0,    ///< 最适合直播模式下的流控算法
    AUTO_ADJUST_LIVEPUSH_RESOLUTION_STRATEGY         =  1,    ///< 不推荐：SDK 内部会调整视频分辨率，如果有 H5 分享的需求请勿使用
    AUTO_ADJUST_REALTIME_VIDEOCHAT_STRATEGY          =  5,    ///< 待废弃，请使用腾讯云 TRTC 服务

    AUTO_ADJUST_BITRATE_STRATEGY_1                   =  0,    ///< 已经废弃  
    AUTO_ADJUST_BITRATE_RESOLUTION_STRATEGY_1        =  1,    ///< 已经废弃  
    AUTO_ADJUST_BITRATE_STRATEGY_2                   =  2,    ///< 已经废弃  
    AUTO_ADJUST_BITRATE_RESOLUTION_STRATEGY_2        =  3,    ///< 已经废弃  
    AUTO_ADJUST_REALTIME_BITRATE_STRATEGY            =  4,    ///< 已经废弃
    AUTO_ADJUST_REALTIME_BITRATE_RESOLUTION_STRATEGY =  5,    ///< 已经废弃 
};

/**
 * 1.7 视频帧的数据格式（未压缩前的）
 */
typedef NS_ENUM(NSInteger, TXVideoType) {
    
    VIDEO_TYPE_420SP          = 1,   ///< Android 视频采集格式，PixelFormat.YCbCr_420_SP 17  
    VIDEO_TYPE_420YpCbCr      = 2,   ///< iOS 视频采集格式，kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange  
    VIDEO_TYPE_420P           = 3,   ///< yuv420p格式 
    VIDEO_TYPE_BGRA8888       = 4,   ///< BGRA8888
    VIDEO_TYPE_RGBA8888       = 5,   ///< RGBA8888  
    VIDEO_TYPE_NV12           = 6,   ///< NV12(iOS) 
};

/**
 * 1.8 本地视频预览镜像类型
 *
 * iOS 的本地画面提供三种设置模式
 */
typedef NS_ENUM(NSUInteger, TXLocalVideoMirrorType) {
    LocalVideoMirrorType_Auto       = 0,       ///< 前置摄像头镜像，后置摄像头不镜像
    LocalVideoMirrorType_Enable     = 1,       ///< 前后置摄像头画面均镜像
    LocalVideoMirrorType_Disable    = 2,       ///< 前后置摄像头画面均不镜像
};

/////////////////////////////////////////////////////////////////////////////////
//
//                    【音频相关枚举值定义】
//                   
/////////////////////////////////////////////////////////////////////////////////

/**
 * 2.1 音频采样率
 */
typedef NS_ENUM(NSInteger, TX_Enum_Type_AudioSampleRate) {
    
    AUDIO_SAMPLE_RATE_8000       = 0,     ///< 8k采样率
    AUDIO_SAMPLE_RATE_16000      = 1,     ///< 16k采样率
    AUDIO_SAMPLE_RATE_32000      = 2,     ///< 32k采样率
    AUDIO_SAMPLE_RATE_44100      = 3,     ///< 44.1k采样率
    AUDIO_SAMPLE_RATE_48000      = 4,     ///< 48k采样率
};

/**
 * 2.2 混响类型
 */
typedef NS_ENUM(NSInteger, TXReverbType) {
    REVERB_TYPE_0                = 0,     ///< 关闭混响 
    REVERB_TYPE_1                = 1,     ///< KTV
    REVERB_TYPE_2                = 2,     ///< 小房间 
    REVERB_TYPE_3                = 3,     ///< 大会堂    
    REVERB_TYPE_4                = 4,     ///< 低沉     
    REVERB_TYPE_5                = 5,     ///< 洪亮    
    REVERB_TYPE_6                = 6,     ///< 金属声    
    REVERB_TYPE_7                = 7,     ///< 磁性    
};

/**
 * 2.3 变声选项
 */
typedef NS_ENUM(NSInteger, TXVoiceChangerType) {
    
    VOICECHANGER_TYPE_0          = 0,     ///< 关闭变声 
    VOICECHANGER_TYPE_1          = 1,     ///< 熊孩子 
    VOICECHANGER_TYPE_2          = 2,     ///< 萝莉 
    VOICECHANGER_TYPE_3          = 3,     ///< 大叔 
    VOICECHANGER_TYPE_4          = 4,     ///< 重金属 
    VOICECHANGER_TYPE_5          = 5,     ///< 感冒 
    VOICECHANGER_TYPE_6          = 6,     ///< 外国人 
    VOICECHANGER_TYPE_7          = 7,     ///< 困兽 
    VOICECHANGER_TYPE_8          = 8,     ///< 死肥仔 
    VOICECHANGER_TYPE_9          = 9,     ///< 强电流 
    VOICECHANGER_TYPE_10         = 10,    ///< 重机械 
    VOICECHANGER_TYPE_11         = 11,    ///< 空灵 
};

/**
 * 2.4 声音播放模式（音频路由）
 *
 * 一般手机都有两个扬声器，设置音频路由的作用就是要决定声音从哪个扬声器播放出来。
 * - Speakerphone：扬声器，位于手机底部，声音偏大，适合外放音乐。
 * - Earpiece：听筒，位于手机顶部，声音偏小，适合通话。
 */
typedef NS_ENUM(NSInteger, TXAudioRouteType) {
    AUDIO_ROUTE_SPEAKER          = 0,      ///< 扬声器，位于手机底部，声音偏大，适合外放音乐。 
    AUDIO_ROUTE_RECEIVER         = 1,      ///< 听筒，位于手机顶部，声音偏小，适合通话。
};

/**
 * 2.5 系统音量类型
 *
 * 该枚举值用于控制推流过程中使用何种系统音量类型
 */
typedef NS_ENUM(NSInteger, TXSystemAudioVolumeType) {
    SYSTEM_AUDIO_VOLUME_TYPE_AUTO             = 0,    ///< 默认类型，SDK会自动选择合适的音量类型
    SYSTEM_AUDIO_VOLUME_TYPE_MEDIA            = 1,    ///< 仅使用媒体音量，SDK不再使用通话音量
    SYSTEM_AUDIO_VOLUME_TYPE_VOIP             = 2,    ///< 仅使用通话音量，SDK一直使用通话音量
};

/**
 * 2.6 推流用网络通道（待废弃）
 */
typedef NS_ENUM(NSInteger, TX_Enum_Type_RTMPChannel) {
    
    RTMP_CHANNEL_TYPE_AUTO       = 0,      ///< 自动：推腾讯云使用加速协议，推友商云使用标准 RTMP 协议。
    RTMP_CHANNEL_TYPE_STANDARD   = 1,      ///< 标准 RTMP 协议  
    RTMP_CHANNEL_TYPE_PRIVATE    = 2,      ///< 腾讯云专属加速协议 
};


/**
 * 2.7 屏幕采集源（用于录屏推流）
 */
#if TARGET_OS_OSX
typedef NS_ENUM(NSInteger, TXCaptureVideoInputSource) {
    TXCaptureVideoInputSourceCamera,
    TXCaptureVideoInputSourceScreen,
    TXCaptureVideoInputSourceWindow
};
#endif




/////////////////////////////////////////////////////////////////////////////////
//
//                    【状态通知字段名 onNetStatus】
//                   
/////////////////////////////////////////////////////////////////////////////////

/**
 * TXLivePushListener 和 TXLivePlayListener 的 onNetStatus() 会以 2s 一次的时间间隔，定时通知网络状态和内部指标，
 * 这些数值采用 key-value 的组织格式，其中 key 值的定义如下：
 */

#define NET_STATUS_CPU_USAGE             @"CPU_USAGE"              ///> 进程 CPU 占用率
#define NET_STATUS_CPU_USAGE_D           @"CPU_USAGE_DEVICE"       ///> 系统 CPU 占用率

#define NET_STATUS_VIDEO_WIDTH           @"VIDEO_WIDTH"            ///> 视频分辨率宽度
#define NET_STATUS_VIDEO_HEIGHT          @"VIDEO_HEIGHT"           ///> 视频分辨率高度
#define NET_STATUS_VIDEO_FPS             @"VIDEO_FPS"              ///> 视频帧率：也就是视频编码器每秒生产了多少帧画面。
#define NET_STATUS_VIDEO_GOP             @"VIDEO_GOP"              ///> 关键帧间隔：即每两个关键帧(I帧)间隔时长，单位：秒。
#define NET_STATUS_VIDEO_BITRATE         @"VIDEO_BITRATE"          ///> 视频码率：即视频编码器每秒生产了多少视频数据，单位：kbps。
#define NET_STATUS_AUDIO_BITRATE         @"AUDIO_BITRATE"          ///> 音频码率：即音频编码器每秒生产了多少音频数据，单位：kbps。
#define NET_STATUS_NET_SPEED             @"NET_SPEED"              ///> 传输速度：即每秒钟发送或接收了多少字节的数据。

#define NET_STATUS_VIDEO_CACHE           @"VIDEO_CACHE"            ///> TXLivePusher：主播端堆积的视频帧数；TXLivePlayer：播放端缓冲的视频总时长。
#define NET_STATUS_AUDIO_CACHE           @"AUDIO_CACHE"            ///> TXLivePusher：主播端堆积的音频帧数；TXLivePlayer：播放端缓冲的音频总时长。
#define NET_STATUS_VIDEO_DROP            @"VIDEO_DROP"             ///> TXLivePusher：主播端主动丢弃的视频帧数；TXLivePlayer: N/A。
#define NET_STATUS_AUDIO_DROP            @"AUDIO_DROP"             ///> 暂未使用

#define NET_STATUS_V_DEC_CACHE_SIZE      @"V_DEC_CACHE_SIZE"       ///> TXLivePlayer：播放端解码器中缓存的视频帧数（Android 端硬解码时存在）。
#define NET_STATUS_V_SUM_CACHE_SIZE      @"V_SUM_CACHE_SIZE"       ///> TXLivePlayer：播放端缓冲的总视频帧数，该数值越大，播放延迟越高。
#define NET_STATUS_AV_PLAY_INTERVAL      @"AV_PLAY_INTERVAL"       ///> TXLivePlayer：音画同步错位时间（播放），单位 ms，此数值越小，音画同步越好。
#define NET_STATUS_AV_RECV_INTERVAL      @"AV_RECV_INTERVAL"       ///> TXLivePlayer：音画同步错位时间（网络），单位 ms，此数值越小，音画同步越好。
#define NET_STATUS_AUDIO_CACHE_THRESHOLD @"AUDIO_CACHE_THRESHOLD"  ///> TXLivePlayer：音频缓冲时长阈值，缓冲超过该阈值后，播放器会开始调控延时。
#define NET_STATUS_AUDIO_BLOCK_TIME      @"AUDIO_BLOCK_TIME"       ///> 拉流专用：音频卡顿时长，单位ms
#define NET_STATUS_AUDIO_INFO            @"AUDIO_INFO"             ///> 音频信息：包括采样率信息和声道数信息
#define NET_STATUS_NET_JITTER            @"NET_JITTER"             ///> 网络抖动：数值越大表示抖动越大，网络越不稳定
#define NET_STATUS_QUALITY_LEVEL         @"NET_QUALITY_LEVEL"      ///> 网络质量：0：未定义 1：最好 2：好 3：一般 4：差 5：很差 6：不可用
#define NET_STATUS_SERVER_IP             @"SERVER_IP"              ///> 连接的Server IP地址


/////////////////////////////////////////////////////////////////////////////////
//
//                    【事件通知字段名 onPushEvent onPlayEvent】
//                   
/////////////////////////////////////////////////////////////////////////////////


/**
 * 腾讯云 LiteAVSDK 通过 TXLivePushListener 中的 onPushEvent()，TXLivePlayListener 中的 onPlayEvent() 向您通知内部错误、警告和事件：
 * - 错误：严重且不可恢复的错误，会中断 SDK 的正常逻辑。
 * - 警告：非致命性的提醒和警告，可以不理会。
 * - 事件：SDK 的流程和状态通知，比如开始推流，开始播放，等等。
 *  
 * 这些数值采用 key-value 的组织格式，其中 key 值的定义如下：
 */
#define EVT_MSG                          @"EVT_MSG"                 ///> 事件ID
#define EVT_TIME                         @"EVT_TIME"                ///> 事件发生的UTC毫秒时间戳
#define EVT_UTC_TIME                     @"EVT_UTC_TIME"            ///> 事件发生的UTC毫秒时间戳(兼容性)
#define EVT_BLOCK_DURATION               @"EVT_BLOCK_DURATION"      ///> 卡顿时间（毫秒）
#define EVT_PARAM1                       @"EVT_PARAM1"              ///> 事件参数1
#define EVT_PARAM2                       @"EVT_PARAM2"              ///> 事件参数2
#define EVT_GET_MSG                      @"EVT_GET_MSG"             ///> 消息内容，收到PLAY_EVT_GET_MESSAGE事件时，通过该字段获取消息内容
#define EVT_PLAY_PROGRESS                @"EVT_PLAY_PROGRESS"       ///> 点播：视频播放进度
#define EVT_PLAY_DURATION                @"EVT_PLAY_DURATION"       ///> 点播：视频总时长
#define EVT_PLAYABLE_DURATION            @"PLAYABLE_DURATION"       ///> 点播：视频可播放时长
#define EVT_PLAY_COVER_URL               @"EVT_PLAY_COVER_URL"      ///> 点播：视频封面
#define EVT_PLAY_URL                     @"EVT_PLAY_URL"            ///> 点播：视频播放地址
#define EVT_PLAY_NAME                    @"EVT_PLAY_NAME"           ///> 点播：视频名称
#define EVT_PLAY_DESCRIPTION             @"EVT_PLAY_DESCRIPTION"    ///> 点播：视频简介

#define STREAM_ID                        @"STREAM_ID"

#endif 
