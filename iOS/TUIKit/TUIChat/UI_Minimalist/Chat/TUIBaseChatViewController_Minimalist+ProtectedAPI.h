//
//  TUIBaseChatViewController+ProtectedAPI.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/6/17.
//

#import "TUIBaseChatViewController_Minimalist.h"
#import "TUICore.h"
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIBaseChatViewController_Minimalist ()<TUIInputControllerDelegate_Minimalist, TUINotificationProtocol>
- (NSString *)forwardTitleWithMyName:(NSString *)nameStr;
@end

NS_ASSUME_NONNULL_END
