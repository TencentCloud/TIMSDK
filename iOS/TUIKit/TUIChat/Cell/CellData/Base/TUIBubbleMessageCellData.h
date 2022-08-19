/**
 *
 *  - 本文件声明了 TUIBubbleMessageCellData 类。
 *  - 本类继承于 TUIMessageCellData，用于存放气泡消息单元所需的一系列数据与信息。
 *  - 本类作为气泡消息数据源的基类，当您想实现自定义的气泡消息时，也需使对应消息的数据源继承自本类。
 *
 *  - This file declares the TUIBubbleMessageCellData class.
 *  - This class inherits from TUIMessageCellData and is used to store a series of data and information required by the bubble message unit.
 *  - This class is used as the base class for the data source of the bubble message. When you want to implement a custom bubble message,
 *   you also need to make the data source of the corresponding message inherit from this class.
 *
 */
#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN
/** 
 * 【模块名称】TUIBubbleMessageCellData
 * 【功能说明】气泡消息数据源。
 *  - 气泡消息，即最常见的包含文本与表情字符的消息，大多数情况下将会是您最常见的消息类型。
 *  - 气泡消息数据源（以下简称数据源），负责存储渲染气泡消息 UI 所需的各种信息。
 *  - 数据源实现了一系列的业务逻辑，可以向气泡消息 UI 提供所需的信息。
 *  - TUIFileMessageCellData 和 TUIVoiceMessageCellData 均继承于本类，实现了气泡消息的 UI。
 *
 * 【Module name】TUIBubbleMessageCellData
 * 【Function description】Bubble message data source.
 *  - Bubble messages, the most common type of messages that contain text and emoji characters, will be your most common type of message in most cases.
 *  - The Bubble Message data source (hereinafter referred to as the data source) is responsible for storing various information required to render the Bubble Message UI.
 *  - The data source implements a series of business logic that can provide the required information to the Bubble Message UI.
 *  - Both TUIFileMessageCellData and TUIVoiceMessageCellData inherit from this class and implement the UI of bubble messages.
 */
@interface TUIBubbleMessageCellData : TUIMessageCellData

/**
 *  气泡顶部的间距，以便确定气泡位置
 *  - 该数值用于确定气泡的位置，方便气泡内的内容进行 UI 布局。
 *  - 若该数值出现异常或者随意设置，会出现消息错位等 UI 异常。
 *
 * Spacing at the top of the bubble, so that the position of the bubble can be determined
 * - This value is used to determine the position of the bubble, which is convenient for UI layout of the the bubble content.
 * - If the value is abnormal or set arbitrarily, UI exceptions such as message dislocation will occur.
 *
 */
@property CGFloat bubbleTop;

/**
 *  气泡图标（正常）
 *  - 气泡图标会根据消息是发送还是接受作出改变，数据源中已实现相关业务逻辑。您也可以根据需求进行个性化定制。
 *
 *  Bubble icon (normal state)
 *  - The bubble icon changes depending on whether the message is sent or received, and the relevant business logic has been implemented in the data source.
 *  - You can also personalize it according to your needs.
 */
@property UIImage *bubble;

/**
 *  气泡图标（高亮）
 *  - 气泡图标会根据消息是发送还是接受作出改变，数据源中已实现相关业务逻辑。您也可以根据需求进行个性化定制。
 *
 *  Bubble icon (highlighted state)
 *  - The bubble icon changes depending on whether the message is sent or received, and the relevant business logic has been implemented in the data source.
 *  - You can also personalize it according to your needs.
 */
@property UIImage *highlightedBubble;

/**
 *  气泡图标（动画闪烁）
 *  Bubble icon (animated blinking state)
 */
@property UIImage *animateHighlightBubble_alpha50;
@property UIImage *animateHighlightBubble_alpha20;


/**
 *  发送气泡图标（正常）
 *  - 气泡的发送图标，当气泡消息单元为发送时赋值给 bubble。
 *
 *  Send bubble icon (normal state)
 *  - The send icon of the bubble, assigned to the @bubble when the bubble message was sent.
 */
@property (nonatomic, class) UIImage *outgoingBubble;

/**
 *  发送气泡图标（高亮）
 *  - 气泡的发送图标（高亮），当气泡消息单元为发送时赋值给 highlightedBubble。
 *
 *  Send bubble icon (highlighted state)
 *  - The send icon (highlighted state) of the bubble, assigned to @highlightedBubble when the bubble message was sent.
 */
@property (nonatomic, class) UIImage *outgoingHighlightedBubble;

/**
 *  接收气泡图标（正常）
 *  - 气泡的接收图标，当气泡消息单元为接收时赋值给 bubble。
 *
 *  Receive bubble icon (normal state)
 *  - The receive icon of the bubble, assigned to the @bubble when the bubble message was received.
 */
@property (nonatomic, class) UIImage *incommingBubble;

/**
 *  接收气泡图标（高亮）
 *  - 气泡的接收图标，当气泡消息单元为接收时赋值给 highlightedBubble。
 *
 *  Receive bubble icon (highlighted state)
 *  - The receive icon of the bubble, assigned to @highlightedBubble when the bubble message was received.
 */
@property (nonatomic, class) UIImage *incommingHighlightedBubble;

/**
 *  发送气泡顶部的间距
 *  - 用于定位发送气泡的顶部，当气泡消息单元为发送时赋值给 bubbleTop。
 *
 *  Spacing at the top of the send bubble
 *  - It is used to locate the top of the sent bubble, and is assigned to @bubbleTop when the bubble message was sent.
 */
@property (nonatomic, class) CGFloat outgoingBubbleTop;

/**
 *  接收气泡顶部的间距
 *  - 用于定位接收气泡的顶部，当气泡消息单元为接收时赋值给 bubbleTop。
 *
 *  Spacing at the top of the receiving bubble
 *  - It is used to locate the top of the receive bubble, and is assigned to @bubbleTop when the bubble message was received.
 */
@property (nonatomic, class) CGFloat incommingBubbleTop;

@end

NS_ASSUME_NONNULL_END
