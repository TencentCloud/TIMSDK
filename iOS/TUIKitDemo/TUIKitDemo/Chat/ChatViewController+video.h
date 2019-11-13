//
//  ChatViewController+video.h
//  TUIKitDemo
//
//  Created by xcoderliu on 9/30/19.
//  Copyright © 2019 Tencent. All rights reserved.
//


#import "VideoCallCell.h"
#import "ChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController (video)
- (BOOL)videoCallTimeOut: (TIMMessage*)message;
- (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewVideoCallMessage:(TIMMessage *)msg;
@end

NS_ASSUME_NONNULL_END
