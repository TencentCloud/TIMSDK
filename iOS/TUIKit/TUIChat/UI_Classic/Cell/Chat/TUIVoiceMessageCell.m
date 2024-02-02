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
#import <TUICore/TUICore.h>

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
        
        self.bottomContainer = [[UIView alloc] init];
        [self.contentView addSubview:self.bottomContainer];

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

- (void)prepareForReuse {
    [super prepareForReuse];
    for (UIView *view in self.bottomContainer.subviews) {
        [view removeFromSuperview];
    }
}

// Override
- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData {
    NSDictionary *param = @{TUICore_TUIChatExtension_BottomContainer_CellData : self.voiceData};
    [TUICore raiseExtension:TUICore_TUIChatExtension_BottomContainer_ClassicExtensionID parentView:self.bottomContainer param:param];
}

- (void)fillWithData:(TUIVoiceMessageCellData *)data {
    // set data
    [super fillWithData:data];
    self.voiceData = data;
    self.bottomContainer.hidden = CGSizeEqualToSize(data.bottomContainerSize, CGSizeZero);
    
    if (data.duration > 0) {
        _duration.text = [NSString stringWithFormat:@"%ld\"", (long)data.duration];
    } else {
        _duration.text = @"1\"";
    }
    _voice.image = data.voiceImage;
    _voice.animationImages = data.voiceAnimationImages;
    BOOL hasRiskContent = self.messageData.innerMessage.hasRiskContent;

    if (hasRiskContent) {
        self.securityStrikeView.textLabel.text = TIMCommonLocalizableString(TUIKitMessageTypeSecurityStrikeVoice);
    }
    
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
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}

- (void)applyStyleFromDirection:(TMsgDirection)direction {
    if (direction == MsgDirectionIncoming) {
        _duration.rtlAlignment = TUITextRTLAlignmentLeading;
        _duration.textColor = TUIChatDynamicColor(@"chat_voice_message_recv_duration_time_color", @"#000000");
    } else {
        _duration.rtlAlignment = TUITextRTLAlignmentTrailing;
        _duration.textColor = TUIChatDynamicColor(@"chat_voice_message_send_duration_time_color", @"#000000");
    }
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// This is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];

    [self.voice sizeToFit];
    [self.voice mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.voiceData.voiceTop);
        make.width.height.mas_equalTo(_voiceData.voiceHeight);
        if (self.voiceData.direction == MsgDirectionOutgoing) {
            make.trailing.mas_equalTo(-self.voiceData.cellLayout.bubbleInsets.right);
        } else {
            make.leading.mas_equalTo(self.voiceData.cellLayout.bubbleInsets.left);
        }
    }];
    
    [self.duration mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_greaterThanOrEqualTo(10);
        make.height.mas_greaterThanOrEqualTo(TVoiceMessageCell_Duration_Size.height);
        make.centerY.mas_equalTo(self.voice);
        if (self.voiceData.direction == MsgDirectionOutgoing) {
            make.trailing.mas_equalTo(self.voice.mas_leading).mas_offset(-5);
        } else {
            make.leading.mas_equalTo(self.voice.mas_trailing).mas_offset(5);
        }
    }];
    
    if (self.voiceData.direction == MsgDirectionOutgoing) {
        self.voiceReadPoint.hidden = YES;
    } else {
        [self.voiceReadPoint mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.top.mas_equalTo(self.bubbleView);
          make.leading.mas_equalTo(self.bubbleView.mas_trailing).mas_offset(1);
          make.size.mas_equalTo(CGSizeMake(5, 5));
        }];
    }
    BOOL hasRiskContent = self.messageData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        [self.securityStrikeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.voice.mas_bottom);
            make.width.mas_equalTo(self.bubbleView);
            make.bottom.mas_equalTo(self.container).mas_offset(- self.messageData.messageContainerAppendSize.height);
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
        [self.messageModifyRepliesButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.voiceData.direction == MsgDirectionIncoming) {
              make.leading.mas_equalTo(self.container.mas_leading);
            } else {
              make.trailing.mas_equalTo(self.container.mas_trailing);
            }
            make.top.mas_equalTo(self.bottomContainer.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(repliesBtnTextWidth + 10, 30));
        }];
    }
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
    TUIVoiceMessageCellData *voiceCellData = (TUIVoiceMessageCellData *)data;
    
    CGFloat bubbleWidth = TVoiceMessageCell_Back_Width_Min + voiceCellData.duration / TVoiceMessageCell_Max_Duration * Screen_Width;
    if (bubbleWidth > TVoiceMessageCell_Back_Width_Max) {
        bubbleWidth = TVoiceMessageCell_Back_Width_Max;
    }

    CGFloat bubbleHeight = TVoiceMessageCell_Duration_Size.height;
    if (voiceCellData.direction == MsgDirectionIncoming) {
        bubbleWidth = MAX(bubbleWidth, [TUIBubbleMessageCell incommingBubble].size.width);
        bubbleHeight = voiceCellData.voiceImage.size.height + 2 * voiceCellData.voiceTop;  //[TUIBubbleMessageCellData incommingBubble].size.height;
    } else {
        bubbleWidth = MAX(bubbleWidth, [TUIBubbleMessageCell outgoingBubble].size.width);
        bubbleHeight = voiceCellData.voiceImage.size.height + 2 * voiceCellData.voiceTop;  // [TUIBubbleMessageCellData outgoingBubble].size.height;
    }
    
    CGFloat width = bubbleWidth + TVoiceMessageCell_Duration_Size.width;
    CGFloat height = bubbleHeight;
    
    BOOL hasRiskContent = voiceCellData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        width = MAX(width, 200);// width must more than  TIMCommonLocalizableString(TUIKitMessageTypeSecurityStrikeVoice)
        height += kTUISecurityStrikeViewTopLineMargin;
        height += kTUISecurityStrikeViewTopLineToBottom;
    }

    return CGSizeMake(width, height);
}


@end
