
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
//
//  TUIAudioRecorder.h
//  TUIChat
//

#import <Foundation/Foundation.h>

/// TUIAudioRecorder is designed for recording audio when sending audio message.

NS_ASSUME_NONNULL_BEGIN

@class TUIAudioRecorder;
@protocol TUIAudioRecorderDelegate <NSObject>

- (void)audioRecorder:(TUIAudioRecorder *)recorder didCheckPermission:(BOOL)isGranted isFirstTime:(BOOL)isFirstTime;
/// Power value can be used to simulate the animation of mic changes when speaking.
- (void)audioRecorder:(TUIAudioRecorder *)recorder didPowerChanged:(float)power;
- (void)audioRecorder:(TUIAudioRecorder *)recorder didRecordTimeChanged:(NSTimeInterval)time;

@end

@interface TUIAudioRecorder : NSObject

@property(nonatomic, weak) id<TUIAudioRecorderDelegate> delegate;

@property(nonatomic, copy, readonly) NSString *recordedFilePath;

- (void)record;
- (void)stop;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
