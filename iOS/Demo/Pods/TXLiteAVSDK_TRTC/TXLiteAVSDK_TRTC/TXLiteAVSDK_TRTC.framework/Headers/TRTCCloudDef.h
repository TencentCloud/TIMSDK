/**
 * Module:   TRTC 关键类型定义
 * Function: 分辨率、质量等级等枚举和常量值的定义
 */
/// @defgroup TRTCCloudDef_ios 关键类型定义
/// 腾讯云实时音视频的关键类型定义
/// @{
#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////////////
//
//                    渲染控件
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * [VIEW] 用于渲染视频画面的渲染控件
 *
 * TRTC 中有很多需要操控视频画面的接口，这些接口都需要您指定视频渲染控件。
 * - 在 iOS 系统中，您可以直接使用 UIView 作为视频渲染控件，SDK 会在您提供的 UIView 上绘制视频画面。
 * - 在 Mac 系统中，您可以直接使用 NSView 作为视频渲染控件，SDK 会在您提供的 NSView 上绘制视频画面。
 * 示例代码如下：
 * <pre>
 * UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 360, 640)];
 * [self.view addSubview:videoView];
 * [trtcCloud startLocalPreview:YES view:_localView];
 * </pre>
 */
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
#import "TXDeviceManager.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                    视频相关枚举值定义
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 1.1 视频分辨率
 *
 * 此处仅定义横屏分辨率（如 640 × 360），如需使用竖屏分辨率（如360 × 640），需要同时指定 TRTCVideoResolutionMode 为 Portrait。
 */
typedef NS_ENUM(NSInteger, TRTCVideoResolution) {

    ///宽高比 1:1；分辨率 120x120；建议码率（VideoCall）80kbps; 建议码率（LIVE）120kbps。
    TRTCVideoResolution_120_120 = 1,

    ///宽高比 1:1 分辨率 160x160；建议码率（VideoCall）100kbps; 建议码率（LIVE）150kbps。
    TRTCVideoResolution_160_160 = 3,

    ///宽高比 1:1；分辨率 270x270；建议码率（VideoCall）200kbps; 建议码率（LIVE）300kbps。
    TRTCVideoResolution_270_270 = 5,

    ///宽高比 1:1；分辨率 480x480；建议码率（VideoCall）350kbps; 建议码率（LIVE）500kbps。
    TRTCVideoResolution_480_480 = 7,

    ///宽高比4:3；分辨率 160x120；建议码率（VideoCall）100kbps; 建议码率（LIVE）150kbps。
    TRTCVideoResolution_160_120 = 50,

    ///宽高比 4:3；分辨率 240x180；建议码率（VideoCall）150kbps; 建议码率（LIVE）250kbps。
    TRTCVideoResolution_240_180 = 52,

    ///宽高比 4:3；分辨率 280x210；建议码率（VideoCall）200kbps; 建议码率（LIVE）300kbps。
    TRTCVideoResolution_280_210 = 54,

    ///宽高比 4:3；分辨率 320x240；建议码率（VideoCall）250kbps; 建议码率（LIVE）375kbps。
    TRTCVideoResolution_320_240 = 56,

    ///宽高比 4:3；分辨率 400x300；建议码率（VideoCall）300kbps; 建议码率（LIVE）450kbps。
    TRTCVideoResolution_400_300 = 58,

    ///宽高比 4:3；分辨率 480x360；建议码率（VideoCall）400kbps; 建议码率（LIVE）600kbps。
    TRTCVideoResolution_480_360 = 60,

    ///宽高比 4:3；分辨率 640x480；建议码率（VideoCall）600kbps; 建议码率（LIVE）900kbps。
    TRTCVideoResolution_640_480 = 62,

    ///宽高比 4:3；分辨率 960x720；建议码率（VideoCall）1000kbps; 建议码率（LIVE）1500kbps。
    TRTCVideoResolution_960_720 = 64,

    ///宽高比 16:9；分辨率 160x90；建议码率（VideoCall）150kbps; 建议码率（LIVE）250kbps。
    TRTCVideoResolution_160_90 = 100,

    ///宽高比 16:9；分辨率 256x144；建议码率（VideoCall）200kbps; 建议码率（LIVE）300kbps。
    TRTCVideoResolution_256_144 = 102,

    ///宽高比 16:9；分辨率 320x180；建议码率（VideoCall）250kbps; 建议码率（LIVE）400kbps。
    TRTCVideoResolution_320_180 = 104,

    ///宽高比 16:9；分辨率 480x270；建议码率（VideoCall）350kbps; 建议码率（LIVE）550kbps。
    TRTCVideoResolution_480_270 = 106,

    ///宽高比 16:9；分辨率 640x360；建议码率（VideoCall）500kbps; 建议码率（LIVE）900kbps。
    TRTCVideoResolution_640_360 = 108,

    ///宽高比 16:9；分辨率 960x540；建议码率（VideoCall）850kbps; 建议码率（LIVE）1300kbps。
    TRTCVideoResolution_960_540 = 110,

    ///宽高比 16:9；分辨率 1280x720；建议码率（VideoCall）1200kbps; 建议码率（LIVE）1800kbps。
    TRTCVideoResolution_1280_720 = 112,

    ///宽高比 16:9；分辨率 1920x1080；建议码率（VideoCall）2000kbps; 建议码率（LIVE）3000kbps。
    TRTCVideoResolution_1920_1080 = 114,

};

/**
 * 1.2 视频宽高比模式
 *
 * TRTCVideoResolution 中仅定义了横屏分辨率（如 640 × 360），如需使用竖屏分辨率（如360 × 640），需要同时指定 TRTCVideoResolutionMode 为 Portrait。
 */
typedef NS_ENUM(NSInteger, TRTCVideoResolutionMode) {

    ///横屏分辨率，例如：TRTCVideoResolution_640_360 + TRTCVideoResolutionModeLandscape = 640 × 360。
    TRTCVideoResolutionModeLandscape = 0,

    ///竖屏分辨率，例如：TRTCVideoResolution_640_360 + TRTCVideoResolutionModePortrait  = 360 × 640。
    TRTCVideoResolutionModePortrait = 1,

};

/**
 * 1.3 视频流类型
 *
 * TRTC 内部有三种不同的视频流，分别是：
 *  - 高清大画面：一般用来传输摄像头的视频数据。
 *  - 低清小画面：小画面和大画面的内容相互，但是分辨率和码率都比大画面低，因此清晰度也更低。
 *  - 辅流画面：一般用于屏幕分享，同一时间在同一个房间中只允许一个用户发布辅流视频，其他用户必须要等该用户关闭之后才能发布自己的辅流。
 * @note 不支持单独开启低清小画面，小画面必须依附于大画面而存在，SDK 会自动设定低清小画面的分辨率和码率。
 */
typedef NS_ENUM(NSInteger, TRTCVideoStreamType) {

    ///高清大画面，一般用来传输摄像头的视频数据。
    TRTCVideoStreamTypeBig = 0,

    ///低清小画面：小画面和大画面的内容相互，但是分辨率和码率都比大画面低，因此清晰度也更低。
    TRTCVideoStreamTypeSmall = 1,

    ///辅流画面：一般用于屏幕分享，同一时间在同一个房间中只允许一个用户发布辅流视频，其他用户必须要等该用户关闭之后才能发布自己的辅流。
    TRTCVideoStreamTypeSub = 2,

};

/**
 * 1.4 视频画面填充模式
 *
 * 如果视频显示区域的宽高比不等于视频内容的宽高比时，就需要您指定画面的填充模式:
 */
typedef NS_ENUM(NSInteger, TRTCVideoFillMode) {

    ///填充模式：即将画面内容居中等比缩放以充满整个显示区域，超出显示区域的部分将会被裁剪掉，此模式下画面可能不完整。
    TRTCVideoFillMode_Fill = 0,

    ///适应模式：即按画面长边进行缩放以适应显示区域，短边部分会被填充为黑色，此模式下图像完整但可能留有黑边。
    TRTCVideoFillMode_Fit = 1,

};

/**
 * 1.5 视频画面旋转方向
 *
 * TRTC 提供了对本地和远程画面的旋转角度设置 API，下列的旋转角度都是指顺时针方向的。
 */
typedef NS_ENUM(NSInteger, TRTCVideoRotation) {

    ///不旋转
    TRTCVideoRotation_0 = 0,

    ///顺时针旋转90度
    TRTCVideoRotation_90 = 1,

    ///顺时针旋转180度
    TRTCVideoRotation_180 = 2,

    ///顺时针旋转270度
    TRTCVideoRotation_270 = 3,

};

/**
 * 1.6 美颜（磨皮）算法
 *
 * TRTC 内置多种不同的磨皮算法，您可以选择最适合您产品定位的方案。
 */
