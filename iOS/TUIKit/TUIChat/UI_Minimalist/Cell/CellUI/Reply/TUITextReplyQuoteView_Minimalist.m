//
//  TUITextReplyQuoteView.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUITextReplyQuoteView_Minimalist.h"
#import "TUITextReplyQuoteViewData_Minimalist.h"
#import "NSString+TUIEmoji.h"
#import "TUIThemeManager.h"

@implementation TUITextReplyQuoteView_Minimalist

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:10.0];
        _textLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_sender_text_color", @"888888");
        _textLabel.numberOfLines = 2;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = self.bounds;
}

- (void)fillWithData:(TUIReplyQuoteViewData_Minimalist *)data
{
    [super fillWithData:data];
    if (![data isKindOfClass:TUITextReplyQuoteViewData_Minimalist.class]) {
        return;
    }
    TUITextReplyQuoteViewData_Minimalist *myData = (TUITextReplyQuoteViewData_Minimalist *)data;
    self.textLabel.attributedText = [myData.text getFormatEmojiStringWithFont:self.textLabel.font emojiLocations:nil];
}

- (void)reset
{
    self.textLabel.text = @"";
}


@end
