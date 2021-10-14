//
//  TCLoginParam.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/4.
//  Copyright © 2016年 tencent. All rights reserved.
//
/** 腾讯云IM Demo用户登录信息类
 *  用来管理用户的登录信息，如登录信息的缓存、过期判断等
 */
#import "TCLoginParam.h"
#import "TCUtil.h"

@implementation TCLoginParam

#define kLoginParamKey     @"kLoginParamKey"

+ (instancetype)shareInstance
{
    static TCLoginParam *mgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (mgr == nil) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if (defaults == nil) {
                defaults = [NSUserDefaults standardUserDefaults];
            }
            NSString *useridKey = [defaults objectForKey:kLoginParamKey];
            if (useridKey) {
                NSString *strLoginParam = [defaults objectForKey:useridKey];
                NSDictionary *dic = [TCUtil jsonSring2Dictionary: strLoginParam];
                if (dic) {
                    mgr = [[TCLoginParam alloc] init];
                    mgr.tokenTime = [[dic objectForKey:@"tokenTime"] longValue];
                    mgr.identifier = [dic objectForKey:@"identifier"];
                    mgr.hashedPwd = [dic objectForKey:@"hashedPwd"];
                    mgr.isLastAppExt = [[dic objectForKey:@"isLastAppExt"] intValue];
                }
            }
        }
    });
    return mgr;
}

/**
 *从本地获取用户登录资料
 */
+ (instancetype)loadFromLocal {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    NSString *useridKey = [defaults objectForKey:kLoginParamKey];
    if (useridKey) {
        NSString *strLoginParam = [defaults objectForKey:useridKey];
        NSDictionary *dic = [TCUtil jsonSring2Dictionary: strLoginParam];
        if (dic) {
            TCLoginParam *param = [[TCLoginParam alloc] init];
            param.tokenTime = [[dic objectForKey:@"tokenTime"] longValue];
            param.identifier = [dic objectForKey:@"identifier"];
            param.hashedPwd = [dic objectForKey:@"hashedPwd"];
            param.isLastAppExt = [[dic objectForKey:@"isLastAppExt"] intValue];
            return param;
        }
    }
    return [[TCLoginParam alloc] init];
}

/**
 *将用户登录资料保存至本地
 */
- (void)saveToLocal {
    if (self.tokenTime == 0) {
        self.tokenTime = [[NSDate date] timeIntervalSince1970];
    }

    if (![self isValid]) {
        return;
    }

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@(self.tokenTime) forKey:@"tokenTime"];
    [dic setObject:self.identifier forKey:@"identifier"];
    [dic setObject:self.hashedPwd forKey:@"hashedPwd"];
#if APP_EXT
    [dic setObject:@(1) forKey:@"isLastAppExt"];
#else
    [dic setObject:@(0) forKey:@"isLastAppExt"];
#endif

    NSData *data = [TCUtil dictionary2JsonData: dic];
    NSString *strLoginParam = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *useridKey = [NSString stringWithFormat:@"%@_LoginParam", self.identifier];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];;
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }

    [defaults setObject:useridKey forKey:kLoginParamKey];

    // save login param
    [defaults setObject:strLoginParam forKey:useridKey];
    [defaults synchronize];
}

/**
 *登录身份过期的判断。在Demo中默认登录身份永不过期。
 *客户也可参照下方函数中的注释代码编写过期判断，根据自己的需求编写过期判断
 */
- (BOOL)isExpired {
//    time_t curTime = [[NSDate date] timeIntervalSince1970];
//    if (curTime - self.tokenTime > 10 * 24 * 3600) {
//        return YES;
//    }
    return NO;
}

/**
 *判断登录信息是否有效
 */
- (BOOL)isValid {
    if (self.identifier == nil || self.identifier.length == 0) {
        return NO;
    }
    if (self.hashedPwd == nil || self.hashedPwd.length == 0) {
        return NO;
    }
    if ([self isExpired]) {
        return NO;
    }
    return YES;
}

@end
