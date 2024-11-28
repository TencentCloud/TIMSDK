//
//  TUITextView.m
//  Masonry
//
//  Created by xiangzhang on 2022/10/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITextView.h"
#import <TUICore/TUIThemeManager.h>

@implementation TUITextView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
        [self setupLongPressGesture];
        self.tintColor = TIMCommonDynamicColor(@"chat_highlight_link_color", @"#6495ED");
    }
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

- (void)buildMenuWithBuilder:(id<UIMenuBuilder>)builder API_AVAILABLE(ios(13.0)) {
    if (@available(iOS 16.0, *)) {
        [builder removeMenuForIdentifier:UIMenuLookup];
    }
    [super buildMenuWithBuilder:builder];
}

- (void)disableHighlightLink {
    self.dataDetectorTypes = UIDataDetectorTypeNone;
}

- (void)setupLongPressGesture {
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:self.longPressGesture];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateBegan) {
        if (self.tuiTextViewDelegate && [self.tuiTextViewDelegate respondsToSelector:@selector(onLongPressTextViewMessage:)]) {
            [self.tuiTextViewDelegate onLongPressTextViewMessage:self];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] &&
        gestureRecognizer != self.longPressGesture) {
        return NO;
    }
    return YES;
}

@end
