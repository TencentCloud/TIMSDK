//
//  TUIVoiceMessageCell.h
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIBubbleMessageCell.h"
#import "TUIVoiceMessageCellData.h"
@import AVFoundation;
@interface TUIVoiceMessageCell : TUIBubbleMessageCell
@property (nonatomic, strong) UIImageView *voice;
@property (nonatomic, strong) UILabel *duration;
@property TUIVoiceMessageCellData *voiceData;

- (void)fillWithData:(TUIVoiceMessageCellData *)data;

- (void)playVoiceMessage;
- (void)stopVoiceMessage;

@end