typedef NS_ENUM(NSInteger, TRTCBeautyStyle) {

    ///光滑，算法比较激进，磨皮效果比较明显，适用于秀场直播。
    TRTCBeautyStyleSmooth = 0,

    ///自然，算法更多地保留了面部细节，磨皮效果更加自然，适用于绝大多数直播场景。
    TRTCBeautyStyleNature = 1,

    ///优图，由优图实验室提供，磨皮效果介于光滑和自然之间，比光滑保留更多皮肤细节，比自然磨皮程度更高。
    TRTCBeautyStylePitu = 2,

};

/**
 * 1.7 视频像素格式
 *
 * TRTC 提供针对视频的自定义采集和自定义渲染功能：
 * - 在自定义采集功能中，您可以用下列枚举值描述您采集的视频像素格式。
 * - 在自定义渲染功能中，您可以指定您期望 SDK 回调出的视频像素格式。
 */
typedef NS_ENUM(NSInteger, TRTCVideoPixelFormat) {

    ///未定义的格式
    TRTCVideoPixelFormat_Unknown = 0,

    /// YUV420P(I420) 格式
    TRTCVideoPixelFormat_I420 = 1,

    /// OpenGL 2D 纹理格式
    TRTCVideoPixelFormat_Texture_2D = 7,

    /// BGRA 格式
    TRTCVideoPixelFormat_32BGRA = 6,

    /// YUV420SP（NV12）格式
    TRTCVideoPixelFormat_NV12 = 5,

};

/**
 * 1.8 视频数据传递方式
 *
 * 在自定义采集和自定义渲染功能，您需要用到下列枚举值来指定您希望以什么方式传递视频数据：
 * - 方案一：使用内存 Buffer 传递视频数据，该方案在 iOS 效率尚可，但在 Android 系统上效率较差，Windows 暂时仅支持内存 Buffer 的传递方式。
 * - 方案二：使用 Texture 纹理传递视频数据，该方案在 iOS 和 Android 系统下均有较高的效率，Windows 暂不支持，需要您有一定的 OpenGL 编程基础。
 */
typedef NS_ENUM(NSInteger, TRTCVideoBufferType) {

    ///未定义的传递方式
    TRTCVideoBufferType_Unknown = 0,

    ///使用内存 Buffer 传递视频数据，iOS: PixelBuffer；Android: 用于 JNI 层的 Direct Buffer；Win: 内存数据块。
    TRTCVideoBufferType_PixelBuffer = 1,

    ///使用内存 Buffer 传递视频数据，iOS: 经过一次额外整理后更加紧凑的 NSData 类型的内存块；Android: 用于 JAVA 层的 byte[]。
    ///该传递的方式的性能是几种方案中效率较差的一种。
    TRTCVideoBufferType_NSData = 2,

    ///使用 Texture 纹理传递视频数据
    TRTCVideoBufferType_Texture = 3,

};

/**
 * 1.9 视频的镜像类型
 *
 * 视频的镜像是指对视频内容进行左右翻转，尤其是对本地的摄像头预览视频，开启镜像后能给主播带来熟悉的“照镜子”体验。
 */
typedef NS_ENUM(NSUInteger, TRTCVideoMirrorType) {

    ///自动模式：如果正使用前置摄像头则开启镜像，如果是后置摄像头则不开启镜像（仅适用于移动设备）。
    TRTCVideoMirrorTypeAuto = 0,

    ///强制开启镜像，不论当前使用的是前置摄像头还是后置摄像头。
    TRTCVideoMirrorTypeEnable = 1,

    ///强制关闭镜像，不论当前使用的是前置摄像头还是后置摄像头。
    TRTCVideoMirrorTypeDisable = 2,

};

/// Old version of TRTCVideoMirrorType, reserved for compatibility with older interface.
typedef NS_ENUM(NSUInteger, TRTCLocalVideoMirrorType) {
    TRTCLocalVideoMirrorType_Auto = TRTCVideoMirrorTypeAuto,
    TRTCLocalVideoMirrorType_Enable = TRTCVideoMirrorTypeEnable,
    TRTCLocalVideoMirrorType_Disable = TRTCVideoMirrorTypeDisable,
} __attribute__((deprecated("use TRTCVideoMirrorType instead")));

/**
 * 1.10 本地视频截图的数据源
 *
 * SDK 支持从如下两种数据源中截取图片并保存成本地文件：
 * - 视频流：从视频流中截取原生的视频内容，截取的内容不受渲染控件的显示控制。
 * - 渲染层：从渲染控件中截取显示的视频内容，可以做到用户所见即所得的效果，但如果显示区域过小，截取出的图片也会很小。
 */
typedef NS_ENUM(NSUInteger, TRTCSnapshotSourceType) {

    ///从视频流中截取原生的视频内容，截取的内容不受渲染控件的显示控制。
    TRTCSnapshotSourceTypeStream = 0,

    ///从渲染控件中截取显示的视频内容，可以做到用户所见即所得的效果，但如果显示区域过小，截取出的图片也会很小。
    TRTCSnapshotSourceTypeView = 1,

};

/////////////////////////////////////////////////////////////////////////////////
//
//                    网络相关枚举值定义
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 2.1 应用场景
 *
 * TRTC 针对常见的音视频应用场景都进行了定向优化，以满足各种垂直场景下的差异化要求，主要场景可以分为如下两类：
 * - 直播（LIVE）场景：包括 LIVE 和 VoiceChatRoom，前者是音频+视频，后者是纯音频。
 *   直播场景下，用户被分成“主播”和“观众”两种角色，单个房间中同时最多支持10万人在线，适合于观众人数众多的直播场景。
 * - 实时（RTC）场景：包括 VideoCall 和 AudioCall，前者是音频+视频，后者是纯音频。
 *   实时场景下，用户没有角色的差异，但单个房间中同时最多支持 300 人在线，适合于小范围实时通信的场景。
 */
typedef NS_ENUM(NSInteger, TRTCAppScene) {

    ///视频通话场景，支持720P、1080P高清画质，单个房间最多支持300人同时在线，最高支持50人同时发言。
    ///适用于[1对1视频通话]、[300人视频会议]、[在线问诊]、[教育小班课]、[远程面试]等业务场景。
    TRTCAppSceneVideoCall = 0,

    ///视频互动直播，支持平滑上下麦，切换过程无需等待，主播延时小于300ms；支持十万级别观众同时播放，播放延时低至1000ms。
    ///适用于[低延时互动直播]、[大班课]、[主播PK]、[视频相亲]、[在线互动课堂]、[远程培训]、[超大型会议]等业务场景。
    ///@note 此场景下，您必须通过 TRTCParams 中的 role 字段指定当前用户的角色。
    TRTCAppSceneLIVE = 1,

    ///语音通话场景，默认采用 SPEECH 音质，单个房间最多支持300人同时在线，最高支持50人同时发言。
    ///适用于[1对1语音通话]、[300人语音会议]、[语音聊天]、[语音会议]、[在线狼人杀]等业务场景。
    TRTCAppSceneAudioCall = 2,

    ///语音互动直播，支持平滑上下麦，切换过程无需等待，主播延时小于300ms；支持十万级别观众同时播放，播放延时低至1000ms。
    ///适用于[语音俱乐部]、[在线K歌房]、[音乐直播间]、[FM电台]等业务场景。
    ///@note 此场景下，您必须通过 TRTCParams 中的 role 字段指定当前用户的角色。
    TRTCAppSceneVoiceChatRoom = 3,

};

/**
 * 2.2 角色
 *
 * 仅适用于直播类场景（即 TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom），把用户区分成两种不同的身份：
 * - 主播：可以随时发布自己的音视频流，但人数有限制，同一个房间中最多只允许 50 个主播同时发布自己的音视频流。
 * - 观众：只能观看其他用户的音视频流，要发布音视频流，需要先通过 {@link switchRole} 切换成主播，同一个房间中最多能容纳10万观众。
 */
typedef NS_ENUM(NSInteger, TRTCRoleType) {

    ///主播：可以随时发布自己的音视频流，但人数有限制，同一个房间中最多只允许 50 个主播同时发布自己的音视频流。
    TRTCRoleAnchor = 20,

    ///观众：只能观看其他用户的音视频流，要发布音视频流，需要先通过 {@link switchRole} 切换成主播，同一个房间中最多能容纳10万观众。
    TRTCRoleAudience = 21,

};

/**
 * 2.3 流控模式（已废弃）
 */
typedef NS_ENUM(NSInteger, TRTCQosControlMode) {

    ///本地控制，用于 SDK 开发内部调试，客户请勿使用。
    TRTCQosControlModeClient = 0,

    ///云端控制，默认模式，推荐选择。
    TRTCQosControlModeServer = 1,

};

/**
 * 2.4 画质偏好
 *
 * TRTC 在弱网络环境下有两种调控模式：“优先保证画面清晰”或“优先保证画面流畅”，两种模式均会优先保障声音数据的传输。
 */
