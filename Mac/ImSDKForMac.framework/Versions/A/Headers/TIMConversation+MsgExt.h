//
//  TIMConversation+MsgExt.h
//  IMMessageExt
//
//  Created by tomzhu on 2016/12/27.
//
//

#ifndef TIMConversation_h
#define TIMConversation_h

#import "ImSDK.h"
#import "TIMMessage+MsgExt.h"

@interface TIMConversation (MsgExt)

/**
 *  保存消息到消息列表，这里只保存在本地
 *
 *  @param msg 消息体
 *  @param sender 发送方
 *  @param isReaded 是否已读，如果发送方是自己，默认已读
 *
 *  @return 0 成功
 */
- (int)saveMessage:(TIMMessage*)msg sender:(NSString*)sender isReaded:(BOOL)isReaded;

/**
 *  获取会话消息
 *
 *  @param count 获取数量
 *  @param last  上次最后一条消息
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 本次操作成功
 */
- (int)getMessage:(int)count last:(TIMMessage*)last succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail;

/**
 *  向前获取会话消息
 *
 *  @param count 获取数量
 *  @param last  上次最后一条消息
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 本次操作成功
 */
- (int)getMessageForward:(int)count last:(TIMMessage*)last succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail;

/**
 *  获取本地会话消息
 *
 *  @param count 获取数量
 *  @param last  上次最后一条消息
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 本次操作成功
 */
- (int)getLocalMessage:(int)count last:(TIMMessage*)last succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail;

/**
 *  获取会话消息
 *
 *  @param locators 消息定位符（TIMMessageLocator）数组
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 本次操作成功
 */
- (int)findMessages:(NSArray*)locators succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail;

/**
 *  撤回消息（仅C2C和GROUP会话有效、onlineMessage无效、AVChatRoom和BChatRoom无效）
 *
 *  @param msg   被撤回的消息
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 本次操作成功
 */
- (int)revokeMessage:(TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  同步本会话的消息撤回通知（仅GROUP会话有效）
 *
 *  @param succ  成功时回调，同步的通知会通过TIMMessageRevokeListener抛出
 *  @param fail  失败时回调
 *
 *  @return 0 本次操作成功
 */
- (int)syncRevokeNotify:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  删除本地会话消息
 *
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 本次操作成功
 */
- (int)deleteLocalMessage:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  设置已读消息
 *
 *  @param readed 会话内最近一条已读的消息，nil表示上报最新消息
 *
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 表示成功
 */
- (int)setReadMessage:(TIMMessage*)readed succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取该会话的未读计数
 *
 *  @return 返回未读计数
 */
- (int)getUnReadMessageNum;

/**
 *  获取最后一条消息
 *
 *  @return 最后一条消息
 */
- (TIMMessage*)getLastMsg;

/**
 *  将消息导入本地数据库
 *
 *  @param msgs 消息（TIMMessage*）列表
 *
 *  @return 0 成功
 */
- (int)importMessages:(NSArray*)msgs;

/**
 *  设置会话草稿
 *
 *  @param draft 草稿内容
 *
 *  @return 0 成功
 */
- (int)setDraft:(TIMMessageDraft*)draft;

/**
 *  获取会话草稿
 *
 *  @return 草稿内容，没有草稿返回nil
 */
- (TIMMessageDraft*)getDraft;

/**
 * 禁用本会话的存储，只对当前初始化有效，重启后需要重新设置
 * 需要 initSdk 之后调用
 */
- (void)disableStorage;

@end

#endif /* TIMConversation_h */
