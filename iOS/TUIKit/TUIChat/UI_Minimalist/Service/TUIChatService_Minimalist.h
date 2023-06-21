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

@interface TUIChatService_Minimalist : NSObject <TUIServiceProtocol>

+ (TUIChatService_Minimalist *)shareInstance;

@end

NS_ASSUME_NONNULL_END
