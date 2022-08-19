
#import <Foundation/Foundation.h>
#import "TUIConversationListController.h"
#import "TUIConversationSelectController.h"
#import "TUICore.h"
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * TUIConversationService 目前提供两个服务：
 * 1、创建会话列表
 * 2、创建会话选择器
 *
 * TUIConversationService 服务唤起有两种方式：
 * 1、强依赖唤起：
 * 如果您强依赖 TUIConversation 组件，可以直接通过 [[TUIConversationService shareInstance] createConversationController] 方法唤起服务。
 *
 * 2、弱依赖唤起：
 * 如果您弱依赖 TUIConversation 组件，可以通过 [TUICore callService:..] 方法唤起服务，不同的服务传参如下：
 * > 创建会话列表：
 * serviceName: TUICore_TUIConversationService
 * method: TUICore_TUIConversationService_GetConversationControllerMethod
 *
 * > 创建会话选择器：
 * serviceName: TUICore_TUIConversationService
 * method ：TUICore_TUIConversationService_GetConversationSelectControllerMethod
 *
 *
 * TUIConversationService currently provides two services:
 * 1. Create a conversation list
 * 2. Create a conversation selector
 *
 * There are two ways to invoke the TUIConversationService service:
 * 1. Strong dependency TUIConversation module to invoke:
 * If you strongly depend on the TUIConversation component, you can invoke the service directly through the [[TUIConversationService shareInstance] createConversationController] method.
 *
 * 2. Weak dependency TUIConversation module to invoke:
 * If you are weakly dependent on the TUIConversation component, you can call the service through the [TUICore callService:..] method. The different service parameters are as follows:
 * > Create a conversation list:
 * serviceName: TUICore_TUIConversationService
 * method: TUICore_TUIConversationService_GetConversationControllerMethod
 *
 * > Create conversation selector:
 * serviceName: TUICore_TUIConversationService
 * method: TUICore_TUIConversationService_GetConversationSelectControllerMethod
 *
 */

@interface TUIConversationService : NSObject<TUIServiceProtocol>

+ (TUIConversationService *)shareInstance;

/**
 *  获取会话列表
 *  Create a conversation list view controller
 */
- (TUIConversationListController *)createConversationController;

/**
 *  获取会话选择列表
 *  Create conversation picker view controller
 */
- (TUIConversationSelectController *)createConversationSelectController;
@end

NS_ASSUME_NONNULL_END
