//
//  TResponderTextView_Minimalist.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/25.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TUIResponderTextView_Minimalist;

@protocol TUIResponderTextViewDelegate_Minimalist <UITextViewDelegate>

- (void)onDeleteBackward:(TUIResponderTextView_Minimalist *)textView;

@end

@interface TUIResponderTextView_Minimalist : UITextView
@property(nonatomic, weak) UIResponder *overrideNextResponder;
@end
