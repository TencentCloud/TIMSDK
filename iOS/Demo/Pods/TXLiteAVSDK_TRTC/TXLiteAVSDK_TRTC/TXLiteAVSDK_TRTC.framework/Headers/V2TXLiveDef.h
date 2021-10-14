//
//  Copyright © 2020 Tencent. All rights reserved.
//
//  Module: V2TXLive
//
/// @defgroup V2TXLiveDef_ios V2TXLiveDef
/// 腾讯云直播服务(LVB)关键类型定义
/// @{
#import "V2TXLiveCode.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
typedef UIView TXView;
typedef UIImage TXImage;
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSView TXView;
typedef NSImage TXImage;
#endif

/**
 * @brief 支持协议
 */
typedef NS_ENUM(NSUInteger, V2TXLiveMode) {

    /// 支持协议: RTMP
    V2TXLiveMode_RTMP,

    /// 支持协议: TRTC
    V2TXLiveMode_RTC

};

/////////////////////////////////////////////////////////////////////////////////
//
//           （一）视频相关类型定义
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 视频相关类型定义
/// @{

/**
 * @brief 视频分辨率
 */
typedef NS_ENUM(NSInteger, V2TXLiveVideoResolution) {

    /// 分辨率 160*160，码率范围：100Kbps ~ 150Kbps，帧率：15fps
    V2TXLiveVideoResolution160x160,

    /// 分辨率 270*270，码率范围：200Kbps ~ 300Kbps，帧率：15fps
    V2TXLiveVideoResolution270x270,

    /// 分辨率 480*480，码率范围：350Kbps ~ 525Kbps，帧率：15fps
    V2TXLiveVideoResolution480x480,

    /// 分辨率 320*240，码率范围：250Kbps ~ 375Kbps，帧率：15fps
    V2TXLiveVideoResolution320x240,

    /// 分辨率 480*360，码率范围：400Kbps ~ 600Kbps，帧率：15fps
    V2TXLiveVideoResolution480x360,

    /// 分辨率 640*480，码率范围：600Kbps ~ 900Kbps，帧率：15fps
    V2TXLiveVideoResolution640x480,

    /// 分辨率 320*180，码率范围：250Kbps ~ 400Kbps，帧率：15fps
    V2TXLiveVideoResolution320x180,

    /// 分辨率 480*270，码率范围：350Kbps ~ 550Kbps，帧率：15fps
    V2TXLiveVideoResolution480x270,

    /// 分辨率 640*360，码率范围：500Kbps ~ 900Kbps，帧率：15fps
    V2TXLiveVideoResolution640x360,

    /// 分辨率 960*540，码率范围：800Kbps ~ 1500Kbps，帧率：15fps
    V2TXLiveVideoResolution960x540,

    /// 分辨率 1280*720，码率范围：1000Kbps ~ 1800Kbps，帧率：15fps
    V2TXLiveVideoResolution1280x720,

    /// 分辨率 1920*1080，码率范围：2500Kbps ~ 3000Kbps，帧率：15fps
    V2TXLiveVideoResolution1920x1080

};

/**
 * @brief 视频宽高比模式。
 *
 * @note
 * - 横屏模式下的分辨率: V2TXLiveVideoResolution640x360 + V2TXLiveVideoResolutionModeLandscape = 640 × 360
 * - 竖屏模式下的分辨率: V2TXLiveVideoResolution640x360 + V2TXLiveVideoResolutionModePortrait  = 360 × 640
 */
typedef NS_ENUM(NSInteger, V2TXLiveVideoResolutionMode) {

    /// 横屏模式
    V2TXLiveVideoResolutionModeLandscape = 0,

    /// 竖屏模式
    V2TXLiveVideoResolutionModePortrait = 1,

};

/**
 * 视频编码参数。
 *
 * 该设置决定远端用户看到的画面质量。
 */
@interface V2TXLiveVideoEncoderParam : NSObject

