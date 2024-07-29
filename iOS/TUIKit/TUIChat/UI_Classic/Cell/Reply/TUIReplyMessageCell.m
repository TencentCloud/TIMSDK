//
//  TUIReplyMessageCell.m
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReplyMessageCell.h"
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
#import "TUITextMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIVoiceMessageCellData.h"

#import "TUIFileReplyQuoteView.h"
#import "TUIImageReplyQuoteView.h"
#import "TUIMergeReplyQuoteView.h"
#import "TUIReplyQuoteView.h"
#import "TUITextReplyQuoteView.h"
#import "TUIVideoReplyQuoteView.h"
#import "TUIVoiceReplyQuoteView.h"

@interface TUIReplyMessageCell () <UITextViewDelegate>

@property(nonatomic, strong) TUIReplyQuoteView *currentOriginView;

@property(nonatomic, strong) NSMutableDictionary<NSString *, TUIReplyQuoteView *> *customOriginViewsCache;

@end

@implementation TUIReplyMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.quoteView addSubview:self.senderLabel];
    [self.quoteView addSubview:self.quoteBorderLine];

    [self.bubbleView addSubview:self.quoteView];
    [self.bubbleView addSubview:self.textView];

    self.bottomContainer = [[UIView alloc] init];
    [self.contentView addSubview:self.bottomContainer];
}

// Override
- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData {
    NSDictionary *param = @{TUICore_TUIChatExtension_BottomContainer_CellData : self.replyData};
    [TUICore raiseExtension:TUICore_TUIChatExtension_BottomContainer_ClassicExtensionID parentView:self.bottomContainer param:param];
}

- (void)fillWithData:(TUIReplyMessageCellData *)data {
    [super fillWithData:data];
    self.replyData = data;
    self.senderLabel.text = [NSString stringWithFormat:@"%@:", data.sender];
    self.textView.attributedText = [data.content getFormatEmojiStringWithFont:self.textView.font emojiLocations:self.replyData.emojiLocations];
    self.bottomContainer.hidden = CGSizeEqualToSize(data.bottomContainerSize, CGSizeZero);
    
    if (data.direction == MsgDirectionIncoming) {
        self.textView.textColor = TUIChatDynamicColor(@"chat_reply_message_content_recv_text_color", @"#000000");
        self.senderLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_recv_text_color", @"#888888");
        self.quoteView.backgroundColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_bg_color", @"#4444440c");
    } else {
        self.textView.textColor = TUIChatDynamicColor(@"chat_reply_message_content_text_color", @"#000000");
        self.senderLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_text_color", @"#888888");
        self.quoteView.backgroundColor = [UIColor colorWithRed:68 / 255.0 green:68 / 255.0 blue:68 / 255.0 alpha:0.05];
    }

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

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    
    [self updateUI:self.replyData];
    
    [self layoutBottomContainer];

}

- (void)updateUI:(TUIReplyMessageCellData *)replyData {
    self.currentOriginView = [self getCustomOriginView:replyData.originCellData];
    [self hiddenAllCustomOriginViews:YES];
    self.currentOriginView.hidden = NO;

    replyData.quoteData.supportForReply = YES;
    replyData.quoteData.showRevokedOriginMessage = replyData.showRevokedOriginMessage;
    [self.currentOriginView fillWithData:replyData.quoteData];

    [self.quoteView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bubbleView).mas_offset(16);
        make.top.mas_equalTo(12);
        make.trailing.mas_lessThanOrEqualTo(self.bubbleView).mas_offset(-16);
        make.width.mas_greaterThanOrEqualTo(self.senderLabel);
        make.height.mas_equalTo(self.replyData.quoteSize.height);
    }];

    [self.quoteBorderLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.quoteView);
        make.top.mas_equalTo(self.quoteView);
        make.width.mas_equalTo(3);
        make.bottom.mas_equalTo(self.quoteView);
    }];
    
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.quoteView).mas_offset(4);
        make.top.mas_equalTo(self.quoteView.mas_bottom).mas_offset(12);
        make.trailing.mas_lessThanOrEqualTo(self.quoteView).mas_offset(-4);;
        make.bottom.mas_equalTo(self.bubbleView).mas_offset(-4);
    }];

    BOOL hasRiskContent = self.messageData.innerMessage.hasRiskContent;
    if (hasRiskContent ) {
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.quoteView).mas_offset(4);
            make.top.mas_equalTo(self.quoteView.mas_bottom).mas_offset(12);
            make.trailing.mas_lessThanOrEqualTo(self.quoteView).mas_offset(-4);
            make.size.mas_equalTo(self.replyData.replyContentSize);
        }];
        
        [self.securityStrikeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.textView.mas_bottom);
            make.width.mas_equalTo(self.bubbleView);
            make.bottom.mas_equalTo(self.container);
        }];
    }
    
    [self.senderLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.textView);
        make.top.mas_equalTo(3);
        make.size.mas_equalTo(self.replyData.senderSize);
    }];
    
    BOOL hideSenderLabel = (replyData.originCellData.innerMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) &&
                            !replyData.showRevokedOriginMessage;
    if (hideSenderLabel) {
        self.senderLabel.hidden = YES;
    } else {
        self.senderLabel.hidden = NO;
    }

    [self.currentOriginView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.senderLabel);
        if (hideSenderLabel) {
            make.centerY.mas_equalTo(self.quoteView);
        } else {
            make.top.mas_equalTo(self.senderLabel.mas_bottom).mas_offset(4);
        }