typedef NS_ENUM(NSInteger, TRTCVideoQosPreference) {

    ///流畅优先：即当前网络不足以传输既清晰又流畅的画面时，优先保证画面的流畅性，代价就是画面会比较模糊且伴随有较多的马赛克。
    TRTCVideoQosPreferenceSmooth = 1,

    ///清晰优先（默认值）：即当前网络不足以传输既清晰又流畅的画面时，优先保证画面的清晰度，代价就是画面会比较卡顿。
    TRTCVideoQosPreferenceClear = 2,

};

/**
 * 2.5 网络质量
 *
 * TRTC 会每隔两秒对当前的网络质量进行评估，评估结果为六个等级：Excellent 表示最好，Down 表示最差。
 */
typedef NS_ENUM(NSInteger, TRTCQuality) {

    ///未定义
    TRTCQuality_Unknown = 0,

    ///当前网络非常好
    TRTCQuality_Excellent = 1,

    ///当前网络比较好
    TRTCQuality_Good = 2,

    ///当前网络一般
    TRTCQuality_Poor = 3,

    ///当前网络较差
    TRTCQuality_Bad = 4,

    ///当前网络很差
    TRTCQuality_Vbad = 5,

    ///当前网络不满足 TRTC 的最低要求
    TRTCQuality_Down = 6,

};

/**
 * 2.6 视频状态类型
 *
 * 该枚举类型用于视频状态变化回调接口{@link onRemoteVideoStatusUpdated}，用于指定当前的视频状态。
 */
typedef NS_ENUM(NSUInteger, TRTCAVStatusType) {

    ///停止播放
    TRTCAVStatusStopped = 0,

    ///正在播放
    TRTCAVStatusPlaying = 1,

    ///正在加载
    TRTCAVStatusLoading = 2,

};

/**
 * 2.7 视频状态变化原因类型
 *
 * 该枚举类型用于视频状态变化回调接口{@link onRemoteVideoStatusUpdated}，用于指定当前的视频状态原因。
 */
typedef NS_ENUM(NSUInteger, TRTCAVStatusChangeReason) {

    ///缺省值
    TRTCAVStatusChangeReasonInternal = 0,

    ///网络缓冲
    TRTCAVStatusChangeReasonBufferingBegin = 1,

    ///结束缓冲
    TRTCAVStatusChangeReasonBufferingEnd = 2,

    ///本地启动视频流播放
    TRTCAVStatusChangeReasonLocalStarted = 3,

    ///本地停止视频流播放
    TRTCAVStatusChangeReasonLocalStopped = 4,

    ///远端视频流开始（或继续）
    TRTCAVStatusChangeReasonRemoteStarted = 5,

    ///远端视频流停止（或中断
    TRTCAVStatusChangeReasonRemoteStopped = 6,

};

/////////////////////////////////////////////////////////////////////////////////
//
//                    音频相关枚举值定义
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 3.1 音频采样率
 *
 * 音频采样率用来衡量声音的保真程度，采样率越高保真程度越好，如果您的应用场景有音乐的存在，推荐使用 TRTCAudioSampleRate48000。
 */
typedef NS_ENUM(NSInteger, TRTCAudioSampleRate) {

    /// 16k采样率
    TRTCAudioSampleRate16000 = 16000,

    /// 32k采样率
    TRTCAudioSampleRate32000 = 32000,

    /// 44.1k采样率
    TRTCAudioSampleRate44100 = 44100,

    /// 48k采样率
    TRTCAudioSampleRate48000 = 48000,

};

/**
 * 3.2 声音音质
 *
 * TRTC 提供了三种精心校调好的模式，用来满足各种垂直场景下对音质的差异化追求：
 * - 人声模式（Speech）：适用于以人声沟通为主的应用场景，该模式下音频传输的抗性较强，TRTC 会通过各种人声处理技术保障在弱网络环境下的流畅度最佳。
 * - 音乐模式（Music）：适用于对声乐要求很苛刻的场景，该模式下音频传输的数据量很大，TRTC 会通过各项技术确保音乐信号在各频段均能获得高保真的细节还原度。
 * - 默认模式（Default）：介于 Speech 和 Music 之间的档位，对音乐的还原度比人声模式要好，但传输数据量比音乐模式要低很多，对各种场景均有不错的适应性。
 */
typedef NS_ENUM(NSInteger, TRTCAudioQuality) {

    ///人声模式：采样率：16k；单声道；编码码率：16kbps；具备几个模式中最强的网络抗性，适合语音通话为主的场景，比如在线会议，语音通话等。
    TRTCAudioQualitySpeech = 1,

    ///默认模式：采样率：48k；单声道；编码码率：50kbps；介于 Speech 和 Music 之间的档位，SDK 默认档位，推荐选择。
    TRTCAudioQualityDefault = 2,

    ///音乐模式：采样率：48k；全频带立体声；编码码率：128kbps；适合需要高保真传输音乐的场景，比如在线K歌、音乐直播等。
    TRTCAudioQualityMusic = 3,

};

/**
 * 3.3 音频路由（即声音的播放模式）
 *
 * 音频路由，即声音是从手机的扬声器还是从听筒中播放出来，因此该接口仅适用于手机等移动端设备。
 * 手机有两个扬声器：一个是位于手机顶部的听筒，一个是位于手机底部的立体声扬声器。
 * - 设置音频路由为听筒时，声音比较小，只有将耳朵凑近才能听清楚，隐私性较好，适合用于接听电话。
 * - 设置音频路由为扬声器时，声音比较大，不用将手机贴脸也能听清，因此可以实现“免提”的功能。
 */
typedef NS_ENUM(NSInteger, TRTCAudioRoute) {

    /// Speakerphone：使用扬声器播放（即“免提”），扬声器位于手机底部，声音偏大，适合外放音乐。
    TRTCAudioModeSpeakerphone = 0,

    /// Earpiece：使用听筒播放，听筒位于手机顶部，声音偏小，适合需要保护隐私的通话场景。
    TRTCAudioModeEarpiece = 1,

};

/**
 * 3.4 声音混响模式
 *
 * 该枚举值应用于设定直播场景中的混响模式，常用于秀场直播中。
 */
typedef NS_ENUM(NSInteger, TRTCReverbType) {

    ///关闭混响
    TRTCReverbType_0 = 0,

    /// KTV
    TRTCReverbType_1 = 1,

    ///小房间
    TRTCReverbType_2 = 2,

    ///大会堂
    TRTCReverbType_3 = 3,

    ///低沉
    TRTCReverbType_4 = 4,

    ///洪亮
    TRTCReverbType_5 = 5,

    ///金属声
    TRTCReverbType_6 = 6,

    ///磁性
    TRTCReverbType_7 = 7,

};

/**
 * 3.5 变声类型
 *
 * 该枚举值应用于设定直播场景中的变声模式，常用于秀场直播中。
 */
typedef NS_ENUM(NSInteger, TRTCVoiceChangerType) {

    ///关闭变声
    TRTCVoiceChangerType_0 = 0,

    ///熊孩子
    TRTCVoiceChangerType_1 = 1,

    ///萝莉
    TRTCVoiceChangerType_2 = 2,

    ///大叔
    TRTCVoiceChangerType_3 = 3,

    ///重金属
    TRTCVoiceChangerType_4 = 4,

    ///感冒
    TRTCVoiceChangerType_5 = 5,

    ///外国人
    TRTCVoiceChangerType_6 = 6,

    ///困兽
    TRTCVoiceChangerType_7 = 7,

    ///死肥仔
    TRTCVoiceChangerType_8 = 8,

    ///强电流
    TRTCVoiceChangerType_9 = 9,

    ///重机械
    TRTCVoiceChangerType_10 = 10,

    ///空灵
    TRTCVoiceChangerType_11 = 11,

};

/**
 * 3.6 系统音量类型（仅适用于移动设备）
 *
 * 现代智能手机中一般都具备两套系统音量类型，即“通话音量”和“媒体音量”。
 * - 通话音量：手机专门为接打电话所设计的音量类型，自带回声抵消（AEC）功能，并且支持通过蓝牙耳机上的麦克风进行拾音，缺点是音质比较一般。
 *            当您通过手机侧面的音量按键下调手机音量时，如果无法将其调至零（也就是无法彻底静音），说明您的手机当前处于通话音量。
 * - 媒体音量：手机专门为音乐场景所设计的音量类型，无法使用系统的 AEC 功能，并且不支持通过蓝牙耳机的麦克风进行拾音，但具备更好的音乐播放效果。
 *            当您通过手机侧面的音量按键下调手机音量时，如果能够将手机音量调至彻底静音，说明您的手机当前处于媒体音量。
 * SDK 目前提供了三种系统音量类型的控制模式：自动切换模式、全程通话音量模式、全程媒体音量模式。
 */
