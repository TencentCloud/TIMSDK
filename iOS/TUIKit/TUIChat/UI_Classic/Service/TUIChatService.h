//
//  TUIChatManager.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/12.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>

@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN
/**
 * TUIChatService currently provides two services:
 * 1. Creating chat class
 * 2. Getting display text information through V2TIMMessage object
 *
 * You can call the service through the [TUICore callService:..] method. The different service parameters are as follows:
 *
 *  > Getting display text information through V2TIMMessage object
 *    serviceName: TUICore_TUIChatService
 *    method ：TUICore_TUIChatService_GetDisplayStringMethod
 *    param: @{TUICore_TUIChatService_GetDisplayStringMethod_MsgKey:V2TIMMessage};
 *
 *  > Send Message
 *  serviceName: TUICore_TUIChatService
 *  method: TUICore_TUIChatService_SendMessageMethod
 *  param: @{TUICore_TUIChatService_SendMessageMethod_MsgKey:V2TIMMessage};
 */

@interface TUIChatService : NSObject <TUIServiceProtocol>

+ (TUIChatService *)shareInstance;

@end
NS_ASSUME_NONNULL_END
