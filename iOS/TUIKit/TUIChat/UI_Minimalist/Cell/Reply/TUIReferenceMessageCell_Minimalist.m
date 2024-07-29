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
    self.senderLabel.rtlAlignment = TUITextRTLAlignmentLeading;
    self.selectContent = data.content;
    self.textView.attributedText = [data.content getFormatEmojiStringWithFont:self.textView.font emojiLocations:self.referenceData.emojiLocations];

    if (isRTL()) {
        self.textView.textAlignment = NSTextAlignmentRight;
    }
    else {
        self.textView.textAlignment = NSTextAlignmentLeft;
    }
    
    UIImage *lineImage = nil;
    if (self.bubbleData.direction == MsgDirectionIncoming) {
        lineImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_reply_line_income")];
    } else {
        lineImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_reply_line_outcome")];
    }
    lineImage = [lineImage rtl_imageFlippedForRightToLeftLayoutDirection];
    
    UIEdgeInsets ei = UIEdgeInsetsFromString(@"{10,0,20,0}");
    ei = rtlEdgeInsetsWithInsets(ei);
    self.quoteLineView.image = [lineImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];

    self.bottomContainer.hidden = CGSizeEqualToSize(data.bottomContainerSize, CGSizeZero);

    @weakify(self);
    [[RACObserve(data, originMessage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(V2TIMMessage *originMessage) {
      @strongify(self);
        // tell constraints they need updating
        [self setNeedsUpdateConstraints];

        // update constraints now so we can animate the change
        [self updateConstraintsIfNeeded];

        [self layoutIfNeeded];
    }];

    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

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
    
    referenceData.quoteData.supportForReply = NO;
    referenceData.quoteData.showRevokedOriginMessage = referenceData.showRevokedOriginMessage;
    [self.currentOriginView fillWithData:referenceData.quoteData];

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
    
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bubbleView.mas_leading).mas_offset(self.referenceData.textOrigin.x);
        make.top.mas_equalTo(self.bubbleView.mas_top).mas_offset(self.referenceData.textOrigin.y);
        make.size.mas_equalTo(self.referenceData.textSize);
    }];
    
    [self.quoteView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.referenceData.direction == MsgDirectionIncoming) {
            make.leading.mas_equalTo(self.bubbleView).mas_offset(15);
        }
        else {
            make.trailing.mas_equalTo(self.bubbleView).mas_offset(- 15);
        }
        make.top.mas_equalTo(self.bubbleView.mas_bottom).mas_offset(self.messageData.messageContainerAppendSize.height + 6);
        make.size.mas_equalTo(self.referenceData.quoteSize);
    }];
    
    [self.senderLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.quoteView).mas_offset(6);
        make.top.mas_equalTo(self.quoteView).mas_offset(8);
        make.width.mas_equalTo(referenceData.senderSize.width);
        make.height.mas_equalTo(referenceData.senderSize.height);
    }];
    
    BOOL hideSenderLabel = (referenceData.originCellData.innerMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) &&
                            !referenceData.showRevokedOriginMessage;
    if (hideSenderLabel) {
        self.senderLabel.hidden = YES;
    } else {
        self.senderLabel.hidden = NO;
    }

    [self.currentOriginView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (hideSenderLabel) {
            make.leading.mas_equalTo(self.quoteView).mas_offset(6);
            make.top.mas_equalTo(self.quoteView).mas_offset(8);
            make.trailing.mas_lessThanOrEqualTo(self.quoteView.mas_trailing);
            make.height.mas_equalTo(self.referenceData.quotePlaceholderSize.height);
        }
        else {
            make.leading.mas_equalTo(self.senderLabel.mas_trailing).mas_offset(4);
            make.top.mas_equalTo(self.senderLabel.mas_top).mas_offset(1);
            make.trailing.mas_lessThanOrEqualTo(self.quoteView.mas_trailing);
            make.height.mas_equalTo(self.referenceData.quotePlaceholderSize.height);
        }
    }];
    
    [self.quoteLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bubbleView.mas_bottom);
        make.bottom.mas_equalTo(self.quoteView.mas_centerY);
        make.width.mas_equalTo(17);
        if (self.referenceData.direction == MsgDirectionIncoming) {
            make.leading.mas_equalTo(self.container.mas_leading).mas_offset(- 1);
        } else {
            make.trailing.mas_equalTo(self.container.mas_trailing);
        }
    }];


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
        NSString *clsStr = NSStringFromClass(class);
        if (![clsStr tui_containsString:@"_Minimalist"]) {
            clsStr = [clsStr stringByAppendingString:@"_Minimalist"];
            class =  NSClassFromString(clsStr);
        }
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
            quoteView.titleLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_recv_text_color", @"#888888");
        } else {
            quoteView.titleLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_text_color", @"#888888");
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

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    
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
    CGFloat offset = self.quoteLineView.hidden ? 0 : 2;

    [self.bottomContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.referenceData.direction == MsgDirectionIncoming) {
            make.leading.mas_equalTo(self.container.mas_leading).mas_offset(offset);
        } else {
            make.trailing.mas_equalTo(self.container.mas_trailing).mas_offset(-offset);
        }
        make.top.mas_equalTo(self.quoteView.mas_bottom).mas_offset(6);
        make.size.mas_equalTo(size);
    }];
    
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
    if (referenceCellData.bottomContainerSize.height > 0) {
        cellHeight += kScale375(6);
    }
    cellHeight += kScale375(6);
    return cellHeight;
}

