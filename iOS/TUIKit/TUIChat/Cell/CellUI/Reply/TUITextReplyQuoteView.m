//
//  TUITextReplyQuoteView.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUITextReplyQuoteView.h"
#import "TUITextReplyQuoteViewData.h"
#import "NSString+emoji.h"

@implementation TUITextReplyQuoteView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:10.0];
        _textLabel.textColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1/1.0];
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

- (void)fillWithData:(TUIReplyQuoteViewData *)data
{
    [super fillWithData:data];
    if (![data isKindOfClass:TUITextReplyQuoteViewData.class]) {
        return;
    }
    TUITextReplyQuoteViewData *myData = (TUITextReplyQuoteViewData *)data;
    self.textLabel.attributedText = [myData.text getFormatEmojiStringWithFont:self.textLabel.font];
}

- (void)reset
{
    self.textLabel.text = @"";
}


@end
