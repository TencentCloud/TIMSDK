//
//  TUIConversationObjectFactory.h
//  TUIConversation
//
//  Created by wyl on 2023/3/29.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * TUIConversationObjectFactory 目前提供两个对象创建：
 * 1、创建会话列表
 * 2、创建会话选择器
 *
 * 您可以通过 [TUICore createObject:..] 方法唤起服务，不同的服务传参如下：
 * > 创建会话列表：
 * factoryName: TUICore_TUIConversationObjectFactory
 * key: TUICore_TUIConversationObjectFactory_GetConversationControllerMethod
 *
 * > 创建会话选择器：
 * factoryName: TUICore_TUIConversationObjectFactory
 * key ：TUICore_TUIConversationObjectFactory_ConversationSelectVC_Classic
 *
 *
 * TUIConversationService currently provides two services:
 * 1. Create a conversation list
 * 2. Create a conversation selector
 *
 * You can call the service through the [TUICore createObject:..] method. The different service parameters are as follows:
 * > Create a conversation list:
 * factoryName: TUICore_TUIConversationObjectFactory
 * key: TUICore_TUIConversationObjectFactory_GetConversationControllerMethod
 *
 * > Create conversation selector:
 * factoryName: TUICore_TUIConversationObjectFactory
 * key: TUICore_TUIConversationObjectFactory_ConversationSelectVC_Classic
 *
 */
@interface TUIConversationObjectFactory : NSObject
+ (TUIConversationObjectFactory *)shareInstance;

@end

NS_ASSUME_NONNULL_END
