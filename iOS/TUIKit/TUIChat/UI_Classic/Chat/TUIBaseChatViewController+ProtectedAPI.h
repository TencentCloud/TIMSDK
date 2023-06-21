//
//  TUIBaseChatViewController+ProtectedAPI.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/6/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import "TUIBaseChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIBaseChatViewController () <TUIInputControllerDelegate, TUINotificationProtocol>
- (NSString *)forwardTitleWithMyName:(NSString *)nameStr;
@end

NS_ASSUME_NONNULL_END
