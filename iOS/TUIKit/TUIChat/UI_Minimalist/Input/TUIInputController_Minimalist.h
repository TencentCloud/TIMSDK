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
#import "TUIInputBar_Minimalist.h"
#import "TUIMenuView_Minimalist.h"
#import "TUIReplyPreviewBar_Minimalist.h"
#import "TUIFaceSegementScrollView.h"

@class TUIInputController_Minimalist;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIInputControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIInputControllerDelegate_Minimalist <NSObject>

/**
 * Callback when the current InputController height changes.
 * You can use this callback to adjust the UI layout of each component in the controller according to the changed height.
 */
- (void)inputController:(TUIInputController_Minimalist *)inputController didChangeHeight:(CGFloat)height;

/**
 *  Callback when the current InputController sends a message.
 */
- (void)inputController:(TUIInputController_Minimalist *)inputController didSendMessage:(V2TIMMessage *)msg;

/**
 * Callback when the more button in the bottom of input controller was clicked
 */
- (void)inputControllerDidSelectMoreButton:(TUIInputController_Minimalist *)inputController;

/**
 * Callback when the take-photo button in the bottom of input controller was clicked
 */
- (void)inputControllerDidSelectCamera:(TUIInputController_Minimalist *)inputController;

/**
 *  Callback when @ character is entered
 */
- (void)inputControllerDidInputAt:(TUIInputController_Minimalist *)inputController;

/**
 *  Callback when there are @xxx characters removed
 */
- (void)inputController:(TUIInputController_Minimalist *)inputController didDeleteAt:(NSString *)atText;

- (void)inputControllerBeginTyping:(TUIInputController_Minimalist *)inputController;
- (void)inputControllerEndTyping:(TUIInputController_Minimalist *)inputController;

/**
 * Callback when AI interrupt button is clicked
 */
- (void)inputControllerDidTouchAIInterrupt:(TUIInputController_Minimalist *)inputController;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIInputControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIInputController_Minimalist : UIViewController

/**
 * A preview view above the input box for message reply scenarios
 */
@property(nonatomic, strong) TUIReplyPreviewBar_Minimalist *replyPreviewBar;

/**
 * The preview view below the input box, with the message reference scene
 *
 */
@property(nonatomic, strong) TUIReferencePreviewBar_Minimalist *referencePreviewBar;

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
@property(nonatomic, strong) TUIInputBar_Minimalist *inputBar;

/**
 *  Emoticon view
 *  The emoticon view generally appears after clicking the "Smiley" button. Responsible for displaying each expression group and the expressions within the
 * group.
 *
 */

@property(nonatomic, strong) TUIFaceSegementScrollView *faceSegementScrollView;

/**
 *  Menu view
 *  The menu view is located below the emoticon view and is responsible for providing the emoticon grouping unit and the send button.
 */
@property(nonatomic, strong) TUIMenuView_Minimalist *menuView;

@property(nonatomic, weak) id<TUIInputControllerDelegate_Minimalist> delegate;

/**
 * AI chat style related properties
 */

/**
 * Whether AI chat style is enabled
 */
@property(nonatomic, assign) BOOL enableAIStyle;

/**
 * AI chat style related methods
 */

/**
 * Enable/disable AI chat style
 */
- (void)enableAIStyle:(BOOL)enable;

/**
 * Set AI state (default/active)
 */
- (void)setAIState:(TUIInputBarAIState_Minimalist)state;

/**
 * Set AI typing state
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
