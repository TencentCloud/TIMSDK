//
//  TUIVoiceMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVoiceMessageCellData.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
@import AVFoundation;

@interface TUIVoiceMessageCellData () <AVAudioPlayerDelegate>
@property AVAudioPlayer *audioPlayer;
@property NSString *wavPath;
@property(nonatomic, strong) NSTimer *timer;
@end

@implementation TUIVoiceMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    V2TIMSoundElem *elem = message.soundElem;
    TUIVoiceMessageCellData *soundData = [[TUIVoiceMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    soundData.duration = elem.duration;
    soundData.length = elem.dataSize;
    soundData.uuid = elem.uuid;
    soundData.reuseId = TVoiceMessageCell_ReuseId;
    soundData.path = elem.path;
    return soundData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return TIMCommonLocalizableString(TUIKitMessageTypeVoice);  // @"[Voice]";
}

- (Class)getReplyQuoteViewDataClass {
    return NSClassFromString(@"TUIVoiceReplyQuoteViewData");
}

- (Class)getReplyQuoteViewClass {
    return NSClassFromString(@"TUIVoiceReplyQuoteView");
}

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            self.cellLayout = [TUIMessageCellLayout incommingVoiceMessageLayout];
            _voiceImage = TUIChatDynamicImage(@"chat_voice_message_receiver_voice_normal_img",
                                              [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"message_voice_receiver_normal")]);
            _voiceImage = [_voiceImage rtl_imageFlippedForRightToLeftLayoutDirection];
            _voiceAnimationImages = [NSArray arrayWithObjects:[self.class formatImageByName:@"message_voice_receiver_playing_1"],
                                             [self.class formatImageByName:@"message_voice_receiver_playing_2"],
                                             [self.class formatImageByName:@"message_voice_receiver_playing_3"], nil];
            _voiceTop = [[self class] incommingVoiceTop];
        } else {
            self.cellLayout = [TUIMessageCellLayout outgoingVoiceMessageLayout];
            _voiceImage = TUIChatDynamicImage(@"chat_voice_message_sender_voice_normal_img",
                                              [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"message_voice_sender_normal")]);
            _voiceImage = [_voiceImage rtl_imageFlippedForRightToLeftLayoutDirection];
            _voiceAnimationImages = [NSArray arrayWithObjects:[self.class formatImageByName:@"message_voice_sender_playing_1"],
                                             [self.class formatImageByName:@"message_voice_sender_playing_2"],
                                             [self.class formatImageByName:@"message_voice_sender_playing_3"], nil];
            _voiceTop = [[self class] outgoingVoiceTop];
        }
        _voiceHeight = 21;
    }

    return self;
}

+ (UIImage *)formatImageByName:(NSString *)imgName {
    NSString *path = TUIChatImagePath(imgName);
    UIImage *img = [[TUIImageCache sharedInstance] getResourceFromCache:path];
    return [img rtl_imageFlippedForRightToLeftLayoutDirection];
}

- (NSString *)getVoicePath:(BOOL *)isExist {
    NSString *path = nil;
    BOOL isDir = false;
    *isExist = NO;
    if (self.direction == MsgDirectionOutgoing) {
        if (_path.length) {
            path = [NSString stringWithFormat:@"%@%@", TUIKit_Voice_Path, _path.lastPathComponent];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
                if (!isDir) {
                    *isExist = YES;
                }
            }
        }
    }

    if (!*isExist) {
        if (_uuid.length) {
            path = [NSString stringWithFormat:@"%@%@.amr", TUIKit_Voice_Path, _uuid];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
                if (!isDir) {
                    *isExist = YES;
                }
            }
        }
    }
    return path;
}

- (V2TIMSoundElem *)getIMSoundElem {
    V2TIMMessage *imMsg = self.innerMessage;
    if (imMsg.elemType == V2TIM_ELEM_TYPE_SOUND) {
        return imMsg.soundElem;
    }
    return nil;
}

