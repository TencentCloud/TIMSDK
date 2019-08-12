/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：TIMManager + MsgExt
//
//  模块功能：此处主要存放待废弃的 API 函数，建议您使用 TIMManager.h 内部声明的接口函数
//
/////////////////////////////////////////////////////////////////////

#ifndef TIMManager_MsgExt_h
#define TIMManager_MsgExt_h

#import "TIMManager.h"

/**
 * IMSDK 扩展类，此处主要存放待废弃的 API 函数，建议您使用 TIMManager.h 内部声明的接口函数
 */
@interface TIMManager (MsgExt)

/**
 *  获取群管理器
 *
 *  此函数待废弃，请直接使用 TIMGroupManager 的 sharedInstance 函数
 * 
 *  @return 群管理器，详情请参考 TIMGroupManager.h 中的 TIMGroupManager 定义
 */
- (TIMGroupManager*)groupManager;


/**
 *  获取好友管理器
 *
 *  此函数待废弃，请直接使用 TIMFriendshipManager 的 sharedInstance 函数
 *
 *  @return 好友管理器，详情请参考 TIMFriendshipManager.h 中的 TIMFriendshipManager 定义
 */
- (TIMFriendshipManager*)friendshipManager;

/**
 *  获取会话数量
 *
 *  @return 会话数量
 */
- (int)conversationCount;

/**
 *  发送消息给多个用户
 *
 *  @param msg   发送的消息
 *  @param users 目标用户的id列表
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送成功
 */
- (int)sendMessage:(TIMMessage*)msg toUsers:(NSArray*)users succ:(TIMSucc)succ fail:(TIMSendToUsersFail)fail;

/**
 *  自定义版本号
 *
 *  @param version 版本号
 *  @note setCustomVersion() 要在 initSdk() 之前调用。
 */
- (void)setCustomVersion:(NSString *)version;

@end


#endif /* TIMManager_MsgExt_h */
