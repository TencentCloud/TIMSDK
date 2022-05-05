//
//  TCLoginModel.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCLoginModel.h"
#import "TCConstants.h"

static NSString * const kKeySavedLoginInfoAppID = @"Key_Login_Info_AppID";
static NSString * const kKeySavedLoginInfoUserID = @"Key_Login_UserID";
static NSString * const kKeySavedLoginInfoUserSig = @"Key_Login_Info_UserSig";
static NSString * const kKeySavedLoginInfoPhone = @"Key_Login_Info_Phone";
static NSString * const kKeySavedLoginInfoToken = @"Key_Login_Info_InfoToken";
static NSString * const kKeySavedLoginInfoIsDirectlyLogin = @"Key_Login_Info_IsDirectlyLogin";
static NSString * const kKeySavedLoginInfoApaasUser = @"Key_Login_Info_ApaasUser";

static NSString * const kKeyLoginInfoService = @"service";
static NSString * const kKeyLoginInfoCaptchaAppID = @"captcha_web_appid";
static NSString * const kKeyLoginInfoSessionID = @"sessionId";
static NSString * const kKeyLoginInfoToken = @"token";

static NSString * const kKeyLoginInfoPhone = @"phone";
static NSString * const kKeyLoginInfoApaasUserID = @"apaasUserId";
static NSString * const kKeyLoginInfoApaasAppID = @"apaasAppId";

NSString * const kKeyLoginInfoApaasTicket = @"ticket";
NSString * const kKeyLoginInfoApaasRandStr = @"randstr";
NSString * const kKeyLoginInfoUserSig = @"sdkUserSig";
NSString * const kKeyLoginInfoUserID = @"userId";

#define constructURL(h, p, q) [self constructURLWithHost:h env:[self curEnv] path:p query:q]
#define safeValueForKey(k) (k ? : @"")

@interface TCLoginModel()

@property (nonatomic, copy) NSString *serviceUrl;
@property (nonatomic, copy) NSString *apaasUserID;

@property (nonatomic, copy, readwrite) NSString *captchaAppID;
@property (nonatomic, copy, readwrite) NSString *token;
@property (nonatomic, copy, readwrite) NSString *userID;
@property (nonatomic, copy, readwrite) NSString *userSig;
@property (nonatomic, assign, readwrite) NSUInteger SDKAppID;
@property (nonatomic, copy, readwrite) NSString *sessionID;

@end

@implementation TCLoginModel

static TCLoginModel *_sharedInstance = nil;

#pragma mark - Life cycle
+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[TCLoginModel alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Public
- (void)getAccessAddressWithSucceedBlock:(TCSuccess)succeed
                               failBlock:(TCFail)fail {
    NSURL *url = constructURL([self curDispatchServiceHost], kGlobalDispatchServicePath, nil);
    [self requestURL:url completion:^(NSInteger errorCode, NSString *errorMsg, NSDictionary *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorCode == 0) {
                self.serviceUrl = data[kKeyLoginInfoService];
                self.captchaAppID = [NSString stringWithFormat:@"%@", data[kKeyLoginInfoCaptchaAppID]];
                if (succeed) {
                    succeed(data);
                }
            } else {
                if (fail) {
                    fail(errorCode, errorMsg);
                }
            }
        });
    }];
}

- (void)getSmsVerificationCodeWithSucceedBlock:(TCSuccess)succeed failBlock:(TCFail)fail {
    void (^block)(void) = ^() {
        NSURL *url = constructURL([self serviceHost], kGetSmsVerfifyCodePath, self.smsVerficationCodeQuery);
        [self requestURL:url completion:^(NSInteger errorCode, NSString *errorMsg, NSDictionary *data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data[kKeyLoginInfoSessionID] != nil) {
                    self.sessionID = data[kKeyLoginInfoSessionID];
                    succeed(@{kKeyLoginInfoSessionID: self.sessionID});
                } else {
                    NSLog(@"getSmsVerificationCodeWithSucceedBlock failed, error: %ld, errorMsg: %@", (long)errorCode, errorMsg);
                    fail(-1, @"get sms code error, please try again later");
                }
            });
        }];
    };

    if ([self serviceHost] == nil) {
        // 再尝试获取一次 serviceUrl
        [self getAccessAddressWithSucceedBlock:^(NSDictionary *data) {
            block();
        } failBlock:^(NSInteger errorCode, NSString *errorMsg) {
            if (fail) {
                fail(errorCode, errorMsg);
            }
        }];
        return;
    }
    block();
}

