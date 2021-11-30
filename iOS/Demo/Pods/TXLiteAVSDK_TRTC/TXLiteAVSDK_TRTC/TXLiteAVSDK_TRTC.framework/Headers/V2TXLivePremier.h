//
//  Copyright © 2020 Tencent. All rights reserved.
//
//  Module: V2TXLive
//
#import "V2TXLiveDef.h"

NS_ASSUME_NONNULL_BEGIN

/// @defgroup V2TXLivePremier_ios V2TXLivePremier
///
/// @{

/////////////////////////////////////////////////////////////////////////////////
//
//                      V2TXLive 高级接口
//
/////////////////////////////////////////////////////////////////////////////////

@protocol V2TXLivePremierObserver;
@protocol V2TXLivePremier <NSObject>

/**
 * 获取 SDK 版本号
 */
+ (NSString *)getSDKVersionStr;

/**
 * 设置 V2TXLivePremier 回调接口
 */
+ (void)setObserver:(id<V2TXLivePremierObserver>)observer;

/**
 * 设置 Log 的配置信息
 */
+ (V2TXLiveCode)setLogConfig:(V2TXLiveLogConfig *)config;

/**
 * 设置 SDK 接入环境
 *
 * @note 如您的应用无特殊需求，请不要调用此接口进行设置。
 * @param env 目前支持 “default” 和 “GDPR” 两个参数
 *        - default：默认环境，SDK 会在全球寻找最佳接入点进行接入。
 *        - GDPR：所有音视频数据和质量统计数据都不会经过中国大陆地区的服务器。
 */
+ (V2TXLiveCode)setEnvironment:(const char *)env;

/**
 * 设置 SDK 的授权 License
 *
 * 文档地址：https://cloud.tencent.com/document/product/454/34750
 * @param url licence的地址
 * @param key licence的秘钥
 */
#if TARGET_OS_IPHONE
+ (void)setLicence:(NSString *)url key:(NSString *)key;
#endif

/**
 * 设置 SDK sock5 代理配置
 *
 * @param host sock5 代理服务器的地址
 * @param port sock5 代理服务器的端口
 * @param username sock5 代理服务器的验证的用户名
 * @param password sock5 代理服务器的验证的密码
 */
+ (V2TXLiveCode)setSocks5Proxy:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      V2TXLive 高级回调接口
//
/////////////////////////////////////////////////////////////////////////////////

@protocol V2TXLivePremierObserver <NSObject>
@optional

/**
 * 自定义 Log 输出回调接口
 */
- (void)onLog:(V2TXLiveLogLevel)level log:(NSString *)log;

/**
 * setLicence 接口回调
 *
 * @param result 设置 licence 结果 0 成功，负数失败
 * @param reason 设置 licence 失败原因
 */
- (void)onLicenceLoaded:(int)result Reason:(NSString *)reason;

@end

@interface V2TXLivePremier : NSObject <V2TXLivePremier>

@end

NS_ASSUME_NONNULL_END

/// @}
