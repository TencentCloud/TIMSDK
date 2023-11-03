//
//  TUICallKitAudioPlayer.m
//  TUICalling
//
//  Created by gg on 2021/9/2.
//  Copyright © 2021 Tencent. All rights reserved
//

#import "TUICallKitAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "TUICallingCommon.h"
#import "TUICallKitHeader.h"

static const int32_t CALLKIT_AUDIO_DIAL_ID = 48;

NS_ASSUME_NONNULL_BEGIN

@interface TUICallKitAudioParam : NSObject

/// default is NO
@property (nonatomic, assign) BOOL loop;

@end

@interface TUICallKitAudioPlayer : NSObject <AVAudioPlayerDelegate>

+ (instancetype)sharedInstance;

- (BOOL)playAudio:(NSURL *)url;

- (BOOL)playAudio:(NSURL *)url params:(TUICallKitAudioParam * _Nullable)param;

- (void)stopAudio;

#pragma mark - Private

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) BOOL loop;
@property (nonatomic, strong, nullable) AVAudioPlayer *player;

@end

NS_ASSUME_NONNULL_END

BOOL playAudioWithFilePath(NSString *filePath) {
    TUICallKitAudioParam *param = [[TUICallKitAudioParam alloc] init];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if (!url) {
        return NO;
    }
    param.loop = YES;
    return [[TUICallKitAudioPlayer sharedInstance] playAudio:url params:param];
}

void playAudio(CallingAudioType type) {
    NSBundle *bundle = [TUICallingCommon callingBundle];
    TUICallKitAudioParam *param = [[TUICallKitAudioParam alloc] init];
    switch (type) {
        case CallingAudioTypeHangup: {
            NSString *path = [[[bundle bundlePath] stringByAppendingPathComponent:@"AudioFile"] stringByAppendingPathComponent:@"phone_hangup.mp3"];
            NSURL *url = [NSURL fileURLWithPath:path];
            if (url) {
                [[TUICallKitAudioPlayer sharedInstance] playAudio:url params:param];
            }
        } break;
        case CallingAudioTypeCalled: {
            NSString *path = [[[bundle bundlePath] stringByAppendingPathComponent:@"AudioFile"] stringByAppendingPathComponent:@"phone_ringing.mp3"];
            NSURL *url = [NSURL fileURLWithPath:path];
            if (url) {
                param.loop = YES;
                [[TUICallKitAudioPlayer sharedInstance] playAudio:url params:param];
            }
        } break;
        case CallingAudioTypeDial: {
            NSString *path = [[[bundle bundlePath] stringByAppendingPathComponent:@"AudioFile"] stringByAppendingPathComponent:@"phone_dialing.m4a"];
            TXAudioMusicParam *audioMusicParam = [[TXAudioMusicParam alloc] init];
            audioMusicParam.ID = CALLKIT_AUDIO_DIAL_ID;
            audioMusicParam.isShortFile = YES;
            audioMusicParam.path = path;
            TXAudioEffectManager *audioEffectManager = [[[TUICallEngine createInstance] getTRTCCloudInstance] getAudioEffectManager];
            [audioEffectManager setMusicPlayoutVolume:CALLKIT_AUDIO_DIAL_ID volume:100];
            [audioEffectManager startPlayMusic:audioMusicParam
                                       onStart:nil
                                    onProgress:nil
                                    onComplete:nil];
        } break;
        default:
            break;
    }
}

void stopAudio(void) {
    [[TUICallKitAudioPlayer sharedInstance] stopAudio];
    [[[[TUICallEngine createInstance] getTRTCCloudInstance] getAudioEffectManager] stopPlayMusic:CALLKIT_AUDIO_DIAL_ID];
}

@implementation TUICallKitAudioParam

- (instancetype)init {
    if (self = [super init]) {
        self.loop = NO;
    }
    return self;
}

@end

@implementation TUICallKitAudioPlayer

- (BOOL)playAudio:(NSURL *)url {
    return [self playAudio:url params:nil];
}

- (BOOL)playAudio:(NSURL *)url params:(TUICallKitAudioParam *)param {
    if (self.player != nil) {
        [self stopAudio];
    }
    [self setAudioSessionPlayback];
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        return NO;
    }
    
    if (![self.player prepareToPlay]) {
        return NO;
    }
    
    self.loop = (param != nil) ? param.loop : NO;
    self.player.delegate = self;
    self.player.numberOfLoops = self.loop ? -1 : 0;
    return [self.player play];
}

- (void)setAudioSessionPlayback {
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [audioSession setActive:YES error:&error];
}

- (void)stopAudio {
    if (self.player == nil) {
        return;
    }
    [self.player stop];
    self.loop = NO;
    self.player = nil;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    if (error) {
        [self stopAudio];
    }
}

#pragma mark - initialize

+ (instancetype)sharedInstance {
    static TUICallKitAudioPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end
