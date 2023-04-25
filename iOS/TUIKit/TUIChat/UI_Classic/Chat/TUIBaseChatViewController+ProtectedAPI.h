//
//  TUIBaseChatViewController+ProtectedAPI.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/6/17.
//

#import "TUIBaseChatViewController.h"
#import <TUICore/TUICore.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIBaseChatViewController ()<TUIInputControllerDelegate, TUINotificationProtocol>
- (NSString *)forwardTitleWithMyName:(NSString *)nameStr;
@end

NS_ASSUME_NONNULL_END
