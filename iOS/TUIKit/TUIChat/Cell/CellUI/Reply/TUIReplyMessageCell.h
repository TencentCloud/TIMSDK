//
//  TUIReplyMessageCell.h
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//

#import "TUIBubbleMessageCell.h"

@class TUIReplyMessageCellData;
@class TUIReplyQuoteViewData;
@class TUIImageVideoReplyQuoteViewData;
@class TUIVoiceFileReplyQuoteViewData;
@class TUIMergeReplyQuoteViewData;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReplyMessageCell : TUIBubbleMessageCell

// 引用的边框
@property (nonatomic, strong) CALayer *quoteBorderLayer;
// 引用视图
@property (nonatomic, strong) UIView *quoteView;
// 回复的内容
@property (nonatomic, strong) UILabel *contentLabel;
// 原始消息发送者昵称
@property (nonatomic, strong) UILabel *senderLabel;


@property (nonatomic, strong) TUIReplyMessageCellData *replyData;

- (void)fillWithData:(TUIReplyMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
