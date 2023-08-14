//
//  TUIReferenceMessageCell.m
//  TUIChat
//
//  Created by wyl on 2022/5/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReferenceMessageCell_Minimalist.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/UIView+TUILayout.h>
#import "TUIFileMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUILinkCellData.h"
#import "TUIMergeMessageCellData.h"
#import "TUIReplyMessageCellData.h"
#import "TUIReplyMessageCell_Minimalist.h"
#import "TUITextMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIVoiceMessageCellData.h"

#import "TUIFileReplyQuoteView_Minimalist.h"
#import "TUIImageReplyQuoteView_Minimalist.h"
#import "TUIMergeReplyQuoteView_Minimalist.h"
#import "TUIReplyQuoteView_Minimalist.h"
#import "TUITextMessageCell_Minimalist.h"
#import "TUITextReplyQuoteView_Minimalist.h"
#import "TUIVideoReplyQuoteView_Minimalist.h"
#import "TUIVoiceReplyQuoteView_Minimalist.h"

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

#define kReplyQuoteViewMaxWidth 175
#define kReplyQuoteViewMarginWidth 35


@interface TUIReferenceMessageCell_Minimalist () <UITextViewDelegate>
@property(nonatomic, strong) TUIReplyQuoteView_Minimalist *currentOriginView;

@property(nonatomic, strong) NSMutableDictionary<NSString *, TUIReplyQuoteView_Minimalist *> *customOriginViewsCache;

@end