///【字段含义】 视频分辨率
///【特别说明】如需使用竖屏分辨率，请指定 videoResolutionMode 为 Portrait，例如： 640 × 360 + Portrait = 360 × 640。
///【推荐取值】
/// - 桌面平台（Win + Mac）：建议选择 640 × 360 及以上分辨率，videoResolutionMode 选择 Landscape，即横屏分辨率。
@property(nonatomic, assign) V2TXLiveVideoResolution videoResolution;

///【字段含义】分辨率模式（横屏分辨率 or 竖屏分辨率）
///【推荐取值】桌面平台（Windows、Mac）建议选择 Landscape。
///【特别说明】如需使用竖屏分辨率，请指定 resMode 为 Portrait，例如： 640 × 360 + Portrait = 360 × 640。
@property(nonatomic, assign) V2TXLiveVideoResolutionMode videoResolutionMode;

///【字段含义】视频采集帧率
///【推荐取值】15fps 或 20fps。5fps 以下，卡顿感明显。10fps 以下，会有轻微卡顿感。20fps 以上，会浪费带宽（电影的帧率为 24fps）。
@property(nonatomic, assign) int videoFps;

///【字段含义】目标视频码率，SDK 会按照目标码率进行编码，只有在弱网络环境下才会主动降低视频码率。
///【推荐取值】请参考 V2TXLiveVideoResolution 在各档位注释的最佳码率，也可以在此基础上适当调高。
///           比如：V2TXLiveVideoResolution1280x720 对应 1200kbps 的目标码率，您也可以设置为 1500kbps 用来获得更好的观感清晰度。
///【特别说明】您可以通过同时设置 videoBitrate 和 minVideoBitrate 两个参数，用于约束 SDK 对视频码率的调整范围：
/// - 如果您将 videoBitrate 和 minVideoBitrate 设置为同一个值，等价于关闭 SDK 对视频码率的自适应调节能力。
@property(nonatomic, assign) int videoBitrate;

///【字段含义】最低视频码率，SDK 会在网络不佳的情况下主动降低视频码率以保持流畅度，最低会降至 minVideoBitrate 所设定的数值。
///【推荐取值】您可以通过同时设置 videoBitrate 和 minVideoBitrate 两个参数，用于约束 SDK 对视频码率的调整范围：
/// - 如果您将 videoBitrate 和 minVideoBitrate 设置为同一个值，等价于关闭 SDK 对视频码率的自适应调节能力。
@property(nonatomic, assign) int minVideoBitrate;

- (instancetype _Nonnull)initWith:(V2TXLiveVideoResolution)resolution;

@end

/**
 * @brief 本地摄像头镜像类型。
 */
typedef NS_ENUM(NSInteger, V2TXLiveMirrorType) {

    /// 系统默认镜像类型，前置摄像头镜像，后置摄像头不镜像
    V2TXLiveMirrorTypeAuto,

    /// 前置摄像头和后置摄像头，都切换为镜像模式
    V2TXLiveMirrorTypeEnable,

    /// 前置摄像头和后置摄像头，都切换为非镜像模式
    V2TXLiveMirrorTypeDisable

};

/**
 * @brief 视频画面填充模式。
 */
typedef NS_ENUM(NSInteger, V2TXLiveFillMode) {

    /// 图像铺满屏幕，超出显示视窗的视频部分将被裁剪，画面显示可能不完整
    V2TXLiveFillModeFill,

    /// 图像长边填满屏幕，短边区域会被填充黑色，画面的内容完整
    V2TXLiveFillModeFit

};

/**
 * @brief 视频画面顺时针旋转角度。
 */
typedef NS_ENUM(NSInteger, V2TXLiveRotation) {

    /// 不旋转
    V2TXLiveRotation0,

    /// 顺时针旋转90度
    V2TXLiveRotation90,

    /// 顺时针旋转180度
    V2TXLiveRotation180,

    /// 顺时针旋转270度
    V2TXLiveRotation270

};

/**
 * @brief 视频帧的像素格式。
 */
