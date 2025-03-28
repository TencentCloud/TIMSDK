// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 贴纸或字幕
 */
@interface TUIMultimediaSticker : NSObject
@property(nullable, nonatomic) UIImage *image;
@property(nonatomic) CGRect frame;
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
