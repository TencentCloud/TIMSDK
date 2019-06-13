//
//  TUIInputBar.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TResponderTextView.h"

@class TUIInputBar;
@protocol TTextViewDelegate <NSObject>
- (void)inputBarDidTouchFace:(TUIInputBar *)textView;
- (void)inputBarDidTouchMore:(TUIInputBar *)textView;
- (void)inputBarDidTouchVoice:(TUIInputBar *)textView;
- (void)inputBar:(TUIInputBar *)textView didChangeInputHeight:(CGFloat)offset;
- (void)inputBar:(TUIInputBar *)textView didSendText:(NSString *)text;
- (void)inputBar:(TUIInputBar *)textView didSendVoice:(NSString *)path;
- (void)inputBarDidTouchKeyboard:(TUIInputBar *)textView;
@end


@interface TUIInputBar : UIView
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *micButton;
@property (nonatomic, strong) UIButton *keyboardButton;
@property (nonatomic, strong) TResponderTextView *inputTextView;
@property (nonatomic, strong) UIButton *faceButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, weak) id<TTextViewDelegate> delegate;
- (void)addEmoji:(NSString *)emoji;
- (void)backDelete;
- (void)clearInput;
- (NSString *)getInput;
@end
