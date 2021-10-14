
#import <Foundation/Foundation.h>
#import "TUISelectGroupMemberViewController.h"
#import "TUICore.h"

NS_ASSUME_NONNULL_BEGIN

// TUIGroupService 目前提供一个服务：
// 创建群成员选择器
//
// TUIGroupService 服务唤起有两种方式：
// 1、强依赖唤起：
// 如果您强依赖 TUIGroup 组件，可以直接通过 [[TUIContactService shareInstance] createSelectGroupMemberViewController] 方法唤起服务。
//
// 2、弱依赖唤起：
// 如果您弱依赖 TUIGroup 组件，可以通过 [TUICore callService:..] 方法唤起服务，不同的服务传参如下：
// > 创建联系人列表：
// serviceName: TUICore_TUIGroupService
// method: TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod
// param: @{
//         TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_GroupIDKey : @"groupID",
//         TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey : @"name",
//         TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_OptionalStyleKey : style
//        };


@interface TUIGroupService : NSObject <TUIServiceProtocol>
/**
 *  获取 TUIGroupService 管理类
 */
+ (TUIGroupService *)shareInstance;

/**
 *  创建群成员选择器
 */
- (TUISelectGroupMemberViewController *)createSelectGroupMemberViewController:(NSString *)groupID name:(NSString *)name optionalStyle:(TUISelectMemberOptionalStyle)optionalStyle;
@end

NS_ASSUME_NONNULL_END
