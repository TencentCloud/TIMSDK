//
//  TCLoginModel.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCLoginModel.h"
#import "TCUtil.h"
#import "AppDelegate.h"
#import "NSString+TUIUtil.h"
#import "TCUtil.h"
#import "TCConstants.h"
#import "GenerateTestUserSig.h"

#define kAutoLoginKey         @"kAutoLoginKey"
#define kEachKickErrorCode    6208   //互踢下线错误码


@interface TCLoginModel()
{
    TCLoginParam *_loginParam;

}
@property (nonatomic, copy) NSString* refreshToken;
@property (nonatomic, assign) int64_t expires;
@property (nonatomic, strong) NSDate *expireTime;
@property (nonatomic, copy) NSString* sign;
@property (nonatomic, copy) NSString* txTime;
@property (nonatomic, copy) NSString* accountType;
@property (nonatomic, assign) int sdkAppID;
@end

@implementation TCLoginModel

static TCLoginModel *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[TCLoginModel alloc] init];
    });
    return _sharedInstance;
}


+ (BOOL)isAutoLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    NSNumber *num = [defaults objectForKey:kAutoLoginKey];
    return [num boolValue];
}

+ (void)setAutoLogin:(BOOL)autoLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    [defaults setObject:@(autoLogin) forKey:kAutoLoginKey];
}

- (void)registerWithUsername:(NSString *)username password:(NSString *)password succ:(TCSuccess)succ fail:(TCFail)fail
{
    NSString *hashPwd = [password md5];
    NSDictionary* params = @{@"userid": username, @"password": hashPwd};
    [TCUtil asyncSendHttpRequest:@"register" params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        NSLog(@"%d, %@, %@", resultCode, message, resultDict.description);
        if (resultCode == 200) {
            if (succ)
                succ();
        }
        else {
            if (fail)
                fail(resultCode, [self localMessage:resultCode default:message]);
        }
    }];
    
    [TCUtil report:Action_Register actionSub:@"" code:@(0) msg:@"register"];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password succ:(TCLoginSuccess)succ fail:(TCFail)fail
{
    NSString *hashPwd = [password md5];

    [self loginByToken:username hashPwd:hashPwd succ:succ fail:fail];
}

- (void)loginByToken:(NSString*)username hashPwd:(NSString*)hashPwd succ:(TCLoginSuccess)succ fail:(TCFail)fail
{
    NSDictionary* params = @{@"userid": username, @"password": hashPwd};
    [TCUtil asyncSendHttpRequest:@"login" params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        if (resultCode == 200) {
            [TCLoginModel setAutoLogin:YES];
            @try {
                NSUInteger sdkAppId = [resultDict[@"im_userSig_info"][@"sdkAppID"] integerValue];
                NSString *userSig = resultDict[@"im_userSig_info"][@"userSig"];
                if (succ)
                    succ(userSig, sdkAppId);
            } @catch (NSException *exception) {

            }
        } else {
            if (fail)
                fail(resultCode, [self localMessage:resultCode default:message]);
        }
    }];
}

- (void)getUserSig:(NSString *)user callback:(void (^)(NSString *sig))callback
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?sdkappid=%d", kHttpGetUserSig, SDKAPPID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    request.HTTPMethod = @"POST";
    NSDictionary *param = @{@"cmd":@"open_account_svc", @"sub_cmd":@"fetch_sig", @"id":user};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int code = [[result objectForKey:@"error_code"] intValue];
            NSString *sig = nil;
            if(code == 0){
                sig = [result objectForKey:@"user_sig"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(sig);
            });
        }else{
            callback(@"");
        }
    }];
    [task resume];
}


- (void)logout:(TCSuccess)completion {
    [TCLoginModel setAutoLogin:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:logoutNotification object:nil];
    if (completion) {
        completion();
    }
    self.token = nil;
    self.refreshToken = nil;
    self.sign = nil;
    self.expires = 0;
    self.txTime = nil;
}

- (TCLoginParam *)getLoginParam {
    if (_loginParam) {
        return _loginParam;
    }
    return [[TCLoginParam alloc] init];
}

