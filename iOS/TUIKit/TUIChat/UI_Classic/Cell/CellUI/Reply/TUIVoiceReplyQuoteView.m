//
//  TUIVoiceReplyQuoteView.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIVoiceReplyQuoteView.h"
#import "NSString+emoji.h"
#import "TUIDarkModel.h"
#import "TUIDefine.h"
#import "TUIVoiceReplyQuoteViewData.h"

@implementation TUIVoiceReplyQuoteView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _iconView = [[UIImageView alloc] init];
        _iconView.image = TUIChatCommonBundleImage(@"message_voice_receiver_normal");
        [self addSubview:_iconView];
        
        self.textLabel.numberOfLines = 1;
        self.textLabel.font = [UIFont systemFontOfSize:10.0];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconView.frame = CGRectMake(0, 0, 15, 15);
    [self.textLabel sizeToFit];
    self.textLabel.mm_centerY = self.iconView.mm_centerY;
    self.textLabel.mm_x = CGRectGetMaxX(self.iconView.frame) + 3;
    self.textLabel.mm_w = self.mm_w - self.textLabel.mm_x;
}

- (void)fillWithData:(TUIReplyQuoteViewData *)data
{
    [super fillWithData:data];
    if (![data isKindOfClass:TUIVoiceReplyQuoteViewData.class]) {
        return;
    }
    TUIVoiceReplyQuoteViewData *myData = (TUIVoiceReplyQuoteViewData *)data;
    self.iconView.image = myData.icon;
    self.textLabel.numberOfLines = 1;
}


@end
