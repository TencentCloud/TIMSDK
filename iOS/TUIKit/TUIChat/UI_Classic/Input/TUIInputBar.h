
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  This file declares the TUIInputBarDelegate protocol and the TUIInputBar class.
 *  TUI input bar, a UI component used to detect and obtain user input.
 *  TUIInputBar, the UI component at the bottom of the chat message. Includes text input box, emoji button, voice button, and "+" button ("More" button)
 *  TUIInputBarDelegate provides callbacks for various situations of the input bar, including the callback for the emoticon of clicking the input bar, the
 * "more" view, and the voice button. And callbacks to send message, send voice, change input height.
 */

#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/TUIThemeManager.h>
#import <UIKit/UIKit.h>
#import "TUIResponderTextView.h"

#define kTUIInputNoramlFont [UIFont systemFontOfSize:16.0]
#define kTUIInputNormalTextColor TUIChatDynamicColor(@"chat_input_text_color", @"#000000")

@class TUIInputBar;

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIInputBarDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIInputBarDelegate <NSObject>

/**
 *  Callback after clicking the emoji button - "smiley" button.
 *  You can use this callback to achieve: After clicking the emoticon button, the corresponding emoticon view is displayed.
 */
- (void)inputBarDidTouchFace:(TUIInputBar *)textView;

/**
 *  Callback after more button - "+" is clicked.
 *  You can use this callback to achieve: corresponding user's click operation to display more corresponding views.
 */
- (void)inputBarDidTouchMore:(TUIInputBar *)textView;

/**
 *  Callback after clicking the voice button - "Sound Wave" icon .
 *  You can use this callback to display the corresponding operation prompt view and start voice recording
 */
- (void)inputBarDidTouchVoice:(TUIInputBar *)textView;

/**
 *  Callback when input bar height changes
 *  This callback is fired when the InputBar height changes when you click the voice button, emoji button, "+" button, or call out/retract the keyboard
 *  You can use this callback to achieve: UI layout adjustment when InputBar height changes through this callback function.
 *  In the default implementation of TUIKit, this callback function further calls the didChangeHeight delegate in TUIInputController to adjust the height of the
 * UI layout after processing the appearance of the expression view and more views.
 */
- (void)inputBar:(TUIInputBar *)textView didChangeInputHeight:(CGFloat)offset;

/**
 *  Callback when sending a text message.
 *  This callback is fired when you send a text message through the InputBar (click the send button from the keyboard).
 *  You can use this callback to get the content of the InputBar and send the message.
 *  In the default implementation of TUIKit, this callback further calls the didSendMessage delegate in TUIInputController for further logical processing of
 * message sending after processing the appearance of the expression view and more views.
 */
- (void)inputBar:(TUIInputBar *)textView didSendText:(NSString *)text;

/**
 *  Callback when sending voice
 *  This callback is triggered when you long press and release the voice button.
 *  You can use this callback to process the recorded voice information and send the voice message.
 *  In the default implementation of TUIKit, this callback function further calls the didSendMessage delegate in TUIInputController for further logical
 * processing of message sending after processing the appearance of the expression view and more views.
 */
- (void)inputBar:(TUIInputBar *)textView didSendVoice:(NSString *)path;

/**
 *  Callback after entering text containing the @ character
 */
- (void)inputBarDidInputAt:(TUIInputBar *)textView;

/**
 *  Callback after removing text containing @ characters (e.g. removing @xxx)
 */
- (void)inputBar:(TUIInputBar *)textView didDeleteAt:(NSString *)text;

/**
 *  Callback after keyboard button click
 *  After clicking the emoticon button, the "smiley face" icon at the corresponding position will become the "keyboard" icon, which is the keyboard button at
 * this time. You can use this callback to: hide the currently displayed emoticon view or more views, and open the keyboard.
 */
- (void)inputBarDidTouchKeyboard:(TUIInputBar *)textView;

/**
 * Callback after clicking delete button on keyboard
 */
- (void)inputBarDidDeleteBackward:(TUIInputBar *)textView;

- (void)inputTextViewShouldBeginTyping:(UITextView *)textView;

- (void)inputTextViewShouldEndTyping:(UITextView *)textView;

/**
 * Callback after clicking AI interrupt button
 */
- (void)inputBarDidTouchAIInterrupt:(TUIInputBar *)textView;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIInputBar
//
/////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, TUIInputBarStyle) {
    TUIInputBarStyleDefault = 0,    // Default style
    TUIInputBarStyleAI = 1,         // AI chat style
};

typedef NS_ENUM(NSInteger, TUIInputBarAIState) {
    TUIInputBarAIStateDefault = 0,  // AI default state: large input box only
    TUIInputBarAIStateActive = 1,   // AI active state: input box + interrupt/send button
};

@interface TUIInputBar : UIView

/**
 *  Separtor
 */
@property(nonatomic, strong) UIView *lineView;

/**
 *  Voice button
 *  Switch to voice input state after clicking
 */
@property(nonatomic, strong) UIButton *micButton;

/**
 *  Keyboard button
 *  Switch to keyboard input state after clicking
 */
@property(nonatomic, strong) UIButton *keyboardButton;

/**
 *  Input view
 */
@property(nonatomic, strong) TUIResponderTextView *inputTextView;

/**
 *  Emoticon button
 *  Switch to emoji input state after clicking
 */
@property(nonatomic, strong) UIButton *faceButton;

/**
 *  More  button
 *  A button that, when clicked, opens up more menu options
 */
@property(nonatomic, strong) UIButton *moreButton;

/**
 *  Record button, long press the button to start recording
 */
@property(nonatomic, strong) UIButton *recordButton;

@property(nonatomic, weak) id<TUIInputBarDelegate> delegate;

@property(nonatomic, copy) void (^inputBarTextChanged)(UITextView * textview);

@property(nonatomic, assign) BOOL isFromReplyPage;

/**
 * AI chat style
 */
@property(nonatomic, assign) TUIInputBarStyle inputBarStyle;

/**
 * AI chat state
 */
@property(nonatomic, assign) TUIInputBarAIState aiState;

/**
 * AI interrupt button
 */
@property(nonatomic, strong) UIButton *aiInterruptButton;

/**
 * AI send button
 */
@property(nonatomic, strong) UIButton *aiSendButton;

/**
 * Whether AI is currently typing
 */
@property(nonatomic, assign) BOOL aiIsTyping;

- (void)defaultLayout;
/**
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

- (void)addDraftToInputBar:(NSAttributedString *)draft;
- (void)addWordsToInputBar:(NSAttributedString *)words;

/**
 * Set input bar style
 */
- (void)setInputBarStyle:(TUIInputBarStyle)style;

/**
 * Set AI state
 */
- (void)setAIState:(TUIInputBarAIState)state;

/**
 * Set AI typing state
 */
- (void)setAITyping:(BOOL)typing;

@end
