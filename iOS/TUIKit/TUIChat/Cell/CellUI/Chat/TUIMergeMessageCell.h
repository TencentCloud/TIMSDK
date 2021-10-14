/******************************************************************************
*
*  本文件声明了 TUIMergeMessageCell 类。
*  合并转发的消息。当多条消息被合并转发之后，会形成一条合并转发消息显示在聊天界面上。
*
* 我们在收到一条转发消息的时候，通常会在聊天界面这样显示：
*  | vinson 和 lynx 的聊天记录                                                                            |        -- title
*  | vinson：新版本 SDK 计划什么时候上线呢？                                                |        -- abstract1
*  | lynx：计划下周一，具体时间要看下这两天的系统测试情况..                       |        -- abstract2
*  | vinson：好的.                                                                                                |        -- abstract3
*
*
******************************************************************************/
#import "TUIMessageCell.h"
#import "TUIMergeMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMergeMessageCell : TUIMessageCell
/**
 * 转发消息的标题 title
 */
@property (nonatomic, strong) UILabel *relayTitleLabel;

/**
 * 转发消息的摘要信息 abstract
 */
@property (nonatomic, strong) UILabel *abstractLabel;

/**
 * 填充UI的数据
 */
@property (nonatomic, strong) TUIMergeMessageCellData *relayData;

/**
 * 填充UI
 *
 * @param data 数据
 */
- (void)fillWithData:(TUIMergeMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
