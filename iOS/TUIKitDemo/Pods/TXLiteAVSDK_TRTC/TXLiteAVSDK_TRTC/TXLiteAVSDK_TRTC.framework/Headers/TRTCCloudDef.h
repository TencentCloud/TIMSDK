/*
 * Module:   TRTC 关键类型定义
 * 
 * Function: 分辨率、质量等级等枚举和常量值的定义
 *
 */

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
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

///@defgroup TRTCCloudDef_ios 关键类型定义
///腾讯云视频通话功能的关键类型定义
///@{

/////////////////////////////////////////////////////////////////////////////////
//
//                    【（一）视频相关枚举值定义】
//                   
/////////////////////////////////////////////////////////////////////////////////

/**
 * 1.1 视频分辨率
 *
 * 此处仅定义横屏分辨率，如需使用竖屏分辨率（例如360 × 640），需要同时指定 TRTCVideoResolutionMode 为 Portrait。
 */
typedef NS_ENUM(NSInteger, TRTCVideoResolution) {
    // 宽高比1:1
    TRTCVideoResolution_120_120     = 1,    ///< [C] 建议码率 VideoCall:80kbps   LIVE:120kbps
    TRTCVideoResolution_160_160     = 3,    ///< [C] 建议码率 VideoCall:100kbps  LIVE:150kbps
    TRTCVideoResolution_270_270     = 5,    ///< [C] 建议码率 VideoCall:200kbps  LIVE:120kbps
    TRTCVideoResolution_480_480     = 7,    ///< [C] 建议码率 VideoCall:350kbps  LIVE:120kbps
    
    // 宽高比4:3
    TRTCVideoResolution_160_120     = 50,   ///< [C] 建议码率 VideoCall:100kbps  LIVE:150kbps
    TRTCVideoResolution_240_180     = 52,   ///< [C] 建议码率 VideoCall:150kbps  LIVE:225kbps
    TRTCVideoResolution_280_210     = 54,   ///< [C] 建议码率 VideoCall:200kbps  LIVE:300kbps
    TRTCVideoResolution_320_240     = 56,   ///< [C] 建议码率 VideoCall:250kbps  LIVE:375kbps
    TRTCVideoResolution_400_300     = 58,   ///< [C] 建议码率 VideoCall:300kbps  LIVE:450kbps
    TRTCVideoResolution_480_360     = 60,   ///< [C] 建议码率 VideoCall:400kbps  LIVE:600kbps
    TRTCVideoResolution_640_480     = 62,   ///< [C] 建议码率 VideoCall:600kbps  LIVE:900kbps
    TRTCVideoResolution_960_720     = 64,   ///< [C] 建议码率 VideoCall:1000kbps LIVE:1500kbps
    
    // 宽高比16:9
    TRTCVideoResolution_160_90      = 100,  ///< [C] 建议码率 VideoCall:150kbps  LIVE:250kbps
    TRTCVideoResolution_256_144     = 102,  ///< [C] 建议码率 VideoCall:200kbps  LIVE:300kbps
    TRTCVideoResolution_320_180     = 104,  ///< [C] 建议码率 VideoCall:250kbps  LIVE:400kbps
    TRTCVideoResolution_480_270     = 106,  ///< [C] 建议码率 VideoCall:350kbps  LIVE:550kbps
    TRTCVideoResolution_640_360     = 108,  ///< [C] 建议码率 VideoCall:550kbps  LIVE:900kbps
    TRTCVideoResolution_960_540     = 110,  ///< [C] 建议码率 VideoCall:850kbps  LIVE:1300kbps
    TRTCVideoResolution_1280_720    = 112,  ///< [C] 建议码率 VideoCall:1200kbps LIVE:1800kbps
    TRTCVideoResolution_1920_1080   = 114,  ///< [S] 建议码率 VideoCall:2000kbps LIVE:3000kbps
};

/**
 * 1.2 视频宽高比模式
 *
 * - 横屏分辨率：TRTCVideoResolution_640_360 + TRTCVideoResolutionModeLandscape = 640 × 360
 * - 竖屏分辨率：TRTCVideoResolution_640_360 + TRTCVideoResolutionModePortrait  = 360 × 640
 */
typedef NS_ENUM(NSInteger, TRTCVideoResolutionMode) {
	TRTCVideoResolutionModeLandscape = 0,  ///< 横屏分辨率
    TRTCVideoResolutionModePortrait  = 1,  ///< 竖屏分辨率
};


/**
 * 1.3 视频流类型
 *
 * TRTC 内部有三种不同的音视频流，分别是：
 * - 主画面：最常用的一条线路，一般用来传输摄像头的视频数据。
 * - 小画面：跟主画面的内容相同，但是分辨率和码率更低。
 * - 辅流画面：一般用于屏幕分享，以及远程播片（例如老师放一段视频给学生）。
 *
 * @note - 如果主播的上行网络和性能比较好，则可以同时送出大小两路画面。
 * @note - SDK 不支持单独开启小画面，小画面必须依附于主画面而存在。
 */

typedef NS_ENUM(NSInteger, TRTCVideoStreamType) {
    TRTCVideoStreamTypeBig   = 0,     ///< 主画面视频流
    TRTCVideoStreamTypeSmall = 1,     ///< 小画面视频流
    TRTCVideoStreamTypeSub   = 2,     ///< 辅流（屏幕分享）

};

/**
 * 1.4 画质级别
 *
 * TRTC SDK 对画质定义了六种不同的级别，Excellent 表示最好，Down 表示不可用。
 */
typedef NS_ENUM(NSInteger, TRTCQuality) {
    TRTCQuality_Unknown     = 0,     ///< 未定义
    TRTCQuality_Excellent   = 1,     ///< 最好
    TRTCQuality_Good        = 2,     ///< 好
    TRTCQuality_Poor        = 3,     ///< 一般
    TRTCQuality_Bad         = 4,     ///< 差
    TRTCQuality_Vbad        = 5,     ///< 很差
    TRTCQuality_Down        = 6,     ///< 不可用
};

/**
 * 1.5 视频画面填充模式
 *
 * 如果画面的显示分辨率不等于画面的原始分辨率，就需要您设置画面的填充模式:
 * - TRTCVideoFillMode_Fill，图像铺满屏幕，超出显示视窗的视频部分将被裁剪，画面显示可能不完整。
 * - TRTCVideoFillMode_Fit，图像长边填满屏幕，短边区域会被填充黑色，画面的内容完整。
 */
typedef NS_ENUM(NSInteger, TRTCVideoFillMode) {
    TRTCVideoFillMode_Fill   = 0,  ///< 图像铺满屏幕，超出显示视窗的视频部分将被裁剪
    TRTCVideoFillMode_Fit    = 1,  ///< 图像长边填满屏幕，短边区域会被填充黑色
};