//        make.width.mas_greaterThanOrEqualTo(self.replyData.quotePlaceholderSize);
        make.trailing.mas_lessThanOrEqualTo(self.quoteView.mas_trailing);
        make.height.mas_equalTo(self.replyData.quotePlaceholderSize);
    }];
}

- (TUIReplyQuoteView *)getCustomOriginView:(TUIMessageCellData *)originCellData {
    NSString *reuseId = originCellData ? NSStringFromClass(originCellData.class) : NSStringFromClass(TUITextMessageCellData.class);
    TUIReplyQuoteView *view = nil;
    BOOL reuse = NO;
    BOOL hasRiskContent = originCellData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        reuseId = @"hasRiskContent";
    }
    if ([self.customOriginViewsCache.allKeys containsObject:reuseId]) {
        view = [self.customOriginViewsCache objectForKey:reuseId];
        reuse = YES;
    }
    
    if (hasRiskContent && view == nil){
        TUITextReplyQuoteView *quoteView = [[TUITextReplyQuoteView alloc] init];
        view = quoteView;
    }
    
    if (view == nil) {
        Class class = [originCellData getReplyQuoteViewClass];
        if (class) {
            view = [[class alloc] init];
        }
    }

    if (view == nil) {
        TUITextReplyQuoteView *quoteView = [[TUITextReplyQuoteView alloc] init];
        view = quoteView;
    }

    if ([view isKindOfClass:[TUITextReplyQuoteView class]]) {
        TUITextReplyQuoteView *quoteView = (TUITextReplyQuoteView *)view;
        if (self.replyData.direction == MsgDirectionIncoming) {
            quoteView.textLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_recv_text_color", @"#888888");
        } else {
            quoteView.textLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_text_color", @"#888888");
        }
    } else if ([view isKindOfClass:[TUIMergeReplyQuoteView class]]) {
        TUIMergeReplyQuoteView *quoteView = (TUIMergeReplyQuoteView *)view;
        if (self.replyData.direction == MsgDirectionIncoming) {
            quoteView.titleLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_recv_text_color", @"#888888");
        } else {
            quoteView.titleLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_text_color", @"#888888");
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
    [self.customOriginViewsCache enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, TUIReplyQuoteView *_Nonnull obj, BOOL *_Nonnull stop) {
      obj.hidden = hidden;
      [obj reset];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

}

- (void)layoutBottomContainer {
    if (CGSizeEqualToSize(self.replyData.bottomContainerSize, CGSizeZero)) {
        return;
    }

    CGSize size = self.replyData.bottomContainerSize;
    CGFloat topMargin = self.bubbleView.mm_maxY + self.nameLabel.mm_h + 8;
    [self.bottomContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bubbleView.mas_bottom).mas_offset(8);
        make.size.mas_equalTo(size);
        if (self.replyData.direction == MsgDirectionOutgoing) {
            make.trailing.mas_equalTo(self.container);
        }
        else {
            make.leading.mas_equalTo(self.container);
        }
    }];
    
    if (!self.messageModifyRepliesButton.hidden) {
        CGRect oldRect = self.messageModifyRepliesButton.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.bottomContainer.frame), oldRect.size.width, oldRect.size.height);
        self.messageModifyRepliesButton.frame = newRect;
    }
}

- (UILabel *)senderLabel {
    if (_senderLabel == nil) {
        _senderLabel = [[UILabel alloc] init];
        _senderLabel.text = @"harvy:";
        _senderLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _senderLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_sender_text_color", @"#888888");
        _senderLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
    }
    return _senderLabel;
}

- (UIView *)quoteView {
    if (_quoteView == nil) {
        _quoteView = [[UIView alloc] init];
        _quoteView.backgroundColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_bg_color", @"#4444440c");
    }
    return _quoteView;
}

