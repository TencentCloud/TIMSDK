//
//  TUIContactService.h
//  lottie-ios
//
//  Created by kayev on 2021/8/18.
//

#import <Foundation/Foundation.h>
#import "TUIContactController.h"
#import "TUIContactSelectController.h"
#import "TUIFriendProfileController.h"
#import "TUIUserProfileController.h"
#import "TUICore.h"
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * TUIContactService 目前提供以下服务：
 * 1、创建联系人列表
 * 2、创建联系人选择器
 * 3、创建好友资料 VC
 * 4、创建用户资料 VC
 * 5、根据 userID 获取好友或用户资料 VC
 *
 * TUIChatService 服务唤起有两种方式：
 * 1、强依赖唤起：
 * 如果您强依赖 TUIContact 组件，可以直接通过 [[TUIContactService shareInstance] createContactController] 方法唤起服务。
 *
 * 2、弱依赖唤起：
 * 如果您弱依赖 TUIContact 组件，可以通过 [TUICore callService:..] 方法唤起服务，不同的服务传参如下：
 * > 创建联系人列表：
 * serviceName: TUICore_TUIContactService
 * method: TUICore_TUIContactService_GetContactControllerMethod
 *
 * > 创建联系人选择器：
 * serviceName: TUICore_TUIContactService
 * method ：TUICore_TUIContactService_GetContactSelectControllerMethod
 *
 * > 创建好友资料 VC：
 * serviceName: TUICore_TUIContactService
 * method: TUICore_TUIContactService_GetFriendProfileControllerMethod
 *
 * > 创建用户资料 VC：
 * serviceName: TUICore_TUIContactService
 * method: TUICore_TUIContactService_GetUserProfileControllerMethod
 *
 * > 根据 userID 获取好友或用户资料 VC：
 * serviceName: TUICore_TUIContactService
 * method: TUICore_TUIContactService_GetUserOrFriendProfileVCMethod
 *
 *
 * TUIContactService currently provides the following services:
 * 1. Create a contact list
 * 2. Create a contact selector
 * 3. Create friend profile view controller
 * 4. Create user profile view controller
 * 5. Get friend or user profile view controller based on userID
 *
 * There are two ways to invoke the TUIChatService service:
 * 1.  Strong dependence on TUIChat module to invoke TUIChatService:
 *   If you strongly depend on the TUIContact component, you can invoke the service directly through the [[TUIContactService shareInstance] createContactController] method.
 *
 * 2. Weak dependence on TUIChat module to invoke TUIChatService
 *   If you are weakly dependent on the TUIContact component, you can call the service through the [TUICore callService:..] method. Different service parameters are as follows:
 *
 *  > Create a contact list:
 *  serviceName: TUICore_TUIContactService
 *  method: TUICore_TUIContactService_GetContactControllerMethod
 *
 *  > Create Contact Picker:
 *  serviceName: TUICore_TUIContactService
 *  method: TUICore_TUIContactService_GetContactSelectControllerMethod
 *
 *  > Create friend profile view controller:
 *  serviceName: TUICore_TUIContactService
 *  method: TUICore_TUIContactService_GetFriendProfileControllerMethod
 *
 *  > Create user profile view controller:
 *  serviceName: TUICore_TUIContactService
 *  method: TUICore_TUIContactService_GetUserProfileControllerMethod
 *
 *  > Get friend or user profile view controller based on userID:
 *  serviceName: TUICore_TUIContactService
 *  method: TUICore_TUIContactService_GetUserOrFriendProfileVCMethod
 *
 */

@interface TUIContactService : NSObject <TUIServiceProtocol>

+ (TUIContactService *)shareInstance;

/**
 *  获取联系人列表
 *  Geting contact list view controller
 */
- (TUIContactController *)createContactController;

/**
 *  获取联系人选择列表
 *  Getting contact picker view controller
 */
- (TUIContactSelectController *)createContactSelectController:(NSArray *)sourceIds
                                                   disableIds:(NSArray *)disableIds;

/**
 *  获取好友资料 VC
 *  Geting friend profile view controller
 */
- (TUIFriendProfileController *)createFriendProfileController:(V2TIMFriendInfo *)friendInfo;

/**
 *  获取用户资料 VC
 *  Getting user profile view controller
 */
- (TUIUserProfileController *)createUserProfileController:(V2TIMUserFullInfo *)user
                                               actionType:(ProfileControllerAction)actionType;

/**
 *  根据 userID，返回好友资料 VC 或用户资料 VC
 *  Get friend or user profile view controller based on userID
 */
- (void)createUserOrFriendProfileVCWithUserID:(NSString *)userID
                                    succBlock:(void(^)(UIViewController *vc))succ
                                    failBlock:(nullable V2TIMFail)fail;
@end

NS_ASSUME_NONNULL_END
