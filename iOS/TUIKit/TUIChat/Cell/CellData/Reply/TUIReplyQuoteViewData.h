//
//  TUIReplyQuoteViewData.h
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import <Foundation/Foundation.h>
@class TUIMessageCellData;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIReplyQuoteAsyncLoadFinish)(void);

@interface TUIReplyQuoteViewData : NSObject

/**
 * 快速创建消息回复引用数据 - 各个子类实现
 */
+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData;

/**
 * 自定义回复内容的尺寸
 *
 * @param maxWidth 显示的最大宽度
 */
- (CGSize)contentSize:(CGFloat)maxWidth;

/**
 * 自定义回复内容如果要异步下载，下载完成之后需要调用改callback，TUI 内部会自动刷新
 */
@property (nonatomic, copy) TUIReplyQuoteAsyncLoadFinish onFinish;

/**
 * 被回复的原始消息
 */
@property (nonatomic, strong) TUIMessageCellData *originCellData;

@end

NS_ASSUME_NONNULL_END
