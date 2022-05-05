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
//
// > 创建好友资料 VC：
// serviceName: TUICore_TUIContactService
// method: TUICore_TUIContactService_GetFriendProfileControllerMethod
//
// > 创建用户资料 VC：
// serviceName: TUICore_TUIContactService
// method: TUICore_TUIContactService_GetUserProfileControllerMethod
//
// > 根据 userID 获取好友或用户资料 VC：
// serviceName: TUICore_TUIContactService
// method: TUICore_TUIContactService_GetUserOrFriendProfileVCMethod


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
- (TUIContactSelectController *)createContactSelectController:(NSArray *)sourceIds
                                                   disableIds:(NSArray *)disableIds;

/**
 *  获取好友资料 VC
 */
- (TUIFriendProfileController *)createFriendProfileController:(V2TIMFriendInfo *)friendInfo;

/**
 *  获取用户资料 VC
 */
- (TUIUserProfileController *)createUserProfileController:(V2TIMUserFullInfo *)user
                                               actionType:(ProfileControllerAction)actionType;

/**
 *  根据 userID，返回好友资料 VC 或用户资料 VC
 */
- (void)createUserOrFriendProfileVCWithUserID:(NSString *)userID
                                    succBlock:(void(^)(UIViewController *vc))succ
                                    failBlock:(nullable V2TIMFail)fail;
@end

NS_ASSUME_NONNULL_END
