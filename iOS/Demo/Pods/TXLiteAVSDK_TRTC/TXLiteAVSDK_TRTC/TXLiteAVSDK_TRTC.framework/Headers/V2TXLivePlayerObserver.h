//
//  Copyright © 2020 Tencent. All rights reserved.
//
//  Module: V2TXLive
//

#import "V2TXLiveDef.h"

@protocol V2TXLivePlayer;

/// @defgroup V2TXLivePlayerObserver_ios V2TXLivePlayerObserver
/// 腾讯云直播的播放器回调通知。<br/>
/// 可以接收 V2TXLivePlayer 播放器的一些回调通知，包括播放器状态、播放音量回调、音视频首帧回调、统计数据、警告和错误信息等。
/// @{

@protocol V2TXLivePlayerObserver <NSObject>

@optional

/////////////////////////////////////////////////////////////////////////////////
//
//                   直播播放器事件回调
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 直播播放器错误通知，播放器出现错误时，会回调该通知
 *
 * @param player    回调该通知的播放器对象
 * @param code      错误码 {@link V2TXLiveCode}
 * @param msg       错误信息
 * @param extraInfo 扩展信息
 */
- (void)onError:(id<V2TXLivePlayer>)player code:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo;

/**
 * 直播播放器警告通知
 *
 * @param player    回调该通知的播放器对象
 * @param code      警告码 {@link V2TXLiveCode}
 * @param msg       警告信息
 * @param extraInfo 扩展信息
 */
- (void)onWarning:(id<V2TXLivePlayer>)player code:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo;

/**
 * 直播播放器分辨率变化通知
 *
 * @param player    回调该通知的播放器对象
 * @param width     视频宽
 * @param height    视频高
 */
- (void)onVideoResolutionChanged:(id<V2TXLivePlayer>)player width:(NSInteger)width height:(NSInteger)height;

/**
 * 已经成功连接到服务器
 *
 * @param player    回调该通知的播放器对象
 * @param extraInfo 扩展信息
 */
- (void)onConnected:(id<V2TXLivePlayer>)player extraInfo:(NSDictionary *)extraInfo;

/**
 * 视频播放事件
 *
 * @param player    回调该通知的播放器对象
 * @param firstPlay 第一次播放标志
 * @param extraInfo 扩展信息
 */
- (void)onVideoPlaying:(id<V2TXLivePlayer>)player firstPlay:(BOOL)firstPlay extraInfo:(NSDictionary *)extraInfo;

/**
 * 音频播放事件
 *
 * @param player    回调该通知的播放器对象
 * @param firstPlay 第一次播放标志
 * @param extraInfo 扩展信息
 */
- (void)onAudioPlaying:(id<V2TXLivePlayer>)player firstPlay:(BOOL)firstPlay extraInfo:(NSDictionary *)extraInfo;

/**
 * 视频加载事件
 *
 * @param player    回调该通知的播放器对象
 * @param extraInfo 扩展信息
 */
- (void)onVideoLoading:(id<V2TXLivePlayer>)player extraInfo:(NSDictionary *)extraInfo;

/**
 * 音频加载事件
 *
 * @param player    回调该通知的播放器对象
 * @param extraInfo 扩展信息
 */
- (void)onAudioLoading:(id<V2TXLivePlayer>)player extraInfo:(NSDictionary *)extraInfo;

/**
 * 播放器音量大小回调
 *
 * @param player 回调该通知的播放器对象
 * @param volume 音量大小
 * @note  调用 [enableVolumeEvaluation](@ref V2TXLivePlayer#enableVolumeEvaluation:) 开启播放音量大小提示之后，会收到这个回调通知。
 */
- (void)onPlayoutVolumeUpdate:(id<V2TXLivePlayer>)player volume:(NSInteger)volume;

/**
 * 直播播放器统计数据回调
 *
 * @param player     回调该通知的播放器对象
 * @param statistics 播放器统计数据 {@link V2TXLivePlayerStatistics}
 */
- (void)onStatisticsUpdate:(id<V2TXLivePlayer>)player statistics:(V2TXLivePlayerStatistics *)statistics;

/**
 * 截图回调
 *
 * @note  调用 [snapshot](@ref V2TXLivePlayer#snapshot) 截图之后，会收到这个回调通知
 * @param player 回调该通知的播放器对象
 * @param image  已截取的视频画面
 */
- (void)onSnapshotComplete:(id<V2TXLivePlayer>)player image:(TXImage *)image;

/**
 * 自定义视频渲染回调
 *
 * @param player     回调该通知的播放器对象
 * @param videoFrame 视频帧数据 {@link V2TXLiveVideoFrame}
 * @note  需要您调用 [enableObserveVideoFrame](@ref V2TXLivePlayer#enableObserveVideoFrame:pixelFormat:bufferType:) 开启回调开关
 */
- (void)onRenderVideoFrame:(id<V2TXLivePlayer>)player frame:(V2TXLiveVideoFrame *)videoFrame;

/**
 * 收到 SEI 消息的回调，发送端通过 {@link V2TXLivePusher} 中的 `sendSeiMessage` 来发送 SEI 消息。
 *
 * @note  调用 {@link V2TXLivePlayer} 中的 `enableReceiveSeiMessage` 开启接收 SEI 消息之后，会收到这个回调通知
 *
 * @param player   回调该通知的播放器对象。
 * @param payloadType    回调数据的SEI payloadType
 * @param data     数据
 */
- (void)onReceiveSeiMessage:(id<V2TXLivePlayer>)player payloadType:(int)payloadType data:(NSData *)data;

@end
/// @}
