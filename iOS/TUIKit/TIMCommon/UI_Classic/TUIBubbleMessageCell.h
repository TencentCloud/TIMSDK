
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  本文件声明了 TUIBubbleMessageCell 类。
 *  气泡消息，即最常见的包含字符串与小表情的字符的消息类型
 *  TUIFileMessageCell 和 TUIVoiceMessageCell 均继承于本类，实现了气泡消息的 UI 视觉。
 *  如果开发者想要实现气泡消息的自定义，也可参照上述两个消息单元的实现方法，实现自己的气泡消息单元。
 *
 *  This document declares the TUIBubbleMessageCell class.
 *  Bubble messages, the most common type of messages that contain strings and emoticons.
 *  Both TUIFileMessageCell and TUIVoiceMessageCell inherit from this class and implement the userinterface of bubble messages.
 *  If developers want to customize the bubble message, they can also refer to the implementation methods of the above two message units to implement their own
 * bubble message unit.
 */
#import "TUIBubbleMessageCellData.h"
#import "TUIMessageCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIBubbleMessageCell : TUIMessageCell

/**
 *  气泡图像视图，即消息的气泡图标，在 UI 上作为气泡的背景板包裹消息的内容。
 *  The bubble image view, the message's bubble icon, wraps the message's content on the UI as a background panel for the bubble.
 */
@property(nonatomic, strong) UIImageView *bubbleView;

@property TUIBubbleMessageCellData *bubbleData;

- (void)fillWithData:(TUIBubbleMessageCellData *)data;

+ (CGFloat)getBubbleTop:(TUIBubbleMessageCellData *)data;


@end


#pragma mark - TUILayoutConfiguration

@interface TUIBubbleMessageCell (TUILayoutConfiguration)

/**
 *  发送气泡图标（正常）
 *  - 气泡的发送图标，当气泡消息单元为发送时赋值给 bubble。
 *
 *  Send bubble icon (normal state)
 *  - The send icon of the bubble, assigned to the @bubble when the bubble message was sent.
 */
@property(nonatomic, class) UIImage *outgoingBubble;

/**
 *  发送气泡图标（高亮）
 *  - 气泡的发送图标（高亮），当气泡消息单元为发送时赋值给 highlightedBubble。
 *
 *  Send bubble icon (highlighted state)
 *  - The send icon (highlighted state) of the bubble, assigned to @highlightedBubble when the bubble message was sent.
 */
@property(nonatomic, class) UIImage *outgoingHighlightedBubble;

/**
 * 发送气泡图标动画过渡
 * Send bubble icon (highlighted state)
 */
@property(nonatomic, class) UIImage *outgoingAnimatedHighlightedAlpha20;
@property(nonatomic, class) UIImage *outgoingAnimatedHighlightedAlpha50;

/**
 *  接收气泡图标（正常）
 *  - 气泡的接收图标，当气泡消息单元为接收时赋值给 bubble。
 *
 *  Receive bubble icon (normal state)
 *  - The receive icon of the bubble, assigned to the @bubble when the bubble message was received.
 */
@property(nonatomic, class) UIImage *incommingBubble;

/**
 *  接收气泡图标（高亮）
 *  - 气泡的接收图标，当气泡消息单元为接收时赋值给 highlightedBubble。
 *
 *  Receive bubble icon (highlighted state)
 *  - The receive icon of the bubble, assigned to @highlightedBubble when the bubble message was received.
 */
@property(nonatomic, class) UIImage *incommingHighlightedBubble;

/**
 * 接收气泡图标动画过渡
 * Receive bubble icon (highlighted state)
 */
@property(nonatomic, class) UIImage *incommingAnimatedHighlightedAlpha20;
@property(nonatomic, class) UIImage *incommingAnimatedHighlightedAlpha50;


/**
 *  发送气泡顶部的间距
 *  - 用于定位发送气泡的顶部，当气泡消息单元为发送时赋值给 bubbleTop。
 *
 *  Spacing at the top of the send bubble
 *  - It is used to locate the top of the sent bubble, and is assigned to @bubbleTop when the bubble message was sent.
 */
@property(nonatomic, class) CGFloat outgoingBubbleTop;

/**
 *  接收气泡顶部的间距
 *  - 用于定位接收气泡的顶部，当气泡消息单元为接收时赋值给 bubbleTop。
 *
 *  Spacing at the top of the receiving bubble
 *  - It is used to locate the top of the receive bubble, and is assigned to @bubbleTop when the bubble message was
 * received.
 */
@property(nonatomic, class) CGFloat incommingBubbleTop;

@end

NS_ASSUME_NONNULL_END
