
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 * This document declares the relevant components to implement the input area.
 * The input area includes the emoticon view input area (TUIFaceView+TUIMoreView), the "more" functional area (TUIMoreView) and the text input area
 * (TUIInputBar). This file contains the TUIInputControllerDelegate protocol and the TInputController class. In the input bar (TUIInputBar), button response
 * callbacks for expressions, voices, and more views are provided. In this class, the InputBar is actually combined with the above three views to realize the
 * display and switching logic of each view.
 */
#import <TIMCommon/TUIMessageCell.h>
#import <UIKit/UIKit.h>
#import "TUIChatDefine.h"
#import "TUIFaceView.h"
#import "TUIInputBar.h"
#import "TUIMenuView.h"
#import "TUIMoreView.h"
#import "TUIReplyPreviewBar.h"
#import "TUIFaceSegementScrollView.h"

@class TUIInputController;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIInputControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIInputControllerDelegate <NSObject>

/**
 * Callback when the current InputController height changes.
 * You can use this callback to adjust the UI layout of each component in the controller according to the changed height.
 */
- (void)inputController:(TUIInputController *)inputController didChangeHeight:(CGFloat)height;

/**
 *  Callback when the current InputController sends a message.
 */
- (void)inputController:(TUIInputController *)inputController didSendMessage:(V2TIMMessage *)msg;

/**
 *  Callback for clicking a more item
 *  You can use this callback to achieve: according to the clicked cell type, do the next step. For example, select pictures, select files, etc.
 *  At the same time, the implementation of this delegate contains the following code:
 *  <pre>
 *  - (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell {
 *      ……
 *      ……
 *      if(_delegate && [_delegate respondsToSelector:@selector(chatController:onSelectMoreCell:)]){
 *          [_delegate chatController:self onSelectMoreCell:cell];
 *      }
 *  }
 *  </pre>
 *  The above code can help you to customize the "more" unit.
 *  For more information you can refer to the comments in TUIChat\UI\Chat\TUIBaseChatController.h
 */
- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell;

/**
 *  Callback when @ character is entered
 */
- (void)inputControllerDidInputAt:(TUIInputController *)inputController;

/**
 *  Callback when there are @xxx characters removed
 */
- (void)inputController:(TUIInputController *)inputController didDeleteAt:(NSString *)atText;

- (void)inputControllerBeginTyping:(TUIInputController *)inputController;

- (void)inputControllerEndTyping:(TUIInputController *)inputController;

- (void)inputControllerDidClickMore:(TUIInputController *)inputController;

/**
 * Callback when AI interrupt button is clicked
 */
- (void)inputControllerDidTouchAIInterrupt:(TUIInputController *)inputController;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIInputControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIInputController : UIViewController

/**
 * A preview view above the input box for message reply scenarios
 */
@property(nonatomic, strong) TUIReplyPreviewBar *replyPreviewBar;

/**
 * The preview view below the input box, with the message reference scene
 *
 */
@property(nonatomic, strong) TUIReferencePreviewBar *referencePreviewBar;

/**
 * Message currently being replied to
 */
@property(nonatomic, strong) TUIReplyPreviewData *replyData;

@property(nonatomic, strong) TUIReferencePreviewData *referenceData;

/**
 *  Input bar
 *  The input bar contains a series of interactive components such as text input box, voice button, "more" button, emoticon button, etc., and provides
 * corresponding callbacks for these components.
 */
@property(nonatomic, strong) TUIInputBar *inputBar;

/**
 *  Emoticon view
 *  The emoticon view generally appears after clicking the "Smiley" button. Responsible for displaying each expression group and the expressions within the
 * group.
 *
 */
//@property(nonatomic, strong) TUIFaceView *faceView;

@property(nonatomic, strong) TUIFaceSegementScrollView *faceSegementScrollView;
/**
 *  Menu view
 *  The menu view is located below the emoticon view and is responsible for providing the emoticon grouping unit and the send button.
 */
@property(nonatomic, strong) TUIMenuView *menuView;

/**
 *  More view
 *  More views generally appear after clicking the "More" button ("+" button), and are responsible for displaying each more unit, such as shooting, video, file,
 * album, etc.
 */
@property(nonatomic, strong) TUIMoreView *moreView;

@property(nonatomic, weak) id<TUIInputControllerDelegate> delegate;

/**
 * AI聊天样式相关属性
 */

/**
 * 是否启用AI聊天样式
 */
@property(nonatomic, assign) BOOL enableAIStyle;

/**
 * AI聊天样式相关方法
 */

/**
 * 启用/禁用AI聊天样式
 */
- (void)enableAIStyle:(BOOL)enable;

/**
 * 设置AI状态（默认/激活）
 */
- (void)setAIState:(TUIInputBarAIState)state;

/**
 * 设置AI输入状态
 */
- (void)setAITyping:(BOOL)typing;

/**
 *  Reset the current input controller.
 *  If there is currently an emoji view or a "more" view being displayed, collapse the corresponding view and set the current status to Input_Status_Input.
 *  That is, no matter what state the current InputController is in, reset it to its initialized state.
 */
- (void)reset;

/**
 * Show/hide preview bar of message reply input box
 */
- (void)showReplyPreview:(TUIReplyPreviewData *)data;
- (void)showReferencePreview:(TUIReferencePreviewData *)data;
- (void)exitReplyAndReference:(void (^__nullable)(void))finishedCallback;

/**
 * Current input box state
 */
@property(nonatomic, assign, readonly) InputStatus status;
@end
