
/*
 * Module:   TRTCStatistics @ TXLiteAVSDK
 *
 * Function: 腾讯云视频通话功能的质量统计相关接口
 *
 */
///@addtogroup TRTCCloudDef_ios
///@{

/// 自己本地的音视频统计信息
@interface TRTCLocalStatistics : NSObject

///视频宽度
@property (nonatomic, assign) uint32_t  width;

///视频高度
@property (nonatomic, assign) uint32_t  height;

///帧率（fps）
@property (nonatomic, assign) uint32_t  frameRate;

///视频发送码率（Kbps）
@property (nonatomic, assign) uint32_t  videoBitrate;

///音频采样率（Hz）
@property (nonatomic, assign) uint32_t  audioSampleRate;

///音频发送码率（Kbps）
@property (nonatomic, assign) uint32_t  audioBitrate;

///流类型（大画面 | 小画面 | 辅路画面）
@property (nonatomic, assign) TRTCVideoStreamType  streamType;
@end


/// 远端成员的音视频统计信息
@interface TRTCRemoteStatistics : NSObject

/// 用户 ID，指定是哪个用户的视频流
@property (nonatomic, retain) NSString* userId;

/** 该线路的总丢包率（％）
 *
 * 这个值越小越好，例如，丢包率为0表示网络很好。
 * 丢包率是该线路的 userId 从上行到服务器再到下行的总丢包率。
 * 如果 downLoss 为0，但是 finalLoss 不为0，说明该 userId 上行时出现了无法恢复的丢包。
 */
@property (nonatomic, assign) uint32_t  finalLoss;

///视频宽度
@property (nonatomic, assign) uint32_t  width;

///视频高度
@property (nonatomic, assign) uint32_t  height;

///接收帧率（fps）
@property (nonatomic, assign) uint32_t  frameRate;

///视频码率（Kbps）
@property (nonatomic, assign) uint32_t  videoBitrate;

///音频采样率（Hz）
@property (nonatomic, assign) uint32_t  audioSampleRate;

///音频码率（Kbps）
@property (nonatomic, assign) uint32_t  audioBitrate;

///流类型（大画面 | 小画面 | 辅路画面）
@property (nonatomic, assign) TRTCVideoStreamType  streamType;
@end


/// 统计数据
@interface TRTCStatistics : NSObject

/** C -> S 上行丢包率（％），
 * 该值越小越好，例如，丢包率为0表示网络很好，
 * 丢包率为30@%则意味着 SDK 向服务器发送的数据包中会有30@%丢失在上行传输中。
 */
@property (nonatomic, assign) uint32_t  upLoss;

/** S -> C 下行丢包率（％），
 * 该值越小越好，例如，丢包率为0表示网络很好，
 * 丢包率为30@%则意味着 SDK 向服务器发送的数据包中会有30@%丢失在下行传输中。
 */
@property (nonatomic, assign) uint32_t  downLoss;

///当前 App 的 CPU 使用率（％）
@property (nonatomic, assign) uint32_t  appCpu;

///当前系统的 CPU 使用率（％）
@property (nonatomic, assign) uint32_t  systemCpu;

/// 延迟（毫秒），
/// 指 SDK 到腾讯云服务器的一次网络往返时间，该值越小越好。
/// 一般低于50ms的 rtt 相对理想，而高于100ms的 rtt 会引入较大的通话延时。
/// 由于数据上下行共享一条网络连接，所以 local 和 remote 的 rtt 相同。
@property (nonatomic, assign) uint32_t  rtt;

/// 总接收字节数（包含信令及音视频）
@property (nonatomic, assign) uint64_t  receivedBytes;

/// 总发送字节数（包含信令及音视频）
@property (nonatomic, assign) uint64_t  sentBytes;

///自己本地的音视频统计信息，可能有主画面、小画面以及辅路画面等多路的情况，因此是一个数组
@property (nonatomic, strong) NSArray<TRTCLocalStatistics*>*  localStatistics;

///远端成员的音视频统计信息，可能有主画面、小画面以及辅路画面等多路的情况，因此是一个数组
@property (nonatomic, strong) NSArray<TRTCRemoteStatistics*>* remoteStatistics;
@end
///@}