typedef NS_ENUM(NSInteger, TRTCSystemVolumeType) {

    ///自动切换模式：
    ///也被称为“麦上通话，麦下媒体”，即主播上麦时使用通话音量，观众不上麦则使用媒体音量，适合在线直播场景。
    ///如果您在 enterRoom 时选择的场景为 TRTCAppSceneLIVE 或 TRTCAppSceneVoiceChatRoom，SDK 会自动使用该模式。
    TRTCSystemVolumeTypeAuto = 0,

    ///全程媒体音量：
    ///通话全程使用媒体音量，并不是非常常用的音量类型，适用于对音质要求比较苛刻的音乐场景中。
    ///如果您的用户大都使用外接设备（比如外接声卡）为主，可以使用该模式，否则请慎用。
    TRTCSystemVolumeTypeMedia = 1,

    ///全程通话音量：
    ///该方案的优势在于用户在上下麦时音频模块无需切换工作模式，可以做到无缝上下麦，适合于用户需要频繁上下麦的应用场景。
    ///如果您在 enterRoom 时选择的场景为 TRTCAppSceneVideoCall 或 TRTCAppSceneAudioCall，SDK 会自动使用该模式。
    TRTCSystemVolumeTypeVOIP = 2,

};

/////////////////////////////////////////////////////////////////////////////////
//
//                      更多枚举值定义
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 4.1 Log 级别
 *
 * 不同的日志等级定义了不同的详实程度和日志数量，推荐一般情况下将日志等级设置为：TRTCLogLevelInfo。
 */
typedef NS_ENUM(NSInteger, TRTCLogLevel) {

    ///输出所有级别的 Log
    TRTCLogLevelVerbose = 0,

    ///输出 DEBUG，INFO，WARNING，ERROR 和 FATAL 级别的 Log
    TRTCLogLevelDebug = 1,

    ///输出 INFO，WARNING，ERROR 和 FATAL 级别的 Log
    TRTCLogLevelInfo = 2,

    ///输出WARNING，ERROR 和 FATAL 级别的 Log
    TRTCLogLevelWarn = 3,

    ///输出ERROR 和 FATAL 级别的 Log
    TRTCLogLevelError = 4,

    ///仅输出 FATAL 级别的 Log
    TRTCLogLevelFatal = 5,

    ///不输出任何 SDK Log
    TRTCLogLevelNone = 6,

};

/**
 * 4.2 重力感应开关（仅适用于移动端）
 */
typedef NS_ENUM(NSInteger, TRTCGSensorMode) {

    ///不适配重力感应
    ///该模式是桌面平台上的默认值，该模式下，当前用户发布出去的视频画面不受重力感应方向变化的影响。
    TRTCGSensorMode_Disable = 0,

    ///适配重力感应
    ///该模式是移动平台上的默认值，该模式下，当前用户发布出去的视频画面会跟随设备的重力感应方向进行相应的调整，同时本地预览画面保持方向不变。
    /// SDK 目前支持的一种适配模式是：当手机或 Pad 上下颠倒时，为了保证远端用户看到的画面方向正常，SDK 会自动将发布出去的画面上下旋转180度。
    ///如果您的 APP 的界面层开启了重力感应自适应，推荐使用 UIFixLayout 模式。
    TRTCGSensorMode_UIAutoLayout = 1,

    ///适配重力感应
    ///该模式下，当前用户发布出去的视频画面会跟随设备的重力感应方向进行相应的调整，同时本地预览画面也会进行相应的旋转适配。
    ///目前支持的一种特性是：当手机或 Pad 上下颠倒时，为了保证远端用户看到的画面方向正常，SDK 会自动将发布出去的画面上下旋转180度。
    ///如果您的 APP 的界面层不支持重力感应自适应，并且希望 SDK 的视频画面能够适配重力感应方向，推荐使用 UIFixLayout 模式。
    TRTCGSensorMode_UIFixLayout = 2,

};

/**
 * 4.3 屏幕分享的目标类型（仅适用于桌面端）
 */
typedef NS_ENUM(NSInteger, TRTCScreenCaptureSourceType) {

    ///未定义
    TRTCScreenCaptureSourceTypeUnknown = -1,

    ///该分享目标是某一个应用的窗口
    TRTCScreenCaptureSourceTypeWindow = 0,

    ///该分享目标是某一台显示器的屏幕
    TRTCScreenCaptureSourceTypeScreen = 1,

};

/**
 * 4.4 云端混流的排版模式
 *
 * TRTC 的云端混流服务能够将房间中的多路音视频流混合成一路，因此您需要指定画面的排版方案，我们提供了如下几种排版模式：
 */
typedef NS_ENUM(NSInteger, TRTCTranscodingConfigMode) {

    ///未定义
    TRTCTranscodingConfigMode_Unknown = 0,

    ///全手动排版模式
    ///该模式下，您需要指定每一路画面的精确排版位置。该模式的自由度最高，但易用性也最差：
    ///- 您需要填写 TRTCTranscodingConfig 中的所有参数，包括每一路画面（TRTCMixUser）的位置坐标。
    ///- 您需要监听 TRTCCloudDelegate 中的 onUserVideoAvailable() 和 onUserAudioAvailable() 事件回调，并根据当前房间中各个麦上用户的音视频状态不断地调整 mixUsers 参数。
    TRTCTranscodingConfigMode_Manual = 1,

    ///纯音频模式
    ///该模式适用于语音通话（AudioCall）和语音聊天室（VoiceChatRoom）等纯音频的应用场景。
    ///- 您只需要在进入房间后，通过 setMixTranscodingConfig() 接口设置一次，之后 SDK 就会自动把房间内所有上麦用户的声音混流到当前用户的直播流上。
    ///- 您无需设置 TRTCTranscodingConfig 中的 mixUsers 参数，只需设置 audioSampleRate、audioBitrate 和 audioChannels 等参数即可。
    TRTCTranscodingConfigMode_Template_PureAudio = 2,

    ///预排版模式
    ///最受欢迎的排版模式，因为该模式支持您通过占位符提前对各路画面的位置进行设定，之后 SDK 会自动根据房间中画面的路数动态进行适配调整。
    ///此模式下，您依然需要设置 mixUsers 参数，但可以将 userId 设置为“占位符”，可选的占位符有：
    /// - "$PLACE_HOLDER_REMOTE$"     :  指代远程用户的画面，可以设置多个。
    /// - "$PLACE_HOLDER_LOCAL_MAIN$" ： 指代本地摄像头画面，只允许设置一个。
    /// - "$PLACE_HOLDER_LOCAL_SUB$"  :  指代本地屏幕分享画面，只允许设置一个。
    ///此模式下，您不需要监听 TRTCCloudDelegate 中的 onUserVideoAvailable() 和 onUserAudioAvailable() 回调进行实时调整，
    ///只需要在进房成功后调用一次 setMixTranscodingConfig() 即可，之后 SDK 会自动将真实的 userId 补位到您设置的占位符上。
    TRTCTranscodingConfigMode_Template_PresetLayout = 3,

    ///屏幕分享模式
    ///适用于在线教育场景等以屏幕分享为主的应用场景，仅支持 Windows 和 Mac 两个平台的 SDK。
    ///该模式下，SDK 会先根据您通过 videoWidth 和 videoHeight 参数设置的目标分辨率构建一张画布，
    ///- 当老师未开启屏幕分享时，SDK 会将老师的摄像头画面等比例拉伸绘制到该画布上；
    ///- 当老师开启屏幕分享之后，SDK 会将屏幕分享画面绘制到同样的画布上。
    ///此种排版模式的目的是为了确保混流模块的输出分辨率一致，避免课程回放和网页观看的花屏问题（网页播放器不支持可变分辨率）。
    ///同时，连麦学生的声音也会被默认混合到老师的音视频流中。
    ///< br>
    ///由于教学模式下的视频内容以屏幕分享为主，因此同时传输摄像头画面和屏幕分享画面是非常浪费带宽的。
    ///推荐的做法是直接将摄像头画面通过 setLocalVideoRenderCallback 接口自定义绘制到当前屏幕上。
    ///在该模式下，您无需设置 TRTCTranscodingConfig 中的 mixUsers 参数，SDK 不会混合学生的画面，以免干扰屏幕分享的效果。
    ///< br>
    ///您可以将 TRTCTranscodingConfig 中的 width × height 设为 0px × 0px，SDK 会自动根据用户当前屏幕的宽高比计算出一个合适的分辨率：
    ///- 如果老师当前屏幕宽度 <= 1920px，SDK 会使用老师当前屏幕的实际分辨率。
    ///- 如果老师当前屏幕宽度 >  1920px，SDK 会根据当前屏幕宽高比，选择 1920x1080(16:9)、1920x1200(16:10)、1920x1440(4:3) 三种分辨率中的一种。
    TRTCTranscodingConfigMode_Template_ScreenSharing = 4,

};

/**
 * 4.5 媒体录制类型
 *
 * 该枚举类型用于本地媒体录制接口{@link startLocalRecording}，用于指定是录制音视频文件还是纯音频文件。
 */
typedef NS_ENUM(NSUInteger, TRTCRecordType) {

    ///仅录制音频
    TRTCRecordTypeAudio = 0,

    ///仅录制视频
    TRTCRecordTypeVideo = 1,

    ///同时录制音频和视频
    TRTCRecordTypeBoth = 2,

};