/**
 * 1.6 视频画面旋转方向
 *
 * TRTC SDK 提供了对本地和远程画面的旋转角度设置 API，下列的旋转角度都是指顺时针方向的。
 */
typedef NS_ENUM(NSInteger, TRTCVideoRotation) {
    TRTCVideoRotation_0      = 0,  ///< 不旋转
    TRTCVideoRotation_90     = 1,  ///< 顺时针旋转90度
    TRTCVideoRotation_180    = 2,  ///< 顺时针旋转180度
    TRTCVideoRotation_270    = 3,  ///< 顺时针旋转270度
};

/**
 * 1.7 美颜（磨皮）算法
 *
 * TRTC SDK 内置多种不同的磨皮算法，您可以选择最适合您产品定位的方案。
 */
typedef NS_ENUM(NSInteger, TRTCBeautyStyle) {
    TRTCBeautyStyleSmooth    = 0,  ///< 光滑，适用于美女秀场，效果比较明显。
    TRTCBeautyStyleNature    = 1,  ///< 自然，磨皮算法更多地保留了面部细节，主观感受上会更加自然。
};

/**
 * 1.8 视频像素格式
 *
 * TRTC SDK 提供针对视频的自定义采集和自定义渲染功能，在自定义采集功能中，您可以用下列枚举值描述您采集的视频像素格式。
 * 在自定义渲染功能中，您可以指定您期望 SDK 回调的视频像素格式。
 */
typedef NS_ENUM(NSInteger, TRTCVideoPixelFormat) {
    TRTCVideoPixelFormat_Unknown    = 0,    ///< 未知
    TRTCVideoPixelFormat_I420       = 1,    ///< YUV420P I420
    TRTCVideoPixelFormat_NV12       = 5,    ///< YUV420SP NV12
    TRTCVideoPixelFormat_32BGRA     = 6,    ///< BGRA8888
};


/**
 * 1.9 视频数据包装格式
 *
 * 在自定义采集和自定义渲染功能，您需要用到下列枚举值来指定您希望以什么类型的容器来包装视频数据。
 * - PixelBuffer：直接使用效率最高，iOS 系统提供了众多 API 获取或处理 PixelBuffer。
 * - NSData：仅用于自定义渲染，SDK 帮您做了一次 PixelBuffer 到 NSData 的内存拷贝工作，会有一定的性能消耗。
 */
typedef NS_ENUM(NSInteger, TRTCVideoBufferType) {
    TRTCVideoBufferType_Unknown         = 0,    ///< 未知
    TRTCVideoBufferType_PixelBuffer     = 1,    ///< 直接使用效率最高，iOS 系统提供了众多 API 获取或处理 PixelBuffer。
    TRTCVideoBufferType_NSData          = 2,    ///< 仅用于自定义渲染，SDK 帮您做了一次 PixelBuffer 到 NSData 的内存拷贝工作，会有一定的性能消耗。
};

/**
 * 1.10 本地视频预览镜像类型
 *
 * iOS 的本地画面提供下列设置模式
 */
typedef NS_ENUM(NSUInteger, TRTCLocalVideoMirrorType) {
    TRTCLocalVideoMirrorType_Auto       = 0,       ///< 前置摄像头镜像，后置摄像头不镜像
    TRTCLocalVideoMirrorType_Enable     = 1,       ///< 前后置摄像头画面均镜像
    TRTCLocalVideoMirrorType_Disable    = 2,       ///< 前后置摄像头画面均不镜像
};

/////////////////////////////////////////////////////////////////////////////////
//
//                    【（二）网络相关枚举值定义】
//                   
/////////////////////////////////////////////////////////////////////////////////

/**
 * 2.1 应用场景
 *
 * TRTC 可用于视频会议和在线直播等多种应用场景，针对不同的应用场景，TRTC SDK 的内部会进行不同的优化配置：
 * - TRTCAppSceneVideoCall    ：视频通话场景，适合[1对1视频通话]、[300人视频会议]、[在线问诊]、[视频聊天]、[远程面试]等。              
 * - TRTCAppSceneLIVE         ：视频互动直播，适合[视频低延时直播]、[十万人互动课堂]、[视频直播 PK]、[视频相亲房]、[互动课堂]、[远程培训]、[超大型会议]等。
 * - TRTCAppSceneAudioCall    ：语音通话场景，适合[1对1语音通话]、[300人语音会议]、[语音聊天]、[语音会议]、[在线狼人杀]等。
 * - TRTCAppSceneVoiceChatRoom：语音互动直播，适合：[语音低延时直播]、[语音直播连麦]、[语聊房]、[K 歌房]、[FM 电台]等。
 */
typedef NS_ENUM(NSInteger, TRTCAppScene) {
	/// 视频通话场景，支持720P、1080P高清画质，单个房间最多支持300人同时在线，最高支持50人同时发言。<br>
	/// 适合：[1对1视频通话]、[300人视频会议]、[在线问诊]、[视频聊天]、[远程面试]等。
    TRTCAppSceneVideoCall      = 0,  
	
	/// 视频互动直播，支持平滑上下麦，切换过程无需等待，主播延时小于300ms；支持十万级别观众同时播放，播放延时低至1000ms。<br>
	/// 适合：[视频低延时直播]、[十万人互动课堂]、[视频直播 PK]、[视频相亲房]、[互动课堂]、[远程培训]、[超大型会议]等。<br>
	/// 注意：此场景下，您必须通过 TRTCParams 中的 role 字段指定当前用户的角色。
    TRTCAppSceneLIVE           = 1,  
	
	/// 语音通话场景，支持 48kHz，支持双声道。单个房间最多支持300人同时在线，最高支持50人同时发言。<br>
	/// 适合：[1对1语音通话]、[300人语音会议]、[语音聊天]、[语音会议]、[在线狼人杀]等。
    TRTCAppSceneAudioCall      = 2,  
	
	/// 语音互动直播，支持平滑上下麦，切换过程无需等待，主播延时小于300ms；支持十万级别观众同时播放，播放延时低至1000ms。<br>
    /// 适合：[语音低延时直播]、[语音直播连麦]、[语聊房]、[K 歌房]、[FM 电台]等。<br>
	/// 注意：此场景下，您必须通过 TRTCParams 中的 role 字段指定当前用户的角色。
    TRTCAppSceneVoiceChatRoom  = 3,  
};

/**
 * 2.2 角色，仅适用于直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）
 *
 * 在直播场景中，多数用户仅为观众，个别用户是主播，这种角色区分有利于 TRTC 进行更好的定向优化。
 *
 * - Anchor：主播，可以上行视频和音频，一个房间里最多支持50个主播同时上行音视频。
 * - Audience：观众，只能观看，不能上行视频和音频，一个房间里的观众人数没有上限。
 */
