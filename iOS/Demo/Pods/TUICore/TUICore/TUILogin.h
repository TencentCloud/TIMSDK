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

@interface TUILogin : NSObject
/**
 *  初始化
 */
+ (void)initWithSdkAppID:(int)sdkAppID;

/**
 *  登录
 */
+ (void)login:(NSString *)userID userSig:(NSString *)userSig succ:(TSucc)succ fail:(TFail)fail;

/**
 *  登出
 */
+ (void)logout:(TSucc)succ fail:(TFail)fail;

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
