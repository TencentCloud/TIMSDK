/******************************************************************************
 *
 *  本文件声明了 TUISystemMessageCell 类，负责实现系统消息的展示。
 *  系统消息单元，即负责展示来自系统的特殊消息。这类消息通常是灰底白字而且居中。
 *
 ******************************************************************************/
#import "TUISystemMessageCellData.h"
#import "TUIMessageCell.h"

/**
 * 【模块名称】TUISystemMessageCell
 * 【功能说明】系统消息单元
 *  用于实现系统消息的 UI 展示。常见的系统消息内容有：撤回消息、群成员变更消息、群成立与解散消息等。
 *  系统消息通常用于展示来自于 App 的通知，这类通知由系统发送，而不来自于任何用户。
 */
@interface TUISystemMessageCell : TUIMessageCell

/**
 *  系统消息标签
 *  用于展示系统消息的内容。例如：“您撤回了一条消息”。
 */
@property (readonly) UILabel *messageLabel;

/**
 *  系统消息单元数据源
 *  消息源中存放了系统消息的内容、消息字体以及消息颜色。
 *  详细信息请参考 Section\Chat\CellData\TUISystemMessageCellData.h
 */
@property (readonly) TUISystemMessageCellData *systemData;

/**
 *  填充数据
 *  根据 data 设置系统消息的数据
 *
 *  @param data 填充数据需要的数据源
 */
- (void)fillWithData:(TUISystemMessageCellData *)data;
@end