typedef NS_ENUM(NSInteger, TRTCRoleType) {
    TRTCRoleAnchor            =  20,   ///< 主播
    TRTCRoleAudience          =  21,   ///< 观众
};

/**
 * 2.3 流控模式
 *
 * TRTC SDK 内部需要时刻根据网络情况调整内部的编解码器和网络模块，以便能够对网络的变化做出反应。
 * 为了支持快速算法升级，SDK 内部设置了两种不同的流控模式：
 * - ModeServer：云端控制，默认模式，推荐选择。
 * - ModeClient：本地控制，用于 SDK 开发内部调试，客户请勿使用。
 *
 * @note 推荐您使用云端控制，这样每当我们升级 Qos 算法时，您无需升级 SDK 即可体验更好的效果。
 */
typedef NS_ENUM(NSInteger, TRTCQosControlMode)
{
    TRTCQosControlModeClient,        ///< 客户端控制（用于 SDK 开发内部调试，客户请勿使用）
    TRTCQosControlModeServer,        ///< 云端控制 （默认）
};

/**
 * 2.4 画质偏好
 *
 * 指当 TRTC SDK 在遇到弱网络环境时，您期望“保清晰”或“保流畅”，两种模式均会优先保障声音数据的传输。
 *
 * - Smooth：弱网下优先流畅性，当用户网络较差的时候画面也会比较模糊。
 * - Clear：默认值，弱网下优先清晰度，当用户网络较差的时候会出现卡顿，但画面清晰度不会大幅缩水。
 */
typedef NS_ENUM(NSInteger, TRTCVideoQosPreference)
{
    TRTCVideoQosPreferenceSmooth = 1,      ///< 弱网下保流畅
    TRTCVideoQosPreferenceClear  = 2,      ///< 弱网下保清晰，默认值
};

/////////////////////////////////////////////////////////////////////////////////
//
//                    【（三）声音相关枚举值定义】
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 3.1 音频采样率
 *
 * 音频采样率用来衡量声音的保真程度，采样率越高保真程度越好，如果您的应用场景有音乐的存在，推荐使用 TRTCAudioSampleRate48000。
 */
typedef NS_ENUM(NSInteger, TRTCAudioSampleRate) {
    TRTCAudioSampleRate16000   = 16000,      ///< 16k采样率
    TRTCAudioSampleRate32000   = 32000,      ///< 32采样率
    TRTCAudioSampleRate44100   = 44100,      ///< 44.1k采样率
    TRTCAudioSampleRate48000   = 48000,      ///< 48k采样率
};

/**
 * 3.2 声音音质
 *
 * 音频音质用来衡量声音的保真程度，TRTCAudioQualitySpeech 适用于通话场景，TRTCAudioQualityMusic 适用于高音质音乐场景。
 */
typedef NS_ENUM(NSInteger, TRTCAudioQuality) {
    /// 流畅音质：采样率：16k；单声道；音频裸码率：16kbps；适合语音通话为主的场景，比如在线会议，语音通话。
    TRTCAudioQualitySpeech = 1,
    /// 默认音质：采样率：48k；单声道；音频裸码率：50kbps；SDK 默认的音频质量，如无特殊需求推荐选择之。
    TRTCAudioQualityDefault = 2,
    /// 高音质：采样率：48k；双声道 + 全频带；音频裸码率：128kbps；适合需要高保真传输音乐的场景，比如K歌、音乐直播等。
    TRTCAudioQualityMusic = 3,
};

/**
 * 3.3 声音播放模式（音频路由）
 *
 * 微信和手机 QQ 里的视频通话功能，都有一个免提模式，开启后就不用把手机贴在耳朵上，这个功能就是基于音频路由实现的。
 * 一般手机都有两个扬声器，设置音频路由的作用就是要决定声音从哪个扬声器播放出来：
 * - Speakerphone：扬声器，位于手机底部，声音偏大，适合外放音乐。
 * - Earpiece：听筒，位于手机顶部，声音偏小，适合通话。
 */
typedef NS_ENUM(NSInteger, TRTCAudioRoute) {
    TRTCAudioModeSpeakerphone  =   0,   ///< 扬声器
    TRTCAudioModeEarpiece      =   1,   ///< 听筒
};

/**
 * 3.4 声音混响模式
 *
 * 该枚举值应用于直播场景中的混响模式，主要用于秀场直播中。
 */
typedef NS_ENUM(NSInteger, TRTCReverbType) {
    TRTCReverbType_0         = 0,    ///< 关闭混响
    TRTCReverbType_1         = 1,    ///< KTV
    TRTCReverbType_2         = 2,    ///< 小房间
    TRTCReverbType_3         = 3,    ///< 大会堂
    TRTCReverbType_4         = 4,    ///< 低沉
    TRTCReverbType_5         = 5,    ///< 洪亮
    TRTCReverbType_6         = 6,    ///< 金属声
    TRTCReverbType_7         = 7,    ///< 磁性
};

/**
 * 3.5 变声模式
 *
 * 该枚举值应用于直播场景中的变声模式，主要用于秀场直播中。
 */
typedef NS_ENUM(NSInteger, TRTCVoiceChangerType) {
    TRTCVoiceChangerType_0   = 0,    ///< 关闭变声
    TRTCVoiceChangerType_1   = 1,    ///< 熊孩子
    TRTCVoiceChangerType_2   = 2,    ///< 萝莉
    TRTCVoiceChangerType_3   = 3,    ///< 大叔
    TRTCVoiceChangerType_4   = 4,    ///< 重金属
    TRTCVoiceChangerType_5   = 5,    ///< 感冒
    TRTCVoiceChangerType_6   = 6,    ///< 外国人
    TRTCVoiceChangerType_7   = 7,    ///< 困兽
    TRTCVoiceChangerType_8   = 8,    ///< 死肥仔
    TRTCVoiceChangerType_9   = 9,    ///< 强电流
    TRTCVoiceChangerType_10  = 10,   ///< 重机械
    TRTCVoiceChangerType_11  = 11,   ///< 空灵
};

