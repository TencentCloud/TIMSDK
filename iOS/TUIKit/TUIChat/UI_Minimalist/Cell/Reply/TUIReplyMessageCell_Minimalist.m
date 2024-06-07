//
//  TUIReplyMessageCell.m
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReplyMessageCell_Minimalist.h"
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

#import "TUIFileReplyQuoteView_Minimalist.h"
#import "TUIImageReplyQuoteView_Minimalist.h"
#import "TUIMergeReplyQuoteView_Minimalist.h"
#import "TUIReplyQuoteView_Minimalist.h"
#import "TUITextReplyQuoteView_Minimalist.h"
#import "TUIVideoReplyQuoteView_Minimalist.h"
#import "TUIVoiceReplyQuoteView_Minimalist.h"

#define kReplyQuoteViewMaxWidth 175
#define kReplyQuoteViewMarginWidth 35

@interface TUIReplyMessageCell_Minimalist ()

@property(nonatomic, strong) TUIReplyQuoteView_Minimalist *currentOriginView;

@property(nonatomic, strong) NSMutableDictionary<NSString *, TUIReplyQuoteView_Minimalist *> *customOriginViewsCache;

@end

@implementation TUIReplyMessageCell_Minimalist

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
    [self.bubbleView addSubview:self.contentLabel];

    self.bottomContainer = [[UIView alloc] init];
    [self.contentView addSubview:self.bottomContainer];
}

// Override
- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData {
    NSDictionary *param = @{TUICore_TUIChatExtension_BottomContainer_CellData : self.replyData};
    [TUICore raiseExtension:TUICore_TUIChatExtension_BottomContainer_MinimalistExtensionID parentView:self.bottomContainer param:param];
}

- (void)fillWithData:(TUIReplyMessageCellData *)data {
    [super fillWithData:data];
    self.replyData = data;

    self.senderLabel.text = [NSString stringWithFormat:@"%@:", data.sender];
    if (data.direction == MsgDirectionIncoming) {
        self.contentLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_content_recv_text_color", @"#000000");
        self.senderLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_recv_text_color", @"#888888");
        self.quoteView.backgroundColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_bg_color", @"#4444440c");
    } else {
        self.contentLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_content_text_color", @"#000000");
        self.senderLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_text_color", @"#888888");
        self.quoteView.backgroundColor = [UIColor colorWithRed:68 / 255.0 green:68 / 255.0 blue:68 / 255.0 alpha:0.05];
    }
    self.contentLabel.attributedText = [data.content getFormatEmojiStringWithFont:self.contentLabel.font emojiLocations:nil];

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
    BOOL hasOriginMsgRevoke = (replyData.originCellData.innerMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED);
    
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

    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.quoteView).mas_offset(4);
        make.top.mas_equalTo(self.quoteView.mas_bottom).mas_offset(12);
        make.trailing.mas_lessThanOrEqualTo(self.quoteView);
    }];

    [self.senderLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentLabel);
        make.top.mas_equalTo(3);
        make.size.mas_equalTo(self.replyData.senderSize);
    }];

    if (hasOriginMsgRevoke) {
        self.senderLabel.hidden = YES;
    }
    else {
        self.senderLabel.hidden = NO;
    }

    
    [self.currentOriginView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.senderLabel);
        if (hasOriginMsgRevoke) {
            make.centerY.mas_equalTo(self.quoteView);
        }
        else {
            make.top.mas_equalTo(self.senderLabel.mas_bottom).mas_offset(4);
        }
