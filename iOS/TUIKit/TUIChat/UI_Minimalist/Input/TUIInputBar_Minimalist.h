
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
#import "TUIResponderTextView_Minimalist.h"
#define kTUIInputNoramlFont [UIFont systemFontOfSize:16.0]
#define kTUIInputNormalTextColor TUIChatDynamicColor(@"chat_input_text_color", @"#000000")

typedef NS_ENUM(NSInteger, TUIRecordStatus) {
    TUIRecordStatus_Init,
    TUIRecordStatus_Record,
    TUIRecordStatus_Delete,
    TUIRecordStatus_Cancel,
};

@class TUIInputBar_Minimalist;

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIInputBarDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIInputBarDelegate_Minimalist <NSObject>

/**
 *  Callback after clicking the emoji button - "smiley" button.
 *  You can use this callback to achieve: After clicking the emoticon button, the corresponding emoticon view is displayed.
 */
- (void)inputBarDidTouchFace:(TUIInputBar_Minimalist *)textView;

/**
 *  Callback after more button - "+" is clicked.
 *  You can use this callback to achieve: corresponding user's click operation to display more corresponding views.
 */
- (void)inputBarDidTouchMore:(TUIInputBar_Minimalist *)textView;

/**
 *  You can use this callback to achieve: jump to the camera interface, take a photo or select a local photo
 */
- (void)inputBarDidTouchCamera:(TUIInputBar_Minimalist *)textView;

/**
 *  Callback when input bar height changes
 *  This callback is fired when the InputBar height changes when you click the voice button, emoji button, "+" button, or call out/retract the keyboard
 *  You can use this callback to achieve: UI layout adjustment when InputBar height changes through this callback function.
 *  In the default implementation of TUIKit, this callback function further calls the didChangeHeight delegate in TUIInputController to adjust the height of the
 * UI layout after processing the appearance of the expression view and more views.
 */
- (void)inputBar:(TUIInputBar_Minimalist *)textView didChangeInputHeight:(CGFloat)offset;

/**
 *  Callback when sending a text message.
 *  This callback is fired when you send a text message through the InputBar (click the send button from the keyboard).
 *  You can use this callback to get the content of the InputBar and send the message.
 *  In the default implementation of TUIKit, this callback further calls the didSendMessage delegate in TUIInputController for further logical processing of
 * message sending after processing the appearance of the expression view and more views.
 */
- (void)inputBar:(TUIInputBar_Minimalist *)textView didSendText:(NSString *)text;

/**
 *  Callback when sending voice
 *  This callback is triggered when you long press and release the voice button.
 *  You can use this callback to process the recorded voice information and send the voice message.
 *  In the default implementation of TUIKit, this callback function further calls the didSendMessage delegate in TUIInputController for further logical
 * processing of message sending after processing the appearance of the expression view and more views.
 */
- (void)inputBar:(TUIInputBar_Minimalist *)textView didSendVoice:(NSString *)path;

/**
 *  Callback after entering text containing the @ character
 */
- (void)inputBarDidInputAt:(TUIInputBar_Minimalist *)textView;

/**
 *  Callback after removing text containing @ characters (e.g. removing @xxx)
 */
- (void)inputBar:(TUIInputBar_Minimalist *)textView didDeleteAt:(NSString *)text;

/**
 *  Callback after keyboard button click
 *  After clicking the emoticon button, the "smiley face" icon at the corresponding position will become the "keyboard" icon, which is the keyboard button at
 * this time. You can use this callback to: hide the currently displayed emoticon view or more views, and open the keyboard.
 */
- (void)inputBarDidTouchKeyboard:(TUIInputBar_Minimalist *)textView;

/**
 * Callback after clicking delete button on keyboard
 */
- (void)inputBarDidDeleteBackward:(TUIInputBar_Minimalist *)textView;

- (void)inputTextViewShouldBeginTyping:(UITextView *)textView;

- (void)inputTextViewShouldEndTyping:(UITextView *)textView;

/**
 * Callback after clicking AI interrupt button
 */
- (void)inputBarDidTouchAIInterrupt:(TUIInputBar_Minimalist *)textView;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIInputBar
//
/////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, TUIInputBarStyle_Minimalist) {
    TUIInputBarStyleDefault_Minimalist = 0,    // Default style
    TUIInputBarStyleAI_Minimalist = 1,         // AI chat style
};

typedef NS_ENUM(NSInteger, TUIInputBarAIState_Minimalist) {
    TUIInputBarAIStateDefault_Minimalist = 0,  // AI default state: large input box only
    TUIInputBarAIStateActive_Minimalist = 1,   // AI active state: input box + interrupt/send button
};

@interface TUIInputBar_Minimalist : UIView

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
 *  Camera button
 *  Switch to camera after clicking
 */
@property(nonatomic, strong) UIButton *cameraButton;

/**
 *  Keyboard button
 *  Switch to keyboard input state after clicking
 */
@property(nonatomic, strong) UIButton *keyboardButton;

/**
 *  Input view
 */
@property(nonatomic, strong) TUIResponderTextView_Minimalist *inputTextView;

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
 *  Record View
 */
@property(nonatomic, strong) UIView *recordView;
@property(nonatomic, strong) UIImageView *recordDeleteView;
@property(nonatomic, strong) UIView *recordBackgroudView;
@property(nonatomic, strong) UIView *recordTipsView;
@property(nonatomic, strong) UILabel *recordTipsLabel;
@property(nonatomic, strong) UILabel *recordTimeLabel;
@property(nonatomic, strong) NSMutableArray *recordAnimateViews;
@property(nonatomic, strong) UIImageView *recordAnimateCoverView;
@property(nonatomic, assign) CGRect recordAnimateCoverViewFrame;

@property(nonatomic, weak) id<TUIInputBarDelegate_Minimalist> delegate;
@property(nonatomic, copy) void (^inputBarTextChanged)(UITextView * textview);

/**
 * AI chat style
 */
@property(nonatomic, assign) TUIInputBarStyle_Minimalist inputBarStyle;

/**
 * AI chat state
 */
@property(nonatomic, assign) TUIInputBarAIState_Minimalist aiState;

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

/**
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
- (void)addDraftToInputBar:(NSAttributedString *)draft;
- (void)addWordsToInputBar:(NSAttributedString *)words;

/**
 * Set input bar style
 */
- (void)setInputBarStyle:(TUIInputBarStyle_Minimalist)style;

/**
 * Set AI state
 */
- (void)setAIState:(TUIInputBarAIState_Minimalist)state;

/**
 * Set AI typing state
 */
- (void)setAITyping:(BOOL)typing;

@end
