//
//  VideoCallManager.h
//  TUIKitDemo
//
//  Created by xcoderliu on 9/30/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIChatController.h"
#import "VideoCallCell.h"

@class ChatViewController;

NS_ASSUME_NONNULL_BEGIN

@interface VideoCallManager : NSObject
+(instancetype) shareInstance;
@property (nonatomic, strong, nullable)UIButton *hungUP;
@property (nonatomic, strong, nullable) UIView* remoteVideoView;
@property (nonatomic, strong, nullable) UIView* localVideoView;
@property (nonatomic, strong, nullable) ChatViewController* currentChatVC;
/// 当前roomID
@property (nonatomic,assign) UInt32 currentRoomID;

//当前用户Identifier
- (NSString*) currentUserIdentifier;

/// 连接参数
@property (nonatomic, strong) TUIConversationCellData *conversationData;

//从聊天界面发起请求
- (void)videoCall:(TUIChatController *)chatController;

//新消息处理
- (void)onNewVideoCallMessage:(TIMMessage *)msg;

/// 离开会议室
/// @param passive 被动离开
- (void)quitRoom:(BOOL)passive;
@end

NS_ASSUME_NONNULL_END
