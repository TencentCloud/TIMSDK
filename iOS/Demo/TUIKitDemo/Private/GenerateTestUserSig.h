/*
 * Module:   GenerateTestUserSig
 *
 * Function: 用于生成测试用的 UserSig，UserSig 是腾讯云为其云服务设计的一种安全保护签名。
 *           其计算方法是对 SDKAppID、UserID 和 EXPIRETIME 进行加密，加密算法为 HMAC-SHA256。
 *
 * Attention: 请不要将如下代码发布到您的线上正式版本的 App 中，原因如下：
 *
 *            本文件中的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能，不适合线上产品，
 *            这是因为客户端代码中的 SECRETKEY 很容易被反编译逆向破解，尤其是 Web 端的代码被破解的难度几乎为零。
 *            一旦您的密钥泄露，攻击者就可以计算出正确的 UserSig 来盗用您的腾讯云流量。
 *
 *            正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，然后由 App 按需向您的服务器获取实时算出的 UserSig。
 *            由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
 *
 * Reference：https://cloud.tencent.com/document/product/269/32688#Server
 */

/*
 * Module:   GenerateTestUserSig
 *
 * Function:  Used to generate UserSig for testing. UserSig is a security signature designed by Tencent Cloud for its cloud services.
 *           It is calculated based on SDKAppID, UserID, and EXPIRETIME using the HMAC-SHA256 encryption algorithm.
 *
 * Attention: Do not use the code below in your commercial application. This is because:
 *
 *            The code may be able to calculate UserSig correctly, but it is only for quick testing of the SDK’s basic features, not for commercial applications.
 *            SECRETKEY in client code can be easily decompiled and reversed, especially on web.
 *            Once your key is disclosed, attackers will be able to steal your Tencent Cloud traffic.
 *
 *            The correct method is to deploy the UserSig calculation code and encryption key on your project server so that your application can request from your server a UserSig that is calculated whenever one is needed.
 *            Given that it is more difficult to hack a server than a client application, server-end calculation can better protect your key.
 *
 * Reference：https://intl.cloud.tencent.com/document/product/1047/34385
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define SDKAPPID [GenerateTestUserSig currentSDKAppid]
#define SECRETKEY [GenerateTestUserSig currentSecretkey]

#define TUIDemoServerName(name, test) [GenerateTestUserSig serverName:name isTest:test]
#define TUIDemoSwitchServer(name) [GenerateTestUserSig switchServer:name]
#define TUIDemoCurrentServer [GenerateTestUserSig currentServer]
#define TUIDemoSwitchTest(test) [GenerateTestUserSig switchTestEnvironmenet:test]
#define TUIDemoIsTestEnvironment [GenerateTestUserSig isTestEnvironment]

// 服务器类型
// Server Type
typedef NS_ENUM(NSInteger, TUIDemoServerType) {
    TUIDemoServerTypePublic         = 0,    // 公有云
    TUIDemoServerTypePrivate        = 1,    // 私有云
    TUIDemoServerTypeSingapore      = 2,    // 新加坡
    TUIDemoServerTypeCustomPrivate  = 3,    // 自定义私有云
    TUIDemoServerTypeKorea          = 4,    // 韩国
    TUIDemoServerTypeGermany        = 5,    // 德国
    TUIDemoServerTypeIndia          = 6,    // 印度
};

/**
 * 公有云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
 *
 * 进入腾讯云云通信[控制台](https://console.cloud.tencent.com/avc) 创建应用，即可看到 SDKAppId，
 * 它是腾讯云用于区分客户的唯一标识。
 */

/**
 * Tencent Cloud SDKAppID. Set it to the SDKAppID of your account.
 *
 * You can view your SDKAppID after creating an application in the [Tencent Cloud IM console](https://console.intl.cloud.tencent.com/im).
 * SDKAppID uniquely identifies a Tencent Cloud account.
 */

static const int public_SDKAPPID = 0;

/**
 * 新加坡环境下的 SDKAppId。
 */

/**
 * SDKAppId in the environment in Singapore
 */
static const int singapore_SDKAPPID = 0;

/**
 * 韩国环境下的 SDKAppId
 */

/**
 * SDKAppId in the environment in South Korea
 */
static const int korea_SDKAPPID = 0;

/**
 * 德国环境下的 SDKAppId
 */

/**
 * SDKAppId in the environment in Germany
 */
static const int germany_SDKAPPID = 0;

/**
 * 印度环境下的 SDKAppId
 */

/**
 * SDKAppId in the environment in India
 */
static const int india_SDKAPPID = 0;

/**
 *  签名过期时间，建议不要设置的过短
 *
 *  时间单位：秒
 *  默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
 */

/**
 *  Signature validity period, which should not be set too short
 *
 *  Time unit: second
 *  Default value: 604800 (7 days)
 */
static const int EXPIRETIME = 604800;

