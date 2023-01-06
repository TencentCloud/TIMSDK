//
//  TUIVoiceReplyQuoteView_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIVoiceReplyQuoteView_Minimalist.h"
#import "TUIVoiceReplyQuoteViewData_Minimalist.h"
#import "TUIDarkModel.h"
#import "TUIDefine.h"
#import "NSString+TUIEmoji.h"

@implementation TUIVoiceReplyQuoteView_Minimalist

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

- (void)fillWithData:(TUIReplyQuoteViewData_Minimalist *)data
{
    [super fillWithData:data];
    if (![data isKindOfClass:TUIVoiceReplyQuoteViewData_Minimalist.class]) {
        return;
    }
    TUIVoiceReplyQuoteViewData_Minimalist *myData = (TUIVoiceReplyQuoteViewData_Minimalist *)data;
    self.iconView.image = myData.icon;
    self.textLabel.numberOfLines = 1;
}


@end