typedef NS_ENUM(NSInteger, V2TXLivePixelFormat) {

    /// 未知
    V2TXLivePixelFormatUnknown,

    /// YUV420P I420
    V2TXLivePixelFormatI420,

    /// YUV420SP NV12
    V2TXLivePixelFormatNV12,

    /// BGRA8888
    V2TXLivePixelFormatBGRA32,

    /// OpenGL 2D 纹理
    V2TXLivePixelFormatTexture2D

};

/**
 * @brief 视频数据包装格式。
 *
 * @note 在自定义采集和自定义渲染功能，您需要用到下列枚举值来指定您希望以什么样的格式来包装视频数据。
 * - PixelBuffer：直接使用效率最高，iOS 系统提供了众多 API 获取或处理 PixelBuffer
 * - NSData：     当使用自定义渲染时，PixelBuffer拷贝一次到NSData。当使用自定义采集时，NSData拷贝一次到PixelBuffer。因此，性能会受到一定程度的影响
 */
typedef NS_ENUM(NSInteger, V2TXLiveBufferType) {

    /// 未知
    V2TXLiveBufferTypeUnknown,

    /// 直接使用效率最高，iOS 系统提供了众多 API 获取或处理 PixelBuffer
    V2TXLiveBufferTypePixelBuffer,

    /// 会有一定的性能消耗，SDK 内部是直接处理 PixelBuffer 的，所以会存在 NSData 和 PixelBuffer 之间类型转换所产生的内存拷贝开销
    V2TXLiveBufferTypeNSData,

    /// 直接操作纹理 ID，性能最好
    V2TXLiveBufferTypeTexture

};

/**
 * @brief 视频帧信息。
 *        V2TXLiveVideoFrame 用来描述一帧视频画面的裸数据，它可以是一帧编码前的画面，也可以是一帧解码后的画面。
 * @note  自定义采集和自定义渲染时使用。自定义采集时，需要使用 V2TXLiveVideoFrame 来包装待发送的视频帧；自定义渲染时，会返回经过 V2TXLiveVideoFrame 包装的视频帧。
 */
@interface V2TXLiveVideoFrame : NSObject

/// 【字段含义】视频帧像素格式
/// 【推荐取值】V2TXLivePixelFormatNV12
@property(nonatomic, assign) V2TXLivePixelFormat pixelFormat;

/// 【字段含义】视频数据包装格式
/// 【推荐取值】V2TXLiveBufferTypePixelBuffer
@property(nonatomic, assign) V2TXLiveBufferType bufferType;

/// 【字段含义】bufferType 为 V2TXLiveBufferTypeNSData 时的视频数据
@property(nonatomic, strong, nullable) NSData *data;

/// 【字段含义】bufferType 为 V2TXLiveBufferTypePixelBuffer 时的视频数据
@property(nonatomic, assign, nullable) CVPixelBufferRef pixelBuffer;

/// 【字段含义】视频宽度
@property(nonatomic, assign) NSUInteger width;

/// 【字段含义】视频高度
@property(nonatomic, assign) NSUInteger height;

/// 【字段含义】视频帧的顺时针旋转角度
@property(nonatomic, assign) V2TXLiveRotation rotation;

/// 【字段含义】视频纹理ID
@property(nonatomic, assign) GLuint textureId;

@end

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//          （二）音频相关类型定义
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 音频相关类型定义
/// @{

/**
 * @brief 声音音质。
 */
typedef NS_ENUM(NSInteger, V2TXLiveAudioQuality) {

    /// 语音音质：采样率：16k；单声道；音频码率：16kbps；适合语音通话为主的场景，比如在线会议，语音通话
    V2TXLiveAudioQualitySpeech,

    /// 默认音质：采样率：48k；单声道；音频码率：50kbps；SDK 默认的音频质量，如无特殊需求推荐选择之
    V2TXLiveAudioQualityDefault,

    /// 音乐音质：采样率：48k；双声道 + 全频带；音频码率：128kbps；适合需要高保真传输音乐的场景，比如K歌、音乐直播等
    V2TXLiveAudioQualityMusic

};

/**
 * @brief 音频帧数据
 */
@interface V2TXLiveAudioFrame : NSObject

