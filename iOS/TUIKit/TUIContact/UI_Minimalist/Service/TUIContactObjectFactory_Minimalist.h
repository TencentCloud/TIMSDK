//
//  TUIContactObjectFactory_Minimalist.h
//  TUIContact
//
//  Created by wyl on 2023/3/29.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 您可以通过 [TUICore createObject:..] 方法唤起服务，不同的服务传参如下：
 * > 创建联系人列表：
 * factoryName: TUICore_TUIContactObjectFactory_Minimalist
 * key: TUICore_TUIContactObjectFactory_GetContactControllerMethod
 *
 * > 创建联系人选择器：
 * factoryName: TUICore_TUIContactObjectFactory_Minimalist
 * key ：TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod
 *
 * > 创建好友资料 VC：
 * factoryName: TUICore_TUIContactObjectFactory_Minimalist
 * key: TUICore_TUIContactObjectFactory_GetFriendProfileControllerMethod
 *
 * > 创建用户资料 VC：
 * factoryName: TUICore_TUIContactObjectFactory_Minimalist
 * key: TUICore_TUIContactObjectFactory_UserProfileController_Minimalist
 *
 * > 根据 userID 获取好友或用户资料 VC：
 * factoryName: TUICore_TUIContactObjectFactory_Minimalist
 * key: TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod
 *
 *
 * TUIContactService currently provides the following services:
 * 1. Create a contact list
 * 2. Create a contact selector
 * 3. Create friend profile view controller
 * 4. Create user profile view controller
 * 5. Get friend or user profile view controller based on userID
 *
 *  You can call the service through the [TUICore createObject:..] method. Different service parameters are as follows:
 *
 *  > Create a contact list:
 *  factoryName: TUICore_TUIContactObjectFactory_Minimalist
 *  key: TUICore_TUIContactObjectFactory_GetContactControllerMethod
 *
 *  > Create Contact Picker:
 *  factoryName: TUICore_TUIContactObjectFactory_Minimalist
 *  key: TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod
 *
 *  > Create friend profile view controller:
 *  factoryName: TUICore_TUIContactObjectFactory_Minimalist
 *  key: TUICore_TUIContactObjectFactory_GetFriendProfileControllerMethod
 *
 *  > Create user profile view controller:
 *  factoryName: TUICore_TUIContactObjectFactory_Minimalist
 *  key: TUICore_TUIContactObjectFactory_UserProfileController_Minimalist
 *
 *  > Get friend or user profile view controller based on userID:
 *  factoryName: TUICore_TUIContactObjectFactory_Minimalist
 *  key: TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod
 *
 */
@interface TUIContactObjectFactory_Minimalist : NSObject
+ (TUIContactObjectFactory_Minimalist *)shareInstance;
@end

NS_ASSUME_NONNULL_END