//        make.width.mas_greaterThanOrEqualTo(self.replyData.quotePlaceholderSize);
        make.trailing.mas_lessThanOrEqualTo(self.quoteView.mas_trailing);
        make.height.mas_equalTo(self.replyData.quotePlaceholderSize);
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
        if (self.replyData.direction == MsgDirectionIncoming) {
            quoteView.textLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_recv_text_color", @"#888888");
        } else {
            quoteView.textLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_text_color", @"#888888");
        }
    } else if ([view isKindOfClass:[TUIMergeReplyQuoteView_Minimalist class]]) {
        TUIMergeReplyQuoteView_Minimalist *quoteView = (TUIMergeReplyQuoteView_Minimalist *)view;
        if (self.replyData.direction == MsgDirectionIncoming) {
            quoteView.titleLabel.textColor = quoteView.subTitleLabel.textColor =
                TUIChatDynamicColor(@"chat_reply_message_quoteView_recv_text_color", @"#888888");
        } else {
            quoteView.titleLabel.textColor = quoteView.subTitleLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_text_color", @"#888888");
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

    [self updateUI:self.replyData];

    [self layoutBottomContainer];
}

- (void)layoutBottomContainer {
    if (CGSizeEqualToSize(self.replyData.bottomContainerSize, CGSizeZero)) {
        return;
    }

    CGSize size = self.replyData.bottomContainerSize;
    [self.bottomContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.replyData.direction == MsgDirectionIncoming) {
            make.leading.mas_equalTo(self.container.mas_leading);
        } else {
            make.trailing.mas_equalTo(self.container.mas_trailing);
        }
        make.top.mas_equalTo(self.bubbleView.mas_bottom).mas_offset(self.messageData.messageContainerAppendSize.height + 6);
        make.size.mas_equalTo(size);
    }];

    if (!self.messageModifyRepliesButton.hidden) {
        CGRect oldRect = self.messageModifyRepliesButton.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.bottomContainer.frame), oldRect.size.width, oldRect.size.height);
        self.messageModifyRepliesButton.frame = newRect;
    }

    for (UIView *view in self.replyAvatarImageViews) {
        CGRect oldRect = view.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.bottomContainer.frame) + 5, oldRect.size.width, oldRect.size.height);
        view.frame = newRect;
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

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:16.0];
        _contentLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_content_text_color", @"#000000");
        _contentLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (NSMutableDictionary *)customOriginViewsCache {
    if (_customOriginViewsCache == nil) {
        _customOriginViewsCache = [[NSMutableDictionary alloc] init];
    }
    return _customOriginViewsCache;
}

#pragma mark - TUIMessageCellProtocol
+ (CGFloat)getHeight:(TUIMessageCellData *)data withWidth:(CGFloat)width {
    NSAssert([data isKindOfClass:TUIReplyMessageCellData.class], @"data must be kind of TUIReplyMessageCellData");
    TUIReplyMessageCellData *replyCellData = (TUIReplyMessageCellData *)data;
    
    CGFloat height = [super getHeight:replyCellData withWidth:width];

    if (replyCellData.bottomContainerSize.height > 0) {
        height += replyCellData.bottomContainerSize.height + 6;
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
    CGFloat quoteMaxWidth = kReplyQuoteViewMaxWidth;
    CGFloat quotePlaceHolderMarginWidth = 12;

    CGRect messageRevokeRect = CGRectZero;
    BOOL hasOriginMsgRevoke = (replyCellData.originCellData.innerMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED);

    
    // Calculate the size of label which displays the sender's displyname
    CGSize senderSize = [@"0" sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}];
    CGRect senderRect = [replyCellData.sender boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}
                                                  context:nil];

    if (hasOriginMsgRevoke) {
        NSString *msgRevokeStr = TIMCommonLocalizableString(TUIKitRepliesOriginMessageRevoke);
        messageRevokeRect = [msgRevokeStr boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}
                                                                   context:nil];
    }

    // Calculate the size of customize quote placeholder view
    CGSize placeholderSize = [replyCellData quotePlaceholderSizeWithType:replyCellData.originMsgType data:replyCellData.quoteData];

    // Calculate the size of label which displays the content of replying the original message
    UIFont *font = [UIFont systemFontOfSize:16.0];
    NSAttributedString *attributeString = [replyCellData.content getFormatEmojiStringWithFont:font emojiLocations:nil];
    CGRect replyContentRect = [attributeString boundingRectWithSize:CGSizeMake(quoteMaxWidth, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            context:nil];

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

    quoteHeight = 3 + senderRect.size.height + 4 + placeholderSize.height + 6;

    if (hasOriginMsgRevoke) {
        quoteWidth = MAX(quoteWidth, messageRevokeRect.size.width);
        quoteHeight = 3  + 4 + messageRevokeRect.size.height + 6;
    }
    
    replyCellData.senderSize = CGSizeMake(quoteWidth, senderRect.size.height);
    replyCellData.quotePlaceholderSize = placeholderSize;
    replyCellData.replyContentSize = CGSizeMake(replyContentRect.size.width, replyContentRect.size.height);
    replyCellData.quoteSize = CGSizeMake(quoteWidth, quoteHeight);

    // Calculate the height of cell
    height = 12 + quoteHeight + 12 + replyCellData.replyContentSize.height + 12;

    CGRect replyContentRect2 = [attributeString boundingRectWithSize:CGSizeMake(MAXFLOAT, [font lineHeight])
                                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                             context:nil];

    // Determine whether the width of the last line exceeds the position of the message status. If it exceeds, the message status will be wrapped.
    if ((int)replyContentRect2.size.width % (int)quoteWidth == 0 ||
        (int)replyContentRect2.size.width % (int)quoteWidth + replyCellData.msgStatusSize.width > quoteWidth) {
        height += replyCellData.msgStatusSize.height;
    }

    return CGSizeMake(quoteWidth + kReplyQuoteViewMarginWidth, height);
}

@end