/**
 * 3.6 系统音量类型
 *
 * 智能手机一般具备两种系统音量类型，即通话音量类型和媒体音量类型。
 * - 通话音量：手机专门为通话场景设计的音量类型，使用手机自带的回声抵消功能，音质相比媒体音量类型较差，
 *             无法通过音量按键将音量调成零，但是支持蓝牙耳机上的麦克风。
 *   
 * - 媒体音量：手机专门为音乐场景设计的音量类型，音质相比于通话音量类型要好，通过通过音量按键可以将音量调成零。
 *             使用媒体音量类型时，如果要开启回声抵消（AEC）功能，SDK 会开启内置的声学处理算法对声音进行二次处理。
 *             在媒体音量模式下，蓝牙耳机无法使用自带的麦克风采集声音，只能使用手机上的麦克风进行声音采集。
 *
 * SDK 目前提供了三种系统音量类型的控制模式，分别为：
 * - Auto：“麦上通话，麦下媒体”，即主播上麦时使用通话音量，观众不上麦则使用媒体音量，适合在线直播场景。
 *         如果您在 enterRoom 时选择的场景为 TRTCAppSceneLIVE 或 TRTCAppSceneVoiceChatRoom，SDK 会自动选择该模式。
 *
 * - VOIP：全程使用通话音量，适合多人会议场景。
 *         如果您在 enterRoom 时选择的场景为 TRTCAppSceneVideoCall 或 TRTCAppSceneAudioCall，SDK 会自动选择该模式。
 *
 * - Media：通话全程使用媒体音量，不常用，适合个别有特殊需求（如主播外接声卡）的应用场景。
 *
 */
typedef NS_ENUM(NSInteger, TRTCSystemVolumeType) {
	/// “麦上通话，麦下媒体”，即主播上麦时使用通话音量，观众不上麦则使用媒体音量，适合在线直播场景。<br>
	/// 如果您在 enterRoom 时选择的场景为 TRTCAppSceneLIVE 或 TRTCAppSceneVoiceChatRoom，SDK 会自动选择该模式。
    TRTCSystemVolumeTypeAuto             = 0,   
	
	/// 通话全程使用媒体音量，不常用，适合个别有特殊需求（如主播外接声卡）的应用场景。
    TRTCSystemVolumeTypeMedia            = 1,    
	
	/// 全程使用通话音量，适合多人会议场景。<br>
	/// 如果您在 enterRoom 时选择的场景为 TRTCAppSceneVideoCall 或 TRTCAppSceneAudioCall 会自动选择该模式。
	TRTCSystemVolumeTypeVOIP             = 2,    
};

#pragma mark -

/////////////////////////////////////////////////////////////////////////////////
//
//                    【（四）更多枚举值定义】
//                   
/////////////////////////////////////////////////////////////////////////////////

/**
 * 4.1 Log 级别
 *
 * 不同的日志等级定义了不同的详实程度和日志数量，推荐一般情况下将日志等级设置为：TRTCLogLevelInfo。
 */
typedef NS_ENUM(NSInteger, TRTCLogLevel) {
    TRTCLogLevelVerbose = 0,   ///< 输出所有级别的 Log
    TRTCLogLevelDebug = 1,     ///< 输出 DEBUG，INFO，WARNING，ERROR 和 FATAL 级别的 Log
    TRTCLogLevelInfo = 2,      ///< 输出 INFO，WARNING，ERROR 和 FATAL 级别的 Log
    TRTCLogLevelWarn = 3,      ///< 只输出WARNING，ERROR 和 FATAL 级别的 Log
    TRTCLogLevelError = 4,     ///< 只输出ERROR 和 FATAL 级别的 Log
    TRTCLogLevelFatal = 5,     ///< 只输出 FATAL 级别的 Log
    TRTCLogLevelNone  = 6,     ///< 不输出任何 SDK Log
};

/**
 * 4.2 重力感应开关
 *
 * 此配置仅适用于 iOS 和 iPad 等移动设备：
 * - Disable：Mac 平台的默认值，视频上行的画面（也就是房间里的其它用户看到的当前用户的画面）不会跟随重力感应方向而自动调整。
 * - UIAutoLayout：iPhone 和 iPad 平台的默认值，视频上行的画面（也就是房间里的其它用户看到的当前用户的画面）会跟随当前界面的状态栏方向而自动调整。
 * - UIFixLayout：待废弃，效果等同于 UIAutoLayout。
 */
typedef NS_ENUM(NSInteger, TRTCGSensorMode) {
    TRTCGSensorMode_Disable         = 0,  ///< 关闭重力感应，Mac 平台的默认值。
    TRTCGSensorMode_UIAutoLayout    = 1,  ///< 开启重力感应，iPhone 和 iPad 平台的默认值。
    TRTCGSensorMode_UIFixLayout     = 2   ///< 待废弃，效果等同于 UIAutoLayout。
};

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#pragma mark -
/**
 * 4.3 设备类型（仅 Mac）
 *
 * 在 Mac 上，每一种类型的设备都可能有多个，TRTC SDK 的 Mac 版本提供了一系列函数用来操作这些设备。
 */
typedef NS_ENUM(NSInteger, TRTCMediaDeviceType) {
    TRTCMediaDeviceTypeUnknown      =   -1,  ///< 未定义
	
    TRTCMediaDeviceTypeAudioInput   =    0,  ///< 麦克风
    TRTCMediaDeviceTypeAudioOutput  =    1,  ///< 扬声器或听筒
    TRTCMediaDeviceTypeVideoCamera  =    2,  ///< 摄像头

    TRTCMediaDeviceTypeVideoWindow  =    3,  ///< 某个窗口（用于屏幕分享）
    TRTCMediaDeviceTypeVideoScreen  =    4,  ///< 整个屏幕（用于屏幕分享）
};
#endif

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#pragma mark -

/**
 * 4.4 屏幕分享目标类型（仅 Mac）
 *
 * 该枚举值主要用于 SDK 区分屏幕分享的目标（某一个窗口或整个屏幕）。
 */
typedef NS_ENUM(NSInteger, TRTCScreenCaptureSourceType) {
    TRTCScreenCaptureSourceTypeUnknown      =   -1,    ///< 未定义
    TRTCScreenCaptureSourceTypeWindow       =    0,    ///< 该分享目标是某一个Mac窗口
    TRTCScreenCaptureSourceTypeScreen       =    1,    ///< 该分享目标是整个Mac桌面
};
#endif

#pragma mark -

/**
 * 4.5 混流参数配置模式
 *
 */
