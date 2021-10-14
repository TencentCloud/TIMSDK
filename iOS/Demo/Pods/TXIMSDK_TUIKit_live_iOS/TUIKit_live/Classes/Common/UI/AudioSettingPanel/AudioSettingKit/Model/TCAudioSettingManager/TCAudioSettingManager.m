//
//  TCAudioSettingManager.m
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/28.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TCAudioSettingManager.h"
#import "TXAudioEffectManager.h"

@interface TCAudioSettingManager (){
    uint32_t _bgmID; // 当前播放的bgmID
}

@property (nonatomic, strong)TXAudioEffectManager *manager;
@property (nonatomic, strong)NSString *currentMusicPath;

@end

@implementation TCAudioSettingManager

- (NSInteger)getcurrentMusicTatolDurationInMs{
    if (self.currentMusicPath == nil) {
        return 0;
    }
    return [self.manager getMusicDurationInMS:self.currentMusicPath];
}

- (void)setAudioEffectManager:(TXAudioEffectManager *)manager {
    self.manager = manager;
}

/// 设置变声效果
/// @param value 变声效果
- (void)setVoiceChangerTypeWithValue:(NSInteger)value {
    [self.manager setVoiceChangerType:value];
}

/// 设置混响效果
/// @param value 设置混响效果
- (void)setReverbTypeWithValue:(NSInteger)value {
    [self.manager setVoiceReverbType:value];
}

- (void)setBGMVolume:(NSInteger)volume {
    if (_bgmID != 0) {
        [self.manager setMusicPlayoutVolume:_bgmID volume:volume];
        [self.manager setMusicPublishVolume:_bgmID volume:volume];
    }
}

- (void)setVoiceVolume:(NSInteger)volume {
    [self.manager setVoiceVolume:volume];
}

- (void)setBGMPitch:(CGFloat)value {
    if (_bgmID != 0) {
        [self.manager setMusicPitch:_bgmID pitch:value];
    }
}

- (void)playMusicWithPath:(NSString *)path bgmID:(NSInteger)bgmID {
    if (_bgmID == bgmID) {
        [self resumePlay];
        return;
    } else {
        [self.manager stopPlayMusic:_bgmID];
        _bgmID = bgmID;
    }
    self.currentMusicPath = path;
    TXAudioMusicParam *params = [[TXAudioMusicParam alloc] init];
    params.ID   = _bgmID;
    params.path = path;
    params.loopCount == 0;
    __weak typeof(self) weakSelf = self;
    [self.manager startPlayMusic:params onStart:^(NSInteger errCode) {
        // 开始
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onStartPlayMusic)]) {
                [weakSelf.delegate onStartPlayMusic];
            }
        });
        
    } onProgress:^(NSInteger progressMs, NSInteger durationMs) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 进度
            if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(onPlayingWithCurrent:total:)]) {
                [weakSelf.delegate onPlayingWithCurrent:progressMs / 1000 total: durationMs / 1000];
            }
        });
    } onComplete:^(NSInteger errCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 播完了，清空bgmID
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf->_bgmID = 0;
            if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(onCompletePlayMusic)]) {
                [weakSelf.delegate onCompletePlayMusic];
            }
        });
    }];
}

- (void)stopPlay {
    if (_bgmID != 0) {
        [self.manager stopPlayMusic:_bgmID];
        _bgmID = 0;
        self.currentMusicPath = nil;
        if (self.delegate && [self.delegate respondsToSelector:@selector(onStartPlayMusic)]) {
            [self.delegate onStopPlayerMusic];
        }
    }
}

- (void)pausePlay {
    if (_bgmID != 0) {
        [self.manager pausePlayMusic:_bgmID];
    }
}

- (void)resumePlay {
    if (_bgmID != 0) {
        [self.manager resumePlayMusic:_bgmID];
    }
}

- (void)clearStates {
    self.currentMusicPath = nil;
    if (_bgmID != 0) {
        [self setBGMPitch:0];
        [self stopPlay];
        _bgmID = 0;
    }
    [self setVoiceVolume:100];
    [self setBGMVolume:100];
    self.manager = nil;
}

@end
