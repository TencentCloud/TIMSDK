//
//  TIMManager+MsgExt.h
//  IMMessageExt
//
//  Created by tomzhu on 2017/1/11.
//
//

#ifndef TIMManager_MsgExt_h
#define TIMManager_MsgExt_h

#import "TIMManager.h"
#import "TIMComm+MsgExt.h"

@class TIMMessage;

@interface TIMManager (MsgExt)

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
 *  获取会话（TIMConversation*）列表
 *
 *  @return 会话列表
 */
- (NSArray*)getConversationList;

/**
 *  删除会话
 *
 *  @param type 会话类型，TIM_C2C：表示单聊；TIM_GROUP：表示群聊
 *  @param receiver 用户 identifier 或者群组 Id
 *
 *  @return TRUE:删除成功；FALSE:删除失败
 */
- (BOOL)deleteConversation:(TIMConversationType)type receiver:(NSString*)receiver;

/**
 *  删除会话和消息
 *
 *  这里只是删除本地消息，通过 getMessage 会拉取到漫游消息，所以存在删除消息成功，但是拉取到消息的情况，取决于是否重新从漫游拉回到本地。如果不需要拉取漫游，可以通过 getLocalMessage 获取本地消息，或者只通过 getMessage 拉取指定条数（如未读条数数量）的消息。
 *
 *  @param type 会话类型，TIM_C2C：表示单聊；TIM_GROUP：表示群聊
 *  @param receiver    用户identifier 或者 群组 Id
 *
 *  @return TRUE:删除成功；FALSE:删除失败
 */
- (BOOL)deleteConversationAndMessages:(TIMConversationType)type receiver:(NSString*)receiver;

/**
 *  获取会话数量
 *
 *  @return 会话数量
 */
- (int)conversationCount;

/**
 *  初始化存储（暂未实现）
 *
 *  仅查看历史消息时使用，如果要收发消息等操作，如login成功，不需要调用此函数
 *
 *  @param param 登陆参数（userSig 不用填写）
 *  @param succ  成功回调，收到回调时，可以获取会话列表和消息
 *  @param fail  失败回调
 *
 *  @return 0：请求成功；1：失败
 */
- (int)initStorage:(TIMLoginParam*)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

@end


#endif /* TIMManager_MsgExt_h */
