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

@property (nonatomic, strong) CALayer *quoteBorderLayer;
@property (nonatomic, strong) UIView *quoteView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *senderLabel;


@property (nonatomic, strong) TUIReplyMessageCellData *replyData;

- (void)fillWithData:(TUIReplyMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
