
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 * 本文件声明了实现输入区的相关组件。
 * 输入区即包括表情视图输入区（TUIFaceView+TUIMoreView）、“更多”功能区（TUIMoreView）和文本输入区（TUIInputBar）。
 * 本文件包含TUIInputControllerDelegate 协议和 TInputController 类。
 * 在输入条（TUIInputBar）中，提供了表情、语音、更多视图的按钮响应委托。
 * 而在本类中，将 InputBar 与上述三个视图实际结合，实现了各个视图的显示与切换的逻辑。
 *
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

@class TUIInputController_Minimalist;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIInputControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIInputControllerDelegate_Minimalist <NSObject>

/**
 * 当前 InputController 高度改变时的回调。
 * 您可以通过该回调实现：根据改变的高度调整控制器内各个组件的 UI 布局。
 *
 * Callback when the current InputController height changes.
 * You can use this callback to adjust the UI layout of each component in the controller according to the changed height.
 */
- (void)inputController:(TUIInputController_Minimalist *)inputController didChangeHeight:(CGFloat)height;

/**
 *  当前 InputController 发送消息时的回调。
 *  Callback when the current InputController sends a message.
 */
- (void)inputController:(TUIInputController_Minimalist *)inputController didSendMessage:(V2TIMMessage *)msg;

/**
 * 点击了 InputController 底部的更多按钮
 * Callback when the more button in the bottom of input controller was clicked
 */
- (void)inputControllerDidSelectMoreButton:(TUIInputController_Minimalist *)inputController;

/**
 * 点击了 InputController 底部的拍照按钮
 * Callback when the take-photo button in the bottom of input controller was clicked
 */
- (void)inputControllerDidSelectCamera:(TUIInputController_Minimalist *)inputController;

/**
 *  有 @ 字符输入
 *  Callback when @ character is entered
 */
- (void)inputControllerDidInputAt:(TUIInputController_Minimalist *)inputController;

/**
 *  有 @xxx 字符删除
 *  Callback when there are @xxx characters removed
 */
- (void)inputController:(TUIInputController_Minimalist *)inputController didDeleteAt:(NSString *)atText;

- (void)inputControllerBeginTyping:(TUIInputController_Minimalist *)inputController;
- (void)inputControllerEndTyping:(TUIInputController_Minimalist *)inputController;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIInputControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIInputController_Minimalist : UIViewController

/**
 * 输入框上方的预览视图，用于消息回复场景
 * A preview view above the input box for message reply scenarios
 */
@property(nonatomic, strong) TUIReplyPreviewBar_Minimalist *replyPreviewBar;

/**
 * 输入框下方的预览视图，拥有消息引用场景
 * The preview view below the input box, with the message reference scene
 *
 */
@property(nonatomic, strong) TUIReferencePreviewBar_Minimalist *referencePreviewBar;

/**
 * 当前正在回复的消息
 * Message currently being replied to
 */
@property(nonatomic, strong) TUIReplyPreviewData_Minimalist *replyData;

@property(nonatomic, strong) TUIReferencePreviewData_Minimalist *referenceData;

/**
 *  输入条
 *  输入条中包含文本输入框、语音按钮、“更多”按钮、表情按钮等一系列交互组件，并提供了这些组件的对应回调委托。
 *
 *  Input bar
 *  The input bar contains a series of interactive components such as text input box, voice button, "more" button, emoticon button, etc., and provides
 * corresponding callbacks for these components.
 */
@property(nonatomic, strong) TUIInputBar_Minimalist *inputBar;

/**
 *  表情视图
 *  表情视图一般在点击“笑脸”按钮后浮现。负责显示各个表情分组，与分组内表情的具体信息。
 *
 *  Emoticon view
 *  The emoticon view generally appears after clicking the "Smiley" button. Responsible for displaying each expression group and the expressions within the
 * group.
 *
 */
@property(nonatomic, strong) TUIFaceView *faceView;

/**
 *  菜单视图
 *  菜单视图位于表情视图下方，负责提供表情分组单元以及发送按钮。
 *
 *  Menu view
 *  The menu view is located below the emoticon view and is responsible for providing the emoticon grouping unit and the send button.
 */
@property(nonatomic, strong) TUIMenuView_Minimalist *menuView;

@property(nonatomic, weak) id<TUIInputControllerDelegate_Minimalist> delegate;

/**
 *  重置当前输入控制器。
 *  如果当前有表情视图或者“更多“视图正在显示，则收起相应视图，并将当前状态设置为 Input_Status_Input。
 *  即无论当前 InputController 处于何种状态，都将其重置为初始化后的状态。
 *
 *  Reset the current input controller.
 *  If there is currently an emoji view or a "more" view being displayed, collapse the corresponding view and set the current status to Input_Status_Input.
 *  That is, no matter what state the current InputController is in, reset it to its initialized state.
 */
- (void)reset;

/**
 * 显示/隐藏消息回复输入框的预览条
 * Show/hide preview bar of message reply input box
 */
- (void)showReplyPreview:(TUIReplyPreviewData_Minimalist *)data;
- (void)showReferencePreview:(TUIReferencePreviewData_Minimalist *)data;
- (void)exitReplyAndReference:(void (^__nullable)(void))finishedCallback;

/**
 * 当前的输入框状态
 * Current input box state
 */
@property(nonatomic, assign, readonly) InputStatus status;
@end
