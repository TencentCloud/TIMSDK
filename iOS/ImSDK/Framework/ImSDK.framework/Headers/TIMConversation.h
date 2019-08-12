/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：TIMConversation 会话模块
//
//  模块功能：一个会话对应一个聊天窗口，比如跟一个好友的 C2C 聊天叫做一个会话，一个聊天群也叫做一个会话。
//     
//  TIMConversation 提供的接口函数都是围绕消息的相关操作，包括：消息发送、获取历史消息、设置消息已读、撤回和删除等等。
//
/////////////////////////////////////////////////////////////////////

#ifndef ImSDK_TIMConversation_h
#define ImSDK_TIMConversation_h

#import "TIMComm.h"
#import "TIMCallback.h"
#import "TIMMessage.h"

@class TIMMessage;

@interface TIMConversation : NSObject

#pragma mark 一，发消息

/////////////////////////////////////////////////////////////////////////////////
//
//                      （一）发消息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 发消息相关接口
/// @{
/**
 *  1.1 发送消息
 *
 *  TIMMessage 由多个 TIMElem 组成，一个 TIMElem 可以是一串文本，也可以是一张图片。
 *  虽然说每一条消息都可以包含多个 TIMElem，但这个并不常用，通常您只需要在一个 TIMMessage 塞入一个 TIMElem 即可。
 *
 *  详情请参考官网文档 [消息收发](https://cloud.tencent.com/document/product/269/9150)
 *
 *  @param msg  消息体
 *  @param succ 发送成功时回调
 *  @param fail 发送失败时回调
 *
 *  @return 0：操作成功；1：操作失败
 */
