 /******************************************************************************
  *
  *  本文件声明了 TUITextMessageCellData 类。
  *  本类继承于 TUIBubbleMessageCellData，用于存放文本消息单元所需的一系列数据与信息。
  *
  ******************************************************************************/
#import "TUIMessageCellData.h"
#import "TUIBubbleMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 * 【模块名称】TUITextMessageCellData
 * 【功能说明】文本消息单元数据源。
 *  文本消息单元，即在多数信息收发情况下最常见的消息单元。
 *  文本消息单元数据源则是为文本消息单元提供一系列所需的数据与信息。
 *  数据源帮助实现了 MVVM 架构，使数据与 UI 进一步解耦，同时使 UI 层更加细化、可定制化。
 */
@interface TUITextMessageCellData : TUIBubbleMessageCellData

/**
 *  消息的文本内容
 */
@property (nonatomic, strong) NSString *content;

/**
 *  文本字体
 *  文本消息显示时的 UI 字体。
 */
@property (nonatomic, strong) UIFont *textFont;

/**
 *  文本颜色
 *  文本消息显示时的 UI 颜色。
 */
@property (nonatomic) UIColor *textColor;

/**
 *  可变字符串
 *  文本消息接收到 content 字符串后，需要将字符串中可能存在的字符串表情（比如[微笑]），转为图片表情。
 *  本字符串则负责存储上述过程转换后的结果。
 */
@property (nonatomic, strong) NSAttributedString *attributedString;

/**
 *  文本内容尺寸。
 *  配合原点定位文本消息。
 */
@property (readonly) CGSize textSize;

/**
 *  文本内容原点。
 *  配合尺寸定位文本消息。
 */
@property (readonly) CGPoint textOrigin;

/**
 *  文本消息颜色（发送）
 *  在消息方向为发送时使用。
 */
@property (nonatomic, class) UIColor *outgoingTextColor;

/**
 *  文本消息字体（发送）
 *  在消息方向为发送时使用。
 */
@property (nonatomic, class) UIFont *outgoingTextFont;

/**
 *  文本消息颜色（接收）
 *  在消息方向为接收时使用。
 */
@property (nonatomic, class) UIColor *incommingTextColor;

/**
 *  文本消息字体（接收）
 *  在消息方向为接收时使用。
 */
@property (nonatomic, class) UIFont *incommingTextFont;

@end

NS_ASSUME_NONNULL_END
