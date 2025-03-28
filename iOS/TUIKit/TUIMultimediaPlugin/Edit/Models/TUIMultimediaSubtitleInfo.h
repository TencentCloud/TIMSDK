// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 字幕信息
 */
@interface TUIMultimediaSubtitleInfo : NSObject <NSCopying>
@property(nonatomic) NSString *text;
@property(nonatomic) UIColor *color;
@property(nonatomic) NSString *wrappedText;

- (instancetype)initWithText:(NSString *)text color:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
