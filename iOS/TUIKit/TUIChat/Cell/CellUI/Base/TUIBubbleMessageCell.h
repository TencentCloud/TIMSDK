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
 *  If developers want to customize the bubble message, they can also refer to the implementation methods of the above two message units to implement their own bubble message unit.
 */
#import "TUIMessageCell.h"
#import "TUIBubbleMessageCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIBubbleMessageCell : TUIMessageCell

/**
 *  气泡图像视图，即消息的气泡图标，在 UI 上作为气泡的背景板包裹消息的内容。
 *  The bubble image view, the message's bubble icon, wraps the message's content on the UI as a background panel for the bubble.
 */
@property (nonatomic, strong) UIImageView *bubbleView;

@property TUIBubbleMessageCellData *bubbleData;

- (void)fillWithData:(TUIBubbleMessageCellData *)data;
@end

NS_ASSUME_NONNULL_END