/**
 * 4.6 混流输入类型
 */
typedef NS_ENUM(NSUInteger, TRTCMixInputType) {

    ///不指定，SDK 会根据另一个参数 pureAudio 的数值决定混流输入类型
    TRTCMixInputTypeUndefined = 0,

    ///混入音频和视频
    TRTCMixInputTypeAudioVideo = 1,

    ///只混入视频
    TRTCMixInputTypePureVideo = 2,

    ///只混入音频
    TRTCMixInputTypePureAudio = 3,

};

/**
 * 4.7 设备类型（仅适用于桌面平台）
 *
 * 该枚举值用于定义三种类型的音视频设备，即摄像头、麦克风和扬声器，以便让一套设备管理接口可以操控三种不同类型的设备。
 * 自 Ver8.0 版本开始，TRTC 在 TXDeviceManager 中重新定义了 “TXMediaDeviceType” 用于替换老版本中的 “TRTCMediaDeviceType”，
 * 此处仅保留 “TRTCMediaDeviceType” 的定义，用于兼容老版本的客户代码。
 */
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
typedef NS_ENUM(NSInteger, TRTCMediaDeviceType) {
    TRTCMediaDeviceTypeUnknown = -1,     ///< undefined device type
    TRTCMediaDeviceTypeAudioInput = 0,   ///< microphone
    TRTCMediaDeviceTypeAudioOutput = 1,  ///< speaker
    TRTCMediaDeviceTypeVideoCamera = 2,  ///< camera
    TRTCMediaDeviceTypeVideoWindow = 3,  ///< windows(for screen share)
    TRTCMediaDeviceTypeVideoScreen = 4,  ///< screen (for screen share)
} __attribute__((deprecated("use TXDeviceManager#TXMediaDeviceType instead")));

typedef TXMediaDeviceInfo TRTCMediaDeviceInfo __attribute__((deprecated("use TXDeviceManager#TXMediaDeviceInfo instead")));
#endif

/**
 * 4.11 音频录制内容类型
 *
 * 该枚举类型用于音频录制接口{@link startAudioRecording}，用于指定录制音频的内容。
 */
typedef NS_ENUM(NSUInteger, TRTCAudioRecordingContent) {

    ///录制本地和远端所有音频
    TRTCAudioRecordingContentAll = 0,

    ///仅录制本地音频
    TRTCAudioRecordingContentLocal = 1,

    ///仅录制远端音频
    TRTCAudioRecordingContentRemote = 2,

};

/////////////////////////////////////////////////////////////////////////////////
//
//                      TRTC 核心类型定义
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 5.1 进房参数
 *
 * 作为 TRTC SDK 的进房参数，只有该参数填写正确，才能顺利进入 roomId 或者 strRoomId 所指定的音视频房间。
 * 由于历史原因，TRTC 支持数字和字符串两种类型的房间号，分别是 roomId 和 strRoomId。
 * 请注意：不要混用 roomId 和 strRoomId，因为它们之间是不互通的，比如数字 123 和字符串 “123” 在 TRTC 看来是两个完全不同的房间。
 */
@interface TRTCParams : NSObject

///【字段含义】应用标识（必填），腾讯云基于 sdkAppId 完成计费统计。
///【推荐取值】在 [实时音视频控制台](https://console.cloud.tencent.com/rav/) 创建应用后可以在账号信息页面中得到该 ID。
@property(nonatomic, assign) UInt32 sdkAppId;

///【字段含义】用户标识（必填），当前用户的 userId，相当于用户名，使用 UTF-8 编码。
///【推荐取值】如果一个用户在您的帐号系统中的 ID 为“mike”，则 userId 即可设置为“mike”。
@property(nonatomic, copy, nonnull) NSString *userId;

///【字段含义】用户签名（必填），当前 userId 对应的验证签名，相当于使用云服务的登录密码。
///【推荐取值】具体计算方法请参见 [如何计算UserSig](https://cloud.tencent.com/document/product/647/17275)。
@property(nonatomic, copy, nonnull) NSString *userSig;

///【字段含义】数字房间号，在同一个房间里的用户（userId）可以彼此看到对方并进行音视频通话。
///【推荐取值】取值范围：1 - 4294967294。
///【特别说明】roomId 与 strRoomId 是互斥的，若您选用 strRoomId，则 roomId 需要填写为0。若两者都填，SDK 将优先选用 roomId。
///【请您注意】不要混用 roomId 和 strRoomId，因为它们之间是不互通的，比如数字 123 和字符串 “123” 在 TRTC 看来是两个完全不同的房间。
@property(nonatomic, assign) UInt32 roomId;

///【字段含义】字符串房间号，在同一个房间里的用户（userId）可以彼此看到对方并进行音视频通话。
///【特别说明】roomId 与 strRoomId 是互斥的，若您选用 strRoomId，则 roomId 需要填写为0。若两者都填，SDK 将优先选用 roomId。
///【请您注意】不要混用 roomId 和 strRoomId，因为它们之间是不互通的，比如数字 123 和字符串 “123” 在 TRTC 看来是两个完全不同的房间。
///【推荐取值】限制长度为64字节。以下为支持的字符集范围（共 89 个字符）:
/// - 大小写英文字母（a-zA-Z）；
/// - 数字（0-9）；
/// - 空格、"!"、"#"、"$"、"%"、"&"、"("、")"、"+"、"-"、":"、";"、"<"、"="、"."、">"、"?"、"@"、"["、"]"、"^"、"_"、" {"、"}"、"|"、"~"、","。
@property(nonatomic, copy, nonnull) NSString *strRoomId;

///【字段含义】直播场景下的角色，仅适用于直播场景（{@link TRTCAppSceneLIVE} 和{@link TRTCAppSceneVoiceChatRoom}），通话场景下指定该参数是无效的。
///【推荐取值】默认值：主播（{@link TRTCRoleAnchor}）。
@property(nonatomic, assign) TRTCRoleType role;

///【字段含义】用于指定在腾讯云直播平台上的 streamId（选填），设置之后，您可以在腾讯云直播 CDN 上通过标准拉流方案（FLV或HLS）播放该用户的音视频流。
///【推荐取值】限制长度为64字节，可以不填写，一种推荐的方案是使用 “sdkappid_roomid_userid_main” 作为 streamid，这中命名方式容易辨认且不会在您的多个应用中发生冲突。
///【特殊说明】要使用腾讯云直播 CDN，您需要先在[控制台](https://console.cloud.tencent.com/trtc/) 中的功能配置页开启“启动自动旁路直播”开关。
///【参考文档】[CDN 旁路直播](https://cloud.tencent.com/document/product/647/16826)。
@property(nonatomic, copy, nullable) NSString *streamId;

///【字段含义】云端录制开关（选填），用于指定是否要在云端将该用户的音视频流录制下来。
///【参考文档】[云端录制](https://cloud.tencent.com/document/product/647/16823)。
///【推荐取值】限制长度为64字节，只允许包含大小写英文字母（a-zA-Z）、数字（0-9）及下划线和连词符。
/// <p>
/// 方案一：手动录制方案：
/// 1. 在“[控制台](https://console.cloud.tencent.com/trtc) => 应用管理 => 云端录制配置”中开启云端录制。
/// 2. 设置“录制形式”为“手动录制”。
/// 3. 设置手动录制后，在一个 TRTC 房间中只有设置了 userDefineRecordId 参数的用户才会在云端录制出视频文件，不指定该参数的用户不会产生录制行为。
/// 4. 云端会以 “userDefineRecordId_起始时间_结束时间” 的格式命名录制下来的文件。
/// <p>
/// 方案二：自动录制方案：
/// 1. 需要在“[控制台](https://console.cloud.tencent.com/trtc) => 应用管理 => 云端录制配置”中开启云端录制。
/// 2. 设置“录制形式”为“自动录制”。
/// 3. 设置自动录制后，在一个 TRTC 房间中的任何一个有音视频上行的用户，均会在云端录制出视频文件。
/// 4. 文件会以 “userDefineRecordId_起始时间_结束时间” 的格式命名，如果不指定 userDefineRecordId，则文件会以 “streamId_起始时间_结束时间”  命名。
/// <br>
@property(nonatomic, copy, nullable) NSString *userDefineRecordId;

///【字段含义】用于权限控制的权限票据（选填），当您希望某个房间只能让特定的 userId 进入时，需要使用 privateMapKey 进行权限保护。
///【推荐取值】仅建议有高级别安全需求的客户使用，更多详情请参见 [进房权限保护](https://cloud.tencent.com/document/product/647/32240)。
@property(nonatomic, copy, nullable) NSString *privateMapKey;

///【字段含义】业务数据字段（选填），部分高级特性才需要用到此字段。
///【推荐取值】请不要自行设置该字段。
@property(nonatomic, copy, nullable) NSString *bussInfo;
@end

/**
 * 5.2 视频编码参数
 *
 * 该设置决定远端用户看到的画面质量，同时也决定了云端录制出的视频文件的画面质量。
 */
