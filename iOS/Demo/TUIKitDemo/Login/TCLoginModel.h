//
//  TCLoginModel.h
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/3.
//  Copyright © 2016 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kKeyLoginInfoApaasTicket;
extern NSString * const kKeyLoginInfoApaasRandStr;
extern NSString * const kKeyLoginInfoUserSig;
extern NSString * const kKeyLoginInfoUserID;

typedef void (^TCSuccess)(NSDictionary *data);
typedef void (^TCFail)(NSInteger errorCode, NSString *errorMsg);

@interface TCLoginModel : NSObject

@property (nonatomic, copy, readonly) NSString *token;
@property (nonatomic, copy, readonly) NSString *captchaAppID;
@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSString *userSig;
@property (nonatomic, assign, readonly) NSUInteger SDKAppID;
@property (nonatomic, copy, readonly) NSString *sessionID;

@property (nonatomic, copy) NSString *ticket;
@property (nonatomic, copy) NSString *randStr;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *smsCode;
@property (nonatomic, assign) BOOL isDirectlyLoginSDK; // debug login is the only way to login sdk directly

+ (instancetype)sharedInstance;

// fetch the global access address from server, usually called when app starts
- (void)getAccessAddressWithSucceedBlock:(TCSuccess)succeed
                               failBlock:(TCFail)fail;

// get sms verification code before logining
- (void)getSmsVerificationCodeWithSucceedBlock:(TCSuccess)succeed
                                     failBlock:(TCFail)fail;

// login account by phone number and sms code
- (void)loginByPhoneWithSucceedBlock:(TCSuccess)succeed
                           failBlock:(TCFail)fail;

// login account by token, usually called in auto-login
- (void)loginByTokenWithSucceedBlock:(TCSuccess)succeed
                           failBlock:(TCFail)fail;

// if user leaves/kills app without logout, app will try auto-login on the next launch of app
- (void)autoLoginWithSucceedBlock:(TCSuccess)succeed
                        failBlock:(TCFail)fail;

// logout the account
- (void)logoutWithSucceedBlock:(TCSuccess)succeed
                     failBlock:(TCFail)fail;

// delete/cancel the account
- (void)deleteUserWithSucceedBlock:(TCSuccess)succeed
                         failBlock:(TCFail)fail;

// clear user's login info
- (void)clearLoginedInfo;

// save user's login info
- (void)saveLoginedInfoWithUserID:(NSString *)userID
                          userSig:(NSString *)userSig;

// load user's login info
- (void)loadLastLoginInfo;

// load user's login info
- (void)loadIsDirectlyLogin;
@end


@interface TCLoginErrorCode : NSObject

+ (NSString *)messageOfCode:(NSInteger)code;

@end
