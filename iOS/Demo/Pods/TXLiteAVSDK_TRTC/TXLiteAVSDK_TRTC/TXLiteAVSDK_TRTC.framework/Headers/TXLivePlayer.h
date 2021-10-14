/*
 *
 * Module:   TXLivePlayer @ TXLiteAVSDK
 *
 * Function: 腾讯云直播播放器
 *
 * Version: <:Version:>
 */

#import <Foundation/Foundation.h>
#import "TXLiveSDKTypeDef.h"
#import "TXLivePlayListener.h"
#import "TXLivePlayConfig.h"
#import "TXVideoCustomProcessDelegate.h"
#import "TXLiveRecordTypeDef.h"
#import "TXLiveRecordListener.h"
#import "TXAudioRawDataDelegate.h"

/// @defgroup TXLivePlayer_ios TXLivePlayer
/// 腾讯云直播播放器接口类
/// @{

/**
 * 支持的直播和点播类型
 *
 * @note 新版本的点播 SDK，推荐参考 TXVodPlayer.h
 */
typedef NS_ENUM(NSInteger, TX_Enum_PlayType) {
    /// RTMP 直播
    PLAY_TYPE_LIVE_RTMP = 0,
    /// FLV 直播
    PLAY_TYPE_LIVE_FLV = 1,
    /// FLV 点播
    PLAY_TYPE_VOD_FLV = 2,
    /// HLS 点播
    PLAY_TYPE_VOD_HLS = 3,
    /// MP4点播
    PLAY_TYPE_VOD_MP4 = 4,
    /// RTMP 直播加速播放
    PLAY_TYPE_LIVE_RTMP_ACC = 5,
    /// 本地视频文件
    PLAY_TYPE_LOCAL_VIDEO = 6,
};


/**
 * 视频播放器
 *
 * 主要负责将直播流的音视频画面进行解码和本地渲染，包含如下技术特点：
 * - 针对腾讯云的拉流地址，可使用低延时拉流，实现直播连麦等相关场景。
 * - 针对腾讯云的拉流地址，可使用直播时移功能，能够实现直播观看与时移观看的无缝切换。
 * - 支持自定义的音视频数据处理，让您可以根据项目需要处理直播流中的音视频数据后，进行渲染以及播放。
 */
@interface TXLivePlayer : NSObject

/////////////////////////////////////////////////////////////////////////////////
//
//                      （一）SDK 基础函数
//
/////////////////////////////////////////////////////////////////////////////////

/// @name SDK 基础函数
/// @{
/**
 * 1.1 设置播放回调，见 “TXLivePlayListener.h” 文件中的详细定义
 */
@property(nonatomic, weak) id <TXLivePlayListener> delegate;

/**
 * 1.2 设置视频处理回调，见 “TXVideoCustomProcessDelegate.h” 文件中的详细定义
 */
@property(nonatomic, weak) id <TXVideoCustomProcessDelegate> videoProcessDelegate;

/**
 * 1.3 设置音频处理回调，见 “TXAudioRawDataDelegate.h” 文件中的详细定义
 */
@property(nonatomic, weak) id <TXAudioRawDataDelegate> audioRawDataDelegate;

/**
 * 1.4 是否开启硬件加速，默认值：NO
 */
@property(nonatomic, assign) BOOL enableHWAcceleration;

/**
 * 1.5 设置 TXLivePlayConfig 播放配置项，见 “TXLivePlayConfig.h” 文件中的详细定义
 */
@property(nonatomic, copy) TXLivePlayConfig *config;

/**
 * 1.6 设置短视频录制回调，见 “TXLiveRecordListener.h” 文件中的详细定义
 */
@property (nonatomic, weak) id<TXLiveRecordListener> recordDelegate;

/**
 * 1.7 startPlay 后是否立即播放，默认 YES，只有点播有效
 */
@property (nonatomic) BOOL isAutoPlay;


/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）播放基础接口
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 播放基础接口
/// @{
/**
 * 2.1 创建 Video 渲染 View，该控件承载着视频内容的展示。
 *
 * 变更历史：1.5.2版本将参数 frame 废弃，设置此参数无效，控件大小与参数 view 的大小保持一致，如需修改控件的大小及位置，请调整父 view 的大小及位置。 参考文档：[绑定渲染界面](https://www.qcloud.com/doc/api/258/4736#step-3.3A-.E7.BB.91.E5.AE.9A.E6.B8.B2.E6.9F.93.E7.95.8C.E9.9D.A2)
 *
 * @param frame Widget 在父 view 中的 frame
 * @param view  父 view
 * @param idx   Widget 在父 view 上 的层级位置
 */
- (void)setupVideoWidget:(CGRect)frame containView:(TXView *)view insertIndex:(unsigned int)idx;

/*
 * 修改 VideoWidget frame
 * 变更历史：1.5.2版本将此方法废弃，调用此方法无效，如需修改控件的大小及位置，请调整父 view 的大小及位置
 * 参考文档：https://www.qcloud.com/doc/api/258/4736#step-3.3A-.E7.BB.91.E5.AE.9A.E6.B8.B2.E6.9F.93.E7.95.8C.E9.9D.A2
 */
//- (void)resetVideoWidgetFrame:(CGRect)frame;

/**
 * 2.2 移除 Video 渲染 Widget
 */
- (void)removeVideoWidget;

/**
 * 2.3 启动从指定 URL 播放 RTMP 音视频流
 *
 * @param url 完整的 URL（如果播放的是本地视频文件，这里传本地视频文件的完整路径）
 * @param playType 播放类型
 * @return 0表示成功，其它为失败
 */
- (int)startPlay:(NSString *)url type:(TX_Enum_PlayType)playType;