/// 【字段含义】音频数据
@property(nonatomic, strong, nullable) NSData *data;

/// 【字段含义】采样率
@property(nonatomic, assign) int sampleRate;

/// 【字段含义】声道数
@property(nonatomic, assign) int channel;

@end

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//          （三）推流器和播放器的一些统计指标数据定义
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 推流器和播放器的一些统计指标数据定义
/// @{

/**
 * @brief 推流器的统计数据。
 */
@interface V2TXLivePusherStatistics : NSObject

/// 【字段含义】当前 App 的 CPU 使用率（％）
@property(nonatomic, assign) NSUInteger appCpu;

/// 【字段含义】当前系统的 CPU 使用率（％）
@property(nonatomic, assign) NSUInteger systemCpu;

/// 【字段含义】视频宽度
@property(nonatomic, assign) NSUInteger width;

/// 【字段含义】视频高度
@property(nonatomic, assign) NSUInteger height;

/// 【字段含义】帧率（fps）
@property(nonatomic, assign) NSUInteger fps;

/// 【字段含义】视频码率（Kbps）
@property(nonatomic, assign) NSUInteger videoBitrate;

/// 【字段含义】音频码率（Kbps）
@property(nonatomic, assign) NSUInteger audioBitrate;

@end

/**
 * @brief 播放器的统计数据。
 */
@interface V2TXLivePlayerStatistics : NSObject

/// 【字段含义】当前 App 的 CPU 使用率（％）
@property(nonatomic, assign) NSUInteger appCpu;

/// 【字段含义】当前系统的 CPU 使用率（％）
@property(nonatomic, assign) NSUInteger systemCpu;

/// 【字段含义】视频宽度
@property(nonatomic, assign) NSUInteger width;

/// 【字段含义】视频高度
@property(nonatomic, assign) NSUInteger height;

/// 【字段含义】帧率（fps）
@property(nonatomic, assign) NSUInteger fps;

/// 【字段含义】视频码率（Kbps）
@property(nonatomic, assign) NSUInteger videoBitrate;

/// 【字段含义】音频码率（Kbps）
@property(nonatomic, assign) NSUInteger audioBitrate;

@end

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//          （四）连接状态相关枚举值定义
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 连接状态相关枚举值定义
/// @{

/**
 * @brief 直播流的连接状态。
 */
typedef NS_ENUM(NSInteger, V2TXLivePushStatus) {

    /// 与服务器断开连接
    V2TXLivePushStatusDisconnected,

    /// 正在连接服务器
    V2TXLivePushStatusConnecting,

    /// 连接服务器成功
    V2TXLivePushStatusConnectSuccess,

    /// 重连服务器中
    V2TXLivePushStatusReconnecting,

};

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//          (五) 音视频状态有关的枚举值的定义
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 音视频状态有关的枚举值的定义
/// @{

/**
 * @brief 音视频状态
 */
typedef NS_ENUM(NSInteger, V2TXLivePlayStatus) {

    /// 播放停止
    V2TXLivePlayStatusStopped,

    /// 正在播放
    V2TXLivePlayStatusPlaying,

    /// 正在缓冲(首次加载不会抛出 Loading 事件)
    V2TXLivePlayStatusLoading,

};

/**
 * @brief 音视频状态对应的原因
 */
typedef NS_ENUM(NSInteger, V2TXLiveStatusChangeReason) {

    /// 内部原因
    V2TXLiveStatusChangeReasonInternal,

    /// 开始网络缓冲
    V2TXLiveStatusChangeReasonBufferingBegin,

    /// 结束网络缓冲
    V2TXLiveStatusChangeReasonBufferingEnd,

    /// 本地启动播放
    V2TXLiveStatusChangeReasonLocalStarted,

    /// 本地停止播放
    V2TXLiveStatusChangeReasonLocalStopped,

    /// 远端可播放
    V2TXLiveStatusChangeReasonRemoteStarted,

    /// 远端流停止或中断
    V2TXLiveStatusChangeReasonRemoteStopped,

    /// 远端流离线
    V2TXLiveStatusChangeReasonRemoteOffline,

};
/// @}

