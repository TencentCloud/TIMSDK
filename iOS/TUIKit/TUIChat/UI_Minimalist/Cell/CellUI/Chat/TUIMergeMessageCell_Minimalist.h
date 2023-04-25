/**
 *  本文件声明了 TUIMergeMessageCell_Minimalist 类。
 *  当多条消息被合并转发之后，会形成一条合并转发消息显示在聊天界面上。
 *
 *  我们在收到一条合并转发消息的时候，通常会在聊天界面这样显示：
 *  | vinson 和 lynx 的聊天记录                                                                            |        -- title
 *  | vinson：新版本 SDK 计划什么时候上线呢？                                                |        -- abstract1
 *  | lynx：计划下周一，具体时间要看下这两天的系统测试情况..                       |        -- abstract2
 *  | vinson：好的.                                                                                                |        -- abstract3
 *
 *
 *  This document declares the TUIMergeMessageCell class.
 *  When multiple messages are merged and forwarded, a merged-forward message will be displayed on the chat interface.
 *
 *  When we receive a merged-forward message, it is usually displayed in the chat interface like this:
 *  | History of vinson and lynx                                                                                                                                                   |        -- title
 *  | vinson：When will the new version of the SDK be released？                                                                                           |        -- abstract1
 *  | lynx：Plan for next Monday, the specific time depends on the system test situation in these two days..                        |        -- abstract2
 *  | vinson：Okay.
 */

#import <TIMCommon/TUIMessageCell_Minimalist.h>
#import "TUIMergeMessageCellData_Minimalist.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIMergeMessageCell_Minimalist : TUIMessageCell_Minimalist
/**
 * 转发消息的标题 title
 * Title of merged-forward message
 */
@property (nonatomic, strong) UILabel *relayTitleLabel;

/**
 * 转发消息的摘要信息 abstract
 * Abstract of merged-forward message
 */
@property (nonatomic, strong) UILabel *abstractLabel;

/**
 * 水平分割线
 * Horizontal dividing line
 */
@property (nonatomic, strong) UIView *separtorView;

/**
 * 底部提示语
 *  bottom prompt
 */
@property (nonatomic, strong) UILabel *bottomTipsLabel;


@property (nonatomic, strong) TUIMergeMessageCellData_Minimalist *relayData;
- (void)fillWithData:(TUIMergeMessageCellData_Minimalist *)data;

@end

NS_ASSUME_NONNULL_END
