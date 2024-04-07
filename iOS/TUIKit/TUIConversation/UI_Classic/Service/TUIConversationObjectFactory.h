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
