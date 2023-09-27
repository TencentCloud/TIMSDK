//
//  TUIVoiceReplyQuoteView.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVoiceReplyQuoteView.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIDarkModel.h>
#import "TUIVoiceReplyQuoteViewData.h"

@implementation TUIVoiceReplyQuoteView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _iconView = [[UIImageView alloc] init];
        _iconView.image = TUIChatCommonBundleImage(@"message_voice_receiver_normal");
        [self addSubview:_iconView];

        self.textLabel.numberOfLines = 1;
        self.textLabel.font = [UIFont systemFontOfSize:10.0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)fillWithData:(TUIReplyQuoteViewData *)data {
    [super fillWithData:data];
    if (![data isKindOfClass:TUIVoiceReplyQuoteViewData.class]) {
        return;
    }
    TUIVoiceReplyQuoteViewData *myData = (TUIVoiceReplyQuoteViewData *)data;
    self.iconView.image = myData.icon;
    self.textLabel.numberOfLines = 1;
    
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
    [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(15);
    }];
    
    [self.textLabel sizeToFit];
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconView.mas_trailing).mas_offset(3);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing);
        make.height.mas_equalTo(self.textLabel.font.lineHeight);
    }];
    

}


@end
