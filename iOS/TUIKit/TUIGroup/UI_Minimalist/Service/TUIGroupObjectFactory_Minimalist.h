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
 * TUIGroupObjectFactory_Minimalist 目前提供的对象创建：
 * 创建群成员选择器
 * 创建群资料界面
 *
 * 您可以通过 [TUICore createObject:..] 方法唤起服务，不同的服务传参如下：
 * > 创建群资料界面：
 * serviceName: TUICore_TUIGroupObjectFactory_Minimalist
 * method: TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Minimalist
 * param: @{
 *         TUICore_TUIGroupObjectFactory_GetGroupInfoVC_GroupID; @"groupID"
 *        };
 * > 创建群成员选择器：
 * serviceName: TUICore_TUIGroupObjectFactory_Minimalist
 * method: TUICore_TUIGroupObjectFactory_GetSelectGroupMemberViewControllerMethod
 * param: @{
 *         TUICore_TUIGroupObjectFactory_GetSelectGroupMemberViewControllerMethod_GroupIDKey : @"groupID",
 *         TUICore_TUIGroupObjectFactory_GetSelectGroupMemberViewControllerMethod_NameKey : @"name",
 *         TUICore_TUIGroupObjectFactory_GetSelectGroupMemberViewControllerMethod_OptionalStyleKey : style
 *        };
 *
 *
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
