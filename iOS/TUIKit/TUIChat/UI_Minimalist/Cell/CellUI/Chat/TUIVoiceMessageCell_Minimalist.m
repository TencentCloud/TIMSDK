//
//  TUIVoiceMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVoiceMessageCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@interface TUIVoiceMessageCell_Minimalist ()
@property(nonatomic, assign) CGRect animationCoverFrame;
@end

@implementation TUIVoiceMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _voicePlay = [[UIImageView alloc] init];
        _voicePlay.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"voice_play")];
        [self.bubbleView addSubview:_voicePlay];

        self.voiceAnimations = [NSMutableArray array];
        for (int i = 0; i < 6; ++i) {
            UIImageView *animation = [[UIImageView alloc] init];
            animation.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"voice_play_animation")];
            [self.bubbleView addSubview:animation];
            [self.voiceAnimations addObject:animation];
        }

        _duration = [[UILabel alloc] init];
        _duration.font = [UIFont boldSystemFontOfSize:14];
        _duration.textAlignment = NSTextAlignmentRight;
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

- (void)fillWithData:(TUIVoiceMessageCellData_Minimalist *)data;
{
    // set data
    [super fillWithData:data];
    self.voiceData = data;

    if (data.duration > 0) {
        _duration.text = [NSString stringWithFormat:@"%d:%.2d", (int)data.duration / 60, (int)data.duration % 60];
    } else {
        _duration.text = @"0:00";
    }

    if (self.voiceData.innerMessage.localCustomInt == 0 && self.voiceData.direction == MsgDirectionIncoming) self.voiceReadPoint.hidden = NO;

    @weakify(self);
    [[RACObserve(data, isPlaying) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
      @strongify(self);
      if ([x boolValue]) {
          [self startAnimating];
      } else {
          [self stopAnimating];
          self.duration.text = [NSString stringWithFormat:@"%d:%.2d", (int)data.duration / 60, (int)data.duration % 60];
      }
    }];

    data.playTime = ^(CGFloat time) {
      @strongify(self);
      self.duration.text = [NSString stringWithFormat:@"%d:%.2d", (int)time / 60, (int)time % 60];
    };
}

- (void)startAnimating {
    _voicePlay.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"voice_pause")];
}

- (void)stopAnimating {
    _voicePlay.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"voice_play")];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _voicePlay.frame = CGRectMake(kScale390(16), 12, 11, 13);

    CGFloat animationWidth = 0;
    CGFloat animationStartX = kScale390(35);
    for (int i = 0; i < self.voiceAnimations.count; ++i) {
        UIImageView *animation = self.voiceAnimations[i];
        animation.frame = CGRectMake(animationStartX + kScale390(25) * i, self.voiceData.voiceTop, self.voiceData.voiceHeight, self.voiceData.voiceHeight);
        animationWidth = animation.mm_maxX - animationStartX;
    }
    _animationCoverFrame = CGRectMake(animationStartX, self.voiceData.voiceTop, animationWidth, self.voiceData.voiceHeight);

    _duration.mm_width(kScale390(34)).mm_height(17).mm_top(self.voiceData.voiceTop + 2).mm_flexToRight(kScale390(14));

    if (self.voiceData.direction == MsgDirectionOutgoing) {
        self.voiceReadPoint.hidden = YES;
    } else {
        self.voiceReadPoint.mm_top(0).mm_right(-self.voiceReadPoint.mm_w);
    }
}

@end
