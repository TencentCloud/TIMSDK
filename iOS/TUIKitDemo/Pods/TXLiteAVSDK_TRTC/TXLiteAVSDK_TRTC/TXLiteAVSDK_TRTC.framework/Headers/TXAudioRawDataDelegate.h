//
//  TXAudioRawDataDelegate.h
//  TXLiteAVSDK
//
//  Created by realingzhou on 2018/2/24.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#ifndef TXAudioRawDataDelegate_h
#define TXAudioRawDataDelegate_h

@protocol TXAudioRawDataDelegate <NSObject>

/**
 * 音频播放信息回调
 *
 * @param sampleRate 采样率
 * @param channels 声道数
 */
@optional
- (void)onAudioInfoChanged:(int)sampleRate channels:(int)channels;

/**
 * 音频播放数据回调，数据格式 ：PCM
 *
 * <！！！注意！！！> 该函数内不要做耗时操作<！！！注意！！！>
 * 音频播放器会在播放数据的前一刻，调用此函数，同步回调将要播放的数据。因此在函数内部做耗时操作可能会影响播放
 *
 *
 * @param data         pcm数据
 * @param timestamp    时间戳。注 ：会有连续相同的时间戳回调出来，超过2048字节，时间戳才会变化。
 */
@optional
- (void)onPcmDataAvailable:(NSData *)data pts:(unsigned long long)timestamp;

@end

#endif /* TXAudioRawDataDelegate_h */
