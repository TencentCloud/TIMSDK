 /**
  *  本文件声明了 TTextViewDelegate 协议和 TUIInputBar 类。
  *  TUI 输入条，用于检测、获取用户输入的 UI 组件。
  *  TUIInputBar，即位于聊天消息最下方的 UI 组件。包括文本输入框、表情按钮、语音按钮和“+”按钮（“更多”按钮）。
  *  TTextViewDelegate 提供了输入条各种情况下的回调委托，包括点击输入条的表情、“更多”视图、语音按钮的回调。以及发送消息、发送语音、更改输入高度的回调。
  *
  *  This file declares the TTextViewDelegate protocol and the TUIInputBar class.
  *  TUI input bar, a UI component used to detect and obtain user input.
  *  TUIInputBar, the UI component at the bottom of the chat message. Includes text input box, emoji button, voice button, and "+" button ("More" button)
  *  TTextViewDelegate provides callbacks for various situations of the input bar, including the callback for the emoticon of clicking the input bar, the "more" view, and the voice button. And callbacks to send message, send voice, change input height.
  */

#import <UIKit/UIKit.h>
#import "TUIResponderTextView.h"
#import "TUICommonModel.h"
#import "TUIThemeManager.h"
#define kTUIInputNoramlFont [UIFont systemFontOfSize:16.0]
#define kTUIInputNormalTextColor TUIChatDynamicColor(@"chat_input_text_color", @"#000000")

@class TUIInputBar;

/////////////////////////////////////////////////////////////////////////////////
//
//                            TTextViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TTextViewDelegate <NSObject>

/**
 *  点击表情按钮，即“笑脸”后的回调。
 *  您可以通过该回调实现：点击表情按钮后，显示出对应的表情视图。
 *
 *  Callback after clicking the emoji button - "smiley" button.
 *  You can use this callback to achieve: After clicking the emoticon button, the corresponding emoticon view is displayed.
 */
- (void)inputBarDidTouchFace:(TUIInputBar *)textView;

/**
 *  点击更多按钮，即“+”后的回调。
 *  您可以通过该回调实现：相应用户的点击操作，显示出对应的更多视图。
 *
 *  Callback after more button - "+" is clicked.
 *  You can use this callback to achieve: corresponding user's click operation to display more corresponding views.
 */
- (void)inputBarDidTouchMore:(TUIInputBar *)textView;

/**
 *  点击语音按钮，即“声波”图标后的回调。
 *  您可以通过该回调实现：显示出相应的操作提示视图，并开始语音的录制
 *
 *  Callback after clicking the voice button - "Sound Wave" icon .
 *  You can use this callback to display the corresponding operation prompt view and start voice recording
 */
- (void)inputBarDidTouchVoice:(TUIInputBar *)textView;

/**
 *  输入条高度更改时的回调
 *  当您点击语音按钮、表情按钮、“+”按钮或者呼出/收回键盘时，InputBar 高度会发生改变时，触发该回调
 *  您可以通过该回调实现：通过该回调函数进行 InputBar 高度改变时的 UI 布局调整。
 *  在 TUIKit 默认的实现中，本回调函数在处理了表情视图与更多视图的浮现后，进一步调用了 TUIInputController 中的 didChangeHeight 委托进行 UI 布局的高度调整。
 *
 *  Callback when input bar height changes
 *  This callback is fired when the InputBar height changes when you click the voice button, emoji button, "+" button, or call out/retract the keyboard
 *  You can use this callback to achieve: UI layout adjustment when InputBar height changes through this callback function.
 *  In the default implementation of TUIKit, this callback function further calls the didChangeHeight delegate in TUIInputController to adjust the height of the UI layout after processing the appearance of the expression view and more views.
 */
- (void)inputBar:(TUIInputBar *)textView didChangeInputHeight:(CGFloat)offset;

/**
 *  发送文本消息时的回调。
 *  当您通过 InputBar 发送文本消息（通过键盘点击发送按钮），触发该回调。
 *  您可以通过该回调实现：获取 InputBar 的内容，并将消息进行发送。
 *  在 TUIKit 默认的实现中，本回调函数在处理了表情视图与更多视图的浮现后，进一步调用了 TUIInputController 中的 didSendMessage 委托进行消息发送的进一步逻辑处理。
 *
 *  Callback when sending a text message.
 *  This callback is fired when you send a text message through the InputBar (click the send button from the keyboard).
 *  You can use this callback to get the content of the InputBar and send the message.
 *  In the default implementation of TUIKit, this callback further calls the didSendMessage delegate in TUIInputController for further logical processing of message sending after processing the appearance of the expression view and more views.
 */