/**
 * 2.4 停止播放音视频流
 *
 * @return 0：成功；其它：失败
 */
- (int)stopPlay;

/**
 * 2.5 是否正在播放
 *
 * @return YES 拉流中，NO 没有拉流
 */
- (BOOL)isPlaying;

/**
 * 2.6 暂停播放
 *
 * 适用于点播，直播（此接口会暂停数据拉流，不会销毁播放器，暂停后，播放器会显示最后一帧数据图像）
 */
- (void)pause;

/**
 * 2.6 继续播放，适用于点播，直播
 */
- (void)resume;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （三）视频相关接口
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 视频相关接口
/// @{
/**
 * 3.1 设置画面的方向
 *
 * @param rotation 方向
 * @see TX_Enum_Type_HomeOrientation
 */
- (void)setRenderRotation:(TX_Enum_Type_HomeOrientation)rotation;

/**
 * 3.2 设置画面的裁剪模式
 *
 * @param renderMode 裁剪
 * @see TX_Enum_Type_RenderMode
 */
- (void)setRenderMode:(TX_Enum_Type_RenderMode)renderMode;

/**
 * 3.3 截屏
 *
 * @param snapshotCompletionBlock 通过回调返回当前图像
 */
- (void)snapshot:(void (^)(TXImage *))snapshotCompletionBlock;

/**
 * 3.4 获取当前渲染帧 pts
 *
 * @return 0：当前未处于正在播放状态（例如：未起播）
 *         >0：当前渲染视频帧的 pts，处于正在播放状态 (单位: 毫秒)
 */
- (uint64_t)getCurrentRenderPts;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）音频相关接口
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 音频相关接口
/// @{
/**
 * 4.1 设置静音
 */
- (void)setMute:(BOOL)bEnable;

/**
 * 4.2 设置音量
 *
 * @param volume 音量大小，取值范围0 - 100
 */
- (void)setVolume:(int)volume;

#if TARGET_OS_IPHONE
/**
 * 4.3 设置声音播放模式（切换扬声器，听筒）
 * @param audioRoute 声音播放模式
 */
+ (void)setAudioRoute:(TXAudioRouteType)audioRoute;
#endif

/**
 * 4.4 设置音量大小回调接口
 *
 * @param volumeEvaluationListener 音量大小回调接口，音量取值范围0 - 100
 */
- (void)setAudioVolumeEvaluationListener:(void(^)(int))volumeEvaluationListener;

/**
 * 4.5 启用音量大小提示
 *
 * 开启后会在 volumeEvaluationListener 中获取到 SDK 对音量大小值的评估。
 *
 * @param interval 决定了 volumeEvaluationListener 回调的触发间隔，单位为ms，最小间隔为100ms，如果小于等于0则会关闭回调，建议设置为300ms；
 */
- (void)enableAudioVolumeEvaluation:(NSUInteger)interval;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （五）直播时移相关接口
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 直播时移相关接口
/// @{
/**
 * 5.1 直播时移准备，拉取该直播流的起始播放时间。
 *
 * 使用时移功能需在播放开始后调用此方法，否则时移失败。时移的使用请参考文档 [超级播放器](https://cloud.tencent.com/document/product/881/20208#.E6.97.B6.E7.A7.BB.E6.92.AD.E6.94.BE)
 *
 * @warning 非腾讯云直播地址不能时移
 *
 * @param domain 时移域名
 * @param bizId 流 bizId
 *
 * @return 0：OK；-1：无播放地址；-2：appId 未配置
 */
- (int)prepareLiveSeek:(NSString*)domain bizId:(NSInteger)bizId;

/**
 * 5.2 停止时移播放，返回直播
 *
 * @return 0：成功；其它：失败
 */
- (int)resumeLive;

#if TARGET_OS_IPHONE
/**
 * 5.3 播放跳转到音视频流某个时间
 * @param time 流时间，单位为秒
 * @return 0：成功；其它：失败
 */
- (int)seek:(float)time;
#endif

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （六）视频录制相关接口
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 视频录制相关接口
/// @{
#if TARGET_OS_IPHONE
/**
 * 6.1 开始录制短视频
 *
 * @param recordType 参见 TXRecordType 定义
 * @return 0：成功；1：正在录制短视频；-2：videoRecorder 初始化失败。
 */
- (int)startRecord:(TXRecordType)recordType;

/**
 * 6.2 结束录制短视频
 *
 * @return 0：成功；1：不存在录制任务；-2：videoRecorder 未初始化。
 */
- (int)stopRecord;

/**
 * 6.3 设置播放速率
 *
 * @param rate 正常速度为1.0；小于为慢速；大于为快速。最大建议不超过2.0
 */
- (void)setRate:(float)rate;
#endif

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （七）更多实用接口
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 更多实用接口
/// @{
/**
 * 7.1 设置状态浮层 view 在渲染 view 上的边距
 *
 * @param margin 边距
 */
- (void)setLogViewMargin:(TXEdgeInsets)margin;

/**
 * 7.2 是否显示播放状态统计及事件消息浮层 view
 *
 * @param isShow 是否显示
 */
- (void)showVideoDebugLog:(BOOL)isShow;

/**
 * 7.3 FLV 直播无缝切换
 *
 * @param playUrl 播放地址
 * @return 0：成功；其它：失败
 * @warning playUrl 必须是当前播放直播流的不同清晰度，切换到无关流地址可能会失败
 */
- (int)switchStream:(NSString *)playUrl;

/**
 * 7.4 调用实验性 API 接口
 *
 * @note 该接口用于调用一些实验性功能
 * @param jsonStr 接口及参数描述的 JSON 字符串
 */
- (void)callExperimentalAPI:(NSString*)jsonStr;

/// @}

@end
/// @}