- (void)playVoiceMessage {
    if (self.isPlaying) {
        [self stopVoiceMessage];
        return;
    }
    self.isPlaying = YES;

    if (self.innerMessage.localCustomInt == 0) self.innerMessage.localCustomInt = 1;

    V2TIMSoundElem *imSound = [self getIMSoundElem];
    BOOL isExist = NO;
    if (self.uuid.length == 0) {
        self.uuid = imSound.uuid;
    }
    NSString *path = [self getVoicePath:&isExist];
    if (isExist) {
        [self playInternal:path];
    } else {
        if (self.isDownloading) {
            return;
        }
        // 
        self.isDownloading = YES;
        @weakify(self);
        [imSound downloadSound:path
            progress:^(NSInteger curSize, NSInteger totalSize) {

            }
            succ:^{
              @strongify(self);
              self.isDownloading = NO;
              [self playInternal:path];
            }
            fail:^(int code, NSString *msg) {
              @strongify(self);
              self.isDownloading = NO;
              [self stopVoiceMessage];
            }];
    }
}

- (void)playInternal:(NSString *)path {
    if (!self.isPlaying) return;
    // play current
    TUIVoiceAudioPlaybackStyle playbackStyle = [self.class getAudioplaybackStyle];
    if(playbackStyle == TUIVoiceAudioPlaybackStyleHandset) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    NSURL *url = [NSURL fileURLWithPath:path];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.audioPlayer.delegate = self;
    bool result = [self.audioPlayer play];
    if (!result) {
        self.wavPath = [[path stringByDeletingPathExtension] stringByAppendingString:@".wav"];
        NSURL *url = [NSURL fileURLWithPath:self.wavPath];
        [self.audioPlayer stop];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer play];
    }
    
    @weakify(self);
    if (@available(iOS 10.0, *)) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                     repeats:YES
                                                       block:^(NSTimer *_Nonnull timer) {
                                                         @strongify(self);
                                                         [self updateProgress];
                                                       }];
    } else {
        // Fallback on earlier versions
    }
}
//The style of audio playback.
+ (TUIVoiceAudioPlaybackStyle)getAudioplaybackStyle {
    NSString *style = [NSUserDefaults.standardUserDefaults objectForKey:@"tui_audioPlaybackStyle"];
    if ([style isEqualToString:@"1"]) {
        return TUIVoiceAudioPlaybackStyleLoudspeaker;
    } else if ([style isEqualToString:@"2"]) {
        return TUIVoiceAudioPlaybackStyleHandset;
    }
    return TUIVoiceAudioPlaybackStyleLoudspeaker;
}

+ (void)changeAudioPlaybackStyle {
    TUIVoiceAudioPlaybackStyle style = [self getAudioplaybackStyle];
    if (style == TUIVoiceAudioPlaybackStyleLoudspeaker) {
        [NSUserDefaults.standardUserDefaults setObject:@"2" forKey:@"tui_audioPlaybackStyle"];
    }
    else {
        [NSUserDefaults.standardUserDefaults setObject:@"1" forKey:@"tui_audioPlaybackStyle"];
    }
    [NSUserDefaults.standardUserDefaults synchronize];
    
}
- (void)updateProgress {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
      @strongify(self);
        self.currentTime = self.audioPlayer.currentTime;
    });
}

- (void)stopVoiceMessage {
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.isPlaying = NO;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
{
    [self stopVoiceMessage];
    [[NSFileManager defaultManager] removeItemAtPath:self.wavPath error:nil];

    if (self.audioPlayerDidFinishPlayingBlock) {
        self.audioPlayerDidFinishPlayingBlock();
    }
}

static CGFloat gIncommingVoiceTop = 12;

+ (void)setIncommingVoiceTop:(CGFloat)incommingVoiceTop {
    gIncommingVoiceTop = incommingVoiceTop;
}

+ (CGFloat)incommingVoiceTop {
    return gIncommingVoiceTop;
}

static CGFloat gOutgoingVoiceTop = 12;

+ (void)setOutgoingVoiceTop:(CGFloat)outgoingVoiceTop {
    gOutgoingVoiceTop = outgoingVoiceTop;
}

+ (CGFloat)outgoingVoiceTop {
    return gOutgoingVoiceTop;
}

@end
