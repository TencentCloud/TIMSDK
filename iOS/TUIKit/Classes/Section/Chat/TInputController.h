//
//  TInputController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTextView.h"
#import "TFaceView.h"
#import "TMenuView.h"
#import "TMoreView.h"
#import "TMessageCell.h"

@class TInputController;
@protocol TInputControllerDelegate <NSObject>
- (void)inputController:(TInputController *)inputController didChangeHeight:(CGFloat)height;
- (void)inputController:(TInputController *)inputController didSendMessage:(TMessageCellData *)msg;
- (void)inputController:(TInputController *)inputController didSelectMoreAtIndex:(NSInteger)index;
@end

@interface TInputController : UIViewController
@property (nonatomic, strong) TTextView *textView;
@property (nonatomic, strong) TFaceView *faceView;
@property (nonatomic, strong) TMenuView *menuView;
@property (nonatomic, strong) TMoreView *moreView;
@property (nonatomic, weak) id<TInputControllerDelegate> delegate;
- (void)reset;
@end
