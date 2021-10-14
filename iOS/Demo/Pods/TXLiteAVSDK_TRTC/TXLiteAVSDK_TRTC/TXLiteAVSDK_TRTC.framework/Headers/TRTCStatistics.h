/**
 * Module:   TRTC 音视频统计指标（只读）
 * Function: TRTC SDK 会以两秒钟一次的频率向您汇报当前实时的音视频指标（帧率、码率、卡顿情况等）
 */
/// @defgroup TRTCStatisic_ios TRTCStatisic
/// TRTC 音视频统计指标
/// @{

/////////////////////////////////////////////////////////////////////////////////
//
//                    本地的音视频统计指标
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 本地的音视频统计指标
/// @{

@interface TRTCLocalStatistics : NSObject

///【字段含义】本地视频的宽度，单位 px
@property(nonatomic, assign) uint32_t width;

///【字段含义】本地视频的高度，单位 px
@property(nonatomic, assign) uint32_t height;

///【字段含义】本地视频的帧率，即每秒钟会有多少视频帧，单位：FPS
@property(nonatomic, assign) uint32_t frameRate;

///【字段含义】远端视频的码率，即每秒钟新产生视频数据的多少，单位 Kbps
@property(nonatomic, assign) uint32_t videoBitrate;

///【字段含义】远端音频的采样率，单位 Hz
@property(nonatomic, assign) uint32_t audioSampleRate;

///【字段含义】本地音频的码率，即每秒钟新产生音频数据的多少，单位 Kbps
@property(nonatomic, assign) uint32_t audioBitrate;

///【字段含义】视频流类型（高清大画面|低清小画面|辅流画面）
@property(nonatomic, assign) TRTCVideoStreamType streamType;

///【字段含义】音频设备采集状态（用于检测音频外设的健康度）
/// 0：采集设备状态正常；1：检测到长时间静音；2：检测到破音；3：检测到声音异常间断。
@property(nonatomic, assign) uint32_t audioCaptureState;
@end

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//                    远端的音视频统计指标
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 远端的音视频统计指标
/// @{

@interface TRTCRemoteStatistics : NSObject

///【字段含义】用户 ID
@property(nonatomic, retain) NSString* userId;

///【字段含义】音频流的总丢包率（％）
/// audioPacketLoss 代表音频流历经“主播 => 云端 => 观众”这样一条完整的传输链路后，最终在观众端统计到的丢包率。
/// audioPacketLoss 越小越好，丢包率为0即表示该路音频流的所有数据均已经完整地到达了观众端。
///如果出现了 downLoss == 0 但 audioPacketLoss != 0 的情况，说明该路音频流在“云端=>观众”这一段链路上没有出现丢包，但是在“主播=>云端”这一段链路上出现了不可恢复的丢包。
@property(nonatomic, assign) uint32_t audioPacketLoss;

///【字段含义】该路视频流的总丢包率（％）
/// videoPacketLoss 代表该路视频流历经“主播 => 云端 => 观众”这样一条完整的传输链路后，最终在观众端统计到的丢包率。
/// videoPacketLoss 越小越好，丢包率为0即表示该路视频流的所有数据均已经完整地到达了观众端。
///如果出现了 downLoss == 0 但 videoPacketLoss != 0 的情况，说明该路视频流在“云端=>观众”这一段链路上没有出现丢包，但是在“主播=>云端”这一段链路上出现了不可恢复的丢包。
@property(nonatomic, assign) uint32_t videoPacketLoss;

///【字段含义】远端视频的宽度，单位 px
@property(nonatomic, assign) uint32_t width;

///【字段含义】远端视频的高度，单位 px
@property(nonatomic, assign) uint32_t height;

///【字段含义】远端视频的帧率，单位：FPS
@property(nonatomic, assign) uint32_t frameRate;

///【字段含义】远端视频的码率，单位 Kbps
@property(nonatomic, assign) uint32_t videoBitrate;

///【字段含义】本地音频的采样率，单位 Hz
@property(nonatomic, assign) uint32_t audioSampleRate;

///【字段含义】本地音频的码率，单位 Kbps
@property(nonatomic, assign) uint32_t audioBitrate;

///【字段含义】播放延迟，单位 ms
///为了避免网络抖动和网络包乱序导致的声音和画面卡顿，TRTC 会在播放端管理一个播放缓冲区，用于对接收到的网络数据包进行整理，
///该缓冲区的大小会根据当前的网络质量进行自适应调整，该缓冲区的大小折算成以毫秒为单位的时间长度，也就是 jitterBufferDelay。
@property(nonatomic, assign) uint32_t jitterBufferDelay;

///【字段含义】端到端延迟，单位 ms
/// point2PointDelay 代表 “主播=>云端=>观众” 的延迟，更准确地说，它代表了“采集=>编码=>网络传输=>接收=>缓冲=>解码=>播放” 全链路的延迟。
/// point2PointDelay 需要本地和远端的 SDK 均为 8.5 及以上的版本才生效，若远端用户为 8.5 以前的版本，此数值会一直为0，代表无意义。
@property(nonatomic, assign) uint32_t point2PointDelay;

