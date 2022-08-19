//
//  TUIReferenceMessageCell.h
//  TUIChat
//
//  Created by wyl on 2022/5/24.
//

#import "TUIBubbleMessageCell.h"
@class TUIReplyMessageCellData;
@class TUIReplyQuoteViewData;
@class TUIImageVideoReplyQuoteViewData;
@class TUIVoiceFileReplyQuoteViewData;
@class TUIMergeReplyQuoteViewData;
@class TUIReferenceMessageCellData;
@class TUITextView;

NS_ASSUME_NONNULL_BEGIN
typedef void(^TUIReferenceSelectAllContentCallback)(BOOL);

@interface TUIReferenceMessageCell : TUIBubbleMessageCell
/**
 * 引用的边框
 * Border of quote view
 */
@property (nonatomic, strong) CALayer *quoteBorderLayer;

@property (nonatomic, strong) UIView *quoteView;

@property (nonatomic, strong) UILabel *senderLabel;

@property (nonatomic, strong) TUIReferenceMessageCellData *referenceData;

@property (nonatomic, strong) TUITextView *textView;
@property (nonatomic, strong) NSString *selectContent;
@property (nonatomic, strong) TUIReferenceSelectAllContentCallback selectAllContentContent;

- (void)fillWithData:(TUIReferenceMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
