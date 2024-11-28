//
//  TUITextView.h
//  Masonry
//
//  Created by xiangzhang on 2022/10/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUITextViewDelegate <NSObject>
- (void)onLongPressTextViewMessage:(UITextView *)textView;
@end

@interface TUITextView : UITextView
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, weak) id<TUITextViewDelegate> tuiTextViewDelegate;

- (void)disableHighlightLink;

@end

NS_ASSUME_NONNULL_END
