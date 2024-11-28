// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <AVKit/AVKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 BGM信息
 */
@interface TUIMultimediaBGM : NSObject <NSCopying>
@property(nonatomic) NSString *name;
@property(nullable, nonatomic) NSString *lyric;   // 歌词
@property(nullable, nonatomic) NSString *source;  // 音乐来源或歌手
@property(nonatomic) float startTime;
@property(nonatomic) float endTime;
@property(nullable, nonatomic) AVAsset *asset;

- (instancetype)initWithName:(NSString *)name lyric:(nullable NSString *)lyric source:(nullable NSString *)source asset:(nullable AVAsset *)asset;
@end

@interface TUIMultimediaBGMGroup : NSObject
@property(nonatomic) NSString *name;
@property(nonatomic) NSArray<TUIMultimediaBGM *> *bgmList;
- (instancetype)initWithName:(NSString *)name bgmList:(NSArray<TUIMultimediaBGM *> *)bgmList;
+ (NSArray<TUIMultimediaBGMGroup *> *)loadBGMConfigs;
@end

NS_ASSUME_NONNULL_END