///【字段含义】音频播放的累计卡顿时长，单位 ms
@property(nonatomic, assign) uint32_t audioTotalBlockTime;

///【字段含义】音频播放卡顿率，单位 (%)
///音频播放卡顿率（audioBlockRate） = 音频播放的累计卡顿时长（audioTotalBlockTime） / 音频播放的总时长
@property(nonatomic, assign) uint32_t audioBlockRate;

///【字段含义】视频播放的累计卡顿时长，单位 ms
@property(nonatomic, assign) uint32_t videoTotalBlockTime;

///【字段含义】视频播放卡顿率，单位 (%)
///视频播放卡顿率（videoBlockRate） = 视频播放的累计卡顿时长（videoTotalBlockTime） / 视频播放的总时长
@property(nonatomic, assign) uint32_t videoBlockRate;

///【字段含义】该路音视频流的总丢包率（％）
///已废弃，不推荐使用；建议使用 audioPacketLoss、videoPacketLoss 替代
@property(nonatomic, assign) uint32_t finalLoss __attribute__((deprecated("Use audioPacketLoss and videoPacketLoss instead.")));

///【字段含义】视频流类型（高清大画面|低清小画面|辅流画面）
@property(nonatomic, assign) TRTCVideoStreamType streamType;
@end

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//                    网络和性能的汇总统计指标
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 网络和性能的汇总统计指标
/// @{

@interface TRTCStatistics : NSObject

///【字段含义】当前应用的 CPU 使用率，单位 (%)
@property(nonatomic, assign) uint32_t appCpu;

///【字段含义】当前系统的 CPU 使用率，单位 (%)
@property(nonatomic, assign) uint32_t systemCpu;

///【字段含义】从 SDK 到云端的上行丢包率，单位 (%)
///该数值越小越好，如果 upLoss 为 0%，则意味着上行链路的网络质量很好，上传到云端的数据包基本不发生丢失。
///如果 upLoss 为 30%，则意味着 SDK 向云端发送的音视频数据包中，会有 30% 丢失在传输链路中。
@property(nonatomic, assign) uint32_t upLoss;

///【字段含义】从云端到 SDK 的下行丢包率，单位 (%)
///该数值越小越好，如果 downLoss 为 0%，则意味着下行链路的网络质量很好，从云端接收的数据包基本不发生丢失。
///如果 downLoss 为 30%，则意味着云端向 SDK 传输的音视频数据包中，会有 30% 丢失在传输链路中。
@property(nonatomic, assign) uint32_t downLoss;

///【字段含义】从 SDK 到云端的往返延时，单位 ms
///该数值代表从 SDK 发送一个网络包到云端，再从云端回送一个网络包到 SDK 的总计耗时，也就是一个网络包经历 “SDK=>云端=>SDK” 的总耗时。
///该数值越小越好：如果 rtt < 50ms，意味着较低的音视频通话延迟；如果 rtt > 200ms，则意味着较高的音视频通话延迟。
///需要特别解释的是，rtt 代表 “SDK=>云端=>SDK” 的总耗时，所不需要区分 upRtt 和 downRtt。
@property(nonatomic, assign) uint32_t rtt;

///【字段含义】从 SDK 到本地路由器的往返时延，单位 ms
///该数值代表从 SDK 发送一个网络包到本地路由器网关，再从网关回送一个网络包到 SDK 的总计耗时，也就是一个网络包经历 “SDK=>网关=>SDK” 的总耗时。
///该数值越小越好：如果 gatewayRtt < 50ms，意味着较低的音视频通话延迟；如果 gatewayRtt > 200ms，则意味着较高的音视频通话延迟。
///当网络类型为蜂窝网时，该值无效。
@property(nonatomic, assign) uint32_t gatewayRtt;

///【字段含义】总发送字节数（包含信令数据和音视频数据），单位：字节数（Bytes）
@property(nonatomic, assign) uint64_t sentBytes;

///【字段含义】总接收字节数（包含信令数据和音视频数据），单位：字节数（Bytes）
@property(nonatomic, assign) uint64_t receivedBytes;

///【字段含义】本地的音视频统计信息
///由于本地可能有三路音视频流（即高清大画面，低清小画面，以及辅流画面），因此本地的音视频统计信息是一个数组。
@property(nonatomic, strong) NSArray<TRTCLocalStatistics*>* localStatistics;

///【字段含义】远端的音视频统计信息
///因为同时可能有多个远端用户，而且每个远端用户同时可能有多路音视频流（即高清大画面，低清小画面，以及辅流画面），因此远端的音视频统计信息是一个数组。
@property(nonatomic, strong) NSArray<TRTCRemoteStatistics*>* remoteStatistics;

@end
/// @}

/// @}
