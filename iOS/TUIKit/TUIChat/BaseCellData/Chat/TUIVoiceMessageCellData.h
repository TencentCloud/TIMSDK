
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TIMCommon/TUIBubbleMessageCellData.h>
#import <TIMCommon/TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TUIVoiceAudioPlaybackStyle) {
    TUIVoiceAudioPlaybackStyleLoudspeaker = 1,
    TUIVoiceAudioPlaybackStyleHandset = 2,
};

@interface TUIVoiceMessageCellData : TUIBubbleMessageCellData

@property(nonatomic, strong) NSString *path;
@property(nonatomic, strong) NSString *uuid;
@property(nonatomic, assign) int duration;
@property(nonatomic, assign) int length;
@property(nonatomic, assign) BOOL isDownloading;
@property(nonatomic, assign) BOOL isPlaying;
@property(nonatomic, assign) CGFloat voiceHeight;
@property(nonatomic, assign) NSTimeInterval currentTime;

/**
 *
 *  Play animation image
 *  An animation used to implement the "sonic image" fade of the speech as it plays.
 *  If you want to customize the implementation of other kinds of animation icons, you can refer to the implementation of voiceAnimationIamges here.
 */
@property NSArray<UIImage *> *voiceAnimationImages;

/**
 *
 *  voice icon
 *  Animated icon to show when the speech is not playing.
 */
@property UIImage *voiceImage;
@property(nonatomic, assign) CGFloat voiceTop;

/**
 *  
 *  Top margin of voice message
 *  This value is used to determine the position of the bubble, which is convenient for UI layout of the content in the bubble.
 *  If the value is abnormal or set arbitrarily, UI errors such as message position dislocation will occur.
 */
@property(nonatomic, class) CGFloat incommingVoiceTop;
@property(nonatomic, class) CGFloat outgoingVoiceTop;

- (void)stopVoiceMessage;

/**
 *  Begin to play voice. It will download the voice file from server if it not exists in local.
 */
- (void)playVoiceMessage;

@property(nonatomic, copy) void (^audioPlayerDidFinishPlayingBlock)(void);


//The style of audio playback.
+ (TUIVoiceAudioPlaybackStyle)getAudioplaybackStyle;
+ (void)changeAudioPlaybackStyle;
@end

NS_ASSUME_NONNULL_END
