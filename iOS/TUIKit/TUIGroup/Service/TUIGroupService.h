
#import <Foundation/Foundation.h>
#import "TUIGroupInfoController.h"
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
// > 创建群资料界面：
// serviceName: TUICore_TUIGroupService
// method: TUICore_TUIGroupService_GetGroupInfoControllerMethod
// param: @{
//         TUICore_TUIGroupService_GetGroupInfoControllerMethod_GroupIDKey; @"groupID"
//        };
// > 创建群成员选择器：
// serviceName: TUICore_TUIGroupService
// method: TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod
// param: @{
//         TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_GroupIDKey : @"groupID",
//         TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey : @"name",
//         TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_OptionalStyleKey : style
//        };
// > 创建群聊：
// serivceName: TUICore_TUIGroupService
// method: TUICore_TUIGroupService_CreateGroupMethod
// param: @{
//         TUICore_TUIGroupService_CreateGroupMethod_GroupTypeKey: @"GroupType",
//         TUICore_TUIGroupService_CreateGroupMethod_OptionKey: option
//         TUICore_TUIGroupService_CreateGroupMethod_ContactsKey: contacts
//         TUICore_TUIGroupService_CreateGroupMethod_CompletionKey: createGroupCompletion
//        };


@interface TUIGroupService : NSObject <TUIServiceProtocol>
/**
 *  获取 TUIGroupService 管理类
 */
+ (TUIGroupService *)shareInstance;

/**
 *  创建群资料界面
 */
- (TUIGroupInfoController *)createGroupInfoController:(NSString *)groupID;

/**
 *  创建群成员选择器
 */
- (TUISelectGroupMemberViewController *)createSelectGroupMemberViewController:(NSString *)groupID name:(NSString *)name optionalStyle:(TUISelectMemberOptionalStyle)optionalStyle;


/**
 * 创建讨论组、群聊、聊天室、社区控制器
 * @param groupType 创建的具体类型。
 * @note GroupType_Work：讨论组，GroupType_Public：群聊，GroupType_Meeting：聊天室，GroupType_Community：社区
 * @param createOption 创建后加群时的选项。参考 V2TIMGroupAddOpt 定义
 * @param contacts 群成员的信息数组。数组内每一个元素分别包含了对应成员的头像、ID 等信息。具体信息可参照 TUICommonContactSelectCellData 定义
 */
- (void)createGroup:(NSString *)groupType
       createOption:(V2TIMGroupAddOpt)createOption
           contacts:(NSArray<TUICommonContactSelectCellData *> *)contacts
         completion:(void (^)(BOOL success, NSString *groupID, NSString *groupName))completion;
@end

NS_ASSUME_NONNULL_END
