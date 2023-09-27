//
//  TUIReplyMessageCell_Minimalist.h
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIBubbleMessageCell_Minimalist.h>
#import "TUIChatDefine.h"

@class TUIReplyMessageCellData;
@class TUIReplyQuoteViewData;
@class TUIImageVideoReplyQuoteViewData;
@class TUIVoiceFileReplyQuoteViewData;
@class TUIMergeReplyQuoteViewData;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReplyMessageCell_Minimalist : TUIBubbleMessageCell_Minimalist

@property(nonatomic, strong) UIView *quoteBorderLine;
@property(nonatomic, strong) UIView *quoteView;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UILabel *senderLabel;

@property(nonatomic, strong) TUIReplyMessageCellData *replyData;

- (void)fillWithData:(TUIReplyMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
