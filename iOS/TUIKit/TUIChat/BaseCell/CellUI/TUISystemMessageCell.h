/**
 *  本文件声明了 TUISystemMessageCell 类，负责实现系统消息的展示。
 *  系统消息单元，即负责展示来自系统的特殊消息。这类消息通常是灰底白字而且居中。
 *
 *  This file declares the TUISystemMessageCell class, which is responsible for displaying system messages.
 *  The system message unit is responsible for displaying special messages from the system. Such messages are usually white on a gray background and centered.
 */
#import "TUISystemMessageCellData.h"
#import "TUIMessageCell.h"

/**
 * 【模块名称】TUISystemMessageCell
 * 【功能说明】系统消息单元
 *  用于实现系统消息的 UI 展示。常见的系统消息内容有：撤回消息、群成员变更消息、群成立与解散消息等。
 *  系统消息通常用于展示来自于 App 的通知，这类通知由系统发送，而不来自于任何用户。
 *
 * 【Module name】 TUISystemMessageCell
 * 【Function description】System message unit
 *  - It is used to display the system messages. Common system messages include: recall-message, group-member-change-message, group-created and group-diss-message, etc.
 *  - System messages are typically used to display notifications from apps that are sent by the system, not from any user.
 */
@interface TUISystemMessageCell : TUIMessageCell

/**
 *  系统消息标签
 *  用于展示系统消息的内容。例如：“您撤回了一条消息”。
 *
 *  The label of display system message content, such as "You recalled a message.".
 */
@property (readonly) UILabel *messageLabel;

@property (readonly) TUISystemMessageCellData *systemData;

- (void)fillWithData:(TUISystemMessageCellData *)data;
@end
