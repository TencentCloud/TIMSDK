#import "TXLiveAudioSessionDelegate.h"

typedef NS_ENUM(NSInteger, TX_Enum_Type_LogLevel) {
    ///输出所有级别的log
    LOGLEVEL_VERBOSE = 0,
    /// 输出 DEBUG，INFO，WARNING，ERROR 和 FATAL 级别的log
    LOGLEVEL_DEBUG = 1,
    /// 输出 INFO，WARNING，ERROR 和 FATAL 级别的log
    LOGLEVEL_INFO = 2,
    /// 只输出WARNING，ERROR 和 FATAL 级别的log
    LOGLEVEL_WARN = 3,
    /// 只输出ERROR 和 FATAL 级别的log
    LOGLEVEL_ERROR = 4,
    /// 只输出 FATAL 级别的log
    LOGLEVEL_FATAL = 5,
    /// 不输出任何sdk log
    LOGLEVEL_NULL = 6, 
};

@protocol TXLiveBaseDelegate <NSObject>
@optional

/**
 @brief Log回调　
 @discussion 
 1.实现TXLiveBaseDelegate，建议在一个比较早的初始化类中如AppDelegate
 2.在初始化中设置此回调，eg：[TXLiveBase sharedInstance].delegate = self;
 3.level类型参见TX_Enum_Type_LogLevel
 4.module值暂无具体意义，目前为固定值TXLiteAVSDK
 */
- (void)onLog:(NSString*)log LogLevel:(int)level WhichModule:(NSString*)module;

/**
 * @brief NTP 校时回调，调用 TXLiveBase updateNetworkTime 后会触发
 * @param errCode 0：表示校时成功且偏差在30ms以内，1：表示校时成功但偏差可能在 30ms 以上，-1：表示校时失败
 */
- (void)onUpdateNetworkTime:(int)errCode message:(NSString *)errMsg;

/**
 @brief  setLicenceURL 接口回调, result = 0 成功，负数失败。
 @discussion
 需在调用 setLicenceURL 前设置 delegate
 */
- (void)onLicenceLoaded:(int)result Reason:(NSString *)reason;

@end

@interface TXLiveBase : NSObject

/// 通过这个delegate将全部log回调给SDK使用者，由SDK使用者来决定log如何处理
@property (nonatomic, weak) id<TXLiveBaseDelegate> delegate;

+ (instancetype)sharedInstance;

/**
 * 设置 liteav SDK 接入的环境。
 * 腾讯云在全球各地区部署的环境，按照各地区政策法规要求，需要接入不同地区接入点。
 *
 * @param env_config 需要接入的环境，SDK 默认接入的环境是：默认正式环境。
 * @return 0：成功；其他：错误
 *
 * @note 目标市场为中国大陆的客户请不要调用此接口，如果目标市场为海外用户，请通过技术支持联系我们，了解 env_config 的配置方法，以确保 App 遵守 GDPR 标准。
 */
+ (int)setGlobalEnv:(const char *)env_config;

/**
 *  设置 log 输出级别
 *  @param level 参见 LOGLEVEL
 */
+ (void)setLogLevel:(TX_Enum_Type_LogLevel)level;

/**
 * 启用或禁用控制台日志打印
 * @param enabled 指定是否启用
 */
+ (void)setConsoleEnabled:(BOOL)enabled;

+ (void)setAppVersion:(NSString *)verNum;

+ (void)setAudioSessionDelegate:(id<TXLiveAudioSessionDelegate>)delegate;

/**
 * @brief 获取 SDK 版本信息
 * @return SDK 版本信息
 */
+ (NSString *)getSDKVersionStr;

/**
 * @brief 获取 pitu 版本信息
 * @return pitu 版本信息
 */
+ (NSString *)getPituSDKVersion;

/**
 * @brief 设置 appID，云控使用
 */
+ (void)setAppID:(NSString*)appID;

/**
 * @brief 设置 sdk 的 Licence 下载 url 和 key
 */
+ (void)setLicenceURL:(NSString *)url key:(NSString *)key;

/**
 * @brief 设置 userId，用于数据上报
 */
+ (void)setUserId:(NSString *)userId;

/**
 * @brief 获取 Licence 信息
 * @return Licence 信息
 */
+ (NSString *)getLicenceInfo;

/**
 * @brief 设置 HEVC 外部解码器工厂实例
 */
+ (void)setExternalDecoderFactory:(id)decoderFactory;

/**
 * 启动 NTP 校时服务
 *
 * @return 0：启动成功；< 0：启动失败
 */
+ (NSInteger)updateNetworkTime;

/**
 * 获取 NTP 时间戳（毫秒），请在收到 onUpdateNetworkTime 回调后使用
 *
 * @return NTP 时间戳（毫秒），若返回 0：未启动 NTP 校时或校时失败，请重启校时
 */
+ (NSInteger)getNetworkTimestamp;

@end
