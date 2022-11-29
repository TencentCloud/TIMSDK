
#import <Foundation/Foundation.h>
#import "TUICore.h"
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * TUIConversationService 目前提供两个服务：
 * 1、创建会话列表
 * 2、创建会话选择器
 *
 * 您可以通过 [TUICore callService:..] 方法唤起服务，不同的服务传参如下：
 * > 创建会话列表：
 * serviceName: TUICore_TUIConversationService_Minimalist
 * method: TUICore_TUIConversationService_GetConversationControllerMethod
 *
 * > 创建会话选择器：
 * serviceName: TUICore_TUIConversationService_Minimalist
 * method ：TUICore_TUIConversationService_GetConversationSelectControllerMethod
 *
 *
 * TUIConversationService currently provides two services:
 * 1. Create a conversation list
 * 2. Create a conversation selector
 *
 * You can call the service through the [TUICore callService:..] method. The different service parameters are as follows:
 * > Create a conversation list:
 * serviceName: TUICore_TUIConversationService_Minimalist
 * method: TUICore_TUIConversationService_GetConversationControllerMethod
 *
 * > Create conversation selector:
 * serviceName: TUICore_TUIConversationService_Minimalist
 * method: TUICore_TUIConversationService_GetConversationSelectControllerMethod
 *
 */

@interface TUIConversationService_Minimalist : NSObject<TUIServiceProtocol>

+ (TUIConversationService_Minimalist *)shareInstance;

@end

NS_ASSUME_NONNULL_END
