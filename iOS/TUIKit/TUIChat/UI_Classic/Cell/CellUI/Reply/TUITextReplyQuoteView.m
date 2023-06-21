//
//  TUITextReplyQuoteView.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITextReplyQuoteView.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TUICore/TUIThemeManager.h>
#import "TUITextReplyQuoteViewData.h"

@implementation TUITextReplyQuoteView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:10.0];
        _textLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_sender_text_color", @"888888");
        _textLabel.numberOfLines = 2;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = self.bounds;
}

- (void)fillWithData:(TUIReplyQuoteViewData *)data {
    [super fillWithData:data];
    if (![data isKindOfClass:TUITextReplyQuoteViewData.class]) {
        return;
    }
    TUITextReplyQuoteViewData *myData = (TUITextReplyQuoteViewData *)data;
    self.textLabel.attributedText = [myData.text getFormatEmojiStringWithFont:self.textLabel.font emojiLocations:nil];
}

- (void)reset {
    self.textLabel.text = @"";
}

@end
