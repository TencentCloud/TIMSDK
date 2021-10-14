//
//  TXAudioCustomProcessDelegate.h
//  TXLiteAVSDK
//
//  Created by realingzhou on 2018/1/15.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#ifndef TXAudioCustomProcessDelegate_h
#define TXAudioCustomProcessDelegate_h
#import <Foundation/Foundation.h>

@protocol TXAudioCustomProcessDelegate <NSObject>

/**
 * 原始声音的回调
 * @param data pcm数据
 * @param timeStamp 时间戳
 * @param sampleRate 采样率
 * @param channels 声道数
 * @param withBgm 回调的数据是否包含bgm,当不开启回声消除时，回调的raw pcm会包含bgm
 */
@optional
- (void)onRecordRawPcmData:(NSData *)data timeStamp:(unsigned long long)timeStamp sampleRate:(int)sampleRate channels:(int)channels withBgm:(BOOL)withBgm;

/**
 * 经过特效处理的声音回调
 * @param data pcm数据
 * @param timeStamp 时间戳
 * @param sampleRate 采样率
 * @param channels 声道数
 */
@optional
- (void)onRecordPcmData:(NSData *)data timeStamp:(unsigned long long)timeStamp sampleRate:(int)sampleRate channels:(int)channels;

@end

#endif /* TXAudioCustomProcessDelegate_h */
