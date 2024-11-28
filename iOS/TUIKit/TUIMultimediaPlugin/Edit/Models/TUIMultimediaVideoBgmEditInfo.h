// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <Foundation/Foundation.h>
#import "TUIMultimediaBGM.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaVideoBgmEditInfo : NSObject
@property(nonatomic) BOOL originAudio;
@property(nullable, nonatomic) TUIMultimediaBGM *bgm;
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
