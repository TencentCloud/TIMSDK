//
//  TUIReplyMessageCell.m
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//

#import "TUIReplyMessageCell.h"
#import "TUIDarkModel.h"
#import "UIView+TUILayout.h"
#import "TUIReplyMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIFileMessageCellData.h"
#import "TUIVoiceMessageCellData.h"
#import "TUITextMessageCellData.h"
#import "TUIMergeMessageCellData.h"
#import "TUILinkCellData.h"
#import "NSString+emoji.h"
#import "TUIThemeManager.h"

#import "TUIReplyQuoteView.h"
#import "TUITextReplyQuoteView.h"
#import "TUIImageReplyQuoteView.h"
#import "TUIVideoReplyQuoteView.h"
#import "TUIVoiceReplyQuoteView.h"
#import "TUIFileReplyQuoteView.h"
#import "TUIMergeReplyQuoteView.h"

@interface TUIReplyMessageCell ()

@property (nonatomic, strong) TUIReplyQuoteView *currentOriginView;

@property (nonatomic, strong) NSMutableDictionary<NSString *, TUIReplyQuoteView *> *customOriginViewsCache;

@end

@implementation TUIReplyMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [self.quoteView addSubview:self.senderLabel];
    [self.quoteView.layer addSublayer:self.quoteBorderLayer];
    
    [self.bubbleView addSubview:self.quoteView];
    [self.bubbleView addSubview:self.contentLabel];
}

- (void)fillWithData:(TUIReplyMessageCellData *)data
{
    [super fillWithData:data];
    self.replyData = data;
    
    self.senderLabel.text = [NSString stringWithFormat:@"%@:", data.sender];
    if (data.direction == MsgDirectionIncoming) {
        self.contentLabel.textColor =
        TUIChatDynamicColor(@"chat_reply_message_content_recv_text_color", @"#000000");
        self.senderLabel.textColor =
        TUIChatDynamicColor(@"chat_reply_message_quoteView_recv_text_color", @"#888888");
        self.quoteView.backgroundColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_bg_color", @"#4444440c");
    } else {
        self.contentLabel.textColor =
        TUIChatDynamicColor(@"chat_reply_message_content_text_color", @"#000000");
        self.senderLabel.textColor =
        TUIChatDynamicColor(@"chat_reply_message_quoteView_text_color", @"#888888");
        self.quoteView.backgroundColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:0.05];
    }
    self.contentLabel.attributedText = [data.content getFormatEmojiStringWithFont:self.contentLabel.font emojiLocations:nil];
    
    @weakify(self)
    [[RACObserve(data, originMessage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(V2TIMMessage *originMessage) {
        @strongify(self)
        [self updateUI:data];
        [self layoutIfNeeded];
    }];
    
    [self layoutIfNeeded];
}

- (void)updateUI:(TUIReplyMessageCellData *)replyData
{
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

- (TUIReplyQuoteView *)getCustomOriginView:(TUIMessageCellData *)originCellData
{
    NSString *reuseId = originCellData?NSStringFromClass(originCellData.class):NSStringFromClass(TUITextMessageCellData.class);
    TUIReplyQuoteView *view = nil;
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
        TUITextReplyQuoteView* quoteView = [[TUITextReplyQuoteView alloc] init];
        view = quoteView;
    }
    
    if ([view isKindOfClass:[TUITextReplyQuoteView class]] ) {
        TUITextReplyQuoteView* quoteView = (TUITextReplyQuoteView*)view;
        if (self.replyData.direction == MsgDirectionIncoming) {
            quoteView.textLabel.textColor =
            TUIChatDynamicColor(@"chat_reply_message_quoteView_recv_text_color", @"#888888");
        }
        else {
            quoteView.textLabel.textColor =
            TUIChatDynamicColor(@"chat_reply_message_quoteView_text_color", @"#888888");
        }
    }
    else if ([view isKindOfClass:[TUIMergeReplyQuoteView class]]) {
        TUIMergeReplyQuoteView * quoteView = (TUIMergeReplyQuoteView *)view;
        if (self.replyData.direction == MsgDirectionIncoming) {
            quoteView.titleLabel.textColor =
            quoteView.subTitleLabel.textColor =
            TUIChatDynamicColor(@"chat_reply_message_quoteView_recv_text_color", @"#888888");
        }
        else {
            quoteView.titleLabel.textColor =
            quoteView.subTitleLabel.textColor =
            TUIChatDynamicColor(@"chat_reply_message_quoteView_text_color", @"#888888");
        }
    }
    
    if (!reuse) {
        [self.customOriginViewsCache setObject:view forKey:reuseId];
        [self.quoteView addSubview:view];
    }
    
    view.hidden = YES;
    return view;
}

- (void)hiddenAllCustomOriginViews:(BOOL)hidden
{
    [self.customOriginViewsCache enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TUIReplyQuoteView * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.hidden = hidden;
        [obj reset];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateUI:self.replyData];
}

- (UILabel *)senderLabel
{
    if (_senderLabel == nil) {
        _senderLabel = [[UILabel alloc] init];
        _senderLabel.text = @"harvy:";
        _senderLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _senderLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_sender_text_color", @"#888888");
    }
    return _senderLabel;
}

- (UIView *)quoteView
{
    if (_quoteView == nil) {
        _quoteView = [[UIView alloc] init];
        _quoteView.backgroundColor = TUIChatDynamicColor(@"chat_reply_message_quoteView_bg_color", @"#4444440c");
    }
    return _quoteView;
}

- (CALayer *)quoteBorderLayer
{
    if (_quoteBorderLayer == nil) {
        _quoteBorderLayer = [CALayer layer];
        _quoteBorderLayer.backgroundColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:0.1].CGColor;
    }
    return _quoteBorderLayer;
}

- (UILabel *)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:16.0];
        _contentLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_content_text_color", @"#000000");
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (NSMutableDictionary *)customOriginViewsCache
{
    if (_customOriginViewsCache == nil) {
        _customOriginViewsCache = [[NSMutableDictionary alloc] init];
    }
    return _customOriginViewsCache;
}

@end
