
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 * TUILogin
 * This module is mainly responsible for the login logic of IM and TRTC
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TFail)(int code, NSString * __nullable msg);
typedef void (^TSucc)(void);
typedef NS_ENUM(NSInteger, TUILogLevel) {
    /**
     * < 不输出任何 sdk log
     * < Do not output any SDK logs
     */
    TUI_LOG_NONE = 0,
    /**
     * < 输出 DEBUG，INFO，WARNING，ERROR 级别的 log
     * < Output logs at the DEBUG, INFO, WARNING, and ERROR levels
     */
    TUI_LOG_DEBUG = 3,
    /**
     * < 输出 INFO，WARNING，ERROR 级别的 log
     * < Output logs at the INFO, WARNING, and ERROR levels
     */
    TUI_LOG_INFO = 4,
    /**
     * < 输出 WARNING，ERROR 级别的 log
     * < Output logs at the WARNING and ERROR levels
     */
    TUI_LOG_WARN = 5,
    /**
     * < 输出 ERROR 级别的 log
     * < Output logs at the ERROR level
     */
    TUI_LOG_ERROR = 6,
};

/**
 * 场景化状态
 * Status in different kinds of business scene
 */
typedef NS_ENUM(NSInteger, TUIBusinessScene) {
    None = 0,
    InRecording = 1,
    InCallingRoom = 2,
    InMeetingRoom = 3,
    InLivingRoom = 4,
};

/**
 * 登录成功的通知
 * Notification for log-in succeed
 */
FOUNDATION_EXTERN NSString *const TUILoginSuccessNotification;

/**
 * 登录失败的通知
 * Notification for log-in failed
 */
FOUNDATION_EXTERN NSString *const TUILoginFailNotification;

/**
 * 登出成功的通知
 * Notification for log-out succeed
 */
FOUNDATION_EXTERN NSString *const TUILogoutSuccessNotification;

/**
 * 登出失败的通知
 * Notification for log-out failed
 */
FOUNDATION_EXTERN NSString *const TUILogoutFailNotification;

@protocol TUILoginListener <NSObject>

/**
 * SDK 正在连接到服务器
 * Callback that the SDK is connecting to the server
 */
- (void)onConnecting;

/**
 * SDK 已经成功连接到服务器
 * Callback that the SDK has successfully connected to the server
 */
- (void)onConnectSuccess;

/**
 * SDK 连接服务器失败
 * Callback for SDK connection to server failure
 */
- (void)onConnectFailed:(int)code err:(NSString * __nullable)err;

/**
 * 当前用户被踢下线，此时可以 UI 提示用户，并再次调用 V2TIMManager 的 login() 函数重新登录。
 * The callback of the current user being kicked off, the user can be prompted on the UI at this time, and the login() function of V2TIMManager can be called
 * again to log in again.
 */
- (void)onKickedOffline;

/**
 * 在线时票据过期：此时您需要生成新的 userSig 并再次调用 V2TIMManager 的 login() 函数重新登录。
 * The callback of the login credentials expired when online, you need to generate a new userSig and call the login() function of V2TIMManager again to log in
 * again.
 */
- (void)onUserSigExpired;

@end

@interface TUILoginConfig : NSObject

@property(nonatomic, assign) TUILogLevel logLevel;

@property(nonatomic, copy, nullable) void (^onLog)(NSInteger logLevel, NSString * __nullable logContent);

@end

@interface TUILogin : NSObject

+ (void)initWithSdkAppID:(int)sdkAppID __attribute__((deprecated("use login:userID:userSig:succ:fail:")));

+ (void)login:(NSString *)userID
      userSig:(NSString *)userSig
         succ:(__nullable TSucc)succ
         fail:(__nullable TFail)fail __attribute__((deprecated("use login:userID:userSig:succ:fail:")));

+ (void)login:(int)sdkAppID
       userID:(NSString *)userID
      userSig:(NSString *)userSig
         succ:(__nullable TSucc)succ
         fail:(__nullable TFail)fail;

+ (void)login:(int)sdkAppID
       userID:(NSString *)userID
      userSig:(NSString *)userSig
       config:(TUILoginConfig * __nullable)config
         succ:(__nullable TSucc)succ
         fail:(__nullable TFail)fail;

+ (void)logout:(__nullable TSucc)succ
          fail:(__nullable TFail)fail;

+ (void)addLoginListener:(id<TUILoginListener>)listener;
+ (void)removeLoginListener:(id<TUILoginListener>)listener;

+ (int)getSdkAppID;
+ (BOOL)isUserLogined;

+ (NSString * __nullable)getUserID;
+ (NSString * __nullable)getUserSig;

+ (NSString * __nullable)getNickName;
+ (NSString * __nullable)getFaceUrl;

/**
 * No-thread-safe
 */
+ (void)setCurrentBusinessScene:(TUIBusinessScene)scene;
+ (TUIBusinessScene)getCurrentBusinessScene;

@end

NS_ASSUME_NONNULL_END
