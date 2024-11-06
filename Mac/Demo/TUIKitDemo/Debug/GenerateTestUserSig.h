
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

/**
 * Tencent Cloud SDKAppID. Set it to the SDKAppID of your account.
 *
 * You can view your SDKAppID after creating an application in the [Tencent Cloud IM console](https://console.intl.cloud.tencent.com/im).
 * SDKAppID uniquely identifies a Tencent Cloud account.
 */
static const int SDKAPPID = 0;


/**
 *  Signature validity period, which should not be set too short
 *
 *  Time unit: second
 *  Default value: 604800 (7 days)
 */
static const int EXPIRETIME = 604800;


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

static NSString * const SECRETKEY = @"";


@interface GenerateTestUserSig : NSObject


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
