//
//  ConversationController.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 对话列表视图
 *  - 本文件实现了会话列表，即 “消息” tabItem 对应的 ViewController
 *  - 本类依赖于腾讯云 TUIKit 和 IMSDK
 *
 *
 *  Tencent Cloud Chat Demo Conversation List View
 *  - This file implements the session list, the ViewController corresponding to the "message" tabItem
 *  - This class depends on Tencent Cloud TUIKit and IMSDK
 */
#import <UIKit/UIKit.h>

@interface ConversationController : UIViewController
@property(nonatomic, copy) void (^viewWillAppear)(BOOL isAppear);

- (void)pushToChatViewController:(NSString *)groupID userID:(NSString *)userID;

@end
