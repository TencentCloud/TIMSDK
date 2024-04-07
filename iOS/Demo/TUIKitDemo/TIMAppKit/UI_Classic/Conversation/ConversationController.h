//
//  ConversationController.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018 Tencent. All rights reserved.
//
/**
 *  Tencent Cloud Chat Demo Conversation List View
 *  - This file implements the session list, the ViewController corresponding to the "message" tabItem
 *  - This class depends on Tencent Cloud TUIKit and IMSDK
 */
#import <UIKit/UIKit.h>

@interface ConversationController : UIViewController
@property(nonatomic, copy) void (^viewWillAppear)(BOOL isAppear);

- (void)pushToChatViewController:(NSString *)groupID userID:(NSString *)userID;

@end
