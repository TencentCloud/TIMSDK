//
//  Copyright © 2020 Tencent. All rights reserved.
//
//  Module: V2TXLive
//

#import "V2TXLivePlayerObserver.h"

/// @defgroup V2TXLivePlayer_ios V2TXLivePlayer
/// 腾讯云直播播放器。<br/>
/// 主要负责从指定的直播流地址拉取音视频数据，并进行解码和本地渲染播放。
///
/// 播放器包含如下能力:
/// - 支持 RTMP, HTTP-FLV, TRTC 以及 WebRTC；
/// - 屏幕截图，可以截取当前直播流的视频画面；
/// - 延时调节，可以设置播放器缓存自动调整的最小和最大时间；
/// - 自定义的视频数据处理，您可以根据项目需要处理直播流中的视频数据后，再进行渲染以及播放。
///
/// @{

@protocol V2TXLivePlayer <NSObject>

/**
 * 设置播放器回调。
 *
 * 通过设置回调，可以监听 V2TXLivePlayer 播放器的一些回调事件，
 * 包括播放器状态、播放音量回调、音视频首帧回调、统计数据、警告和错误信息等。
 *
 * @param observer 播放器的回调目标对象，更多信息请查看 {@link V2TXLivePlayerObserver}
 */
- (void)setObserver:(id<V2TXLivePlayerObserver>)observer;

/**
 * 设置播放器的视频渲染 View。 该控件负责显示视频内容。
 *
 * @param view 播放器渲染 View
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK：成功
 */
- (V2TXLiveCode)setRenderView:(TXView *)view;

/**
 * 设置播放器画面的旋转角度。
 *
 * @param rotation 旋转角度 {@link V2TXLiveRotation}
 *         - V2TXLiveRotation0【默认值】: 0度, 不旋转
 *         - V2TXLiveRotation90:  顺时针旋转90度
 *         - V2TXLiveRotation180: 顺时针旋转180度
 *         - V2TXLiveRotation270: 顺时针旋转270度
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 */
- (V2TXLiveCode)setRenderRotation:(V2TXLiveRotation)rotation;

/**
 * 设置画面的填充模式。
 *
 * @param mode 画面填充模式 {@link V2TXLiveFillMode}。
 *         - V2TXLiveFillModeFill 【默认值】: 图像铺满屏幕，不留黑边，如果图像宽高比不同于屏幕宽高比，部分画面内容会被裁剪掉
 *         - V2TXLiveFillModeFit: 图像适应屏幕，保持画面完整，但如果图像宽高比不同于屏幕宽高比，会有黑边的存在
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 */
- (V2TXLiveCode)setRenderFillMode:(V2TXLiveFillMode)mode;

/**
 * 开始播放音视频流。
 *
 * @param url 音视频流的播放地址，支持 RTMP, HTTP-FLV, TRTC。
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 操作成功，开始连接并播放
 *         - V2TXLIVE_ERROR_INVALID_PARAMETER: 操作失败，url 不合法
 *         - V2TXLIVE_ERROR_REFUSED: RTC 不支持同一设备上同时推拉同一个 StreamId。
 */
- (V2TXLiveCode)startPlay:(NSString *)url;

/**
 * 停止播放音视频流。
 *
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 */
- (V2TXLiveCode)stopPlay;

/**
 * 播放器是否正在播放中。
 *
 * @return 是否正在播放
 *         - 1: 正在播放中
 *         - 0: 已经停止播放
 */
- (int)isPlaying;

/**
 * 暂停播放器的音频流。
 *
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 */
- (V2TXLiveCode)pauseAudio;

/**
 * 恢复播放器的音频流。
 *
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 */
- (V2TXLiveCode)resumeAudio;

/**
 * 暂停播放器的视频流。
 *
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 */
- (V2TXLiveCode)pauseVideo;

/**
 * 恢复播放器的视频流。
 *
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 */
- (V2TXLiveCode)resumeVideo;