typedef NS_ENUM(NSInteger, TRTCTranscodingConfigMode) {
    /// 非法值
    TRTCTranscodingConfigMode_Unknown                = 0,

    /// 全手动模式，灵活性最高，可以自由组合出各种混流方案，但易用性最差。
    /// 此模式下，您需要填写 TRTCTranscodingConfig 中的所有参数，并需要监听 TRTCCloudDelegate 中的 onUserVideoAvailable() 和 onUserAudioAvailable() 回调，
    /// 以便根据当前房间中各个上麦用户的音视频状态不断地调整 mixUsers 参数，否则会导致混流失败。
    TRTCTranscodingConfigMode_Manual                 = 1,
    
    /// 纯音频模式，适用于语音通话（AudioCall）和语音聊天室（VoiceChatRoom）等纯音频场景。
    /// 只需要在进房后通过 setMixTranscodingConfig() 接口设置一次，之后 SDK 就会自动把房间内所有上麦用户的声音混流到当前用户的直播流上。
    /// 此模式下，您无需设置 TRTCTranscodingConfig 中的 mixUsers 参数，只需设置 audioSampleRate、audioBitrate 和 audioChannels 等参数。
    TRTCTranscodingConfigMode_Template_PureAudio     = 2,

    /// 预排版模式，通过占位符提前对各路画面进行排布
    /// 此模式下，您依然需要设置 mixUsers 参数，但可以将 userId 设置为占位符，可选的占位符有：
    /// - "$PLACE_HOLDER_REMOTE$"     :  指代远程用户的画面，可以设置多个。
    /// - "$PLACE_HOLDER_LOCAL_MAIN$" ： 指代本地摄像头画面，只允许设置一个。
    /// - "$PLACE_HOLDER_LOCAL_SUB$"  :  指代本地屏幕分享画面，只允许设置一个。
    /// 但是您可以不需要监听 TRTCCloudDelegate 中的 onUserVideoAvailable() 和 onUserAudioAvailable() 回调进行实时调整，
    /// 只需要在进房成功后调用一次 setMixTranscodingConfig() 即可，之后 SDK 会自动将真实的 userId 补位到您设置的占位符上。
    TRTCTranscodingConfigMode_Template_PresetLayout  = 3,
    
    /// 屏幕分享模式，适用于在线教育场景等以屏幕分享为主的应用场景，仅支持 Windows 和 Mac 两个平台的 SDK。
    /// SDK 会先根据您（通过 videoWidth 和 videoHeight 参数）设置的目标分辨率构建一张画布，
    /// 当老师未开启屏幕分享时，SDK 会将摄像头画面等比例拉伸绘制到该画布上；当老师开启屏幕分享之后，SDK 会将屏幕分享画面绘制到同样的画布上。
    /// 这样操作的目的是为了确保混流模块的输出分辨率一致，避免课程回放和网页观看的花屏问题（网页播放器不支持可变分辨率）。
    /// 同时，连麦学生的声音会被默认混合到老师的音视频流中。
    ///
    /// 由于教学模式下的视频内容以屏幕分享为主，因此同时传输摄像头画面和屏幕分享画面是非常浪费带宽的。
    /// 推荐的做法是直接将摄像头画面通过 setLocalVideoRenderCallback 接口自定义绘制到当前屏幕上。
    /// 在该模式下，您无需设置 TRTCTranscodingConfig 中的 mixUsers 参数，SDK 不会混合学生的画面，以免干扰屏幕分享的效果。
    ///
    /// 您可以将 TRTCTranscodingConfig 中的 width × height 设为 0px × 0px，SDK 会自动根据用户当前屏幕的宽高比计算出一个合适的分辨率：
    /// - 如果老师当前屏幕宽度 <= 1920px，SDK 会使用老师当前屏幕的实际分辨率。
    /// - 如果老师当前屏幕宽度 > 1920px，SDK 会根据当前屏幕宽高比，选择 1920x1080(16:9)、1920x1200(16:10)、1920x1440(4:3) 三种分辨率中的一种。
    TRTCTranscodingConfigMode_Template_ScreenSharing = 4,
};


/////////////////////////////////////////////////////////////////////////////////
//
//                      【（五）TRTC 核心类型定义】
//                   
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -

/** 
 * 5.1 进房相关参数
 *
 * 只有该参数填写正确，才能顺利调用 enterRoom 进入 roomId 所指定的音视频房间。
 */
@interface TRTCParams : NSObject

///【字段含义】应用标识 [必填]，腾讯云基于 sdkAppId 完成计费统计。
///【推荐取值】在 [实时音视频控制台](https://console.cloud.tencent.com/rav/) 创建应用后可以在账号信息页面中得到该 ID
@property (nonatomic, assign) UInt32   sdkAppId;

///【字段含义】用户标识 [必填]，当前用户的 userId，相当于登录用户名。
///【推荐取值】限制长度为32字节，只允许包含大小写英文字母（a-zA-Z）、数字（0-9）及下划线和连词符。
@property (nonatomic, copy, nonnull) NSString* userId;

///【字段含义】用户签名 [必填]，当前 userId 对应的验证签名，相当于登录密码。
///【推荐取值】具体计算方法请参见 [如何计算UserSig](https://cloud.tencent.com/document/product/647/17275)。
@property (nonatomic, copy, nonnull) NSString* userSig;

///【字段含义】房间号码 [必填]，在同一个房间内的用户可以看到彼此并进行视频通话。
///【推荐取值】取值范围：1 - 4294967294。
@property (nonatomic, assign) UInt32 roomId;

///【字段含义】直播场景下的角色，仅适用于直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom），通话场景下指定无效。
///【推荐取值】默认值：主播（TRTCRoleAnchor）
@property (nonatomic, assign) TRTCRoleType role;

///【字段含义】绑定腾讯云直播 CDN 流 ID[非必填]，设置之后，您就可以在腾讯云直播 CDN 上通过标准直播方案（FLV或HLS）播放该用户的音视频流。
///【推荐取值】限制长度为64字节，可以不填写，一种推荐的方案是使用 “sdkappid_roomid_userid_main” 作为 streamid，这样比较好辨认且不会在您的多个应用中发生冲突。
///【特殊说明】要使用腾讯云直播 CDN，您需要先在[控制台](https://console.cloud.tencent.com/trtc/) 中的功能配置页开启“启动自动旁路直播”开关。
///【参考文档】[CDN 旁路直播](https://cloud.tencent.com/document/product/647/16826)。
@property (nonatomic, copy, nullable) NSString* streamId;

///【字段含义】云端录制开关，用于指定是否要在云端将该用户的音视频流录制成指定格式的文件。
/// 方案一：手动录制
///   - 需要在“[控制台](https://console.cloud.tencent.com/trtc) => 应用管理 => 云端录制配置”中开启云端录制。
///   - 设置“录制形式”为“手动录制”。
///   - 设置手动录制后，在一个 TRTC 房间中只有设置了 userDefineRecordId 参数的用户才会在云端录制出视频文件，不指定该参数的用户不会产生录制行为。
///   - 文件会以 “userDefineRecordId_起始时间_结束时间” 的格式命名。
///
/// 方案二：自动录制
///   - 需要在“[控制台](https://console.cloud.tencent.com/trtc) => 应用管理 => 云端录制配置”中开启云端录制。
///   - 设置“录制形式”为“自动录制”。
///   - 设置自动录制后，在一个 TRTC 房间中的任何一个有音视频上行的用户，均会在云端录制出视频文件。
///   - 文件会以 “userDefineRecordId_起始时间_结束时间” 的格式命名，如果不指定 userDefineRecordId，则文件会以 streamid 命名。
///
///【推荐取值】限制长度为64字节，只允许包含大小写英文字母（a-zA-Z）、数字（0-9）及下划线和连词符。
///【参考文档】[云端录制](https://cloud.tencent.com/document/product/647/16823)。
@property (nonatomic, copy, nullable) NSString* userDefineRecordId;

