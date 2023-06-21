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
#import "TUIFileMessageCellData_Minimalist.h"
#import "TUIImageMessageCellData_Minimalist.h"
#import "TUILinkCellData_Minimalist.h"
#import "TUIMergeMessageCellData_Minimalist.h"
#import "TUIReplyMessageCellData_Minimalist.h"
#import "TUITextMessageCellData_Minimalist.h"
#import "TUIVideoMessageCellData_Minimalist.h"
#import "TUIVoiceMessageCellData_Minimalist.h"

#import "TUIFileReplyQuoteView_Minimalist.h"
#import "TUIImageReplyQuoteView_Minimalist.h"
#import "TUIMergeReplyQuoteView_Minimalist.h"
#import "TUIReplyQuoteView_Minimalist.h"
#import "TUITextReplyQuoteView_Minimalist.h"
#import "TUIVideoReplyQuoteView_Minimalist.h"
#import "TUIVoiceReplyQuoteView_Minimalist.h"

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
    [self.quoteView.layer addSublayer:self.quoteBorderLayer];

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

- (void)fillWithData:(TUIReplyMessageCellData_Minimalist *)data {
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
      [self updateUI:data];
      [self layoutIfNeeded];
    }];

    [self layoutIfNeeded];
}

- (void)updateUI:(TUIReplyMessageCellData_Minimalist *)replyData {
    self.currentOriginView = [self getCustomOriginView:replyData.originCellData];
    [self hiddenAllCustomOriginViews:YES];
    self.currentOriginView.hidden = NO;

    [self.currentOriginView fillWithData:replyData.quoteData];

    self.quoteView.mm_x = 16;
    self.quoteView.mm_y = 12;
    self.quoteView.mm_w = self.replyData.quoteSize.width;
    self.quoteView.mm_h = self.replyData.quoteSize.height;

    self.quoteBorderLayer.frame = CGRectMake(0, 0, 3, self.quoteView.mm_h);

    self.contentLabel.mm_y = CGRectGetMaxY(self.quoteView.frame) + 12.0;
    self.contentLabel.mm_x = 18;
    self.contentLabel.mm_w = self.replyData.replyContentSize.width;
    self.contentLabel.mm_h = self.replyData.replyContentSize.height;

    self.senderLabel.mm_x = 6;
    self.senderLabel.mm_y = 3;
    self.senderLabel.mm_w = self.replyData.senderSize.width;
    self.senderLabel.mm_h = self.replyData.senderSize.height;

    self.currentOriginView.mm_y = CGRectGetMaxY(self.senderLabel.frame) + 4;
    self.currentOriginView.mm_x = self.senderLabel.mm_x;
    self.currentOriginView.mm_w = self.replyData.quotePlaceholderSize.width;
    self.currentOriginView.mm_h = self.replyData.quotePlaceholderSize.height;
}

- (TUIReplyQuoteView_Minimalist *)getCustomOriginView:(TUIMessageCellData *)originCellData {
    NSString *reuseId = originCellData ? NSStringFromClass(originCellData.class) : NSStringFromClass(TUITextMessageCellData_Minimalist.class);
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
    UIView *view = self.replyEmojiView.hidden ? self.bubbleView : self.replyEmojiView;
    CGFloat topMargin = view.mm_maxY + self.nameLabel.mm_h + 6;

    if (self.replyData.direction == MsgDirectionOutgoing) {
        self.bottomContainer.mm_top(topMargin).mm_width(size.width).mm_height(size.height).mm_right(self.mm_w - self.container.mm_maxX);
    } else {
        self.bottomContainer.mm_top(topMargin).mm_width(size.width).mm_height(size.height).mm_left(self.container.mm_minX);
    }

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

- (CALayer *)quoteBorderLayer {
    if (_quoteBorderLayer == nil) {
        _quoteBorderLayer = [CALayer layer];
        _quoteBorderLayer.backgroundColor = [UIColor colorWithRed:68 / 255.0 green:68 / 255.0 blue:68 / 255.0 alpha:0.1].CGColor;
    }
    return _quoteBorderLayer;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:16.0];
        _contentLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_content_text_color", @"#000000");
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

@end