/**
 * 设置播放器音量。
 *
 * @param volume 音量大小，取值范围0 - 100。【默认值】: 100
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 */
- (V2TXLiveCode)setPlayoutVolume:(NSUInteger)volume;

/**
 * 设置播放器缓存自动调整的最小和最大时间 ( 单位：秒 )。
 *
 * @param minTime 缓存自动调整的最小时间，取值需要大于0。【默认值】：1
 * @param maxTime 缓存自动调整的最大时间，取值需要大于0。【默认值】：5
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 *         - V2TXLIVE_ERROR_INVALID_PARAMETER: 操作失败，minTime 和 maxTime 需要大于0
 *         - V2TXLIVE_ERROR_REFUSED: 播放器处于播放状态，不支持修改缓存策略
 */
- (V2TXLiveCode)setCacheParams:(CGFloat)minTime maxTime:(CGFloat)maxTime;

/**
 * 启用播放音量大小提示。
 *
 * 开启后可以在 [onPlayoutVolumeUpdate](@ref V2TXLivePlayerObserver#onPlayoutVolumeUpdate:volume:) 回调中获取到 SDK 对音量大小值的评估。
 *
 * @param intervalMs 决定了 onPlayoutVolumeUpdate 回调的触发间隔，单位为ms，最小间隔为100ms，如果小于等于0则会关闭回调，建议设置为300ms；【默认值】：0，不开启
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 */
- (V2TXLiveCode)enableVolumeEvaluation:(NSUInteger)intervalMs;

/**
 * 截取播放过程中的视频画面。
 *
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 *         - V2TXLIVE_ERROR_REFUSED: 播放器处于停止状态，不允许调用截图操作
 */
- (V2TXLiveCode)snapshot;

/**
 * 设置视频自定义渲染回调。
 *
 * 通过该方法，可以获取解码后的每一帧视频画面，进行自定义渲染处理，添加自定义显示效果。
 *
 * @param enable      是否开启自定义渲染。【默认值】：NO
 * @param pixelFormat 自定义渲染回调的视频像素格式 {@link V2TXLivePixelFormat}。
 * @param bufferType  自定义渲染回调的视频数据格式 {@link V2TXLiveBufferType}。
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 *         - V2TXLIVE_ERROR_NOT_SUPPORTED: 像素格式或者数据格式不支持
 */
- (V2TXLiveCode)enableCustomRendering:(BOOL)enable pixelFormat:(V2TXLivePixelFormat)pixelFormat bufferType:(V2TXLiveBufferType)bufferType;

/**
 * 开启接收 SEI 消息
 *
 * @param enable      true: 开启接收 SEI 消息; false: 关闭接收 SEI 消息。【默认值】: false
 * @param payloadType 指定接收 SEI 消息的 payloadType，支持 5、242，请与发送端的 payloadType 保持一致。
 *
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 */
- (V2TXLiveCode)enableReceiveSeiMessage:(BOOL)enable payloadType:(int)payloadType;

/**
 * 是否显示播放器状态信息的调试浮层。
 *
 * @param isShow 是否显示。【默认值】：NO
 */
- (void)showDebugView:(BOOL)isShow;

/**
 * 调用 V2TXLivePlayer 的高级 API 接口。
 *
 * @note  该接口用于调用一些高级功能。
 * @param key   高级 API 对应的 key。
 * @param value 调用 key 所对应的高级 API 时，需要的参数。
 * @return 返回值 {@link V2TXLiveCode}
 *         - V2TXLIVE_OK: 成功
 *         - V2TXLIVE_ERROR_INVALID_PARAMETER: 操作失败，key 不允许为 nil
 */
- (V2TXLiveCode)setProperty:(NSString *)key value:(NSObject *)value;

@end

/// @}

@interface V2TXLivePlayer : NSObject <V2TXLivePlayer>

@end