@interface TRTCVideoEncParam : NSObject

///【字段含义】 视频分辨率
///【特别说明】如需使用竖屏分辨率，请指定 resMode 为 Portrait，例如： 640 × 360 + Portrait = 360 × 640。
///【推荐取值】
/// - 手机视频通话：建议选择 360 × 640 及以下分辨率，resMode 选择 Portrait，即竖屏分辨率。
/// - 手机在线直播：建议选择 540 × 960，resMode 选择 Portrait，即竖屏分辨率。
/// - 桌面平台（Win + Mac）：建议选择 640 × 360 及以上分辨率，resMode 选择 Landscape，即横屏分辨率。
@property(nonatomic, assign) TRTCVideoResolution videoResolution;

///【字段含义】分辨率模式（横屏分辨率 or 竖屏分辨率）
///【推荐取值】手机平台（iOS、Android）建议选择 Portrait，桌面平台（Windows、Mac）建议选择 Landscape。
///【特别说明】如需使用竖屏分辨率，请指定 resMode 为 Portrait，例如： 640 × 360 + Portrait = 360 × 640。
@property(nonatomic, assign) TRTCVideoResolutionMode resMode;

///【字段含义】视频采集帧率
///【推荐取值】15fps或20fps。5fps以下，卡顿感明显。10fps以下，会有轻微卡顿感。20fps以上，会浪费带宽（电影的帧率为24fps）。
///【特别说明】部分 Android 手机的前置摄像头并不支持15fps以上的采集帧率，部分主打美颜功能的 Android 手机的前置摄像头的采集帧率可能低于10fps。
@property(nonatomic, assign) int videoFps;

///【字段含义】目标视频码率，SDK 会按照目标码率进行编码，只有在弱网络环境下才会主动降低视频码率。
///【推荐取值】请参考本 TRTCVideoResolution 在各档位注释的最佳码率，也可以在此基础上适当调高。
///           比如：TRTCVideoResolution_1280_720 对应 1200kbps 的目标码率，您也可以设置为 1500kbps 用来获得更好的观感清晰度。
///【特别说明】您可以通过同时设置 videoBitrate 和 minVideoBitrate 两个参数，用于约束 SDK 对视频码率的调整范围：
/// - 如果您追求“弱网络下允许卡顿但要保持清晰”的效果，可以设置 minVideoBitrate 为 videoBitrate 的 60%；
/// - 如果您追求“弱网络下允许模糊但要保持流畅”的效果，可以设置 minVideoBitrate 为一个较低的数值（比如 100kbps）；
/// - 如果您将 videoBitrate 和 minVideoBitrate 设置为同一个值，等价于关闭 SDK 对视频码率的自适应调节能力。
@property(nonatomic, assign) int videoBitrate;

///【字段含义】最低视频码率，SDK 会在网络不佳的情况下主动降低视频码率以保持流畅度，最低会降至 minVideoBitrate 所设定的数值。
///【特别说明】 默认值：0，此时最低码率由 SDK 会根据您指定的分辨率，自动计算出合适的数值。
///【推荐取值】您可以通过同时设置 videoBitrate 和 minVideoBitrate 两个参数，用于约束 SDK 对视频码率的调整范围：
/// - 如果您追求“弱网络下允许卡顿但要保持清晰”的效果，可以设置 minVideoBitrate 为 videoBitrate 的 60%；
/// - 如果您追求“弱网络下允许模糊但要保持流畅”的效果，可以设置 minVideoBitrate 为一个较低的数值（比如 100kbps）；
/// - 如果您将 videoBitrate 和 minVideoBitrate 设置为同一个值，等价于关闭 SDK 对视频码率的自适应调节能力。
@property(nonatomic, assign) int minVideoBitrate;

///【字段含义】是否允许动态调整分辨率（开启后会对云端录制产生影响）。
///【推荐取值】该功能适用于不需要云端录制的场景，开启后 SDK 会根据当前网络情况，智能选择出一个合适的分辨率，避免出现“大分辨率+小码率”的低效编码模式。
///【特别说明】默认值：关闭。如有云端录制的需求，请不要开启此功能，因为如果视频分辨率发生变化后，云端录制出的 MP4 在普通的播放器上无法正常播放。
@property(nonatomic, assign) BOOL enableAdjustRes;
@end

/**
 * 5.3 网络流控（Qos）参数集
 *
 * 网络流控相关参数，该设置决定 SDK 在弱网络环境下的调控策略（例如：“清晰优先”或“流畅优先”）
 */
@interface TRTCNetworkQosParam : NSObject

///【字段含义】清晰优先还是流畅优先
///【推荐取值】清晰优先
///【特别说明】该参数主要影响 TRTC 在较差网络环境下的音视频表现：
/// - 流畅优先：即当前网络不足以传输既清晰又流畅的画面时，优先保证画面的流畅性，代价就是画面会比较模糊且伴随有较多的马赛克。
/// - 清晰优先（默认值）：即当前网络不足以传输既清晰又流畅的画面时，优先保证画面的清晰度，代价就是画面会比较卡顿。
@property(nonatomic, assign) TRTCVideoQosPreference preference;

///【字段含义】流控模式（已废弃）
///【推荐取值】云端控制
///【特别说明】请设置为云端控制模式（TRTCQosControlModeServer）
@property(nonatomic, assign) TRTCQosControlMode controlMode;
@end

/**
 * 5.4 视频画面的渲染参数
 *
 * 您可以通过设置此参数来控制画面的旋转角度、填充模式和左右镜像模式。
 */
@interface TRTCRenderParams : NSObject

///【字段含义】图像的顺时针旋转角度
///【推荐取值】支持90、180以及270旋转角度，默认值：{@link TRTCVideoRotation_0}
@property(nonatomic) TRTCVideoRotation rotation;

///【字段含义】画面填充模式
///【推荐取值】填充（画面可能会被拉伸裁剪）或适应（画面可能会有黑边），默认值：{@link TRTCVideoFillMode_Fill}
@property(nonatomic) TRTCVideoFillMode fillMode;

///【字段含义】画面镜像模式
///【推荐取值】默认值：{@link TRTCVideoMirrorType_Auto}
@property(nonatomic) TRTCVideoMirrorType mirrorType;

@end

/**
 * 5.5 网络质量
 *
 * 表征网络质量的好坏，您可以通过该数值在用户界面上展示每个用户的网络质量。
 */
@interface TRTCQualityInfo : NSObject

///用户 ID
@property(nonatomic, copy, nullable) NSString *userId;

///网络质量
@property(nonatomic, assign) TRTCQuality quality;
@end

/**
 * 5.6 音量大小
 *
 * 表征语音音量的评估值，您可以通过该数值在用户界面上展示每个用户的音量大小。
 */
@interface TRTCVolumeInfo : NSObject

///说话者的 userId, 如果 userId 为空则代表是当前用户自己。
@property(nonatomic, copy, nullable) NSString *userId;

///说话者的音量大小, 取值范围[0 - 100]。
@property(assign, nonatomic) NSUInteger volume;

@end

/**
 * 5.7 网络测速结果
 *
 * 您可以在用户进入房间前通过 {@link startSpeedTest} 接口进行测速（注意：请不要在通话中调用），
 * 测速结果会每2 - 3秒钟返回一次，每次返回一个 IP 地址的测试结果。
 */
@interface TRTCSpeedTestResult : NSObject

///服务器 IP 地址
@property(strong, nonatomic, nonnull) NSString *ip;

///内部通过评估算法测算出的网络质量，网络质量越好得分越高。
@property(nonatomic) TRTCQuality quality;

///上行丢包率，取值范围是 [0 - 1.0]，例如 0.3 表示每向服务器发送10个数据包可能会在中途丢失3个。
@property(nonatomic) float upLostRate;

///下行丢包率，取值范围是 [0 - 1.0]，例如 0.2 表示每从服务器收取10个数据包可能会在中途丢失2个。
@property(nonatomic) float downLostRate;

///延迟（毫秒），指当前设备到 TRTC 服务器的一次网络往返时间，该值越小越好，正常数值范围是10ms - 100ms。
@property(nonatomic) uint32_t rtt;
@end

/**
 * 5.9 视频帧信息
 *
 * TRTCVideoFrame 用来描述一帧视频画面的裸数据，也就是编码前或者解码后的视频画面数据。
 */
@interface TRTCVideoFrame : NSObject

///【字段含义】视频的像素格式
@property(nonatomic, assign) TRTCVideoPixelFormat pixelFormat;

///【字段含义】视频数据结构类型
@property(nonatomic, assign) TRTCVideoBufferType bufferType;

///【字段含义】bufferType 为 {@link TRTCVideoBufferType_PixelBuffer} 时的视频数据，承载 iOS 平台专用的 PixelBuffer。
@property(nonatomic, assign, nullable) CVPixelBufferRef pixelBuffer;

///【字段含义】bufferType 为 {@link TRTCVideoBufferType_NSData} 时的视频数据，承载 NSData 类型的内存数据块。
@property(nonatomic, retain, nullable) NSData *data;

