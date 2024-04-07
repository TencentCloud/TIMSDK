//
//  TUIGroupObjectFactory_Minimalist.h
//  TUIGroup
//
//  Created by wyl on 2023/3/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
NS_ASSUME_NONNULL_BEGIN

/**
 * TUIGroupService currently provides a service:
 * Create group member selector
 *
 * You can call the service through the [TUICore createObject:..] method. The different service parameters are as follows:
 * > Create group information interface:
 * serviceName: TUICore_TUIGroupObjectFactory_Minimalist
 * method: TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Minimalist
 * param: @{
 *          TUICore_TUIGroupObjectFactory_GetGroupInfoVC_GroupID; @"groupID"
 *       };
 * > Create group member selector:
 * serviceName: TUICore_TUIGroupObjectFactory_Minimalist
 * method: TUICore_TUIGroupObjectFactory_GetSelectGroupMemberViewControllerMethod
 * param: @{
 *          TUICore_TUIGroupObjectFactory_GetSelectGroupMemberViewControllerMethod_GroupIDKey : @"groupID",
 *          TUICore_TUIGroupObjectFactory_GetSelectGroupMemberViewControllerMethod_NameKey : @"name",
 *          TUICore_TUIGroupObjectFactory_GetSelectGroupMemberViewControllerMethod_OptionalStyleKey : style
 *       };
 */
@interface TUIGroupObjectFactory_Minimalist : NSObject
+ (TUIGroupObjectFactory_Minimalist *)shareInstance;
@end

NS_ASSUME_NONNULL_END
