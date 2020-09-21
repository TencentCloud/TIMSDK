/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：TIMConversation + MsgExt
//
//  模块功能：此处主要存放待废弃的 API 函数，建议您使用 TIMConversation.h 内部声明的接口函数
//
/////////////////////////////////////////////////////////////////////

#ifndef TIMConversation_h
#define TIMConversation_h
#import "TIMConversation.h"


@interface TIMConversation (MsgExt)

/**
 *  向前获取会话漫游消息
 *
 *  调用方式和 getMessage 一样，区别是 getMessage 获取的是时间更老的消息，主要用于下拉 Tableview 刷新消息数据，getMessageForward 获取的是时间更新的消息，主要用于上拉 Tableview 刷新消息数据。
 *
 *  @param count 获取数量
 *  @param last  上次最后一条消息，如果 last 为 nil，从最新的消息开始读取
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0：本次操作成功；1：本次操作失败
 */
- (int)getMessageForward:(int)count last:(TIMMessage*)last succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail;

/**
 *  获取指定会话消息
 *
 *  @param locators 消息定位符（TIMMessageLocator）数组
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0：本次操作成功；1：本次操作失败
 */
- (int)findMessages:(NSArray*)locators succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail;

/**
 *  获取自己的 id
 *
 *  @return 用户 id
 */
- (NSString*)getSelfIdentifier;

/**
 *  删除单个会话和对应的本地会话消息
 *
 *  与 deleteConversation() 的差异在于本接口在删除会话的同时仅仅删除了本地消息，如果该会话因为发消息等操作重新激活，仍然能拉取到漫游消息。
 *
 *  @note 本接口只能删除本地缓存的历史消息，无法删除云端保存的历史消息。
 *  @param type 会话类型，详情请参考 TIMComm.h 里面的 TIMConversationType 定义
 *  @param conversationId 会话 Id
 *                        单聊类型（C2C）   ：为对方 userID；
 *                        群组类型（GROUP） ：为群组 groupId；
 *                        系统类型（SYSTEM）：为 @""
 *
 *  @return YES:删除成功；NO:删除失败
 */
- (BOOL)deleteConversationAndMessages:(TIMConversationType)type receiver:(NSString*)conversationId;

/**
 *  删除当前会话的本地历史消息
 *
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 本次操作成功
 */
- (int)deleteLocalMessage:(TIMSucc)succ fail:(TIMFail)fail;

@end

#endif /* TIMConversation_h */