- (int)sendMessage:(TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  1.2 发送在线消息（无痕消息）
 *
 *  “在线消息”，也可以称为是“无痕消息”。跟普通消息的区别在于：在线消息不会被云服务存储，也不会存储于本地数据库中。
 *  如果接收者在线，可以收到消息，但如果接收者离线，重新上线后也不能通过 getMessage() 接口从历史消息里查到它们。
 *
 *  该类型消息比较适合用作发送广播通知等不重要的提示消息。
 *
 *  1. 在线消息不会被计入未读计数
 *  2. 暂不支持在 AVChatRoom 和 BChatRoom 中发送。
 *
 *  @param msg  消息体
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0：操作成功；1：操作失败
 */
- (int)sendOnlineMessage:(TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

///@}

#pragma mark 二，获取消息
/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）获取消息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 获取消息相关接口
/// @{
/**
 *  2.1 从云端拉取历史消息
 *
 *  如果用户的网络正常且登录成功，可以通过该接口拉取历史消息，该接口会返回云端存储的历史消息（最多存储7天）。
 *
 *  1. 单聊和群聊消息会在云端免费存储7天，如果希望存储更长时间，可前往 
 *     ([IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 消息 ->消息漫游时长)进行购买，
 *     具体资费请参考 [价格说明](https://cloud.tencent.com/document/product/269/11673)。
 *
 *  2. 对于图片、语音等资源类消息，获取到的消息体只会包含描述信息，需要通过额外的接口下载数据，
 *     详情请参考 [消息收发]（https://cloud.tencent.com/document/product/269/9150）中的 "消息解析" 部分文档。
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
 *  2.2 从本地数据库中获取历史消息
 *
 *  如果客户网络异常或登录失败，可以通过该接口获取本地存储的历史消息，调用方法和 getMessage() 一致
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
 *  2.3 获取当前会话的最后一条消息
 *
 *  可用于“装饰”会话列表，目前大多数 App 的会话列表中都会显示该会话的最后一条消息
 *
 *  @return 最后一条消息
 */
- (TIMMessage*)getLastMsg;

///@}

#pragma mark 三，设置消息已读
/////////////////////////////////////////////////////////////////////////////////
//
//                      （三）设置消息已读
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 设置消息已读
/// @{
/**
 *  3.1 标记消息为已读状态
 *
 *  该接口会标记当前消息以及之前的所有消息为已读状态，标记消息为已读状态会有两个作用：
 *  1. 已经被标记为已读的消息不会重复提醒，下次登录或者换一台终端设备登录 IM 时，都不会再次收到该消息的未读提醒。
 *  2. 如果发送者通过 TIMUserConfig -> enableReadReceipt 开启了 “被阅回执”，接收者在标记已读状态时，发送者会收到“被阅提醒”。
 *  
 *  @note 该接口尚不支持标记单独一条消息，只能标记一批。即标记当前一条消息，之前的消息也会全被标记为已读状态。
 *
 *  @param fromMsg 会话内最近一条已读的消息，nil 表示上报最新消息
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 表示成功 
 */
- (int)setReadMessage:(TIMMessage*)fromMsg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  3.2 获取会话的未读消息计数
 *
 *  1. 同一个终端登录，在未卸载 APP 的情况下，您可以通过当前接口获取的未读消息的个数。
 *  2. 如果希望换一台终端也能取到同样的未读计数提醒，或者卸载 APP 再重装，未读计数提醒还能保留卸载前的状态，
 *     就需要设置 TIMUserConfig 的 disableAutoReport 为 YES，这样可以开启多终端同步未读提醒。
 *
 *  详情参考 [未读消息计数]（https://cloud.tencent.com/document/product/269/9151）
 *
 *  @return 返回未读计数
 */
- (int)getUnReadMessageNum;

///@}

#pragma mark 四，撤回/删除消息
/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）撤回/删除消息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 撤回/删除消息相关接口
/// @{
/**
 *  4.1 撤回一条已发送的消息（消息发送后 ）
 *
 *  1. 消息撤回的有效时间为2分钟，即消息发出2分钟后不能再撤回。
 *  2. 仅支持 C2C 会话和 GROUP 会话中发送的消息，无法撤销 OnlineMessage，也无法撤销 AVChatRoom 和 BChatRoom 中的消息。
 *  3. 您需要在 TIMUserConfig -> TIMMessageRevokeListener 监听 onRevokeMessage() 消息撤回回调，
 *     如果消息撤回成功，消息的接收方会收到一次 onRevokeMessage:(TIMMessageLocator*) 回调，TIMMessageLocator 相当于一条消息的定位标志。
 *     您可以在已收到的历史消息里进行遍历，通过 TIMMessage 中的 respondsToLocator() 接口进行比对，以便定位到该条消息。
 *
 *  @param msg   被撤回的消息
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0：本次操作成功；1：本次操作失败
 */
- (int)revokeMessage:(TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  4.2 删除当前会话的本地历史消息
 *
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 本次操作成功
 */
- (int)deleteLocalMessage:(TIMSucc)succ fail:(TIMFail)fail;

///@}

#pragma mark 五，获取会话信息
/////////////////////////////////////////////////////////////////////////////////
//
//                      （五）获取会话信息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 获取会话信息相关接口
/// @{

/**
 *  5.1 获取会话类型
 *
 *  @return 会话类型
 */
- (TIMConversationType)getType;

/**
 *  5.2 获取会话 ID
 *
 *  C2C：对方账号；Group：群组Id。
 *
 *  对同一个单聊或则群聊会话，getReceiver 获取的会话 ID 都是固定的，C2C 获取的是对方账号，Group 获取的是群组 Id。
 *
 *  @return 会话人
 */
- (NSString*)getReceiver;

/**
 *  5.3 获取群名称
 *
 *  获取群名称，只有群会话有效。
 *
 *  @return 群名称
 */
- (NSString*)getGroupName;

///@}

#pragma mark 六，草稿箱
/////////////////////////////////////////////////////////////////////////////////
//
//                      （六）草稿箱
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 草稿箱
/// @{

/**
 *  6.1 添加未编辑完的草稿消息
 *
 *  在发送消息时，常常会遇到尚未编辑完毕就要切换到其它聊天窗口的情况，这些未编辑完的消息就可以通过 setDraft() 接口存储到草稿箱中。
 *  草稿信息会存本地数据库，重新登录后依然可以获取。
 *  
 *
 *  @param draft 草稿内容，详情请参考 TIMMessage.h 里面的 TIMMessageDraft 定义
 *
 *  @return 0：成功；1：失败
 */
- (int)setDraft:(TIMMessageDraft*)draft;

/**
 *  6.2 获取未编辑完的草稿消息
 *
 *  @return 草稿内容，没有草稿返回 nil
 */
- (TIMMessageDraft*)getDraft;

///@}

#pragma mark 七，导入消息到会话
/////////////////////////////////////////////////////////////////////////////////
//
//                      （七）导入消息到会话
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 导入消息到会话相关接口
/// @{
/**
 *  7.1 向本地消息列表中添加一条消息，但并不将其发送出去。
 *
 *  该接口主要用于满足向聊天会话中插入一些提示性消息的需求，比如“您已经退出该群”，这类消息有展示
 *  在聊天消息区的需求，但并没有发送给其他人的必要。
 *  所以 saveMessage() 相当于一个被禁用了网络发送能力的 sendMessage() 接口。
 *
 *  @param msg 消息体
 *  @param sender 发送方
 *  @param isRead 是否已读，如果发送方是自己，默认已读
 *
 *  @return 0：成功；1：失败
 */
- (int)saveMessage:(TIMMessage*)msg sender:(NSString*)sender isReaded:(BOOL)isRead;

/**
 *  7.2 将消息导入本地数据库
 *
 *  @param msgs 消息（TIMMessage*）列表
 *
 *  @return 0：成功；1：失败
 */
- (int)importMessages:(NSArray*)msgs;

///@}
@end


#endif