@implementation TUIReferenceMessageCell_Minimalist
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self setupContentTextView];
    [self.quoteView addSubview:self.senderLabel];
    [self.contentView addSubview:self.quoteLineView];
    [self.contentView addSubview:self.quoteView];

    self.bottomContainer = [[UIView alloc] init];
    [self.contentView addSubview:self.bottomContainer];
}
- (void)setupContentTextView {
    self.textView = [[TUITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.scrollEnabled = NO;
    self.textView.editable = NO;
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:16.0];
    self.textView.textColor = TUIChatDynamicColor(@"chat_reference_message_content_text_color", @"#000000");

    [self.bubbleView addSubview:self.textView];
}

- (void)fillWithData:(TUIReferenceMessageCellData *)data {
    [super fillWithData:data];
    self.referenceData = data;

    self.senderLabel.text = [NSString stringWithFormat:@"%@:", data.sender];
    self.selectContent = data.content;
    self.textView.attributedText = [data.content getFormatEmojiStringWithFont:self.textView.font emojiLocations:self.referenceData.emojiLocations];

    UIImage *lineImage = nil;
    if (self.bubbleData.direction == MsgDirectionIncoming) {
        lineImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_reply_line_income")];
    } else {
        lineImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_reply_line_outcome")];
    }
    self.quoteLineView.image = [lineImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{10,0,20,0}") resizingMode:UIImageResizingModeStretch];

    self.bottomContainer.hidden = CGSizeEqualToSize(data.bottomContainerSize, CGSizeZero);

    @weakify(self);
    [[RACObserve(data, originMessage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(V2TIMMessage *originMessage) {
      @strongify(self);
      [self updateUI:data];
      [self layoutIfNeeded];
    }];

    [self layoutIfNeeded];
}

// Override
- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData {
    NSDictionary *param = @{TUICore_TUIChatExtension_BottomContainer_CellData : self.referenceData};
    [TUICore raiseExtension:TUICore_TUIChatExtension_BottomContainer_MinimalistExtensionID parentView:self.bottomContainer param:param];
}

- (void)updateUI:(TUIReferenceMessageCellData *)referenceData {
    self.currentOriginView = [self getCustomOriginView:referenceData.originCellData];
    [self hiddenAllCustomOriginViews:YES];
    self.currentOriginView.hidden = NO;

    [self.currentOriginView fillWithData:referenceData.quoteData];

    self.textView.frame = (CGRect){.origin = self.referenceData.textOrigin, .size = self.referenceData.textSize};

    if (referenceData.direction == MsgDirectionIncoming) {
        self.textView.textColor = TUIChatDynamicColor(@"chat_reference_message_content_recv_text_color", @"#000000");
        self.senderLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_recv_text_color", @"#888888");
        self.quoteView.backgroundColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_bg_color", @"#4444440c");
    } else {
        self.textView.textColor = TUIChatDynamicColor(@"chat_reference_message_content_text_color", @"#000000");
        self.senderLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_text_color", @"#888888");
        self.quoteView.backgroundColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_bg_color", @"#4444440c");
    }
    if (referenceData.textColor) {
        self.textView.textColor = referenceData.textColor;
    }

    CGFloat marginX = 6;
    CGFloat marginY = 8;

    self.senderLabel.mm_x = marginX;
    self.senderLabel.mm_y = marginY;
    self.senderLabel.mm_w = self.referenceData.senderSize.width + 4;
    self.senderLabel.mm_h = self.referenceData.senderSize.height;

    self.quoteView.mm_w = self.referenceData.quoteSize.width;
    self.quoteView.mm_h = self.referenceData.quoteSize.height;
    self.quoteView.mm_bottom(self.container.mm_b - self.quoteView.mm_h - self.replyEmojiView.mm_h - 6);
    if (self.referenceData.direction == MsgDirectionIncoming) {
        self.quoteView.mm_left(self.container.mm_x + 15);
    } else {
        self.quoteView.mm_right(self.container.mm_r + 15);
    }

    self.quoteLineView.mm_y = self.container.mm_maxY - 14;
    self.quoteLineView.mm_w = 17;
    self.quoteLineView.mm_h = self.quoteView.mm_centerY - self.quoteLineView.mm_y;
    if (self.referenceData.direction == MsgDirectionIncoming) {
        self.quoteLineView.mm_left(self.container.mm_x - 1);
    } else {
        self.quoteLineView.mm_right(self.container.mm_r);
    }

    self.currentOriginView.mm_y = marginY + 1;
    self.currentOriginView.mm_x = self.senderLabel.mm_w + self.senderLabel.mm_x + marginX;
    self.currentOriginView.mm_w = self.referenceData.quotePlaceholderSize.width;
    self.currentOriginView.mm_h = self.referenceData.quotePlaceholderSize.height;
}

- (TUIReplyQuoteView_Minimalist *)getCustomOriginView:(TUIMessageCellData *)originCellData {
    NSString *reuseId = originCellData ? NSStringFromClass(originCellData.class) : NSStringFromClass(TUITextMessageCellData.class);
    TUIReplyQuoteView_Minimalist *view = nil;
    BOOL reuse = NO;
    if ([self.customOriginViewsCache.allKeys containsObject:reuseId]) {
        view = [self.customOriginViewsCache objectForKey:reuseId];
        reuse = YES;
    }

    if (view == nil) {
        Class class = [originCellData getReplyQuoteViewClass];
        if (class) {
            view = [[class alloc] init];
        }
    }

    if (view == nil) {
        TUITextReplyQuoteView_Minimalist *quoteView = [[TUITextReplyQuoteView_Minimalist alloc] init];
        view = quoteView;
    }

    if ([view isKindOfClass:[TUITextReplyQuoteView_Minimalist class]]) {
        TUITextReplyQuoteView_Minimalist *quoteView = (TUITextReplyQuoteView_Minimalist *)view;
        if (self.referenceData.direction == MsgDirectionIncoming) {
            quoteView.textLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_recv_text_color", @"#888888");
        } else {
            quoteView.textLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_text_color", @"#888888");
        }
    } else if ([view isKindOfClass:[TUIMergeReplyQuoteView_Minimalist class]]) {
        TUIMergeReplyQuoteView_Minimalist *quoteView = (TUIMergeReplyQuoteView_Minimalist *)view;
        if (self.referenceData.direction == MsgDirectionIncoming) {
            quoteView.titleLabel.textColor = quoteView.subTitleLabel.textColor =
                TUIChatDynamicColor(@"chat_reference_message_quoteView_recv_text_color", @"#888888");
        } else {
            quoteView.titleLabel.textColor = quoteView.subTitleLabel.textColor =
                TUIChatDynamicColor(@"chat_reference_message_quoteView_text_color", @"#888888");
        }
    }

    if (!reuse) {
        [self.customOriginViewsCache setObject:view forKey:reuseId];
        [self.quoteView addSubview:view];
    }

    view.hidden = YES;
    return view;
}

- (void)hiddenAllCustomOriginViews:(BOOL)hidden {
    [self.customOriginViewsCache enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, TUIReplyQuoteView_Minimalist *_Nonnull obj, BOOL *_Nonnull stop) {
      obj.hidden = hidden;
      [obj reset];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self updateUI:self.referenceData];

    [self layoutBottomContainer];
}

- (void)layoutBottomContainer {
    if (CGSizeEqualToSize(self.referenceData.bottomContainerSize, CGSizeZero)) {
        return;
    }

    CGSize size = self.referenceData.bottomContainerSize;
    /// TransitionView should not cover the replyView.
    /// Add an extra tiny offset to the left or right of TransitionView if replyView is visible.
    CGFloat offset = self.quoteLineView.hidden ? 0 : 1;
    UIView *view = self.replyEmojiView.hidden ? self.bubbleView : self.replyEmojiView;
    CGFloat topMargin = view.mm_maxY + self.nameLabel.mm_h + 6;

    if (self.referenceData.direction == MsgDirectionOutgoing) {
        self.bottomContainer.mm_top(topMargin).mm_width(size.width).mm_height(size.height).mm_right(self.mm_w - self.container.mm_maxX);
    } else {
        self.bottomContainer.mm_top(topMargin).mm_width(size.width).mm_height(size.height).mm_left(self.container.mm_minX);
    }
    if (!self.quoteView.hidden) {
        CGRect oldRect = self.quoteView.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.bottomContainer.frame) + 5, oldRect.size.width, oldRect.size.height);
        self.quoteView.frame = newRect;
    }
    if (!self.messageModifyRepliesButton.hidden) {
        CGRect oldRect = self.messageModifyRepliesButton.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.quoteView.frame) + 5, oldRect.size.width, oldRect.size.height);
        self.messageModifyRepliesButton.frame = newRect;
    }
    for (UIView *view in self.replyAvatarImageViews) {
        CGRect oldRect = view.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.quoteView.frame) + 5, oldRect.size.width, oldRect.size.height);
        view.frame = newRect;
    }
    if (!self.quoteLineView.hidden) {
        CGRect oldRect = self.quoteLineView.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y, oldRect.size.width, oldRect.size.height + self.bottomContainer.mm_h);
        self.quoteLineView.frame = newRect;
    }
}