- (UIView *)quoteBorderLine {
    if (_quoteBorderLine == nil) {
        _quoteBorderLine = [[UIView alloc] init];
        _quoteBorderLine.backgroundColor = [UIColor colorWithRed:68 / 255.0 green:68 / 255.0 blue:68 / 255.0 alpha:0.1];
    }
    return _quoteBorderLine;
}

- (TUITextView *)textView {
    if (_textView == nil) {
        _textView = [[TUITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:16.0];
        _textView.textColor = TUIChatDynamicColor(@"chat_reply_message_content_text_color", @"#000000");
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.scrollEnabled = NO;
        _textView.editable = NO;
        _textView.delegate = self;
        _textView.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
    }
    return _textView;
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
        for (NSDictionary *emojiLocation in self.replyData.emojiLocations) {
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
    NSAssert([data isKindOfClass:TUIReplyMessageCellData.class], @"data must be kind of TUIReplyMessageCellData");
    TUIReplyMessageCellData *replyCellData = (TUIReplyMessageCellData *)data;
    
    CGFloat height = [super getHeight:replyCellData withWidth:width];

    if (replyCellData.bottomContainerSize.height > 0) {
        height += replyCellData.bottomContainerSize.height + kScale375(6);
    }

    return height;
}

+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUIReplyMessageCellData.class], @"data must be kind of TUIReplyMessageCellData");
    TUIReplyMessageCellData *replyCellData = (TUIReplyMessageCellData *)data;
    
    CGFloat height = 0;
    CGFloat quoteHeight = 0;
    CGFloat quoteWidth = 0;

    CGFloat quoteMinWidth = 100;
    CGFloat quoteMaxWidth = TReplyQuoteView_Max_Width;
    CGFloat quotePlaceHolderMarginWidth = 12;

    // Calculate the size of label which displays the sender's displyname
    CGSize senderSize = [@"0" sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}];
    CGRect senderRect = [replyCellData.sender boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}
                                                  context:nil];
    
    //  Calculate the size of revoke string
    CGRect messageRevokeRect = CGRectZero;
    BOOL showRevokeStr = (replyCellData.originCellData.innerMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) &&
                            !replyCellData.showRevokedOriginMessage;
    if (showRevokeStr) {
        NSString *msgRevokeStr = TIMCommonLocalizableString(TUIKitRepliesOriginMessageRevoke);
        messageRevokeRect = [msgRevokeStr boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}
                                                                   context:nil];
    }

    // Calculate the size of customize quote placeholder view
    CGSize placeholderSize = [replyCellData quotePlaceholderSizeWithType:replyCellData.originMsgType data:replyCellData.quoteData];

    // Calculate the size of label which displays the content of replying the original message
    NSAttributedString *attributeString = [replyCellData.content getFormatEmojiStringWithFont:[UIFont systemFontOfSize:16.0] emojiLocations:nil];
    CGRect replyContentRect = [attributeString boundingRectWithSize:CGSizeMake(quoteMaxWidth, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            context:nil];

    // 
    // Calculate the size of quote view base the content
    quoteWidth = senderRect.size.width;
    if (quoteWidth < placeholderSize.width) {
        quoteWidth = placeholderSize.width;
    }
    if (quoteWidth < replyContentRect.size.width) {
        quoteWidth = replyContentRect.size.width;
    }
    quoteWidth += quotePlaceHolderMarginWidth;
    if (quoteWidth > quoteMaxWidth) {
        quoteWidth = quoteMaxWidth;
    }
    if (quoteWidth < quoteMinWidth) {
        quoteWidth = quoteMinWidth;
    }
    if (showRevokeStr) {
        quoteWidth = MAX(quoteWidth, messageRevokeRect.size.width);
    }
    
    quoteHeight = 3 + senderRect.size.height + 4 + placeholderSize.height + 6;

    replyCellData.senderSize = CGSizeMake(quoteWidth, senderRect.size.height);
    replyCellData.quotePlaceholderSize = placeholderSize;
    replyCellData.replyContentSize = CGSizeMake(replyContentRect.size.width, replyContentRect.size.height);
    replyCellData.quoteSize = CGSizeMake(quoteWidth, quoteHeight);

    //  cell 
    // Calculate the height of cell
    height = 12 + quoteHeight + 12 + replyCellData.replyContentSize.height + 12;
    
    CGSize size = CGSizeMake(quoteWidth + TReplyQuoteView_Margin_Width, height);
    
    BOOL hasRiskContent = replyCellData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        size.width = MAX(size.width, 200);// width must more than  TIMCommonLocalizableString(TUIKitMessageTypeSecurityStrike)
        size.height += kTUISecurityStrikeViewTopLineMargin;
        size.height += kTUISecurityStrikeViewTopLineToBottom;
    }
    return size;
}

@end