- (void)inputBar:(TUIInputBar *)textView didSendText:(NSString *)text;

/**
 *  发送语音时的回调
 *  当您长按语音按钮并松开时，触发该回调。
 *  您可以通过该回调实现：对录制到的语音信息进行处理并发送该语音消息。
 *  在 TUIKit 默认的实现中，本回调函数在处理了表情视图与更多视图的浮现后，进一步调用了 TUIInputController 中的 didSendMessage 委托进行消息发送的进一步逻辑处理。
 *
 *  Callback when sending voice
 *  This callback is triggered when you long press and release the voice button.
 *  You can use this callback to process the recorded voice information and send the voice message.
 *  In the default implementation of TUIKit, this callback function further calls the didSendMessage delegate in TUIInputController for further logical processing of message sending after processing the appearance of the expression view and more views.
 */
- (void)inputBar:(TUIInputBar *)textView didSendVoice:(NSString *)path;

/**
 *  输入含有 @ 字符的文本后的回调
 *  Callback after entering text containing the @ character
 */
- (void)inputBarDidInputAt:(TUIInputBar *)textView;

/**
 *  删除含有 @ 字符后的回调（比如删除 @xxx）
 *  Callback after removing text containing @ characters (e.g. removing @xxx)
 */
- (void)inputBar:(TUIInputBar *)textView didDeleteAt:(NSString *)text;

/**
 *  点击键盘按钮后的回调
 *  点击表情按钮后，对应位置的“笑脸”会变成“键盘”图标，此时为键盘按钮。
 *  您可以通过该回调实现：隐藏当前显示的表情视图或者更多视图，并浮现键盘。
 *
 *  Callback after keyboard button click
 *  After clicking the emoticon button, the "smiley face" icon at the corresponding position will become the "keyboard" icon, which is the keyboard button at this time.
 *  You can use this callback to: hide the currently displayed emoticon view or more views, and open the keyboard.
 */
- (void)inputBarDidTouchKeyboard:(TUIInputBar *)textView;

/**
 * 点击键盘上的删除按钮后的回调
 * Callback after clicking delete button on keyboard
 */
- (void)inputBarDidDeleteBackward:(TUIInputBar *)textView;

- (void)inputTextViewShouldBeginTyping:(UITextView *)textView;

- (void)inputTextViewShouldEndTyping:(UITextView *)textView;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIInputBar
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIInputBar : UIView

/**
 *  分割线
 *  Separtor
 */
@property (nonatomic, strong) UIView *lineView;

/**
 *  语音按钮
 *  点击后切换成语音输入状态
 *
 *  Voice button
 *  Switch to voice input state after clicking
 */
@property (nonatomic, strong) UIButton *micButton;

/**
 *  键盘按钮
 *  点击后切换成键盘输入状态
 *
 *  Keyboard button
 *  Switch to keyboard input state after clicking
 */
@property (nonatomic, strong) UIButton *keyboardButton;

/**
 *  文本输入视图
 *  Input view
 */
@property (nonatomic, strong) TUIResponderTextView *inputTextView;

/**
 *  表情按钮
 *  点击后切换成表情输入状态
 *
 *  Emoticon button
 *  Switch to emoji input state after clicking
 */
@property (nonatomic, strong) UIButton *faceButton;

/**
 *  更多按钮
 *  点击后可以打开更多菜单选项的按钮
 *
 *  More  button
 *  A button that, when clicked, opens up more menu options
 */
@property (nonatomic, strong) UIButton *moreButton;

/**
 *  录音按钮，长按该按钮开始录音
 *  Record button, long press the button to start recording
 */
@property (nonatomic, strong) UIButton *recordButton;


@property (nonatomic, weak) id<TTextViewDelegate> delegate;

/**
 *  添加表情
 *  用于实现在当前文本输入框中输入 emoji
 *
 *  @param emoji 需要输入的表情的字符串表示形式。
 *
 *  Add emoticon text
 *  Used to input emoticon text in the current text input box
 *
 *  @param emoji The string representation of the emoticon to be entered.
 */
- (void)addEmoji:(TUIFaceCellData *)emoji;

- (void)backDelete;

- (void)clearInput;

- (NSString *)getInput;

- (void)updateTextViewFrame;

- (void)changeToKeyboard;

@end