- (UILabel *)senderLabel {
    if (_senderLabel == nil) {
        _senderLabel = [[UILabel alloc] init];
        _senderLabel.text = @"harvy:";
        _senderLabel.font = [UIFont systemFontOfSize:12.0];
        _senderLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_sender_text_color", @"#888888");
    }
    return _senderLabel;
}

- (UIImageView *)quoteLineView {
    if (_quoteLineView == nil) {
        _quoteLineView = [[UIImageView alloc] init];
    }
    return _quoteLineView;
}

- (UIView *)quoteView {
    if (_quoteView == nil) {
        _quoteView = [[UIView alloc] init];
        _quoteView.backgroundColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_bg_color", @"#4444440c");
        _quoteView.layer.cornerRadius = 10.0;
        _quoteView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quoteViewOnTap)];
        [_quoteView addGestureRecognizer:tap];
    }
    return _quoteView;
}

- (void)quoteViewOnTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectMessage:)]) {
        [self.delegate onSelectMessage:self];
    }
}

- (NSMutableDictionary *)customOriginViewsCache {
    if (_customOriginViewsCache == nil) {
        _customOriginViewsCache = [[NSMutableDictionary alloc] init];
    }
    return _customOriginViewsCache;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSAttributedString *selectedString = [textView.attributedText attributedSubstringFromRange:textView.selectedRange];
    if (self.selectAllContentContent && selectedString) {
        if (selectedString.length == textView.attributedText.length) {
            self.selectAllContentContent(YES);
        } else {
            self.selectAllContentContent(NO);
        }
    }
    if (selectedString.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        [attributedString appendAttributedString:selectedString];
        NSUInteger offsetLocation = 0;
        for (NSDictionary *emojiLocation in self.referenceData.emojiLocations) {
            NSValue *key = emojiLocation.allKeys.firstObject;
            NSAttributedString *originStr = emojiLocation[key];
            NSRange currentRange = [key rangeValue];
            currentRange.location += offsetLocation;
            if (currentRange.location >= textView.selectedRange.location) {
                currentRange.location -= textView.selectedRange.location;
                if (currentRange.location + currentRange.length <= attributedString.length) {
                    [attributedString replaceCharactersInRange:currentRange withAttributedString:originStr];
                    offsetLocation += originStr.length - currentRange.length;
                }
            }
        }
        self.selectContent = attributedString.string;
    } else {
        self.selectContent = nil;
    }
}

