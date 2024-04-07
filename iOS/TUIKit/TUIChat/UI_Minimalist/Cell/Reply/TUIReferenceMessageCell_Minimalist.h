//
//  TUIReferenceMessageCell_Minimalist.h
//  TUIChat
//
//  Created by wyl on 2022/5/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIBubbleMessageCell_Minimalist.h>
#import "TUIChatDefine.h"

@class TUIReplyMessageCellData;
@class TUIReplyQuoteViewData;
@class TUIImageVideoReplyQuoteViewData;
@class TUIVoiceFileReplyQuoteViewData;
@class TUIMergeReplyQuoteViewData;
@class TUIReferenceMessageCellData;
@class TUITextView;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReferenceMessageCell_Minimalist : TUIBubbleMessageCell_Minimalist
/**
 * 
 * Border of quote view
 */
@property(nonatomic, strong) CALayer *quoteBorderLayer;

@property(nonatomic, strong) UIImageView *quoteLineView;

@property(nonatomic, strong) UIView *quoteView;

@property(nonatomic, strong) UILabel *senderLabel;

@property(nonatomic, strong) TUIReferenceMessageCellData *referenceData;

@property(nonatomic, strong) TUITextView *textView;
@property(nonatomic, strong) NSString *selectContent;
@property(nonatomic, strong) TUIReferenceSelectAllContentCallback selectAllContentContent;

- (void)fillWithData:(TUIReferenceMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
