//
//  ChatViewController.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIChatController.h"

@interface ChatViewController : UIViewController
@property (nonatomic, strong) TUIConversationCellData *conversationData;
@end