///【字段含义】房间签名 [非必填]，当您希望某个房间只能让特定的 userId 进入时，需要使用 privateMapKey 进行权限保护。
///【推荐取值】仅建议有高级别安全需求的客户使用，更多详情请参见 [进房权限保护](https://cloud.tencent.com/document/product/647/32240)。
@property (nonatomic, copy, nullable) NSString* privateMapKey;

///【字段含义】业务数据 [非必填]，部分高级特性才需要用到此字段。
///【推荐取值】不建议使用
@property (nonatomic, copy, nullable) NSString* bussInfo;
@end

#pragma mark -

/** 
 * 5.2 视频编码参数
 *
 * 该设置决定远端用户看到的画面质量（同时也是云端录制出的视频文件的画面质量）。
 */
@interface TRTCVideoEncParam : NSObject

///【字段含义】视频分辨率
///【推荐取值】 
///     - 视频通话建议选择360 × 640及以下分辨率，resMode 选择 Portrait。
///     - 手机直播建议选择540 × 960，resMode 选择 Portrait。
///     - Window 和 iMac 建议选择640 × 360 及以上分辨率，resMode 选择 Landscape。
///【特别说明】 TRTCVideoResolution 默认只有横屏模式的分辨率，例如640 × 360。
///           如需使用竖屏分辨率，请指定 resMode 为 Portrait，例如640 × 360结合 Portrait 则为360 × 640。
@property (nonatomic, assign) TRTCVideoResolution videoResolution;

///【字段含义】分辨率模式（横屏分辨率 - 竖屏分辨率）
///【推荐取值】手机直播建议选择 Portrait，Window 和 Mac 建议选择 Landscape。
///【特别说明】如果 videoResolution 指定分辨率 640 × 360，resMode 指定模式为 Portrait，则最终编码出的分辨率为360 × 640。
@property (nonatomic, assign) TRTCVideoResolutionMode resMode;

///【字段含义】视频采集帧率
///【推荐取值】15fps或20fps，5fps以下，卡顿感明显。10fps以下，会有轻微卡顿感。20fps以上，则过于浪费（电影的帧率为24fps）。
///【特别说明】很多 Android 手机的前置摄像头并不支持15fps以上的采集帧率，部分过于突出美颜功能的 Android 手机前置摄像头的采集帧率可能低于10fps。
@property (nonatomic, assign) int videoFps;

///【字段含义】目标视频码率，SDK 会按照目标码率进行编码，只有在网络不佳的情况下才会主动降低视频码率。
///【推荐取值】请参考本 TRTCVideoResolution 在各档位注释的最佳码率，也可以在此基础上适当调高。
///            比如 TRTCVideoResolution_1280_720 对应 1200kbps 的目标码率，您也可以设置为 1500kbps 用来获得更好的清晰度观感。
///【特别说明】SDK 会努力按照 videoBitrate 指定的码率进行编码，只有在网络不佳的情况下才会主动降低视频码率，最低会降至 minVideoBitrate 所设定的数值。
///            如果您追求“允许卡顿但要保持清晰”的效果，可以设置 minVideoBitrate 为 videoBitrate 的 60%；
///            如果您追求“允许模糊但要保持流畅”的效果，可以设置 minVideoBitrate 为 200kbps；
///            如果您将 videoBitrate 和 minVideoBitrate 设置为同一个值，等价于关闭 SDK 的自适应调节能力。
@property (nonatomic, assign) int videoBitrate;

///【字段含义】最低视频码率，SDK 会在网络不佳的情况下主动降低视频码率，最低会降至 minVideoBitrate 所设定的数值。
///【推荐取值】
///     - 如果您追求“允许卡顿但要保持清晰”的效果，可以设置 minVideoBitrate 为 videoBitrate 的 60%；
///     - 如果您追求“允许模糊但要保持流畅”的效果，可以设置 minVideoBitrate 为 200kbps；
///     - 如果您将 videoBitrate 和 minVideoBitrate 设置为同一个值，等价于关闭 SDK 的自适应调节能力；
///     - 默认值：0，此时最低码率由 SDK 根据分辨率情况，自动设置合适的数值。
///【特别说明】
///     - 当您把分辨率设置的比较高时，minVideoBitrate 不适合设置的太低，否则会出现画面模糊和大范围的马赛克宏块。
///        比如把分辨率设置为 720p，把码率设置为 200kbps，那么编码出的画面将会出现大范围区域性马赛克。
@property (nonatomic, assign) int minVideoBitrate;

///【字段含义】是否允许 SDK 动态调整分辨率，开启后会对云端录制产生影响。
///【推荐取值】 
///     - 需要开启云端录制的场景建议设置为 NO，中途视频分辨率发生变化后，云端录制出的 MP4 在一般的播放器上都无法正常播放。
///     - 视频通话模式，若无需云端录制，可以设置为 YES，此时 SDK 会根据当前待带宽情况自动选择合适的分辨率（仅针对 TRTCVideoStreamTypeBig 生效）。
///     - 默认值：NO。
///【特别说明】如有云端录制需求，请设置为 NO。
@property (nonatomic, assign) BOOL enableAdjustRes;
@end

#pragma mark -

/** 
 * 5.3 网络流控相关参数
 *
 * 网络流控相关参数，该设置决定 SDK 在各种网络环境下的调控方向（例如弱网下选择“保清晰”或“保流畅”）
 */
@interface TRTCNetworkQosParam : NSObject

///【字段含义】弱网下是“保清晰”或“保流畅”
///【特别说明】
///   - 弱网下保流畅：在遭遇弱网环境时，画面会变得模糊，且出现较多马赛克，但可以保持流畅不卡顿
///   - 弱网下保清晰：在遭遇弱网环境时，画面会尽可能保持清晰，但可能会更容易出现卡顿
@property (nonatomic, assign) TRTCVideoQosPreference preference;

///【字段含义】视频分辨率（云端控制 - 客户端控制）
///【推荐取值】云端控制
///【特别说明】
///   - Server 模式（默认）：云端控制模式，若无特殊原因，请直接使用该模式
///   - Client 模式：客户端控制模式，用于 SDK 开发内部调试，客户请勿使用
@property (nonatomic, assign) TRTCQosControlMode controlMode;
@end

#pragma mark -