/**
 * @brief 声音播放模式（音频路由）
 */
typedef NS_ENUM(NSInteger, V2TXAudioRoute) {

    /// 扬声器
    V2TXAudioModeSpeakerphone,

    /// 听筒
    V2TXAudioModeEarpiece,

};

/**
 * @brief 混流输入类型配置
 */
typedef NS_ENUM(NSInteger, V2TXLiveMixInputType) {

    /// 混入音视频
    V2TXLiveMixInputTypeAudioVideo,

    /// 只混入视频
    V2TXLiveMixInputTypePureVideo,

    /// 只混入音频
    V2TXLiveMixInputTypePureAudio,

};

/**
 * @brief 云端混流中每一路子画面的位置信息
 */
@interface V2TXLiveMixStream : NSObject

/// 【字段含义】参与混流的 userId
@property(nonatomic, copy, nonnull) NSString *userId;

/// 【字段含义】参与混流的 userId 所在对应的推流 streamId，nil 表示当前推流 streamId
@property(nonatomic, copy, nullable) NSString *streamId;

/// 【字段含义】图层位置 x 坐标（绝对像素值）
@property(nonatomic, assign) NSInteger x;

/// 【字段含义】图层位置 y 坐标（绝对像素值）
@property(nonatomic, assign) NSInteger y;

/// 【字段含义】图层位置宽度（绝对像素值）
@property(nonatomic, assign) NSInteger width;

/// 【字段含义】图层位置高度（绝对像素值）
@property(nonatomic, assign) NSInteger height;

/// 【字段含义】图层层次（1 - 15）不可重复
@property(nonatomic, assign) NSUInteger zOrder;

/// 【字段含义】该直播流的输入类型
@property(nonatomic, assign) V2TXLiveMixInputType inputType;

@end

/**
 * @brief 云端混流（转码）配置
 */
@interface V2TXLiveTranscodingConfig : NSObject

/// 【字段含义】最终转码后的视频分辨率的宽度
/// 【推荐取值】推荐值：360px，如果你是纯音频推流，请将 width × height 设为 0px × 0px，否则混流后会携带一条画布背景的视频流
@property(nonatomic, assign) NSUInteger videoWidth;

/// 【字段含义】最终转码后的视频分辨率的高度
/// 【推荐取值】推荐值：640px，如果你是纯音频推流，请将 width × height 设为 0px × 0px，否则混流后会携带一条画布背景的视频流
@property(nonatomic, assign) NSUInteger videoHeight;

/// 【字段含义】最终转码后的视频分辨率的码率（kbps）
/// 【推荐取值】如果填0，后台会根据 videoWidth 和 videoHeight 来估算码率，您也可以参考枚举定义 V2TXLiveVideoResolution 的注释
@property(nonatomic, assign) NSUInteger videoBitrate;

/// 【字段含义】最终转码后的视频分辨率的帧率（FPS）
/// 【推荐取值】默认值：15fps，取值范围是 (0,30]
@property(nonatomic, assign) NSUInteger videoFramerate;

/// 【字段含义】最终转码后的视频分辨率的关键帧间隔（又称为 GOP）
/// 【推荐取值】默认值：2，单位为秒，取值范围是 [1,8]
@property(nonatomic, assign) NSUInteger videoGOP;

/// 【字段含义】混合后画面的底色颜色，默认为黑色，格式为十六进制数字，比如：“0x61B9F1” 代表 RGB 分别为(97,158,241)
/// 【推荐取值】默认值：0x000000，黑色
@property(nonatomic, assign) NSUInteger backgroundColor;

/// 【字段含义】混合后画面的背景图
/// 【推荐取值】默认值：nil，即不设置背景图
/// 【特别说明】背景图需要您事先在 “[控制台](https://console.cloud.tencent.com/trtc) => 应用管理 => 功能配置 => 素材管理” 中上传，
///            上传成功后可以获得对应的“图片ID”，然后将“图片ID”转换成字符串类型并设置到 backgroundImage 里即可。
///            例如：假设“图片ID” 为 63，可以设置 backgroundImage = "63";
@property(nonatomic, copy, nullable) NSString *backgroundImage;

