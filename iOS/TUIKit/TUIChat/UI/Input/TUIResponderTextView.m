//
//  TResponderTextView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIResponderTextView.h"
#import "NSString+emoji.h"

@implementation TUIResponderTextView

- (UIResponder *)nextResponder
{
    if(_overrideNextResponder == nil){
        return [super nextResponder];
    }
    else{
        return _overrideNextResponder;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (_overrideNextResponder != nil)
        return NO;
    else
        return [super canPerformAction:action withSender:sender];
}

- (void)deleteBackward
{
    id<TUIResponderTextViewDelegate> delegate = (id<TUIResponderTextViewDelegate>)self.delegate;
    
    if ([delegate respondsToSelector:@selector(onDeleteBackward:)]) {
        [delegate onDeleteBackward:self];
    }
    
    [super deleteBackward];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegate textViewDidChange:self];
    }
}

- (void)copy:(__unused id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [[self.textStorage attributedSubstringFromRange:self.selectedRange] getPlainString];
}

- (void)cut:(nullable id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [[self.textStorage attributedSubstringFromRange:self.selectedRange] getPlainString];
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: textFont}];
    [self.textStorage replaceCharactersInRange:self.selectedRange withAttributedString:spaceString];
    
}
@end
