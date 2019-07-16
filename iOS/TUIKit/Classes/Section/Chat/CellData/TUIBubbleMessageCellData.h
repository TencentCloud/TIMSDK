/******************************************************************************
 *
 *  本文件声明了 TUIBubbleMessageCellData 类。
 *  本类继承于 TUIMessageCellData，用于存放气泡消息单元所需的一系列数据与信息。
 *  同时本类作为气泡消息数据源的基类，当您想实现自定义的气泡消息时，也需使对应消息的数据源继承自本类。
 *
 ******************************************************************************/
#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN
/** 
 * 【模块名称】TUIBubbleMessageCellData
 * 【功能说明】气泡消息单元数据源。
 *  气泡消息，即最常见的包含字符串与小表情的字符，大多数情况下将会是您最常见的消息单元类型。
 *  而气泡消息单元数据源（一下简称数据源），则是负责存储气泡消息单元所需的各种信息。
 *  数据源实现了一系列业务逻辑，使得数据源能够根据消息收发下的不同情况，向数据源提供正确的信息。
 *  数据源帮助实现了 MVVM 架构，使数据与 UI 进一步解耦，同时使 UI 层更加细化、可定制化。
 *  TUIFileMessageCellData 和 TUIVoiceMessageCellData 均继承于本类，实现了气泡消息的 UI 视觉。
 */
@interface TUIBubbleMessageCellData : TUIMessageCellData

/**
 *  气泡顶部 以便确定气泡位置
 *  该数值用于确定气泡位置，方便气泡内的内容进行 UI 布局。
 *  若该数值出现异常或者随意设置，会出现消息位置错位等 UI 错误。
 */
@property CGFloat bubbleTop;

/**
 *  气泡图标（正常）
 *  气泡图标会根据消息是发送还是接受作出改变，数据源中已实现相关业务逻辑。您也可以根据需求进行个性化定制。
 */
@property UIImage *bubble;

/**
 *  气泡图标（高亮）
 *  气泡图标会根据消息是发送还是接受作出改变，数据源中已实现相关业务逻辑。您也可以根据需求进行个性化定制。
 */
@property UIImage *highlightedBubble;


/**
 *  发送气泡图标（正常）
 *  气泡的发送图标，当气泡消息单元为发送时赋值给 bubble。
 */
@property (nonatomic, class) UIImage *outgoingBubble;

/**
 *  发送气泡图标（高亮）
 *  气泡的发送图标（高亮），当气泡消息单元为发送时赋值给 highlightedBubble。
 */
@property (nonatomic, class) UIImage *outgoingHighlightedBubble;

/**
 *  接收气泡图标（正常）
 *  气泡的接收图标，当气泡消息单元为接收时赋值给 bubble。
 */
@property (nonatomic, class) UIImage *incommingBubble;

/**
 *  接收气泡图标（高亮）
 *  气泡的接收图标，当气泡消息单元为接收时赋值给 highlightedBubble。
 */
@property (nonatomic, class) UIImage *incommingHighlightedBubble;

/**
 *  发送气泡顶部
 *  用于定位发送气泡的顶部，当气泡消息单元为发送时赋值给 bubbleTop。
 */
@property (nonatomic, class) CGFloat outgoingBubbleTop;

/**
 *  接收气泡顶部
 *  用于定位接收气泡的顶部，当气泡消息单元为接收时赋值给 bubbleTop。
 */
@property (nonatomic, class) CGFloat incommingBubbleTop;

@end

NS_ASSUME_NONNULL_END
