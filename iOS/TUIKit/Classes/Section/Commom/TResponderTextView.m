//
//  TResponderTextView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TResponderTextView.h"

@implementation TResponderTextView

- (UIResponder *)nextResponder
{
    if(_overrideNextResponder == nil){
        return [super nextResponder];
    }
    else{
        return _overrideNextResponder;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (_overrideNextResponder != nil)
        return NO;
    else
        return [super canPerformAction:action withSender:sender];
}
@end
