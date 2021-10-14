//
//  TUIContactService.h
//  lottie-ios
//
//  Created by kayev on 2021/8/18.
//

#import <Foundation/Foundation.h>
#import "TUIContactController.h"
#import "TUIContactSelectController.h"
#import "TUICore.h"
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

// TUIContactService 目前提供两个服务：
// 1、创建联系人列表
// 2、创建联系人选择器
//
// TUIChatService 服务唤起有两种方式：
// 1、强依赖唤起：
// 如果您强依赖 TUIContact 组件，可以直接通过 [[TUIContactService shareInstance] createContactController] 方法唤起服务。
//
// 2、弱依赖唤起：
// 如果您弱依赖 TUIContact 组件，可以通过 [TUICore callService:..] 方法唤起服务，不同的服务传参如下：
// > 创建联系人列表：
// serviceName: TUICore_TUIContactService
// method: TUICore_TUIContactService_GetContactControllerMethod
//
// > 创建联系人选择器：
// serviceName: TUICore_TUIContactService
// method ：TUICore_TUIContactService_GetContactSelectControllerMethod

@interface TUIContactService : NSObject <TUIServiceProtocol>
/**
 *  获取 TUIContactService 管理类
 */
+ (TUIContactService *)shareInstance;

/**
 *  获取联系人列表
 */
- (TUIContactController *)createContactController;

/**
 *  获取联系人选择列表
 */
- (TUIContactSelectController *)createContactSelectController;
@end

NS_ASSUME_NONNULL_END