///【字段含义】视频纹理 ID,bufferType 为 {@link TRTCVideoBufferType_Texture} 时的视频数据，承载用于 OpenGL 渲染的纹理数据。
@property(nonatomic, assign) GLuint textureId;

///【字段含义】视频宽度
@property(nonatomic, assign) uint32_t width;

///【字段含义】视频高度
@property(nonatomic, assign) uint32_t height;

///【字段含义】视频帧的时间戳，单位毫秒
///【推荐取值】自定义视频采集时可以设置为0。若该参数为0，SDK 会自定填充 timestamp 字段，但请“均匀”地控制 sendCustomVideoData 的调用间隔。
@property(nonatomic, assign) uint64_t timestamp;

///【字段含义】视频像素的顺时针旋转角度
@property(nonatomic, assign) TRTCVideoRotation rotation;

@end

/**
 * 5.10 音频帧数据
 */
@interface TRTCAudioFrame : NSObject

///【字段含义】音频数据
@property(nonatomic, retain, nonnull) NSData *data;

///【字段含义】采样率
@property(nonatomic, assign) TRTCAudioSampleRate sampleRate;

///【字段含义】声道数
@property(nonatomic, assign) int channels;

///【字段含义】时间戳，单位ms
@property(nonatomic, assign) uint64_t timestamp;

///【字段含义】音频额外数据，远端用户通过 `onLocalProcessedAudioFrame` 写入的数据会通过该字段回调
@property(nonatomic, retain, nullable) NSData *extraData;
@end

/**
 * 5.11 云端混流中各路画面的描述信息
 *
 * TRTCMixUser 用于指定云端混流中每一路视频画面的位置、大小、图层以及流类型等信息。
 */
@interface TRTCMixUser : NSObject

///【字段含义】用户 ID
@property(nonatomic, copy, nonnull) NSString *userId;

///【字段含义】该路音视频流所在的房间号（设置为空值代表当前用户所在的房间号）
@property(nonatomic, copy, nullable) NSString *roomID;

///【字段含义】指定该路画面的坐标区域（单位：像素）
@property(nonatomic, assign) CGRect rect;

///【字段含义】指定该路画面的层级（取值范围：1 - 15，不可重复）
@property(nonatomic, assign) int zOrder;

///【字段含义】指定该路画面是主路画面（{@link TRTCVideoStreamTypeBig}）还是辅路画面（{@link TRTCVideoStreamTypeSub}）。
@property(nonatomic) TRTCVideoStreamType streamType;

///【字段含义】指定该路流是不是只混合声音
///【推荐取值】默认值：NO
///【特别说明】已废弃，推荐使用8.5版本开始新引入的字段：inputType。
@property(nonatomic, assign) BOOL pureAudio;

///【字段含义】指定该路流的混合内容（只混合音频、只混合视频、混合音频和视频），该字段是对 pureAudio 字段的升级。
///【推荐取值】默认值：TRTCMixInputTypeUndefined，代表参考 pureAudio 的取值。
///   - 如果您是第一次使用 TRTC，之前并没有对 pureAudio 字段进行过设置，您可以根据实际需要设置该字段，不建议您再设置 pureAudio。
///   - 如果您之前在老版本中已经使用了 pureAudio 字段，并期望保持其设置，则可以将 inputType 设置为 TRTCMixInputTypeUndefined。
@property(nonatomic, assign) TRTCMixInputType inputType;

@end

/**
 * 5.12 云端混流的排版布局和转码参数
 *
 * 用于指定混流时各路画面的排版位置信息和云端转码的编码参数。
 */
@interface TRTCTranscodingConfig : NSObject

///【字段含义】排版模式
///【推荐取值】请根据您的业务场景要求自行选择，预排版模式是适用性较好的一种模式。
@property(nonatomic, assign) TRTCTranscodingConfigMode mode;

///【字段含义】腾讯云直播服务的 AppID
///【推荐取值】请在 [实时音视频控制台](https://console.cloud.tencent.com/trtc) 依次单击【应用管理】=>【应用信息】，并在【旁路直播信息】中获取 appid。
@property(nonatomic) int appId;

///【字段含义】腾讯云直播服务的 bizid
///【推荐取值】请在 [实时音视频控制台](https://console.cloud.tencent.com/trtc) 依次单击【应用管理】=>【应用信息】，并在【旁路直播信息】中获取 bizid。
@property(nonatomic) int bizId;

///【字段含义】指定云端转码的目标分辨率（宽度）
///【推荐取值】单位：像素值，推荐值：360，如果你只混合音频流，请将 width 和 height 均设置位 0，否则混流转码后的直播流中会有黑色背景。
@property(nonatomic, assign) int videoWidth;

///【字段含义】指定云端转码的目标分辨率（高度）
///【推荐取值】单位：像素值，推荐值：640，如果你只混合音频流，请将 width 和 height 均设置位 0，否则混流转码后的直播流中会有黑色背景。
@property(nonatomic, assign) int videoHeight;

///【字段含义】指定云端转码的目标视频码率（kbps）
///【推荐取值】如果填0，TRTC 会根据 videoWidth 和 videoHeight 估算出一个合理的码率值，您也可以参考视频分辨率枚举定义中所推荐的码率值（见注释部分）。
@property(nonatomic, assign) int videoBitrate;

///【字段含义】指定云端转码的目标视频帧率（FPS）
///【推荐取值】默认值：15fps，取值范围是 (0,30]。
@property(nonatomic, assign) int videoFramerate;

///【字段含义】指定云端转码的目标视频关键帧间隔（GOP）
///【推荐取值】默认值：2，单位为秒，取值范围是 [1,8]。
@property(nonatomic, assign) int videoGOP;

///【字段含义】指定混合画面的底色颜色
///【推荐取值】默认值：0x000000 代表黑色。格式为十六进制数字，比如：“0x61B9F1” 代表 RGB 分别为(97,158,241)。
@property(nonatomic, assign) int backgroundColor;

///【字段含义】指定混合画面的背景图片
///【推荐取值】默认值：空值，即不设置背景图片。
///【特别说明】背景图需要您事先在 “[控制台](https://console.cloud.tencent.com/trtc) => 应用管理 => 功能配置 => 素材管理” 中单击【新增图片】按钮进行上传。
///           上传成功后可以获得对应的“图片ID”，然后将“图片ID”转换成字符串类型并设置到 backgroundImage 里即可。
///           例如：假设“图片ID” 为 63，可以设置 backgroundImage = @"63";
@property(nonatomic, copy, nullable) NSString *backgroundImage;

///【字段含义】指定云端转码的目标音频采样率
///【推荐取值】默认值：48000Hz。支持12000HZ、16000HZ、22050HZ、24000HZ、32000HZ、44100HZ、48000HZ。
@property(nonatomic, assign) int audioSampleRate;

///【字段含义】指定云端转码的目标音频码率
///【推荐取值】默认值：64kbps，取值范围是 [32，192]。
@property(nonatomic, assign) int audioBitrate;

///【字段含义】指定云端转码的音频声道数
///【推荐取值】默认值：1，代表单声道。可设定的数值只有两个数字：1-单声道，2-双声道。
@property(nonatomic, assign) int audioChannels;

///【字段含义】指定云端混流中每一路视频画面的位置、大小、图层以及流类型等信息
///【推荐取值】该字段是一个 TRTCMixUser 类型的数组，数组中的每一个元素都用来代表每一路画面的信息。
@property(nonatomic, copy, nonnull) NSArray<TRTCMixUser *> *mixUsers;

///【字段含义】输出到 CDN 上的直播流 ID
///【推荐取值】默认值：空值，即房间里的多路音视频流最终会混合到接口调用者的那一路音视频流上。
///    - 如不设置该参数，SDK 会执行默认逻辑，即房间里的多路音视频流会混合到该接口调用者的那一路音视频流上，也就是 A + B => A。
///    - 如您设置该参数，SDK 会将房间里的多路音视频流混合到您指定的直播流上，也就是 A + B => C（C 代表您指定的 streamId）。
@property(nonatomic, copy, nullable) NSString *streamId;

@end

/**
 * 5.13 向非腾讯云 CDN 上发布音视频流时需设置的转推参数
 *
 * TRTC 的后台服务支持通过标准 RTMP 协议，将其中的音视频流发布到第三方直播 CDN 服务商。
 * 如果您使用腾讯云直播 CDN 服务，可无需关注此参数，直接使用 {@link startPublish} 接口即可。
 */
@interface TRTCPublishCDNParam : NSObject

///【字段含义】腾讯云直播服务的 AppID
///【推荐取值】请在 [实时音视频控制台](https://console.cloud.tencent.com/trtc) 依次单击【应用管理】=>【应用信息】，并在【旁路直播信息】中获取 appid。
@property(nonatomic) int appId;

