
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**

 *  This file declares the TUIVoiceMessageCell class, which is responsible for implementing the display of voice messages.
 *  Voice messages, i.e. message units displayed after voice is sent/received. TUIKit displays it as a message with a "sound wave" icon in a bubble by default.
 *  The voice message unit is also responsible for responding to the user's operation and playing the corresponding audio information when the user clicks.
 */
#import <TIMCommon/TUIBubbleMessageCell_Minimalist.h>
#import "TUIVoiceMessageCellData.h"
@import AVFoundation;

/**
 *
 * 【Module name】 TUIVoiceMessageCell_Minimalist
 * 【Function description】 Voice message unit
 *  - Voice messages, i.e. message units displayed after voice is sent/received. TUIKit displays it as a message with a "sound wave" icon in a bubble by
 * default.
 *  - The voice message unit provides the display and playback functions of voice messages.
 *  - The TUIVoiceMessageCellData in the voice message unit integrates and calls the voice download and acquisition of the IM SDK, and handles the related
 * business logic.
 *  - This class inherits from TUIBubbleMessageCell to implement bubble messages. You can implement custom bubbles by referring to this inheritance
 * relationship.
 */
@interface TUIVoiceMessageCell_Minimalist : TUIBubbleMessageCell_Minimalist

@property(nonatomic, strong) UIImageView *voicePlay;

/**
 *  Voice icon
 *  It is used to display the voice "sound wave" icon, and at the same time realize the animation effect of the voice when it is playing.
 */
@property(nonatomic, strong) NSMutableArray *voiceAnimations;

/**
 *  Label for displays video duration
 *  Used to display the duration of the speech outside the bubble, the default value is an integer and the unit is seconds.
 */
@property(nonatomic, strong) UILabel *duration;

@property(nonatomic, strong) UIImageView *voiceReadPoint;

@property TUIVoiceMessageCellData *voiceData;

- (void)fillWithData:(TUIVoiceMessageCellData *)data;

@end
