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
-(void) onLog:(NSString*)log LogLevel:(int)level WhichModule:(NSString*)module;

@end

@interface TXLiveBase : NSObject

/// 通过这个delegate将全部log回调给SDK使用者，由SDK使用者来决定log如何处理
@property (nonatomic, weak) id<TXLiveBaseDelegate> delegate;

+ (instancetype) sharedInstance;

/**  设置log输出级别
 *  @param level 参见 LOGLEVEL
 *
 */
+ (void) setLogLevel:(TX_Enum_Type_LogLevel)level;

/**
 * 启用或禁用控制台日志打印
 * @param enabled 指定是否启用
 */
+ (void) setConsoleEnabled:(BOOL)enabled;

+ (void) setAppVersion:(NSString *)verNum;

+ (void)setAudioSessionDelegate:(id<TXLiveAudioSessionDelegate>)delegate;

/// 获取SDK版本信息
+ (NSString *)getSDKVersionStr;

///　 获取pitu版本信息
+ (NSString *)getPituSDKVersion;

/// 设置appID，云控使用
+ (void)setAppID:(NSString*)appID;

/// 设置sdk的licence下载url和key
+ (void)setLicenceURL:(NSString *)url key:(NSString *)key;

/// 获取 Licence 信息
+ (NSString *)getLicenceInfo;
@end