- (void)loginByPhoneWithSucceedBlock:(TCSuccess)succeed failBlock:(TCFail)fail {
    NSURL *url = constructURL([self serviceHost], kLoginByPhonePath, self.loginByPhoneQuery);
    [self requestURL:url completion:^(NSInteger errorCode, NSString *errorMsg, NSDictionary *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorCode == 0) {
                [self saveLoginedInfoWithData:data];
                if (succeed) {
                    succeed(data);
                }
            } else {
                if (fail) {
                    fail(errorCode, errorMsg);
                }
            }
        });
    }];
}

- (void)loginByTokenWithSucceedBlock:(TCSuccess)succeed failBlock:(TCFail)fail {
    void (^block)(void) = ^() {
        NSURL *url = constructURL([self serviceHost], kLoginByTokenPath, self.loginByTokenQuery);
        [self requestURL:url completion:^(NSInteger errorCode, NSString *errorMsg, NSDictionary *data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (errorCode == 0) {
                    [self saveLoginedInfoWithData:data];
                    self.token = data[kKeyLoginInfoToken];
                    if (succeed) {
                        succeed(data);
                    }
                } else {
                    if (fail) {
                        fail(errorCode, errorMsg);
                    }
                }
            });
        }];
    };
    
    if ([self serviceHost] == nil) {
        [self getAccessAddressWithSucceedBlock:^(NSDictionary *data) {
            block();
        } failBlock:^(NSInteger errorCode, NSString *errorMsg) {
            if (fail) {
                fail(errorCode, errorMsg);
            }
        }];
        return;
    }
    block();
}

- (void)autoLoginWithSucceedBlock:(TCSuccess)succeed
                        failBlock:(TCFail)fail {
    [self loadIsDirectlyLogin];
    [self loadLastLoginInfo];
    
    if (self.isDirectlyLoginSDK) {
        if (succeed) {
            NSDictionary *data = @{
                kKeyLoginInfoUserSig: safeValueForKey(self.userSig),
                kKeyLoginInfoUserID: safeValueForKey(self.userID),
            };
            succeed(data);
        }
        return;
    }
    [self loginByTokenWithSucceedBlock:^(NSDictionary *data) {
        if (succeed) {
            succeed(data);
        }
    } failBlock:^(NSInteger errorCode, NSString *errorMsg) {
        if (fail) {
            fail(errorCode, errorMsg);
        }
    }];
}

- (void)logoutWithSucceedBlock:(TCSuccess)succeed failBlock:(TCFail)fail {
    if (self.isDirectlyLoginSDK) {
        [self clearDirectlyLoginedInfo];
        if (succeed) {
            succeed(@{});
        }
        return;
    }
    NSURL *url = constructURL([self serviceHost], kLogoutPath, self.logoutQuery);
    [self requestURL:url completion:^(NSInteger errorCode, NSString *errorMsg, NSDictionary *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorCode == 0) {
                [self clearLoginedInfo];
                if (succeed) {
                    succeed(data);
                }
            } else {
                if (fail) {
                    fail(errorCode, errorMsg);
                }
            }
        });
    }];
}

- (void)deleteUserWithSucceedBlock:(TCSuccess)succeed failBlock:(TCFail)fail {
    if (self.isDirectlyLoginSDK) {
        [self clearDirectlyLoginedInfo];
        if (succeed) {
            succeed(@{});
        }
        return;
    }
    NSURL *url = constructURL([self serviceHost], kDeleteUserPath, [self deleteUserQuery]);
    [self requestURL:url completion:^(NSInteger errorCode, NSString *errorMsg, NSDictionary *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorCode == 0) {
                [self clearLoginedInfo];
                if (succeed) {
                    succeed(data);
                }
            } else {
                if (fail) {
                    fail(errorCode, errorMsg);
                }
            }
        });
    }];
}