///【字段含义】腾讯云直播服务的 bizid
///【推荐取值】请在 [实时音视频控制台](https://console.cloud.tencent.com/trtc) 依次单击【应用管理】=>【应用信息】，并在【旁路直播信息】中获取 bizid。
@property(nonatomic) int bizId;

///【字段含义】指定该路音视频流在第三方直播服务商的推流地址（RTMP 格式）
///【推荐取值】各家服务商的推流地址规则差异较大，请根据目标服务商的要求填写合法的推流 URL，TRTC 的后台服务器会按照您填写的 URL 向第三方服务商推送标准格式音视频流。
///【特别说明】推流 URL 必须为 RTMP 格式，必须符合您的目标直播服务商的规范要求，否则目标服务商会拒绝来自 TRTC 后台服务的推流请求。
@property(nonatomic, strong, nonnull) NSString *url;

@end

/**
 * 5.14 本地音频文件的录制参数
 *
 * 该参数用于在音频录制接口 {@link startAudioRecording} 中指定录制参数。
 */
@interface TRTCAudioRecordingParams : NSObject

///【字段含义】录音文件的保存路径（必填）。
///【特别说明】该路径需精确到文件名及格式后缀，格式后缀用于决定录音文件的格式，目前支持的格式有 PCM、WAV 和 AAC。
///           例如：假如您指定路径为 "mypath/record/audio.aac"，代表您希望 SDK 生成一个 AAC 格式的音频录制文件。
///           请您指定一个有读写权限的合法路径，否则录音文件无法生成。
@property(nonatomic, strong, nonnull) NSString *filePath;

///【字段含义】音频录制内容类型。
///【特别说明】默认录制所有本地和远端音频。
@property(nonatomic, assign) TRTCAudioRecordingContent recordingContent;

@end

/**
 * 5.15 本地媒体文件的录制参数
 *
 * 该参数用于在本地媒体文件的录制接口 {@link startLocalRecording} 中指定录制相关参数。
 * 接口 startLocalRecording 是接口 startAudioRecording 的能力加强版本，前者可以录制视频文件，后者只能录制音频文件。
 */
@interface TRTCLocalRecordingParams : NSObject

///【字段含义】录制的文件地址（必填），请确保路径有读写权限且合法，否则录制文件无法生成。
///【特别说明】该路径需精确到文件名及格式后缀，格式后缀用于决定录制出的文件格式，目前支持的格式暂时只有 MP4。
///           例如：假如您指定路径为 "mypath/record/test.mp4"，代表您希望 SDK 生成一个 MP4 格式的本地视频文件。
///           请您指定一个有读写权限的合法路径，否则录制文件无法生成。
@property(nonatomic, copy, nonnull) NSString *filePath;

///【字段含义】媒体录制类型，默认值：TRTCRecordTypeBoth，即同时录制音频和视频。
@property(nonatomic, assign) TRTCRecordType recordType;

///【字段含义】interval 录制信息更新频率，单位毫秒，有效范围：1000-10000。默认值为-1，表示不回调。
@property(nonatomic, assign) int interval;

@end

/**
 * 5.16 音效参数（已废弃）
 *
 * TRTC 中的“音效”特指一些短暂的音频文件，通常仅有几秒钟的播放时间，比如“鼓掌声”、“欢笑声”等。
 * 该参数用于在早期版本的音效播放接口 {@link TRTCCloud#playAudioEffect} 中指定音效文件（即短音频文件）的路径和播放次数等。
 * 在 7.3 版本以后，音效接口已被新的接口 {@link TXAudioEffectManager#startPlayMusic} 所取代。
 * 您在指定 startPlayMusic 的参数 {@link TXAudioMusicParam} 时，如果将 “isShortFile” 设置为 true，即为“音效”文件。
 */
@interface TRTCAudioEffectParam : NSObject

+ (_Nonnull instancetype)new __attribute__((unavailable("Use -initWith:(int)effectId path:(NSString * )path instead")));
- (_Nonnull instancetype)init __attribute__((unavailable("Use -initWith:(int)effectId path:(NSString *)path instead")));

///【字段含义】音效 ID
///【特别说明】SDK 允许播放多路音效，因此需要音效 ID 进行标记，用于控制音效的开始、停止、音量等。
@property(nonatomic, assign) int effectId;

///【字段含义】音效文件路径，支持的文件格式：aac, mp3, m4a。
@property(nonatomic, copy, nonnull) NSString *path;

///【字段含义】循环播放次数
///【推荐取值】取值范围为0 - 任意正整数，默认值：0，表示播放音效一次；1表示播放音效两次；以此类推。
@property(nonatomic, assign) int loopCount;

///【字段含义】音效是否上行
///【推荐取值】YES：音效在本地播放的同时，会上行至云端，因此远端用户也能听到该音效；NO：音效不会上行至云端，因此只能在本地听到该音效。默认值：NO
@property(nonatomic, assign) BOOL publish;

///【字段含义】音效音量
///【推荐取值】取值范围为0 - 100；默认值：100
@property(nonatomic, assign) int volume;

- (_Nonnull instancetype)initWith:(int)effectId path:(NSString *_Nonnull)path;
@end

/**
 * 5.17 房间切换参数
 *
 * 该参数用于切换房间接口{@link switchRoom}，可以让用户从一个房间快速切换到另一个房间。
 */
@interface TRTCSwitchRoomConfig : NSObject

///【字段含义】数字房间号码 [选填]，在同一个房间内的用户可以看到彼此并能够进行音视频通话。
///【推荐取值】取值范围：1 - 4294967294。
///【特别说明】roomId 和 strRoomId 必须并且只能填一个。若两者都填，则优先选择 roomId。
@property(nonatomic, assign) UInt32 roomId;

///【字段含义】字符串房间号码 [选填]，在同一个房间内的用户可以看到彼此并能够进行音视频通话。
///【特别说明】roomId 和 strRoomId 必须并且只能填一个。若两者都填，则优先选择 roomId。
@property(nonatomic, copy, nullable) NSString *strRoomId;

///【字段含义】用户签名 [选填]，当前 userId 对应的验证签名，相当于登录密码。
///           如果您在切换房间时不指定新计算出的 userSig，SDK 会继续使用您在进入房间时（enterRoom）时所指定的 userSig。
///           这就需要您必须保证旧的 userSig 在切换房间的那一刻仍在签名允许的效期内，否则会导致房间切换失败。
///【推荐取值】具体计算方法请参考 [如何计算UserSig](https://cloud.tencent.com/document/product/647/17275)。
@property(nonatomic, copy, nullable) NSString *userSig;

///【字段含义】用于权限控制的权限票据（选填），当您希望某个房间只能让特定的 userId 进入时，需要使用 privateMapKey 进行权限保护。
///【推荐取值】仅建议有高级别安全需求的客户使用，更多详情请参见 [进房权限保护](https://cloud.tencent.com/document/product/647/32240)。
@property(nonatomic, copy, nullable) NSString *privateMapKey;

@end

/**
 * 5.18 音频自定义回调的格式参数
 *
 * 该参数用于在音频自定义回调相关的接口中，设置 SDK 回调出来的音频数据的相关格式（包括采样率、声道数等）。
 */
@interface TRTCAudioFrameDelegateFormat : NSObject

///【字段含义】采样率
///【推荐取值】默认值：48000Hz。支持 16000, 32000, 44100, 48000。
@property(nonatomic, assign) TRTCAudioSampleRate sampleRate;

///【字段含义】声道数
///【推荐取值】默认值：1，代表单声道。可设定的数值只有两个数字：1-单声道，2-双声道。
@property(nonatomic, assign) int channels;

///【字段含义】采样点数
///【推荐取值】取值必须是 sampleRate/100 的整数倍。
@property(nonatomic, assign) int samplesPerCall;

@end

/**
 * 5.20 屏幕分享的目标信息（仅适用于桌面系统）
 *
 * 在用户进行屏幕分享时，可以选择抓取整个桌面，也可以仅抓取某个程序的窗口。
 * TRTCScreenCaptureSourceInfo 用于描述待分享目标的信息，包括 ID、名称、缩略图等，该结构体中的字段信息均是只读的。
 */
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
@interface TRTCScreenCaptureSourceInfo : NSObject

///【字段含义】采集源类型（是分享整个屏幕？还是分享某个窗口？）
@property(assign, nonatomic) TRTCScreenCaptureSourceType type;

///【字段含义】采集源的ID，对于窗口，该字段代表窗口的 ID；对于屏幕，该字段代表显示器的 ID。
@property(copy, nonatomic, nullable) NSString *sourceId;

///【字段含义】采集源名称（采用 UTF8 编码）
@property(copy, nonatomic, nullable) NSString *sourceName;

///【字段含义】窗口的扩展信息
@property(nonatomic, strong, nullable) NSDictionary *extInfo;

///【字段含义】分享窗口的缩略图
@property(nonatomic, readonly, nullable) NSImage *thumbnail;

///【字段含义】分享窗口的图标
@property(nonatomic, readonly, nullable) NSImage *icon;

@end
#endif

/// @}
