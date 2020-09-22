 /******************************************************************************
  *
  *  本文件声明了 TTextViewDelegate 协议和 TUIInputBar 类。
  *  TUI 输入条，用于检测、获取用户输入的 UI 组件。
  *  TUIInputBar，即位于聊天消息最下方的 UI 组件。包括文本输入框、表情按钮、语音按钮和“+”按钮（“更多”按钮）。
  *  TTextViewDelegate 提供了输入条各种情况下的回调委托，包括点击输入条的表情、“更多”视图、语音按钮的回调。以及发送消息、发送语音、更改输入高度的回调。
  *
  ******************************************************************************/

#import <UIKit/UIKit.h>
#import "TResponderTextView.h"

@class TUIInputBar;


/////////////////////////////////////////////////////////////////////////////////
//
//                            TTextViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  输入条的回调委托
 *  本委托包含输入条各种情况下的对于各种事件的回调。
 */
@protocol TTextViewDelegate <NSObject>
/**
 *  点击表情按钮，即“笑脸”后的回调委托。
 *  您可以通过该回调实现：点击表情按钮后，显示出对应的表情视图。
 *
 *  @param textView 委托者，当前与用户交互的 InputBar。
 */
- (void)inputBarDidTouchFace:(TUIInputBar *)textView;

/**
 *  点击更多按钮，即“+”后的回调委托。
 *  您可以通过该回调实现：相应用户的点击操作，显示出对应的更多视图。
 *
 *  @param textView 委托者，当前与用户交互的 InputBar。
 */
- (void)inputBarDidTouchMore:(TUIInputBar *)textView;

/**
 *  点击语音按钮，即“声波”图标后的回调委托。
 *  您可以通过该回调实现：显示出相应的操作提示视图，并开始语音的录制采集。
 *
 *  @param textView 委托者，当前与用户交互的 InputBar。
 */
- (void)inputBarDidTouchVoice:(TUIInputBar *)textView;

/**
 *  输入条高度更改时的回调委托
 *  当您点击语音按钮、表情按钮、“+”按钮或者呼出/收回键盘时，InputBar 高度会发生改变时，执行该回调
 *  您可以通过该回调实现：通过该回调函数进行 InputBar 高度改变时的 UI 布局调整。
 *  在 TUIKit 默认的实现中，本回调函数在处理了表情视图与更多视图的浮现后，进一步调用了 TUIInputController 中的 didChangeHeight 委托进行 UI 布局的高度调整。
 *
 *  @param textView 委托者，当前与用户交互的 InputBar。
 *  @param offset 输入条高度改变的偏移量。
 */
- (void)inputBar:(TUIInputBar *)textView didChangeInputHeight:(CGFloat)offset;

/**
 *  发送文本消息时的回调委托。
 *  当您通过 InputBar 发送文本消息（通过键盘点击发送时），执行该回调函数。
 *  您可以通过该回调实现：获取 InputBar 的内容，并将消息进行发送。
 *  在 TUIKit 默认的实现中，本回调函数在处理了表情视图与更多视图的浮现后，进一步调用了 TUIInputController 中的 didSendMessage 委托进行消息发送的进一步逻辑处理。
 *
 *  @param textView 委托者，当前与用户交互的 InputBar。
 *  @param text 点击发送时，当前 InputBar 中的文本消息。
 */
- (void)inputBar:(TUIInputBar *)textView didSendText:(NSString *)text;

/**
 *  发送语音后的回调委托
 *  当您长按语音按钮并松开时，执行该回调函数。
 *  您可以通过该回调实现：对录制到的语音信息进行处理并发送该语音消息。
 *  在 TUIKit 默认的实现中，本回调函数在处理了表情视图与更多视图的浮现后，进一步调用了 TUIInputController 中的 didSendMessage 委托进行消息发送的进一步逻辑处理。
 *
 *  @param textView 委托者，当前与用户交互的 InputBar。
 *  @param path 松开语音按钮时，当前录制的语音所在的路径。
 */
