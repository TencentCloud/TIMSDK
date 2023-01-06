//
//  TUIReplyMessageCell_Minimalist.h
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//

#import "TUIBubbleMessageCell_Minimalist.h"
#import "TUIChatDefine.h"

@class TUIReplyMessageCellData_Minimalist;
@class TUIReplyQuoteViewData_Minimalist;
@class TUIImageVideoReplyQuoteViewData_Minimalist;
@class TUIVoiceFileReplyQuoteViewData_Minimalist;
@class TUIMergeReplyQuoteViewData_Minimalist;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReplyMessageCell_Minimalist : TUIBubbleMessageCell_Minimalist

@property (nonatomic, strong) CALayer *quoteBorderLayer;
@property (nonatomic, strong) UIView *quoteView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *senderLabel;

@property (nonatomic, strong) TUIReplyMessageCellData_Minimalist *replyData;

- (void)fillWithData:(TUIReplyMessageCellData_Minimalist *)data;

@end

NS_ASSUME_NONNULL_END
