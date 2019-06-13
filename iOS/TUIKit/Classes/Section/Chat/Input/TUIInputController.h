//
//  TInputController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIInputBar.h"
#import "TUIFaceView.h"
#import "TUIMenuView.h"
#import "TUIMoreView.h"
#import "TUIMessageCell.h"

@class TUIInputController;
@protocol TInputControllerDelegate <NSObject>
- (void)inputController:(TUIInputController *)inputController didChangeHeight:(CGFloat)height;
- (void)inputController:(TUIInputController *)inputController didSendMessage:(TUIMessageCellData *)msg;
- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell;
@end

@interface TUIInputController : UIViewController
@property (nonatomic, strong) TUIInputBar *inputBar;
@property (nonatomic, strong) TUIFaceView *faceView;
@property (nonatomic, strong) TUIMenuView *menuView;
@property (nonatomic, strong) TUIMoreView *moreView;
@property (nonatomic, weak) id<TInputControllerDelegate> delegate;
- (void)reset;
@end
