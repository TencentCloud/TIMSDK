// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <Foundation/Foundation.h>
#import <TXLiteAVSDK_Professional/TXUGCRecord.h>
#import <TXLiteAVSDK_Professional/TXVideoEditer.h>
#import <TXLiteAVSDK_Professional/TXVideoEditerTypeDef.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaEncodeConfig : NSObject
@property(nonatomic) int fps;
@property(nonatomic) int bitrate;

- (instancetype)initWithVideoQuality:(int)videoQuality;
- (TXVideoCompressed)getVideoEditCompressed;
- (TXVideoResolution)getVideoRecordResolution;
@end

NS_ASSUME_NONNULL_END
