//
//  AudioEffectSettingViewModel.h
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TCMusicPlayStatusDelegate <NSObject>

- (void)onStartPlayMusic;
- (void)onStopPlayerMusic;
- (void)onCompletePlayMusic;
- (void)onPlayingWithCurrent:(NSInteger)currentSec total:(NSInteger)totalSec;

@end

@class TCAudioScrollMenuCellModel;
@class TCMusicSelectedModel;
@class TXAudioEffectManager;
@interface AudioEffectSettingViewModel : NSObject

@property (nonatomic, weak)id<TCMusicPlayStatusDelegate> delegate;

@property (nonatomic, strong) NSArray<TCAudioScrollMenuCellModel *> *voiceChangeSources;
@property (nonatomic, strong) NSArray<TCAudioScrollMenuCellModel *> *reverberationSources;

@property (nonatomic, strong) NSArray<TCMusicSelectedModel *> *musicSources;

- (NSInteger)getcurrentMusicTatolDurationInMs;

- (void)setAudioEffectManager:(TXAudioEffectManager *)manager;

- (void)setMusicVolum:(NSInteger)volum;

- (void)setVoiceVolum:(NSInteger)volum;

- (void)setPitchVolum:(CGFloat)volum;

/// 播放音乐
/// @param path 音乐路径
/// @param bgmID 音乐ID
- (void)playMusicWithPath:(NSString *)path bgmID:(NSInteger)bgmID;

- (void)stopPlay;

- (void)pausePlay;

- (void)resumePlay;

- (void)resetStatus;

- (void)recoveryVoiceSetting; // 恢复音效设置

@end

NS_ASSUME_NONNULL_END