/** 
 * 5.4 视频质量
 *
 * 表示视频质量的好坏，通过这个数值，您可以在 UI 界面上用图标表征 userId 的通话线路质量
 */
@interface TRTCQualityInfo : NSObject
/// 用户 ID
@property (nonatomic, copy, nullable)  NSString* userId;
/// 视频质量
@property (nonatomic, assign)   TRTCQuality quality;
@end

#pragma mark -

/** 
 * 5.5 音量大小
 *
 * 表示语音音量的评估大小，通过这个数值，您可以在 UI 界面上用图标表征 userId 是否有在说话 
 */
@interface TRTCVolumeInfo : NSObject <NSCopying>
/// 说话者的 userId, nil 为自己
@property (strong, nonatomic, nullable) NSString *userId;
/// 说话者的音量, 取值范围0 - 100
@property (assign, nonatomic) NSUInteger volume;
@end

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#pragma mark -

/**
 * 5.6 媒体设备描述
 *
 * 在 Mac 上，每一种类型的设备都可能有多个，TRTC SDK 的 Mac 版本提供了一系列函数用来操作这些设备。
 */
@interface TRTCMediaDeviceInfo : NSObject
/// 设备类型
@property (assign, nonatomic) TRTCMediaDeviceType type;
/// 设备ID
@property (copy, nonatomic, nullable) NSString * deviceId;
/// 设备名称
@property (copy, nonatomic, nullable) NSString * deviceName;
@end
#endif

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#pragma mark -

/**
 * 5.7 屏幕分享目标信息（仅 Mac）
 *
 * 如果您要给您的 App 增加屏幕分享功能，一般需要先显示一个窗口选择界面，用户才可以选择希望分享的窗口。
 * TRTCScreenCaptureSourceInfo 主要用于定义分享窗口的 ID、类型、窗口名称以及缩略图。
 */
@interface TRTCScreenCaptureSourceInfo : NSObject
/// 分享类型：需要某个窗口或整个屏幕
@property (assign, nonatomic) TRTCScreenCaptureSourceType type;
/// 窗口ID
@property (copy, nonatomic, nullable) NSString * sourceId;
/// 窗口名称
@property (copy, nonatomic, nullable) NSString * sourceName;
/// 窗口属性
@property (nonatomic, strong, nullable) NSDictionary * extInfo;
/// 窗口缩略图
@property (nonatomic, readonly, nullable) NSImage *thumbnail;
/// 窗口小图标
@property (nonatomic, readonly, nullable) NSImage *icon;
@end
#endif

#pragma mark -

/**
 * 5.8 网络测速结果
 *
 * 您可以在用户进入房间前通过 TRTCCloud 的 startSpeedTest 接口进行测速 （注意：请不要在通话中调用），
 * 测速结果会每2 - 3秒钟返回一次，每次返回一个 IP 地址的测试结果。
 *
 * @note - quality 是内部通过评估算法测算出的网络质量，loss 越低，rtt 越小，得分便越高。
 * @note - upLostRate 是指上行丢包率。例如，0.3表示每向服务器发送10个数据包可能会在中途丢失3个。
 * @note - downLostRate 是指下行丢包率。例如，0.2表示每从服务器收取10个数据包可能会在中途丢失2个。
 * @note - rtt 是指当前设备到腾讯云服务器的一次网络往返时间，该值越小越好，正常数值范围是10ms - 100ms
 */
@interface TRTCSpeedTestResult : NSObject

/// 服务器 IP 地址
@property (strong, nonatomic, nonnull) NSString *ip;

/// 网络质量，内部通过评估算法测算出的网络质量，loss 越低，rtt 越小，得分便越高。
@property (nonatomic) TRTCQuality quality;

/// 上行丢包率，范围是0 - 1.0，例如，0.3表示每向服务器发送10个数据包可能会在中途丢失3个。
@property (nonatomic) float upLostRate;

/// 下行丢包率，范围是0 - 1.0，例如，0.2表示每从服务器收取10个数据包可能会在中途丢失2个。
@property (nonatomic) float downLostRate;

/// 延迟（毫秒），指当前设备到腾讯云服务器的一次网络往返时间，该值越小越好，正常数值范围是10ms - 100ms
@property (nonatomic) uint32_t rtt;
@end

#pragma mark -

/** 
 *  5.9 视频帧信息
 *
 *  TRTCVideoFrame 用来描述一帧视频画面的裸数据，它可以是一帧编码前的画面，也可以是一帧解码后的画面。
 */
@interface TRTCVideoFrame : NSObject

///【字段含义】视频像素格式
///【推荐取值】TRTCVideoPixelFormat_NV12 
@property (nonatomic, assign) TRTCVideoPixelFormat pixelFormat;

///【字段含义】视频数据结构类型
///【推荐取值】TRTCVideoBufferType_PixelBuffer
@property (nonatomic, assign) TRTCVideoBufferType bufferType;

///【字段含义】bufferType 为 TRTCVideoBufferType_PixelBuffer 时的视频数据。
@property (nonatomic, assign, nullable) CVPixelBufferRef pixelBuffer;

///【字段含义】bufferType 为 TRTCVideoBufferType_NSData 时的视频数据。
@property (nonatomic, retain, nullable) NSData* data;

///【字段含义】视频帧的时间戳，单位毫秒
///【推荐取值】自定义视频采集时可以设置为0，若该参数为0，SDK 会自定填充 timestamp 字段，但请“均匀”地控制 sendCustomVideoData 的调用间隔。
@property (nonatomic, assign) uint64_t timestamp;

///【字段含义】视频宽度
///【推荐取值】自定义视频采集时不需要填写。
@property (nonatomic, assign) uint32_t width;

///【字段含义】视频高度
///【推荐取值】自定义视频采集时不需要填写。
@property (nonatomic, assign) uint32_t height;

///【字段含义】视频像素的顺时针旋转角度
@property (nonatomic, assign) TRTCVideoRotation rotation;
@end


/** 
 * 5.10 音频帧数据
 */
#pragma mark -
/// 音频帧数据
@interface TRTCAudioFrame : NSObject
/// 音频数据
@property (nonatomic, retain, nonnull) NSData * data;
/// 采样率
@property (nonatomic, assign) TRTCAudioSampleRate sampleRate;
/// 声道数
@property (nonatomic, assign) int channels;
/// 时间戳，单位ms
@property (nonatomic, assign) uint64_t timestamp;
@end