/**
 * 计算签名用的加密密钥，获取步骤如下：
 *
 * step1. 进入腾讯云云通信[控制台](https://console.cloud.tencent.com/avc) ，如果还没有应用就创建一个，
 * step2. 单击“应用配置”进入基础配置页面，并进一步找到“帐号体系集成”部分。
 * step3. 点击“查看密钥”按钮，就可以看到计算 UserSig 使用的加密的密钥了，请将其拷贝并复制到如下的变量中
 *
 * 注意：该方案仅适用于调试Demo，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
 * 文档：https://cloud.tencent.com/document/product/269/32688#Server
 */

/**
 * Follow the steps below to obtain the key required for UserSig calculation.
 *
 * Step 1. Log in to the [Tencent Cloud IM console](https://console.intl.cloud.tencent.com/im), and create an application if you don’t have one.
 * Step 2. Click Application Configuration to go to the basic configuration page and locate Account System Integration.
 * Step 3. Click View Key to view the encrypted key used for UserSig calculation. Then copy and paste the key to the variable below.
 *
 * Note: this method is for testing only. Before commercial launch, please migrate the UserSig calculation code and key to your backend server to prevent key disclosure and traffic stealing.
 * Reference：https://intl.cloud.tencent.com/document/product/1047/34385
 */
static NSString * const public_SECRETKEY = @"";

/**
 * 新加坡环境下的加密密钥
 */

/**
 * Encryption key in the environment in Singapore
 */
static NSString * const singapore_SECRETKEY = @"";

/**
 * 韩国环境下的加密秘钥
 */

/**
 * Encryption key in the environment in South Korea
 */
static NSString * const korea_SECRETKEY = @"";

/**
 * 德国环境下的加密秘钥
 */

/**
 * Encryption key in the environment in Germany
 */
static NSString * const germany_SECRETKEY = @"";

/**
 * 印度环境下的加密秘钥
 */

/**
 * Encryption key in the environment in India
 */
static NSString * const india_SECRETKEY = @"";

@interface GenerateTestUserSig : NSObject

// 获取服务器名称
// Get the server name
+ (NSString *)serverName:(TUIDemoServerType)serverType isTest:(BOOL)isTest;

// 切换服务器
// Switch the server
+ (void)switchServer:(TUIDemoServerType)serverType;

// 服务器是否切换过
+ (BOOL)isServerSwitched;

// 获取当前服务器类型
// Get the current server type
+ (TUIDemoServerType)currentServer;

// 环境相关
// Environment-related
+ (BOOL)isTestEnvironment;
+ (void)switchTestEnvironmenet:(BOOL)test;

// 设置/获取自定义私有化服务器信息
// Set/Get custom private server information
+ (void)setCustomPrivateServer:(NSString *)server;
+ (NSString *)customPrivateServer;
+ (void)setCustomPrivatePort:(NSUInteger)port;
+ (NSUInteger)customPrivatePort;

// 获取当前的 sdkappid 和 secretKey
// Get the current SDKAppID and SecretKey
+ (unsigned int)currentSDKAppid;
+ (NSString *)currentSecretkey;


/**
 * 计算 UserSig 签名
 *
 * 函数内部使用 HMAC-SHA256 非对称加密算法，对 SDKAPPID、userId 和 EXPIRETIME 进行加密。
 *
 * @note: 请不要将如下代码发布到您的线上正式版本的 App 中，原因如下：
 *
 * 本文件中的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能，不适合线上产品，
 * 这是因为客户端代码中的 SECRETKEY 很容易被反编译逆向破解，尤其是 Web 端的代码被破解的难度几乎为零。
 * 一旦您的密钥泄露，攻击者就可以计算出正确的 UserSig 来盗用您的腾讯云流量。
 *
 * 正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，然后由 App 按需向您的服务器获取实时算出的 UserSig。
 * 由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
 *
 * 文档：https://cloud.tencent.com/document/product/269/32688#Server
 */

/**
 * Calculate UserSig
 *
 * The asymmetric encryption algorithm HMAC-SHA256 is used in the function to calculate UserSig based on SDKAppID, UserID, and EXPIRETIME.
 *
 * Attention: Do not use the code below in your commercial application. This is because:
 *
 * The code may be able to calculate UserSig correctly, but it is only for quick testing of the SDK’s basic features, not for commercial applications.
 * SECRETKEY in client code can be easily decompiled and reversed, especially on web.
 * Once your key is disclosed, attackers will be able to steal your Tencent Cloud traffic.
 *
 * The correct method is to deploy the UserSig calculation code and encryption key on your project server so that your application can request from your server a UserSig that is calculated whenever one is needed.
 * Given that it is more difficult to hack a server than a client application, server-end calculation can better protect your key.
 *
 * Reference：https://intl.cloud.tencent.com/document/product/1047/34385
 */

+ (NSString *)genTestUserSig:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
