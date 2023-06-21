//
//  TUIVoiceMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVoiceMessageCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIVoiceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _voice = [[UIImageView alloc] init];
        _voice.animationDuration = 1;
        [self.bubbleView addSubview:_voice];

        _duration = [[UILabel alloc] init];
        _duration.font = [UIFont boldSystemFontOfSize:12];
        [self.bubbleView addSubview:_duration];

        _voiceReadPoint = [[UIImageView alloc] init];
        _voiceReadPoint.backgroundColor = [UIColor redColor];
        _voiceReadPoint.frame = CGRectMake(0, 0, 5, 5);
        _voiceReadPoint.hidden = YES;
        [_voiceReadPoint.layer setCornerRadius:_voiceReadPoint.frame.size.width / 2];
        [_voiceReadPoint.layer setMasksToBounds:YES];
        [self.bubbleView addSubview:_voiceReadPoint];
    }
    return self;
}

- (void)fillWithData:(TUIVoiceMessageCellData *)data;
{
    // set data
    [super fillWithData:data];
    self.voiceData = data;
    if (data.duration > 0) {
        _duration.text = [NSString stringWithFormat:@"%ld\"", (long)data.duration];
    } else {
        _duration.text = @"1\"";
    }
    _voice.image = data.voiceImage;
    _voice.animationImages = data.voiceAnimationImages;

    if (self.voiceData.innerMessage.localCustomInt == 0 && self.voiceData.direction == MsgDirectionIncoming) self.voiceReadPoint.hidden = NO;

    // animate
    @weakify(self);
    [[RACObserve(data, isPlaying) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
      @strongify(self);
      if ([x boolValue]) {
          [self.voice startAnimating];
      } else {
          [self.voice stopAnimating];
      }
    }];

    [self applyStyleFromDirection:data.direction];
}

- (void)applyStyleFromDirection:(TMsgDirection)direction {
    if (direction == MsgDirectionIncoming) {
        _duration.textAlignment = NSTextAlignmentLeft;
        _duration.textColor = TUIChatDynamicColor(@"chat_voice_message_recv_duration_time_color", @"#000000");
    } else {
        _duration.textAlignment = NSTextAlignmentRight;
        _duration.textColor = TUIChatDynamicColor(@"chat_voice_message_send_duration_time_color", @"#000000");
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];

    self.duration.mm_sizeToFitThan(10, TVoiceMessageCell_Duration_Size.height);

    self.voice.mm_sizeToFit().mm_top(self.voiceData.voiceTop);

    if (self.voiceData.direction == MsgDirectionOutgoing) {
        self.voice.mm_right(self.voiceData.cellLayout.bubbleInsets.right);
        self.duration.mm_left(self.voice.mm_x - self.duration.mm_w - 5);
        self.voiceReadPoint.hidden = YES;
    } else {
        self.voice.mm_left(self.voiceData.cellLayout.bubbleInsets.left);
        self.duration.mm_left(self.voice.mm_x + self.voice.mm_w + 5);
        self.voiceReadPoint.mm_top(0).mm_right(-self.voiceReadPoint.mm_w);
    }
    self.duration.mm_centerY = self.voice.mm_centerY;
}

@end
