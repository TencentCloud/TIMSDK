//
//  TTextView.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TResponderTextView.h"

@class TTextView;
@protocol TTextViewDelegate <NSObject>
- (void)textViewDidTouchFace:(TTextView *)textView;
- (void)textViewDidTouchMore:(TTextView *)textView;
- (void)textViewDidTouchVoice:(TTextView *)textView;
- (void)textView:(TTextView *)textView didChangeInputHeight:(CGFloat)offset;
- (void)textView:(TTextView *)textView didSendMessage:(NSString *)text;
- (void)textView:(TTextView *)textView didSendVoice:(NSString *)path;
@end


@interface TTextView : UIView
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
