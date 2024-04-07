//
//  TUIResponderTextView_Minimalist.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/25.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TUIResponderTextView_Minimalist.h"
#import <TIMCommon/NSString+TUIEmoji.h>

@implementation TUIResponderTextView_Minimalist

- (UIResponder *)nextResponder {
    if (_overrideNextResponder == nil) {
        return [super nextResponder];
    } else {
        return _overrideNextResponder;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (_overrideNextResponder != nil)
        return NO;
    else
        return [super canPerformAction:action withSender:sender];
}
- (void)buildMenuWithBuilder:(id<UIMenuBuilder>)builder API_AVAILABLE(ios(13.0)) {
    if (@available(iOS 16.0, *)) {
        [builder removeMenuForIdentifier:UIMenuLookup];
    }
    [super buildMenuWithBuilder:builder];
}

- (void)deleteBackward {
    id<TUIResponderTextViewDelegate_Minimalist> delegate = (id<TUIResponderTextViewDelegate_Minimalist>)self.delegate;

    if ([delegate respondsToSelector:@selector(onDeleteBackward:)]) {
        [delegate onDeleteBackward:self];
    }

    [super deleteBackward];
}

- (void)setText:(NSString *)text {
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
    NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName : textFont}];
    [self.textStorage replaceCharactersInRange:self.selectedRange withAttributedString:spaceString];
}
@end