/// 【字段含义】最终转码后的音频采样率
/// 【推荐取值】默认值：48000Hz。支持12000HZ、16000HZ、22050HZ、24000HZ、32000HZ、44100HZ、48000HZ
@property(nonatomic, assign) NSUInteger audioSampleRate;

/// 【字段含义】最终转码后的音频码率
/// 【推荐取值】默认值：64kbps，取值范围是 [32，192]，单位：kbps
@property(nonatomic, assign) NSUInteger audioBitrate;

/// 【字段含义】最终转码后的音频声道数
/// 【推荐取值】默认值：1。取值范围为 [1,2] 中的整型
@property(nonatomic, assign) NSUInteger audioChannels;

/// 【字段含义】每一路子画面的位置信息
@property(nonatomic, copy, nonnull) NSArray<V2TXLiveMixStream *> *mixStreams;

/// 【字段含义】输出到 CDN 上的直播流 ID
///          如不设置该参数，SDK 会执行默认逻辑，即房间里的多路流会混合到该接口调用者的视频流上，也就是 A + B => A；
///          如果设置该参数，SDK 会将房间里的多路流混合到您指定的直播流 ID 上，也就是 A + B => C。
/// 【推荐取值】默认值：nil，即房间里的多路流会混合到该接口调用者的视频流上。
@property(nonatomic, copy, nullable) NSString *outputStreamId;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//          (六) 公共配置组件
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 公共配置组件有关的枚举值的定义
/// @{

/**
 * @brief 日志级别枚举值
 */
typedef NS_ENUM(NSInteger, V2TXLiveLogLevel) {

    /// 输出所有级别的 log
    V2TXLiveLogLevelAll = 0,

    /// 输出 DEBUG，INFO，WARNING，ERROR 和 FATAL 级别的 log
    V2TXLiveLogLevelDebug = 1,

    /// 输出 INFO，WARNING，ERROR 和 FATAL 级别的 log
    V2TXLiveLogLevelInfo = 2,

    /// 只输出 WARNING，ERROR 和 FATAL 级别的 log
    V2TXLiveLogLevelWarning = 3,

    /// 只输出 ERROR 和 FATAL 级别的 log
    V2TXLiveLogLevelError = 4,

    /// 只输出 FATAL 级别的 log
    V2TXLiveLogLevelFatal = 5,

    /// 不输出任何 sdk log
    V2TXLiveLogLevelNULL = 6,

};

@interface V2TXLiveLogConfig : NSObject

/// 【字段含义】设置 Log 级别
/// 【推荐取值】默认值：V2TXLiveLogLevelAll
@property(nonatomic, assign) V2TXLiveLogLevel logLevel;

/// 【字段含义】是否通过 V2TXLivePremierObserver 接收要打印的 Log 信息
/// 【特殊说明】如果您希望自己实现 Log 写入，可以打开此开关，Log 信息会通过 V2TXLivePremierObserver#onLog 回调给您。
/// 【推荐取值】默认值：NO
@property(nonatomic, assign) BOOL enableObserver;

/// 【字段含义】是否允许 SDK 在编辑器（XCoder、Android Studio、Visual Studio 等）的控制台上打印 Log
/// 【推荐取值】默认值：NO
@property(nonatomic, assign) BOOL enableConsole;

/// 【字段含义】是否启用本地 Log 文件
/// 【特殊说明】如非特殊需要，请不要关闭本地 Log 文件，否则腾讯云技术团队将无法在出现问题时进行跟踪和定位。
/// 【推荐取值】默认值：YES
@property(nonatomic, assign) BOOL enableLogFile;

/// 【字段含义】设置本地 Log 的存储目录，默认 Log 存储位置：
///  iOS & Mac: sandbox Documents/log
@property(nonatomic, copy, nullable) NSString *logPath;

@end
/// @}

/// @}
