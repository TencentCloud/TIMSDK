//
//  TUIGroupChatViewController.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/6/17.
//

#import "TUIBaseChatViewController.h"
#import "TUIGroupPendencyCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupChatViewController : TUIBaseChatViewController

@property (nonatomic, copy) void (^openUserProfileVCBlock)(TUIGroupPendencyCell *cell);

@end

NS_ASSUME_NONNULL_END