/** 
* 5.11 云端混流中每一路子画面的位置信息
*
* TRTCMixUser 用于指定每一路（即每一个 userId）视频画面的具体摆放位置
*/
@interface TRTCMixUser : NSObject
/// 参与混流的 userId
@property(nonatomic, copy, nonnull) NSString * userId;
/// 混流的房间， 可填 nil 表示是自己所在的房间
@property (nonatomic, copy, nullable) NSString * roomID;
/// 图层位置坐标以及大小，左上角为坐标原点(0,0) （绝对像素值）
@property(nonatomic, assign) CGRect rect;
/// 图层层次（1 - 15）不可重复
@property(nonatomic, assign) int zOrder;
/// 参与混合的是主路画面（TRTCVideoStreamTypeBig）或屏幕分享（TRTCVideoStreamTypeSub）画面
@property (nonatomic) TRTCVideoStreamType streamType;
/// 该用户是不是只开启了音频
@property (nonatomic, assign) BOOL pureAudio;

@end

 
/** 
* 5.12 云端混流（转码）配置
*
* 包括最终编码质量和各路画面的摆放位置
*/
@interface TRTCTranscodingConfig : NSObject

///【字段含义】转码config模式
@property(nonatomic, assign) TRTCTranscodingConfigMode mode; 

///【字段含义】腾讯云直播 AppID
///【推荐取值】请在 [实时音视频控制台](https://console.cloud.tencent.com/rav) 选择已经创建的应用，单击【帐号信息】后，在“直播信息”中获取
@property (nonatomic) int appId; 

///【字段含义】腾讯云直播 bizid
///【推荐取值】请在 [实时音视频控制台](https://console.cloud.tencent.com/rav) 选择已经创建的应用，单击【帐号信息】后，在“直播信息”中获取
@property (nonatomic) int bizId;                  

///【字段含义】最终转码后的视频分辨率的宽度。
///【推荐取值】推荐值：360px ，如果你是纯音频推流，请将 width × height 设为 0px × 0px，否则混流后会携带一条画布背景的视频流。
@property(nonatomic, assign) int videoWidth;       

///【字段含义】最终转码后的视频分辨率的高度。
///【推荐取值】推荐值：640px ，如果你是纯音频推流，请将 width × height 设为 0px × 0px，否则混流后会携带一条画布背景的视频流。
@property(nonatomic, assign) int videoHeight;      

///【字段含义】最终转码后的视频分辨率的码率（kbps）。
///【推荐取值】如果填0，后台会根据videoWidth和videoHeight来估算码率，您也可以参考枚举定义TRTCVideoResolution_640_480的注释。
@property(nonatomic, assign) int videoBitrate;     

///【字段含义】最终转码后的视频分辨率的帧率（FPS）。
///【推荐取值】默认值：15fps，取值范围是 (0,30]。
@property(nonatomic, assign) int videoFramerate;   

///【字段含义】最终转码后的视频分辨率的关键帧间隔（又称为 GOP）。
///【推荐取值】默认值：2，单位为秒，取值范围是 [1,8]。
@property(nonatomic, assign) int videoGOP; 

///【字段含义】混合后画面的底色颜色，默认为黑色，格式为十六进制数字，比如：“0x61B9F1” 代表 RGB 分别为(97,158,241)。
///【推荐取值】默认值：0x000000，黑色
@property(nonatomic, assign) int backgroundColor;

///【字段含义】最终转码后的音频采样率。
///【推荐取值】默认值：48000Hz。支持12000HZ、16000HZ、22050HZ、24000HZ、32000HZ、44100HZ、48000HZ。
@property(nonatomic, assign) int audioSampleRate;  

///【字段含义】最终转码后的音频码率。
///【推荐取值】默认值：64kbps，取值范围是 [32，192]。
@property(nonatomic, assign) int audioBitrate;  

///【字段含义】最终转码后的音频声道数
///【推荐取值】默认值：1。取值范围为 [1,2] 中的整型。
@property(nonatomic, assign) int audioChannels;    

///【字段含义】每一路子画面的位置信息
@property(nonatomic, copy, nonnull) NSArray<TRTCMixUser *> * mixUsers;
@end

#pragma mark -

/** 
 * 5.13 CDN 旁路推流参数
 */
@interface TRTCPublishCDNParam : NSObject
/// 腾讯云 AppID，请在 [实时音视频控制台](https://console.cloud.tencent.com/rav) 选择已经创建的应用，单击【帐号信息】，在“直播信息”中获取
@property (nonatomic) int appId;

/// 腾讯云直播 bizid，请在 [实时音视频控制台](https://console.cloud.tencent.com/rav) 选择已经创建的应用，单击【帐号信息】，在“直播信息”中获取
@property (nonatomic) int bizId;

/// 旁路转推的 URL
@property (nonatomic, strong, nonnull) NSString * url;
@end

/**
 * 5.14 录音参数
 *
 * 请正确填写参数，确保录音文件顺利生成。
 */
@interface TRTCAudioRecordingParams : NSObject

///【字段含义】文件路径（必填），录音文件的保存路径。该路径需要用户自行指定，请确保路径存在且可写。
///【特别说明】该路径需精确到文件名及格式后缀，格式后缀决定录音文件的格式，目前支持的格式有 PCM、WAV 和 AAC。
///          例如，指定路径为 path/to/audio.aac，则会生成一个 AAC 格式的文件。
///          请指定一个有读写权限的合法路径，否则录音文件无法生成。
@property (nonatomic, strong, nonnull) NSString * filePath;
@end

/**
 * 5.15 音效
 *
 */
@interface TRTCAudioEffectParam : NSObject

+ (_Nonnull instancetype)new  __attribute__((unavailable("Use -initWith:(int)effectId path:(NSString * )path instead")));
- (_Nonnull instancetype)init __attribute__((unavailable("Use -initWith:(int)effectId path:(NSString *)path instead")));

/// 【字段含义】音效 ID
/// 【特别说明】SDK 允许播放多路音效，因此需要音效 ID 进行标记，用于控制音效的开始、停止、音量等
@property(nonatomic, assign) int effectId;

/// 【字段含义】音效文件路径，支持的文件格式：aac, mp3, m4a。
@property(nonatomic, copy, nonnull) NSString * path;

/// 【字段含义】循环播放次数
/// 【推荐取值】取值范围为0 - 任意正整数，默认值：0。0表示播放音效一次；1表示播放音效两次；以此类推
@property(nonatomic, assign) int loopCount;

/// 【字段含义】音效是否上行
/// 【推荐取值】YES：音效在本地播放的同时，会上行至云端，因此远端用户也能听到该音效；NO：音效不会上行至云端，因此只能在本地听到该音效。默认值：NO
@property(nonatomic, assign) BOOL publish;

/// 【字段含义】音效音量
/// 【推荐取值】取值范围为0 - 100；默认值：100
@property(nonatomic, assign) int volume;

- (_Nonnull instancetype)initWith:(int)effectId path:(NSString * _Nonnull)path;
@end
/// @}
