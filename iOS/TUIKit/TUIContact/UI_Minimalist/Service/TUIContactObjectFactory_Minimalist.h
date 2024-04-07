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