#pragma mark - TUIMessageCellProtocol
+ (CGFloat)getHeight:(TUIMessageCellData *)data withWidth:(CGFloat)width {
    NSAssert([data isKindOfClass:TUIReferenceMessageCellData.class], @"data must be kind of TUIReferenceMessageCellData");
    TUIReferenceMessageCellData *referenceCellData = (TUIReferenceMessageCellData *)data;
    
    CGFloat cellHeight = [super getHeight:referenceCellData withWidth:width];
    cellHeight += referenceCellData.quoteSize.height + referenceCellData.bottomContainerSize.height;
    cellHeight += kScale375(6);
    return cellHeight;
}

+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUIReferenceMessageCellData.class], @"data must be kind of TUIReferenceMessageCellData");
    TUIReferenceMessageCellData *referenceCellData = (TUIReferenceMessageCellData *)data;
    
    CGFloat quoteHeight = 0;
    CGFloat quoteWidth = 0;
    CGFloat quoteMaxWidth = kReplyQuoteViewMaxWidth;
    CGFloat quotePlaceHolderMarginWidth = 12;

    // 动态计算发送者的尺寸
    // Calculate the size of label which displays the sender's displayname
    CGSize senderSize = [@"0" sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}];
    CGRect senderRect = [referenceCellData.sender boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}
                                                               context:nil];
    // 动态计算自定义引用占位视图的尺寸
    // Calculate the size of customize quote placeholder view
    CGSize placeholderSize = [referenceCellData quotePlaceholderSizeWithType:referenceCellData.originMsgType data:referenceCellData.quoteData];

    // 动态计算回复内容的尺寸
    // Calculate the size of label which displays the content of replying the original message
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    NSAttributedString *attributeString = [referenceCellData.content getFormatEmojiStringWithFont:textFont emojiLocations:nil];

    CGRect replyContentRect = [attributeString boundingRectWithSize:CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT)
                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            context:nil];
    CGSize size = CGSizeMake(CGFLOAT_CEIL(replyContentRect.size.width), CGFLOAT_CEIL(replyContentRect.size.height));

    CGRect replyContentRect2 = [attributeString boundingRectWithSize:CGSizeMake(MAXFLOAT, [textFont lineHeight])
                                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                             context:nil];
    CGSize size2 = replyContentRect2.size;

    // 如果有多行，判断下最后一行的宽度是否超过了消息状态的位置，如果超过，消息状态换行
    // 如果只有一行，需要加上消息状态的宽度
    if ((int)size2.width / (int)TTextMessageCell_Text_Width_Max > 0) {
        if ((int)size2.width % (int)TTextMessageCell_Text_Width_Max > TTextMessageCell_Text_Width_Max - referenceCellData.msgStatusSize.width) {
            size.height += referenceCellData.msgStatusSize.height;
        }
    } else {
        size.width += referenceCellData.msgStatusSize.width + kScale390(10);
    }

    referenceCellData.textSize = size;
    CGFloat y = referenceCellData.cellLayout.bubbleInsets.top + [TUIBubbleMessageCell_Minimalist getBubbleTop:referenceCellData];
    referenceCellData.textOrigin = CGPointMake(referenceCellData.cellLayout.bubbleInsets.left, y);

    size.height += referenceCellData.cellLayout.bubbleInsets.top + referenceCellData.cellLayout.bubbleInsets.bottom;
    size.width += referenceCellData.cellLayout.bubbleInsets.left + referenceCellData.cellLayout.bubbleInsets.right;

    if (referenceCellData.direction == MsgDirectionIncoming) {
        size.height = MAX(size.height, TUIBubbleMessageCell_Minimalist.incommingBubble.size.height);
    } else {
        size.height = MAX(size.height, TUIBubbleMessageCell_Minimalist.outgoingBubble.size.height);
    }

    quoteWidth = senderRect.size.width;
    quoteWidth += placeholderSize.width;
    quoteWidth += (quotePlaceHolderMarginWidth * 2);

    quoteHeight = MAX(senderRect.size.height, placeholderSize.height);
    quoteHeight += (8 + 8);

    referenceCellData.senderSize = CGSizeMake(senderRect.size.width, senderRect.size.height);
    referenceCellData.quotePlaceholderSize = placeholderSize;
    //    self.replyContentSize = CGSizeMake(replyContentRect.size.width, replyContentRect.size.height);
    referenceCellData.quoteSize = CGSizeMake(quoteWidth, quoteHeight);

    return size;
}

@end
