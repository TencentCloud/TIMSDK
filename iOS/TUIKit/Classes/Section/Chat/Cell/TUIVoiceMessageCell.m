//
//  TUIVoiceMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIVoiceMessageCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"


@implementation TUIVoiceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _voice = [[UIImageView alloc] init];
        _voice.animationDuration = 1;
        [self.bubbleView addSubview:_voice];

        _duration = [[UILabel alloc] init];
        _duration.font = [UIFont systemFontOfSize:12];
        _duration.textColor = [UIColor grayColor];
        [self.bubbleView addSubview:_duration];

        _voiceReadPoint = [[UIImageView alloc] init];
        _voiceReadPoint.backgroundColor = [UIColor redColor];
        _voiceReadPoint.frame = CGRectMake(0, 0, 5, 5);
        _voiceReadPoint.hidden = YES;
        [_voiceReadPoint.layer setCornerRadius:_voiceReadPoint.frame.size.width/2];
        [_voiceReadPoint.layer setMasksToBounds:YES];
        [self.bubbleView addSubview:_voiceReadPoint];
    }
    return self;
}

- (void)fillWithData:(TUIVoiceMessageCellData *)data;
{
    //set data
    [super fillWithData:data];
    self.voiceData = data;
    if (data.duration > 0) {
        _duration.text = [NSString stringWithFormat:@"%ld\"", (long)data.duration];
    } else {
        _duration.text = @"1\"";    // 显示0秒容易产生误解
    }
    _voice.image = data.voiceImage;
    _voice.animationImages = data.voiceAnimationImages;
    
    //voiceReadPoint
    //此处0为语音消息未播放，1为语音消息已播放
    //发送出的消息，不展示红点
    if(self.voiceData.innerMessage.localCustomInt == 0 && self.voiceData.direction == MsgDirectionIncoming)
        self.voiceReadPoint.hidden = NO;

    //animate
    @weakify(self)
    [[RACObserve(data, isPlaying) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
        @strongify(self)
        if ([x boolValue]) {
            [self.voice startAnimating];
        } else {
            [self.voice stopAnimating];
        }
    }];
    if (data.direction == MsgDirectionIncoming) {
        _duration.textAlignment = NSTextAlignmentLeft;
    } else {
        _duration.textAlignment = NSTextAlignmentRight;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.duration.mm_sizeToFitThan(10,TVoiceMessageCell_Duration_Size.height).mm__centerY(self.bubbleView.mm_h/2 - 1);
    
    self.voice.mm_sizeToFit().mm_top(self.voiceData.voiceTop);
    
    if (self.voiceData.direction == MsgDirectionOutgoing) {
        self.bubbleView.mm_left(self.duration.mm_w).mm_flexToRight(0);
        self.duration.mm_left(-self.duration.mm_w);
        self.voice.mm_right(self.voiceData.cellLayout.bubbleInsets.right);
        self.voiceReadPoint.hidden = YES;
    } else {
        self.bubbleView.mm_left(0).mm_flexToRight(self.duration.mm_w);
        self.duration.mm_right(-self.duration.mm_w);
        self.voice.mm_left(self.voiceData.cellLayout.bubbleInsets.left);
        self.voiceReadPoint.mm_bottom(self.duration.mm_y + self.duration.mm_h).mm_left(self.duration.mm_x);
    }
}


@end