- (void)inputBar:(TUIInputBar *)textView didSendVoice:(NSString *)path;

/**
 *  输入含有 @ 字符的委托
 *
 *  @param textView 委托者，当前与用户交互的 InputBar。
 */
- (void)inputBarDidInputAt:(TUIInputBar *)textView;

/**
 *  删除含有 @ 字符的委托（比如删除 @xxx）
 *
 *  @param textView 委托者，当前与用户交互的 InputBar。
 */
- (void)inputBar:(TUIInputBar *)textView didDeleteAt:(NSString *)text;

/**
 *  点击键盘按钮后的回调委托
 *  点击表情按钮后，对应位置的“笑脸”会变成“键盘”图标，此时为键盘按钮。
 *  您可以通过该回调实现：隐藏当前显示的表情视图或者更多视图，并浮现键盘。
 *
 *  @param textView 委托者，当前与用户交互的 InputBar。
 */
- (void)inputBarDidTouchKeyboard:(TUIInputBar *)textView;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIInputBar
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIInputBar
 * 【功能说明】TUI 输入条，用于检测、获取用户输入的 UI 组件。
 *  输入条，即位于聊天消息最下方的 UI 组件。包括文本输入框、表情按钮、语音按钮和“+”按钮（“更多”按钮）。
 *  本类配合上述声明的回调委托，能够响应多种交互事件，包括点击输入条的表情、“更多”视图、语音按钮。以及发送消息、发送语音、更改输入高度等。
 *  本类不仅是实现了一个文本输入框中的业务逻辑，同时也是表情、more、和语音视图的逻辑入口。
 */
@interface TUIInputBar : UIView

/**
 *  线视图
 *  在视图中的分界线，使得 InputBar 与其他视图在视觉上区分，从而让 InputBar 在显示逻辑上更加清晰有序。
 */
@property (nonatomic, strong) UIView *lineView;

/**
 *  语音按钮
 *  即在输入条最右侧的，具有“音波”图标的按钮。
 */
@property (nonatomic, strong) UIButton *micButton;

/**
 *  键盘按钮
 *  即点击表情按钮（“笑脸”）后，笑脸变化后的按钮。
 */
@property (nonatomic, strong) UIButton *keyboardButton;

/**
 *  文本输入视图
 *  即在输入条中占据大部分面积的白色文本输入框
 *  继承自 UITextView
 */
@property (nonatomic, strong) TResponderTextView *inputTextView;

/**
 *  表情按钮
 *  即在输入条中的“笑脸”按钮。
 *  对应回调委托中的表情按钮回调。
 */
@property (nonatomic, strong) UIButton *faceButton;

/**
 *  更多按钮
 *  即在输入条中的“+”号按钮。
 *  对应回调委托中的“更多”按钮回调。
 */
@property (nonatomic, strong) UIButton *moreButton;

/**
 *  录音按钮
 *  在您点击了语音按钮（“声波图标”）后，原本的文本输入框会变成改按钮。
 *  您可以引导用户点击该按钮开始语音的录制，并通过本按钮的回调函数实现声音的录制。
 */
@property (nonatomic, strong) UIButton *recordButton;

/**
 *  实现 TTextViewDelegate 协议的委托。
 */
@property (nonatomic, weak) id<TTextViewDelegate> delegate;

/**
 *  添加表情
 *  用于实现在当前文本输入框中输入 emoji
 *
 *  @param emoji 需要输入的表情的字符串表示形式。
 */
- (void)addEmoji:(NSString *)emoji;

/**
 *  删除函数
 *  删除当前文本输入框中最右侧的字符（替换为“”）。
 */
- (void)backDelete;

/**
 *  清空整个文本输入框中的内容（替换为“”）。
 */
- (void)clearInput;

/**
 *  获取文本输入框中的内容。
 *
 *  @return 以字符串形式返回当前输入框中的内容。
 */
- (NSString *)getInput;

/**
 *  更新 textView 坐标
 */
- (void)updateTextViewFrame;
@end
