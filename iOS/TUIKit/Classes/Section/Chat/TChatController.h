//
//  TChatController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TInputController.h"
#import "TMessageController.h"
#import "TConversationCell.h"

@class TChatController;
@protocol TChatControllerDelegate <NSObject>
- (void)chatControllerDidClickRightBarButton:(TChatController *)controller;
- (void)chatController:(TChatController *)chatController didSelectMoreAtIndex:(NSInteger)index;
- (void)chatController:(TChatController *)chatController didSelectMessages:(NSMutableArray *)msgs atIndex:(NSInteger)index;

@end

@interface TChatController : UIViewController
@property (nonatomic, strong) TConversationCellData *conversation;
@property (nonatomic, strong) TMessageController *messageController;
@property (nonatomic, strong) TInputController *inputController;
@property (nonatomic, weak) id<TChatControllerDelegate> delegate;
- (void)sendImageMessage:(UIImage *)image;
- (void)sendVideoMessage:(NSURL *)url;
- (void)sendFileMessage:(NSURL *)url;
@end