- (void)getCosSign:(void (^)(int, NSString *, NSDictionary *))completion
{
    NSDictionary* params = @{@"userid": _loginParam.identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":@(self.expires)};

    [TCUtil asyncSendHttpRequest:@"get_cos_sign" token:self.token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        completion(resultCode, message, resultDict);
    }];
}

- (void)getVodSign:(void (^)(int, NSString *, NSDictionary *))completion
{
    NSDictionary* params = @{@"userid": _loginParam.identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":@(self.expires)};
    [TCUtil asyncSendHttpRequest:@"get_vod_sign" token:self.token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        completion(resultCode, message, resultDict);
    }];
}

- (void)uploadUGC:(NSDictionary *)params completion:(void (^)(int, NSString *, NSDictionary *))completion
{
    NSDictionary* hparams = @{@"userid": _loginParam.identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":@(self.expires)};

    NSMutableDictionary* mparams = [NSMutableDictionary dictionaryWithDictionary:hparams];
    [mparams addEntriesFromDictionary:params];

    [TCUtil asyncSendHttpRequest:@"upload_ugc" token:self.token params:mparams handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        completion(resultCode, message, resultDict);
    }];
}

- (void)smsRequest:(RequestType)type param:(NSDictionary *)param succ:(TCSmsSuccess)succ fail:(TCFail)fail {
    NSURL *url = [NSURL URLWithString:[self getSmsUrl:type param:param]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    request.HTTPMethod = @"GET";
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int code = [[result objectForKey:@"errorCode"] intValue];
            if(code == 0){
                NSDictionary *data = result[@"data"];
                if (type == RequestType_GetSms) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (data[@"sessionId"] != nil) {
                            succ(@{@"sessionId":data[@"sessionId"]});
                        } else {
                            fail(-1,@"sessionId is nil");
                        }
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (data[@"userId"] != nil && data[@"userSig"] != nil) {
                            succ(@{@"userId":data[@"userId"],@"userSig":data[@"userSig"]});
                        } else {
                            fail(-1,@"userId or userSig is nil");
                        }
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    fail(code,result[@"errorMessage"]);
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(-1, NSLocalizedString(@"ErrorTipsOpFailed", nil));
            });
        }
    }];
    [task resume];
}


- (NSString *)getSmsUrl:(RequestType)type param:(NSDictionary *)param{
    switch (type) {
        case RequestType_GetSms:
            return [NSString stringWithFormat:@"%@?type=im&phone=%@&ticket=%@&randstr=%@",kHttpSmsImageAddr,param[@"phone"],param[@"ticket"],param[@"randstr"]];
            break;
        case RequestType_Smslogin:{            
            NSString *host = (TUIDemoCurrentServer == TUIDemoServerTypeSingapore) ? kHttpSmsLoginAddr_singapore : kHttpSmsLoginAddr_public;
            return [NSString stringWithFormat:@"%@?method=login&type=im&phone=%@&code=%@&&sessionId=%@",host,param[@"phone"],param[@"code"],param[@"sessionId"]];
        }
            break;
        default:
            break;
    }
    return nil;
}

- (NSString *)localMessage:(int)code default:(NSString *)defaultMessage
{
    if (code == 610)
        return NSLocalizedString(@"ErrorTipsInvalidUser", nil); // @"用户名格式错误";
    if (code == 602)
        return NSLocalizedString(@"ErrorTIpsInvalidUserPwd", nil); // @"用户名或密码不合法";
    if (code == 612)
        return NSLocalizedString(@"ErrorTipsUsernameExists", nil); // @"用户名已存在";
    if (code == 500)
        return NSLocalizedString(@"ErrorTipsServer", nil); // @"服务器错误";
    if (code == 620)
        return NSLocalizedString(@"ErrorTipsUsernameNull", nil); // @"用户不存在";
    if (code == 621)
        return NSLocalizedString(@"ErrorTipsPwdError", nil); // @"密码错误";
    return defaultMessage;

}

@end
