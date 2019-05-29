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
 *  TIMMessage 由多个 TIMElem 组成，每个 TIMElem 可以是文本和图片，也就是说每一条消息可包含多个文本和多张图片。详情请参考官网文档 [消息收发](https://cloud.tencent.com/document/product/269/9150)
 *
 *  @param msg  消息体
 *  @param succ 发送成功时回调
 *  @param fail 发送失败时回调
 *
 *  @return 0：操作成功；1：操作失败
 */
- (int)sendMessage:(TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  发送在线消息（服务器不保存消息）
 *
 *  1. 对于某些场景，需要发送在线消息，即用户在线时收到消息，如果用户不在线，下次登录也不会看到消息，可用于通知类消息，这种消息不会进行存储，也不会计入未读计数。发送接口与 sendMessage 类似。
 *  2. 暂不支持 AVChatRoom 和 BChatRoom 类型。
 *
 *  @param msg  消息体
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0：操作成功；1：操作失败
 */
- (int)sendOnlineMessage:(TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取会话人
 *
 *  C2C：对方账号；Group：群组Id。
 *
 *  对同一个 C2C 会话或则群聊会话，getReceiver 获取的会话人都是固定的，C2C 获取的是对方账号，Group 获取的是群组 Id。
 *
 *  @return 会话人
 */
- (NSString*)getReceiver;

/**
 *  获取群名称
 *
 *  获取群名称，只有群会话有效。
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
 *  获取自己的 id
 *
 *  @return 用户 id
 */
- (NSString*)getSelfIdentifier;

@end


#endif