- (void)clearLoginedInfo {
    self.userID = nil;
    self.isDirectlyLoginSDK = false;
    self.token = nil;
    self.sessionID = nil;
    self.ticket = nil;
    self.randStr = nil;
    self.phone = nil;
    self.smsCode = nil;
    self.userSig = nil;
    self.SDKAppID = 0;
    self.apaasUserID = nil;
    [self clearSavedLoginedInfo];
}

- (void)saveLoginedInfoWithUserID:(NSString *)userID
                          userSig:(NSString *)userSig {
    if (userID.length == 0 || userSig.length == 0) {
        return;
    }
    [self saveLoginedInfoWithData:@{
        kKeyLoginInfoUserID: userID,
        kKeyLoginInfoUserSig: userSig
    }];
}

#pragma mark - Private
- (void)clearDirectlyLoginedInfo {
    self.userID = nil;
    self.userSig = nil;
    self.isDirectlyLoginSDK = false;
    self.apaasUserID = nil;
    
    [self clearSavedLoginedInfo];
}

- (NSURL *)constructURLWithHost:(NSString *)host
                            env:(NSString *)env
                           path:(NSString *)path
                          query:(NSDictionary *)query {
    if (host.length == 0 || env.length == 0 || path.length == 0) {
        return nil;
    }
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"https";
    components.host = host;
    components.path = [NSString stringWithFormat:@"%@%@", env, path];
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *key in query.allKeys) {
        NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:query[key]];
        [items addObject:item];
    }
    components.queryItems = [items copy];
    
    return components.URL;
}

- (void)requestURL:(NSURL *)url
        completion:(void(^)(NSInteger errorCode, NSString *errorMsg, NSDictionary *data))block {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:30];
    if (url == nil && block) {
        block(-2, @"construct url failed, check the input params", nil);
        return;
    }
    request.HTTPMethod = @"GET";
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int code = [result[@"errorCode"] intValue];
            NSString *msg = result[@"errorMessage"];
            NSDictionary *data = result[@"data"];
            if (block) {
                block(code, msg, data);
            }
            NSLog(@"\n---------------response---------------\nurl: %@\ncode: %d\nmsg: %@\ndata: %@", url, code, msg, data);
        } else {
            if (block) {
                block(error.code, error.userInfo[NSLocalizedDescriptionKey], nil);
            }
            NSLog(@"\n---------------response---------------\nurl: %@\ncode: %ld\nmsg: %@", url, (long)error.code, error.userInfo[NSLocalizedDescriptionKey]);
        }
    }];
    [task resume];
}

#pragma mark -- Persistence
- (void)saveLoginedInfoWithData:(NSDictionary *)data {
    NSString *userID = data[kKeyLoginInfoUserID];
    NSNumber *appID = data[@"sdkAppId"];
    NSString *userSig = data[kKeyLoginInfoUserSig];
    NSString *token = data[kKeyLoginInfoToken];
    NSString *phone = data[kKeyLoginInfoPhone];
    NSString *apaasUserID = data[kKeyLoginInfoApaasUserID];
    
    if (appID) {
        self.SDKAppID = [appID unsignedIntValue];
        [[NSUserDefaults standardUserDefaults] setObject:appID forKey:kKeySavedLoginInfoAppID];
        
    }
    if (userID.length > 0) {
        self.userID = userID;
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:kKeySavedLoginInfoUserID];
    }
    if (userSig.length > 0) {
        self.userSig = userSig;
        [[NSUserDefaults standardUserDefaults] setObject:userSig forKey:kKeySavedLoginInfoUserSig];
    }
    if (phone.length > 0) {
        self.phone = phone;
        [[NSUserDefaults standardUserDefaults] setObject:phone forKey:kKeySavedLoginInfoPhone];
    }
    if (token.length > 0) {
        self.token = token;
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:kKeySavedLoginInfoToken];
    }
    if (apaasUserID.length > 0) {
        self.apaasUserID = apaasUserID;
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:kKeySavedLoginInfoApaasUser];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearSavedLoginedInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeySavedLoginInfoUserSig];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeySavedLoginInfoToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeySavedLoginInfoPhone];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeySavedLoginInfoUserID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeySavedLoginInfoUserID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeySavedLoginInfoApaasUser];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadLastLoginInfo {
    self.userID = [[NSUserDefaults standardUserDefaults] objectForKey:kKeySavedLoginInfoUserID];
    self.token = [[NSUserDefaults standardUserDefaults] objectForKey:kKeySavedLoginInfoToken];
    self.userSig = [[NSUserDefaults standardUserDefaults] objectForKey:kKeySavedLoginInfoUserSig];
    self.apaasUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kKeySavedLoginInfoApaasUser];
}

