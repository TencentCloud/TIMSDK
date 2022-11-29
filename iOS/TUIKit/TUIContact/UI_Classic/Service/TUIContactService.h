//
//  TUIContactService.h
//  lottie-ios
//
//  Created by kayev on 2021/8/18.
//

#import <Foundation/Foundation.h>
#import "TUICore.h"
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 您可以通过 [TUICore callService:..] 方法唤起服务，不同的服务传参如下：
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
 *  You can call the service through the [TUICore callService:..] method. Different service parameters are as follows:
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

@end

NS_ASSUME_NONNULL_END
