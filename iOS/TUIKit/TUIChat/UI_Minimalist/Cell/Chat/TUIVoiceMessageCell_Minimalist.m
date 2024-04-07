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
#import <TUICore/TUICore.h>

@interface TUIVoiceMessageCell_Minimalist ()

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
        _duration.rtlAlignment = TUITextRTLAlignmentTrailing;
        [self.bubbleView addSubview:_duration];

        _voiceReadPoint = [[UIImageView alloc] init];
        _voiceReadPoint.backgroundColor = [UIColor redColor];
        _voiceReadPoint.frame = CGRectMake(0, 0, 5, 5);
        _voiceReadPoint.hidden = YES;
        [_voiceReadPoint.layer setCornerRadius:_voiceReadPoint.frame.size.width / 2];
        [_voiceReadPoint.layer setMasksToBounds:YES];
        [self.bubbleView addSubview:_voiceReadPoint];
        
        self.bottomContainer = [[UIView alloc] init];
        [self.contentView addSubview:self.bottomContainer];

    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    for (UIView *view in self.bottomContainer.subviews) {
        [view removeFromSuperview];
    }
}

// Override
- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData {
    NSDictionary *param = @{TUICore_TUIChatExtension_BottomContainer_CellData : self.voiceData};
    [TUICore raiseExtension:TUICore_TUIChatExtension_BottomContainer_MinimalistExtensionID parentView:self.bottomContainer param:param];
}

- (void)fillWithData:(TUIVoiceMessageCellData *)data;
{
    // set data
    [super fillWithData:data];
    self.voiceData = data;

    if (data.duration > 0) {
        _duration.text = [NSString stringWithFormat:@"%d:%.2d", (int)data.duration / 60, (int)data.duration % 60];
    } else {
        _duration.text = @"0:01";
    }

    self.bottomContainer.hidden = CGSizeEqualToSize(data.bottomContainerSize, CGSizeZero);

    if (self.voiceData.innerMessage.localCustomInt == 0 && self.voiceData.direction == MsgDirectionIncoming) self.voiceReadPoint.hidden = NO;

    @weakify(self);
    [[RACObserve(data, isPlaying) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
      @strongify(self);
      if ([x boolValue]) {
          [self startAnimating];
      } else {
          [self stopAnimating];
          if (data.duration > 0) {
              self.duration.text = [NSString stringWithFormat:@"%d:%.2d", (int)data.duration / 60, (int)data.duration % 60];
          } else {
              self.duration.text = @"0:01";
          }
      }
    }];

    [[RACObserve(data, currentTime) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *time) {
        @strongify(self);
        if (!data.isPlaying) {
            return;
        }
        int min = (int)data.currentTime / 60;
        int sec = (int)data.currentTime % 60;
        NSString *forMatStr = [NSString stringWithFormat:@"%d:%.2d", min, sec];
        self.duration.text = [NSString stringWithFormat:@"%d:%.2d", (int)data.currentTime / 60, (int)data.currentTime % 60];
    }];

    
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

    [self.voicePlay mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
        make.leading.mas_equalTo(kScale390(16));
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(13);
    }];
    
    CGFloat animationStartX = kScale390(35);
    for (int i = 0; i < self.voiceAnimations.count; ++i) {
        UIImageView *animation = self.voiceAnimations[i];
        [animation mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bubbleView).mas_offset(animationStartX + kScale390(25) * i);
            make.top.mas_equalTo(self.bubbleView).mas_offset(self.voiceData.voiceTop);
            make.width.height.mas_equalTo(_voiceData.voiceHeight);
        }];
    }

    [self.duration mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_greaterThanOrEqualTo(kScale390(34));
        make.height.mas_greaterThanOrEqualTo(17);
        make.top.mas_equalTo(self.voiceData.voiceTop + 2);
        make.trailing.mas_equalTo(self.container).mas_offset(- kScale390(14));
    }];
    
    if (self.voiceData.direction == MsgDirectionOutgoing) {
        self.voiceReadPoint.hidden = YES;
    }
    else {
        [self.voiceReadPoint mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.top.mas_equalTo(self.bubbleView);
          make.leading.mas_equalTo(self.bubbleView.mas_trailing).mas_offset(1);
          make.size.mas_equalTo(CGSizeMake(5, 5));
        }];
    }
    [self layoutBottomContainer];

}
- (void)layoutBottomContainer {
    if (CGSizeEqualToSize(self.voiceData.bottomContainerSize, CGSizeZero)) {
        return;
    }

    CGSize size = self.voiceData.bottomContainerSize;
    
    [self.bottomContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.voiceData.direction == MsgDirectionIncoming) {
            make.leading.mas_equalTo(self.container.mas_leading);
        } else {
            make.trailing.mas_equalTo(self.container.mas_trailing);
        }
        make.top.mas_equalTo(self.container.mas_bottom).offset(6);
        make.size.mas_equalTo(size);
    }];

    CGFloat repliesBtnTextWidth = self.messageModifyRepliesButton.frame.size.width;
    if (!self.messageModifyRepliesButton.hidden) {
        UIImageView *lastAvatarImageView = self.replyAvatarImageViews.lastObject;
        [self.messageModifyRepliesButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.voiceData.direction == MsgDirectionIncoming) {
                make.leading.mas_equalTo(lastAvatarImageView.mas_trailing);
            } else {
              make.trailing.mas_equalTo(self.container.mas_trailing);
            }
            make.top.mas_equalTo(self.bottomContainer.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(repliesBtnTextWidth + 10, 30));
        }];
    }
}

- (void)startAnimating {
    _voicePlay.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"voice_pause")];
}

- (void)stopAnimating {
    _voicePlay.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"voice_play")];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - TUIMessageCellProtocol
+ (CGFloat)getHeight:(TUIMessageCellData *)data withWidth:(CGFloat)width {
    CGFloat height = [super getHeight:data withWidth:width];
    if (data.bottomContainerSize.height > 0) {
        height += data.bottomContainerSize.height + kScale375(6);
    }
    return height;
}
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUIVoiceMessageCellData.class], @"data must be kind of TUIVoiceMessageCellData");
    TUIVoiceMessageCellData *voiceCellData = (TUIVoiceMessageCellData *)data;
    
    return CGSizeMake((voiceCellData.voiceHeight + kScale390(5)) * 6 + kScale390(82),
                      voiceCellData.voiceHeight + voiceCellData.voiceTop * 3 + voiceCellData.msgStatusSize.height);
}

@end