- (void)setIsDirectlyLoginSDK:(BOOL)isDirectlyLoginSDK {
    if (_isDirectlyLoginSDK == isDirectlyLoginSDK) {
        return;
    }
    _isDirectlyLoginSDK = isDirectlyLoginSDK;
    [[NSUserDefaults standardUserDefaults] setBool:isDirectlyLoginSDK forKey:kKeySavedLoginInfoIsDirectlyLogin];
}

- (void)loadIsDirectlyLogin {
    self.isDirectlyLoginSDK = [[NSUserDefaults standardUserDefaults] boolForKey:kKeySavedLoginInfoIsDirectlyLogin];
}

#pragma mark - Getter
- (NSDictionary *)smsVerficationCodeQuery {
    return @{
        @"appId": safeValueForKey(self.captchaAppID), // 图片验证码的 appID
        kKeyLoginInfoApaasTicket: safeValueForKey(self.ticket), // 图片验证码服务返回的 ticket
        kKeyLoginInfoApaasRandStr: safeValueForKey(self.randStr), // 图片验证码服务返回的 randstr
        kKeyLoginInfoPhone: safeValueForKey(self.phone), // phone
        kKeyLoginInfoApaasAppID: [self curApaasAppID] // 多租户
    };
}

- (NSDictionary *)loginByPhoneQuery {
    return @{
        kKeyLoginInfoSessionID: safeValueForKey(self.sessionID), // 获取短信验证码返回的 sessionID
        kKeyLoginInfoPhone: safeValueForKey(self.phone), // phone 和 email 二选一
        @"code": safeValueForKey(self.smsCode), // 用户输入的短信验证码
        kKeyLoginInfoApaasAppID: [self curApaasAppID] // 多租户
    };
}

- (NSDictionary *)loginByTokenQuery {
    return @{
        kKeyLoginInfoUserID: safeValueForKey(self.userID), // 登录之后返回的 userID
        kKeyLoginInfoToken: safeValueForKey(self.token), // 登录之后返回的 token
        kKeyLoginInfoApaasAppID: [self curApaasAppID],
        kKeyLoginInfoApaasUserID: safeValueForKey(self.apaasUserID)
    };
}

- (NSDictionary *)logoutQuery {
    return [self loginByTokenQuery];
}

- (NSDictionary *)deleteUserQuery {
    return [self loginByTokenQuery];
}

- (NSString *)curEnv {
    return kEnvProd;
}

- (NSString *)curApaasAppID {
#if BUILDINTERNATIONAL
    return kApaasAppID_international;
#else
    return kApaasAppID;
#endif
}

- (NSString *)curDispatchServiceHost {
#if BUILDINTERNATIONAL
    return kGlobalDispatchServiceHost_international;
#else
    return kGlobalDispatchServiceHost;
#endif
}

- (NSString *)serviceHost {
    if (self.serviceUrl == nil) {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:self.serviceUrl];
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    return components.host;
}

@end
