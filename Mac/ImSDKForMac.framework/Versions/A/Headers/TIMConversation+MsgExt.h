//
//  TIMConversation+MsgExt.h
//  IMMessageExt
//
//  Created by tomzhu on 2016/12/27.
//
//

#ifndef TIMConversation_h
#define TIMConversation_h

#import "TIMConversation.h"
#import "TIMMessage+MsgExt.h"

@interface TIMConversation (MsgExt)

/**
 *  保存会话消息
 *
 *  保存消息到消息列表，这里只保存在本地。
 *
 *  @param msg 消息体
 *  @param sender 发送方
 *  @param isReaded 是否已读，如果发送方是自己，默认已读
 *
 *  @return 0：成功；1：失败
 */
- (int)saveMessage:(TIMMessage*)msg sender:(NSString*)sender isReaded:(BOOL)isReaded;

/**
 *  获取会话漫游消息
 *
 *  1. 登录后可以获取漫游消息，单聊和群聊消息免费漫游7天，用户有额外消息漫游需求时，可前往 [IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 消息 ->消息漫游时长 购买，具体资费请参考 [价格说明](https://cloud.tencent.com/document/product/269/11673)。
 *  2. 如果本地消息全部都是连续的，则不会通过网络获取，如果本地消息不连续，会通过网络获取断层消息。
 *  3. 对于图片、语音等资源类消息，消息体只会包含描述信息，需要通过额外的接口下载数据，详情请参考 [消息收发]（https://cloud.tencent.com/document/product/269/9150）中的 "消息解析" 部分文档。
 *
 *  @param count 获取数量
 *  @param last  上次最后一条消息，如果 last 为 nil，从最新的消息开始读取
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0：本次操作成功；1：本次操作失败
 */
- (int)getMessage:(int)count last:(TIMMessage*)last succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail;

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
 *  获取本地会话消息
 *
 *  1. 对于单聊，登录后可以获取本地缓存消息
 *  2. 对于群组，开启最近联系人漫游（登录之后 SDK 默认开启，可以通过 TIMUserConfig 里面的 disableRecnetContact 关闭）的情况下，登录后只能获取最近一条消息，可通过 getMessage 获取漫游消息
 *
 *  @param count 获取数量
 *  @param last  上次最后一条消息
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0：本次操作成功；1：本次操作失败
 */
- (int)getLocalMessage:(int)count last:(TIMMessage*)last succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail;

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
 *  撤回消息
 *
 *  1. 仅 C2C 和 GROUP 会话有效、onlineMessage 无效、AVChatRoom 和 BChatRoom 无效。
 *  2. 可以在 TIMUserConfig 设置的 TIMMessageRevokeListener 监听 onRevokeMessage 消息撤回回调。
 *  3. 遍历本地消息列表，如果消息的 respondsToLocator 函数返回 YES，则是对应的消息，您可以在 UI 上执行删除操作，具体可以参考 TMessageController.h 里面的 onRevokeMessage 回调的实现。
 *
 *  @param msg   被撤回的消息
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0：本次操作成功；1：本次操作失败
 */
- (int)revokeMessage:(TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  同步群的消息撤回通知
 *
 *  针对群组，断线重连后，如果用户处于群组聊天界面，需要业务端主动同步该群组会话的消息撤回通知。其他场景不需要主动同步消息撤回通知。
 *
 *  @param succ  成功时回调，同步的通知会通过 TIMMessageRevokeListener 抛出
 *  @param fail  失败时回调
 *
 *  @return 0 本次操作成功
 */
- (int)syncRevokeNotify:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  删除本地会话消息
 *
 *  可以在保留会话同时删除本地的会话消息。
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
 *  1. 如果在 TIMUserConfig 关闭了自动已读上报（设置 disableAutoReport 为 YES），这里需要显示调用 setReadMessage ，消息的已读状态才会改变。
 *  2. 如果在 TIMUserConfig 开启了消息回执（设置 enableReadReceipt 为 YES），收消息的用户需要显示调用 setReadMessage ，发消息的用户才能通过 TIMMessageReceiptListener 监听到消息的已读回执。
 *  3. 如果您需要设置单条消息的已读状态，请使用 TIMMessage+MsgExt.h 中的 setCustomInt 自定义字段接口设置，通过 customInt 获取，需要注意的是，这个接口设置的字段只在本地保存，如果切换了终端，或则 APP 被卸载，这个值都会失效。
 *
 *  @param readed 会话内最近一条已读的消息，nil 表示上报最新消息
 *
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 表示成功
 */
- (int)setReadMessage:(TIMMessage*)readed succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取会话的未读计数
 *
 *  1. 单终端，未卸载 APP 的情况下，您可以通过当前接口获取准确的未读计数。
 *  2. 如果需要在多终端或则程序 APP 卸载重装后未读计数依然准确，请设置 TIMUserConfig 的 disableAutoReport 为 YES，然后显示调用 setReadMessage。详情请参考 [未读消息计数]（https://cloud.tencent.com/document/product/269/9151）
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
 *  @return 0：成功；1：失败
 */
- (int)importMessages:(NSArray*)msgs;

/**
 *  设置会话草稿
 *
 *  UI 展示最近联系人列表时，时常会展示用户的草稿内容，ImSDK 提供了设置和获取草稿的接口，用户可以通过此接口设置会话的草稿信息。草稿信息会存本地数据库，重新登录后依然可以获取。
 *
 *  @param draft 草稿内容，详情请参考 TIMMessage+MsgExt.h 里面的 TIMMessageDraft 定义
 *
 *  @return 0：成功；1：失败
 */
- (int)setDraft:(TIMMessageDraft*)draft;

/**
 *  获取会话草稿
 *
 *  @return 草稿内容，没有草稿返回 nil
 */
- (TIMMessageDraft*)getDraft;

/**
 *  禁用本会话的存储(暂未实现)
 *
 *  1. 需要 initSdk 之后调用
 *  2. 只对当前初始化有效，重启后需要重新设置
 */
- (void)disableStorage;

@end

#endif /* TIMConversation_h */
