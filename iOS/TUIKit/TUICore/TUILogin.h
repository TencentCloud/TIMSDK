/////////////////////////////////////////////////////////////////////
//
//                     IMSDK 的管理类
//
//  模块名称：TUILogin
//
//  该模块主要负责 IM 和 TRTC 的登录逻辑
//
/////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

typedef void (^TFail)(int code, NSString * msg);
typedef void (^TSucc)(void);


@protocol TUILoginListener <NSObject>

/// SDK 正在连接到服务器
- (void)onConnecting;

/// SDK 已经成功连接到服务器
- (void)onConnectSuccess;

/// SDK 连接服务器失败
- (void)onConnectFailed:(int)code err:(NSString*)err;

/// 当前用户被踢下线，此时可以 UI 提示用户，并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onKickedOffline;

/// 在线时票据过期：此时您需要生成新的 userSig 并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onUserSigExpired;

@end

@interface TUILogin : NSObject
/**
 *  初始化
 */
+ (void)initWithSdkAppID:(int)sdkAppID __attribute__((deprecated("use login:userID:userSig:succ:fail:")));
/**
 *  登录
 */
+ (void)login:(NSString *)userID
      userSig:(NSString *)userSig
         succ:(TSucc)succ
         fail:(TFail)fail __attribute__((deprecated("use login:userID:userSig:succ:fail:")));

/**
 * 登录
 */
+ (void)login:(int)sdkAppID
       userID:(NSString *)userID
      userSig:(NSString *)userSig
         succ:(TSucc)succ
         fail:(TFail)fail;

/**
 *  登出
 */
+ (void)logout:(TSucc)succ fail:(TFail)fail;


+ (void)addLoginListener:(id<TUILoginListener>)listener;
+ (void)removeLoginListener:(id<TUILoginListener>)listener;

/**
 *  获取 sdkappid
 */
+ (int)getSdkAppID;

/**
 *  获取 userID
 */
+ (NSString *)getUserID;

/**
 *  获取 userSig
 */
+ (NSString *)getUserSig;

/**
 *  获取昵称
 */
+ (NSString *)getNickName;

/**
 *  获取头像
 */
+ (NSString *)getFaceUrl;
@end
