//
//  TIMConversation.h
//  ImSDK
//
//  Created by bodeng on 28/1/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMConversation_h
#define ImSDK_TIMConversation_h

#import "TIMComm.h"
#import "TIMCallback.h"

@class TIMMessage;

/**
 *  会话
 */
@interface TIMConversation : NSObject

/**
 *  发送消息
 *
 *  @param msg  消息体
 *  @param succ 发送成功时回调
 *  @param fail 发送失败时回调
 *
 *  @return 0 本次操作成功
 */
- (int)sendMessage:(TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  发送在线消息（服务器不保存消息）
 *
 *  @param msg  消息体
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 成功
 */
- (int)sendOnlineMessage:(TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取会话人，单聊为对方账号，群聊为群组Id
 *
 *  @return 会话人
 */
- (NSString*)getReceiver;

/**
 *  获取群名称（只有群会话有效）
 *
 *  @return 群名称
 */
- (NSString*)getGroupName;

/**
 *  获取会话类型
 *
 *  @return 会话类型
 */
- (TIMConversationType)getType;

/**
 *  获取该会话所属用户的id
 *
 *  @return 用户id
 */
- (NSString*)getSelfIdentifier;

@end


#endif
