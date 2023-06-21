//
//  TUIReferenceMessageCell_Minimalist.h
//  TUIChat
//
//  Created by wyl on 2022/5/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIBubbleMessageCell_Minimalist.h>
#import "TUIChatDefine.h"

@class TUIReplyMessageCellData_Minimalist;
@class TUIReplyQuoteViewData_Minimalist;
@class TUIImageVideoReplyQuoteViewData_Minimalist;
@class TUIVoiceFileReplyQuoteViewData_Minimalist;
@class TUIMergeReplyQuoteViewData_Minimalist;
@class TUIReferenceMessageCellData_Minimalist;
@class TUITextView;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReferenceMessageCell_Minimalist : TUIBubbleMessageCell_Minimalist
/**
 * 引用的边框
 * Border of quote view
 */
@property(nonatomic, strong) CALayer *quoteBorderLayer;

@property(nonatomic, strong) UIImageView *quoteLineView;

@property(nonatomic, strong) UIView *quoteView;

@property(nonatomic, strong) UILabel *senderLabel;

@property(nonatomic, strong) TUIReferenceMessageCellData_Minimalist *referenceData;

@property(nonatomic, strong) TUITextView *textView;
@property(nonatomic, strong) NSString *selectContent;
@property(nonatomic, strong) TUIReferenceSelectAllContentCallback selectAllContentContent;

- (void)fillWithData:(TUIReferenceMessageCellData_Minimalist *)data;

@end

NS_ASSUME_NONNULL_END
