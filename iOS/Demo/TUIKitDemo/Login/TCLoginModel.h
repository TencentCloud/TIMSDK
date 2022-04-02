//
//  TCLoginModel.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef APP_EXT
#import "TCLoginModel.h"
#endif
#import "TCLoginParam.h"
#import <Foundation/Foundation.h>

#define  logoutNotification  @"logoutNotification"

typedef NS_ENUM(NSInteger,RequestType) {
    RequestType_GetSms,
    RequestType_Smslogin,
};

typedef void (^TCSuccess)();
typedef void (^TCFail)(int errCode, NSString* errMsg);
typedef void (^TCSmsSuccess)(NSDictionary *smsParam);
typedef void (^TCLoginSuccess)(NSString *sig, NSUInteger sdkAppId);

@protocol TCLoginListener <NSObject>
- (void)LoginOK:(NSString*)userName hashedPwd:(NSString*)pwd;
@end

/**
 *  业务server登录
 */
@interface TCLoginModel : NSObject

@property (nonatomic, copy) NSString* token;

+ (instancetype)sharedInstance;

+ (BOOL)isAutoLogin;

+ (void)setAutoLogin:(BOOL)autoLogin;

- (void)registerWithUsername:(NSString *)username password:(NSString *)password succ:(TCSuccess)succ fail:(TCFail)fail;

- (void)loginWithUsername:(NSString*)username password:(NSString*)password succ:(TCLoginSuccess)succ fail:(TCFail)fail;

- (void)loginByToken:(NSString*)username hashPwd:(NSString*)hashPwd succ:(TCLoginSuccess)succ fail:(TCFail)fail;

- (void)logout:(TCSuccess)completion;

- (void)getCosSign:(void (^)(int errCode, NSString* msg, NSDictionary* resultDict))completion;
- (void)getVodSign:(void (^)(int errCode, NSString* msg, NSDictionary* resultDict))completion;
- (void)uploadUGC:(NSDictionary*)params completion:(void (^)(int errCode, NSString* msg, NSDictionary* resultDict))completion;

- (void)reLogin:(TCLoginSuccess)succ fail:(TCFail)fail;

- (void)smsRequest:(RequestType)type param:(NSDictionary *)param succ:(TCSmsSuccess)succ fail:(TCFail)fail;

@end