+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUIReferenceMessageCellData.class], @"data must be kind of TUIReferenceMessageCellData");
    TUIReferenceMessageCellData *referenceCellData = (TUIReferenceMessageCellData *)data;
    
    CGFloat quoteHeight = 0;
    CGFloat quoteWidth = 0;
    CGFloat quoteMaxWidth = TReplyQuoteView_Max_Width;
    CGFloat quotePlaceHolderMarginWidth = 12;
    
    // Calculate the size of label which displays the sender's displayname
    CGSize senderSize = [@"0" sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}];
    CGRect senderRect = [[NSString stringWithFormat:@"%@:",referenceCellData.sender] boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}
                                                               context:nil];
    
    // Calculate the size of revoke string
    CGRect messageRevokeRect = CGRectZero;
    bool showRevokeStr = (referenceCellData.originCellData.innerMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) &&
                            !referenceCellData.showRevokedOriginMessage;
    if (showRevokeStr) {
        NSString *msgRevokeStr = TIMCommonLocalizableString(TUIKitReferenceOriginMessageRevoke);
        messageRevokeRect = [msgRevokeStr boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                    attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}
                                                       context:nil];
    }

    // Calculate the size of customize quote placeholder view
    CGSize placeholderSize = [referenceCellData quotePlaceholderSizeWithType:referenceCellData.originMsgType data:referenceCellData.quoteData];

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

    // If there are multiple lines, determine whether the font width of the last line exceeds the position of the message status. If so, the message status will wrap.
    // If there is only one line, directly add the width of the message status
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

    if (showRevokeStr) {
        quoteWidth = messageRevokeRect.size.width;
        quoteHeight =  MAX(senderRect.size.height, placeholderSize.height);
        quoteHeight += (8 + 8);
    }
    
    referenceCellData.senderSize = CGSizeMake(CGFLOAT_CEIL(senderRect.size.width)+3, senderRect.size.height);
    referenceCellData.quotePlaceholderSize = CGSizeMake(CGFLOAT_CEIL(placeholderSize.width), placeholderSize.height);
    //    self.replyContentSize = CGSizeMake(replyContentRect.size.width, replyContentRect.size.height);
    referenceCellData.quoteSize = CGSizeMake(CGFLOAT_CEIL(quoteWidth), quoteHeight);

    return size;
}

@end
