#import "GenerateTestUserSig.h"
#import <CommonCrypto/CommonCrypto.h>
#import <zlib.h>
#import "TCLoginModel.h"

@implementation GenerateTestUserSig

+ (NSString *)serverName:(TUIDemoServerType)serverType isTest:(BOOL)isTest {
    NSDictionary * tuidemo_serverName = @{
        @(TUIDemoServerTypePublic): @"公有云",
        @(TUIDemoServerTypePrivate): @"私有云",
        @(TUIDemoServerTypeSingapore): @"新加坡",
        @(TUIDemoServerTypeCustomPrivate): @"自定义私有云",
        @(TUIDemoServerTypeGermany): @"德国",
        @(TUIDemoServerTypeKorea): @"韩国",
        @(TUIDemoServerTypeIndia): @"印度",
    };
    
    NSString *name = tuidemo_serverName[@(serverType)];
    if (serverType != TUIDemoServerTypeCustomPrivate) {
        name = [name stringByAppendingFormat:@"%@", isTest?@"测试环境":@"正式环境"];
    }
    
    return name;
}

+ (void)switchServer:(TUIDemoServerType)serverType {
    [NSUserDefaults.standardUserDefaults setInteger:serverType forKey:@"server_type"];
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"server_switched"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (BOOL)isServerSwitched {
    return [NSUserDefaults.standardUserDefaults boolForKey:@"server_switched"];
}

+ (TUIDemoServerType)currentServer {
    return (TUIDemoServerType)[NSUserDefaults.standardUserDefaults integerForKey:@"server_type"];
}

+ (BOOL)isTestEnvironment {
    return [NSUserDefaults.standardUserDefaults boolForKey:@"test_environment"];
}

+ (void)switchTestEnvironmenet:(BOOL)test {
    [NSUserDefaults.standardUserDefaults setBool:test forKey:@"test_environment"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (void)setCustomPrivateServer:(NSString *)server {
    [NSUserDefaults.standardUserDefaults setObject:server forKey:@"custom_private_server"];
    [NSUserDefaults.standardUserDefaults synchronize];
}
+ (NSString *)customPrivateServer {
    return [NSUserDefaults.standardUserDefaults objectForKey:@"custom_private_server"];
}
+ (void)setCustomPrivatePort:(NSUInteger)port {
    [NSUserDefaults.standardUserDefaults setInteger:port forKey:@"custom_private_port"];
    [NSUserDefaults.standardUserDefaults synchronize];
}
+ (NSUInteger)customPrivatePort {
    return [NSUserDefaults.standardUserDefaults integerForKey:@"custom_private_port"];;
}

+ (unsigned int)currentSDKAppid {
    if (![TCLoginModel sharedInstance].isDirectlyLoginSDK) {
        return (unsigned int)[TCLoginModel sharedInstance].SDKAppID;
    }
    int appid = public_SDKAPPID;
    if ([self currentServer] == TUIDemoServerTypeSingapore) {
        appid = singapore_SDKAPPID;
    } else if ([self currentServer] == TUIDemoServerTypeKorea) {
        appid = korea_SDKAPPID;
    } else if ([self currentServer] == TUIDemoServerTypeGermany) {
        appid = germany_SDKAPPID;
    } else if ([self currentServer] == TUIDemoServerTypeIndia) {
        appid = india_SDKAPPID;
    }
    return appid;
}

+ (NSString *)currentSecretkey {
    NSString *secret = public_SECRETKEY;
    if ([self currentServer] == TUIDemoServerTypeSingapore) {
        secret = singapore_SECRETKEY;
    } else if ([self currentServer] == TUIDemoServerTypeKorea) {
        secret = korea_SECRETKEY;
    } else if ([self currentServer] == TUIDemoServerTypeGermany) {
        secret = germany_SECRETKEY;
    } else if ([self currentServer] == TUIDemoServerTypeIndia) {
        secret = india_SECRETKEY;
    }
    return secret;
}


+ (NSString *)genTestUserSig:(NSString *)identifier
{
    CFTimeInterval current = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970;
    long TLSTime = floor(current);
    NSMutableDictionary *obj = [@{@"TLS.ver": @"2.0",
                                  @"TLS.identifier": identifier,
                                  @"TLS.sdkappid": @(SDKAPPID),
                                  @"TLS.expire": @(EXPIRETIME),
                                  @"TLS.time": @(TLSTime)} mutableCopy];
    NSMutableString *stringToSign = [[NSMutableString alloc] init];
    NSArray *keyOrder = @[@"TLS.identifier",
                          @"TLS.sdkappid",
                          @"TLS.time",
                          @"TLS.expire"];
    for (NSString *key in keyOrder) {
        [stringToSign appendFormat:@"%@:%@\n", key, obj[key]];
    }
    NSLog(@"%@", stringToSign);
    //NSString *sig = [self sigString:stringToSign];
    NSString *sig = [self hmac:stringToSign];

    obj[@"TLS.sig"] = sig;
    NSLog(@"sig: %@", sig);
    NSError *error = nil;
    NSData *jsonToZipData = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&error];
    if (error) {
        NSLog(@"[Error] json serialization failed: %@", error);
        return @"";
    }

    const Bytef* zipsrc = (const Bytef*)[jsonToZipData bytes];
    uLongf srcLen = jsonToZipData.length;
    uLong upperBound = compressBound(srcLen);
    Bytef *dest = (Bytef*)malloc(upperBound);
    uLongf destLen = upperBound;
    int ret = compress2(dest, &destLen, (const Bytef*)zipsrc, srcLen, Z_BEST_SPEED);
    if (ret != Z_OK) {
        NSLog(@"[Error] Compress Error %d, upper bound: %lu", ret, upperBound);
        free(dest);
        return @"";
    }
    NSString *result = [self base64URL: [NSData dataWithBytesNoCopy:dest length:destLen]];
    return result;
}

+ (NSString *)hmac:(NSString *)plainText
{
    const char *cKey  = [SECRETKEY cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plainText cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return [HMACData base64EncodedStringWithOptions:0];
}

+ (NSString *)base64URL:(NSData *)data
{
    NSString *result = [data base64EncodedStringWithOptions:0];
    NSMutableString *final = [[NSMutableString alloc] init];
    const char *cString = [result cStringUsingEncoding:NSUTF8StringEncoding];
    for (int i = 0; i < result.length; ++ i) {
        char x = cString[i];
        switch(x){
            case '+':
                [final appendString:@"*"];
                break;
            case '/':
                [final appendString:@"-"];
                break;
            case '=':
                [final appendString:@"_"];
                break;
            default:
                [final appendFormat:@"%c", x];
                break;
        }
    }
    return final;
}

@end
