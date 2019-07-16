/******************************************************************************
 *
 *  本文件声明了 TUIConversationDataProviderServiceProtocol 协议。
 *  本协议包含了获取消息的委托，您可以通过本协议在初始化会话/刷新会话时，向会话提供消息数据。
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "ImSDK/TIMConversation.h"
@import UIKit;

@class TIMConversation;
NS_ASSUME_NONNULL_BEGIN

@protocol TUIConversationDataProviderServiceProtocol <NSObject>

/**
 *  获取消息数据。
 *  该协议可以帮助您实现：
 *  1、当前网络状态为连接失败/未连接时，调用 IM SDK 中 TIMConversation 类的 getLocalMessage 接口从本地拉取消息。
 *  2、当当前网络状态正常时，调用 IM SDK 中 TIMConversation 类的 getMessage 接口在线拉取消息。
 *
 *  @param conv 会话示例，负责提供消息的拉取功能。
 *  @param count 想要拉取的消息数目。
 *  @param last 上次最后一条消息
 *  @param succ 成功回调。
 *  @param fail 失败回调。
 *
 *  @return 0:本次操作成功；1:本次操作失败。
 */
- (int)getMessage:(TIMConversation *)conv count:(int)count last:(TIMMessage*)last succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail;

@end

NS_ASSUME_NONNULL_END
