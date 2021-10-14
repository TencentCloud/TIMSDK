
#import <Foundation/Foundation.h>
#import "TUIConversationListController.h"
#import "TUIConversationSelectController.h"
#import "TUICore.h"
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

// TUIConversationService 目前提供两个服务：
// 1、创建会话列表
// 2、创建会话选择器
//
// TUIConversationService 服务唤起有两种方式：
// 1、强依赖唤起：
// 如果您强依赖 TUIConversation 组件，可以直接通过 [[TUIConversationService shareInstance] createConversationController] 方法唤起服务。
//
// 2、弱依赖唤起：
// 如果您弱依赖 TUIConversation 组件，可以通过 [TUICore callService:..] 方法唤起服务，不同的服务传参如下：
// > 创建会话列表：
// serviceName: TUICore_TUIConversationService
// method: TUICore_TUIConversationService_GetConversationControllerMethod
//
// > 创建会话选择器：
// serviceName: TUICore_TUIConversationService
// method ：TUICore_TUIConversationService_GetConversationSelectControllerMethod

@interface TUIConversationService : NSObject<TUIServiceProtocol>
/**
 *  获取 TUIConversationService 实例
 */
+ (TUIConversationService *)shareInstance;

/**
 *  获取会话列表
 */
- (TUIConversationListController *)createConversationController;

/**
 *  获取会话选择列表
 */
- (TUIConversationSelectController *)createConversationSelectController;
@end

NS_ASSUME_NONNULL_END
