/******************************************************************************
 *
 *  本文件声明了 TUITextMessageCell 类。
 *  文本消息单元，即进包含文本以及小表情的消息单元
 *  该类继承自 TUIBubbleMessageCell 来实现气泡消息。您可以参考这一继承关系实现自定义气泡。
 *
 ******************************************************************************/
#import "TUIBubbleMessageCell.h"
#import "TUITextMessageCellData.h"

/**
 * 【模块名称】TUITextMessageCell
 * 【功能说明】文本消息单元
 *  文本消息单元，即在多数信息收发情况下最常见的消息单元。
 *  文本消息单元继承自气泡消息单元（TUIBubbleMessageCell），在气泡消息单元提供的气泡视图基础上填充文本信息并显示。
 */
@interface TUITextMessageCell : TUIBubbleMessageCell

/**
 *  内容标签
 *  用于展示文本消息的内容。
 */
@property (nonatomic, strong) UILabel *content;

/**
 *  文本消息单元数据源
 *  数据源内存放了文本消息的内容信息、消息字体、消息颜色、并存放了发送、接收两种状态下的不同字体颜色。
 */
@property TUITextMessageCellData *textData;

/**
 *  填充数据
 *  根据 data 设置文本消息的数据。
 *
 *  @param  data    填充数据需要的数据源
 */
- (void)fillWithData:(TUITextMessageCellData *)data;
@end
