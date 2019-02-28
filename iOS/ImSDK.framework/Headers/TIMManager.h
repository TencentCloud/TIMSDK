//
//  TIMManager.h
//  ImSDK
//
//  Created by bodeng on 28/1/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMManager_h
#define ImSDK_TIMManager_h

#import "TIMComm.h"
#import "TIMCallback.h"

@class TIMGroupManager;
//@class TIMFriendshipManager;

/////////////////////////////////////////////////////////
///  Tencent 开放 SDK API
/////////////////////////////////////////////////////////

/**
 *  通讯管理
 */
@interface TIMManager : NSObject


/**
 *  获取管理器实例
 *
 *  @return 管理器实例
 */
+ (TIMManager*)sharedInstance;

/**
 *  初始化SDK
 *
 *  @param config      配置信息，全局有效
 *
 *  @return 0 成功
 */
- (int)initSdk:(TIMSdkConfig*)config;

/**
 *  获取全局配置
 *
 *  @return 全局配置
 */
- (TIMSdkConfig*)getGlobalConfig;

/**
 *  初始化当前manager，在initSdk:后调用，login:前调用
 *
 *  @param config    配置信息，对当前TIMManager有效
 *
 *  @return 0 成功
 */
- (int)setUserConfig:(TIMUserConfig*)config;

/**
 *  获取当前manager绑定用户的配置
 *
 *  @return 当前manager绑定用户的配置
 */
- (TIMUserConfig*)getUserConfig;

/**
 *  添加消息回调（重复添加无效）
 *
 *  @param listener 回调
 *
 *  @return 成功
 */
- (int)addMessageListener:(id<TIMMessageListener>)listener;

/**
 *  移除消息回调
 *
 *  @param listener 回调
 *
 *  @return 成功
 */
- (int)removeMessageListener:(id<TIMMessageListener>)listener;

/**
 *  登陆
 *
 *  @param param 登陆参数
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 请求成功
 */
- (int)login: (TIMLoginParam*)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  获取当前登陆的用户
 *
 *  @return 如果登陆返回用户的identifier，如果未登录返回nil
 */
- (NSString*)getLoginUser;

/**
 *  获取当前登录状态
 *
 *  @return 登录状态
 */
- (TIMLoginStatus)getLoginStatus;

/**
 *  登出
 *
 *  @param succ 成功回调，登出成功
 *  @param fail 失败回调，返回错误吗和错误信息
 *
 *  @return 0 发送登出包成功，等待回调
 */
- (int)logout:(TIMLoginSucc)succ fail:(TIMFail)fail;

#pragma mark - 消息会话操作

/**
 *  获取会话
 *
 *  @param type 会话类型，TIM_C2C 表示单聊 TIM_GROUP 表示群聊
 *              TIM_SYSTEM 表示系统会话
 *  @param receiver C2C 为对方用户 identifier，GROUP 为群组Id，SYSTEM为@""
 *
 *  @return 会话对象
 */
- (TIMConversation*)getConversation:(TIMConversationType)type receiver:(NSString*)receiver;

#pragma mark - APNs推送

/**
 *  设置Token，需要登录后调用
 *
 *  @param token token信息
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 成功
 */
- (int)setToken:(TIMTokenParam*)token succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  设置APNS配置
 *
 *  @param config APNS配置
 *  @param succ   成功回调
 *  @param fail   失败回调
 *
 *  @return 0 成功
 */
- (int)setAPNS:(TIMAPNSConfig*)config succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取APNS配置
 *
 *  @param succ 成功回调，返回配置信息
 *  @param fail 失败回调
 *
 *  @return 0 成功
 */
- (int)getAPNSConfig:(TIMAPNSConfigSucc)succ fail:(TIMFail)fail;

/**
 *  app 切后台时调用
 *
 *  @param param 上报参数
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 表示成功
 */
- (int)doBackground:(TIMBackgroundParam*)param succ:(TIMSucc)succ fail:(TIMFail)fail;


/**
 *  切前台
 *
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 表示成功
 */
- (int)doForeground:(TIMSucc)succ fail:(TIMFail)fail;

#pragma mark - 调试使用

/**
 * 获取网络状态
 */
- (TIMNetworkStatus)networkStatus;

/**
 *  设置环境（在InitSdk之前调用，注意：除非是IM工作人员指定要求设置，否则不需要调用此接口）
 *
 *  @param env  0 正式环境（默认）
 *              1 测试环境
 */
- (void)setEnv:(int)env;

/**
 *  获取环境类型
 *
 *  @return env 0 正式环境（默认）
 *              1 测试环境
 *              2 beta 环境
 */
- (int)getEnv;

/**
 *  获取版本号
 *
 *  @return 返回版本号，字符串表示，例如v1.1.1
 */
- (NSString*)GetVersion;

/**
 *  获取联网SDK的版本号
 *
 *  @return 返回版本号
 */
- (NSString*)GetQALVersion;

/**
 *  打印日志，通过ImSDK提供的日志功能打印日志
 *
 *  @param level 日志级别
 *  @param tag   模块tag
 *  @param msg   要输出的日志内容
 */
- (void)log:(TIMLogLevel)level tag:(NSString*)tag msg:(NSString*)msg;

#pragma mark - 登录多账号

/**
 *  创建新的管理器类型（多用户登陆时使用，否则可直接调用sharedInstance）
 *
 *  @return 管理器实例
 */
+ (TIMManager*)newManager;

/**
 *  获取管理器类型（多用户登陆时使用，否则可直接调用sharedInstance）
 *
 *  @param identifier 用户identifier
 *
 *  @return 对应管理器类型，如果没有创建过，返回nil
 */
+ (TIMManager*)getManager:(NSString*)identifier;

/**
 *  销毁管理器（多用户登陆时使用，否则可直接调用sharedInstance）
 *
 *  @param manager 需要销毁的管理器
 */
+ (void)deleteManager:(TIMManager*)manager;

/**
 *  获取好友管理器
 *
 *  @return 好友管理器
 */
//- (TIMFriendshipManager*)friendshipManager;

/**
 *  获取群管理器
 *
 *  @return 群管理器
 */
- (TIMGroupManager*)groupManager;

#pragma mark - 内部使用的方法

/**
 * 获取日志文件路径
 */
- (NSString*)getLogPath;

/**
 * 是否开启sdk日志打印
 */
- (BOOL)getIsLogPrintEnabled;

/**
 *  获取日志级别
 *
 *  @return 返回日志级别
 */
-(TIMLogLevel) getLogLevel;
@end
#endif
