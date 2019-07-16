/******************************************************************************
 *
 *  本文件声明了 TUIBubbleMessageCell 类。
 *  气泡消息，即最常见的包含字符串与小表情的字符，大多数情况下将会是您最常见的消息单元类型。
 *  TUIFileMessageCell 和 TUIVoiceMessageCell 均继承于本类，实现了气泡消息的 UI 视觉。
 *  如果开发者想要实现气泡消息的自定义，也可参照上述两个消息单元的实现方法，实现自己的气泡消息单元。
 *
 ******************************************************************************/
#import "TUIMessageCell.h"
#import "TUIBubbleMessageCellData.h"
NS_ASSUME_NONNULL_BEGIN

/** 腾讯云 TUIKit
 * 【模块名称】TUIBubbleMessageCell
 * 【功能说明】气泡消息视图。
 *  气泡消息，即最常见的包含字符串与小表情的字符，大多数情况下将会是您最常见的消息单元类型。
 *  气泡消息负责包裹文本和小表情（如[微笑]），并将其以消息单元的形式展现出来。
 */
@interface TUIBubbleMessageCell : TUIMessageCell

/**
 *  气泡图像视图，即消息的气泡图标，在 UI 上作为气泡的背景板包裹消息信息内容。
 */
@property (nonatomic, strong) UIImageView *bubbleView;

/**
 *  气泡单元数据源
 *  气泡单元数据源中存放了气泡的各类图标，比如接收图标（正常与高亮）、发送图标（正常与高亮）。
 *  并能根据具体的发送、接收状态选择相应的图标进行显示。
 */
@property TUIBubbleMessageCellData *bubbleData;

/**
 *  填充数据
 *  根据 data 设置气泡消息的数据。
 *
 *  @param data 填充数据需要的数据源
 */
- (void)fillWithData:(TUIBubbleMessageCellData *)data;
@end

NS_ASSUME_NONNULL_END
